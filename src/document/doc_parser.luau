--!strict
local syntax = require("@std/syntax")
local pretty_print = require("../utility/prettyprint")

local interface = {}
local schema = {}
local meta = { __index = schema }

type tag_type = "CLASS" | "METHOD" | "WITHIN" | "DESCRIPTION"

type tag = {
	type: tag_type,
	text: string,
	trivia: syntax.Trivia,
}

type class_declaration = {
	declaration: syntax.Trivia,
	properties: { string },
}

export type doc_parser = setmetatable<{
	classes: { [string]: class_declaration },
	methods: {},

}, typeof(meta)>

interface.new = function(): doc_parser
	local parser = {}
	parser.classes = {}
	parser.methods = {}
	parser.properties = {}

	return setmetatable(parser, meta)
end

schema.consume = function(self: doc_parser, comments: { syntax.Trivia })

	local tags: { tag } = {}
	for i, v in comments do
		if v.tag == "comment" then table.insert(tags, self:process_comment(v)) end
	end

	pretty_print(tags :: { unknown })
end

schema.process_block_comment = function(self: doc_parser, comment: syntax.Trivia) end

schema.process_comment = function(self: doc_parser, comment: syntax.Trivia): tag
	local text = comment.text

	local is_tag = false
	local tag_pos = 0

	for i = 1, #text do
		local char = text:sub(i, i)
		if char == "-" then continue end
		if char:match("%s") then continue end

		if char ~= "@" then break end

		is_tag = true
		tag_pos = i
	end

	if is_tag == false then return {
		type = "DESCRIPTION",
		text = text:sub(4, #text),
		trivia = comment,
	} end

	local next_whitespace: number = text:find("%s", tag_pos) :: number

	local tag_type: tag_type = text:sub(tag_pos + 1, next_whitespace - 1):upper() :: tag_type

	return {
		type = tag_type,
		text = text:sub(next_whitespace + 1, #text),
		trivia = comment,
	}
end

return interface
