--!strict
local syntax = require("@std/syntax")
local pretty_print = require("../utility/prettyprint")

local types = require("../types")

local interface = {}
local schema = {}
local meta = { __index = schema }

export type doc_parser = setmetatable<{
	classes: { [string]: types.class_declaration },

}, typeof(meta)>

interface.new = function(): doc_parser
	local parser = {}
	parser.classes = {}

	return setmetatable(parser, meta)
end

schema.consume = function(self: doc_parser, blocks: { types.document_block })
	local tags: { types.tag } = {}
	for i, v in blocks do
		local extracted = self:processDocumentBlock(v)

		table.move(extracted, 1, #extracted, #tags + 1, tags)
	end

	local sorted_tags: { types.tag } = {}

	local method_tags: { types.tag } = {}
	local other_tags: { types.tag } = {}

	for i, tag in ipairs(tags) do
		if tag.type == "WITHIN" then
			table.move(method_tags, 1, #method_tags, #sorted_tags + 1, sorted_tags)
			table.move(other_tags, 1, #other_tags, #sorted_tags + 1, sorted_tags)

			table.clear(method_tags)
			table.clear(other_tags)

			table.insert(sorted_tags, tag)

		elseif tag.type == "METHOD" then
			table.insert(method_tags, tag)
		else
			table.insert(other_tags, tag)
		end
	end

	table.move(method_tags, 1, #method_tags, #sorted_tags + 1, sorted_tags)
	table.move(other_tags, 1, #other_tags, #sorted_tags + 1, sorted_tags)

	for i, v in sorted_tags do
		print(`[{i}]: {v.type} {v.text}`)
	end
end

schema.processDocumentBlock = function(self: doc_parser, block: types.document_block): { types.tag }
	local tags = {}

	for i, comment in block.comments do
		local new_tag = self:processComment(comment)

		table.insert(tags, new_tag)
	end

	local declaration: syntax.AstStatFunction = block.declaration :: syntax.AstStatFunction
	if declaration.name then
		local name_expression = declaration.name

		if name_expression and name_expression.kind == "expr" and name_expression.tag == "indexname" then
			table.insert(tags, {
				type = "METHOD" :: types.tag_type,
				text = name_expression.index.text,
				location = declaration.func.functionKeyword.location,
			})
		end
	end

	return tags
end

schema.processComment = function(self: doc_parser, comment: syntax.Trivia): types.tag
	local text = comment.text

	local is_tag = text:match("@") ~= nil and text:sub(1, 3) == "---"
	local tag_pos: number = text:find("@") :: number

	if tag_pos ~= nil and text:sub(4, tag_pos - 1):match("%S+") ~= nil then is_tag = false end

	if is_tag == false then
		return {
			type = "DESCRIPTION",
			text = text:sub(4, #text),
			location = comment.location,
		}
	end

	local next_whitespace: number = text:find("%s", tag_pos) :: number

	local tag_type: types.tag_type = text:sub(tag_pos + 1, next_whitespace - 1):upper() :: types.tag_type

	return {
		type = tag_type,
		text = text:sub(next_whitespace + 1, #text),
		location = comment.location,
	}
end

return interface
