--!strict
local syntax = require("@std/syntax")
local pretty_print = require("../utility/prettyprint")

local types = require("./types")

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

schema.consume = function(self: doc_parser, comments: { syntax.Trivia })

	local tags: { types.tag } = {}
	for i, v in comments do
		if v.tag == "comment" then table.insert(tags, self:process_comment(v)) end
		--if v.tag == "blockcomment" then print("block comments not implemented yet") end
	end

	--pretty_print(tags :: { unknown })

	local description = ""

	local current_class: types.class_declaration? = nil
	local current_method: types.method? = nil

	for i, tag: types.tag in ipairs(tags) do
		if tag.type == "DESCRIPTION" then
			description ..= tag.text
		elseif tag.type == "WITHIN" then
			if self.classes[tag.text] == nil then
				self.classes[tag.text] = {
					declaration = nil,
					properties = {},
					methods = {},
					description = "",
				}
			end
			current_class = self.classes[tag.text]

		elseif tag.type == "CLASS" then
			if self.classes[tag.text] == nil then
				self.classes[tag.text] = {
					declaration = nil,
					properties = {},
					methods = {},
					description = "",
				}
			end

			current_class = self.classes[tag.text]

			current_class.declaration = tag.trivia
			current_class.description = description

			description = ""
		elseif tag.type == "METHOD" then
			assert(
				current_class ~= nil,
				"error with parsing: forgot to declare class when defining method, use ---@within <classname> to declare class"
			)

			current_class.methods[tag.text] = {
				name = tag.text,
				declaration = tag.trivia,
				params = {},
				returns = "",
				description = description,
			}

			description = ""

			current_method = current_class.methods[tag.text]
		end

	end

end

schema.process_block_comment = function(self: doc_parser, comment: syntax.Trivia)
	local text = comment.text:match("^%-%-%[=%[(.-)%]=%]$")

	print(text)
end

schema.process_comment = function(self: doc_parser, comment: syntax.Trivia): types.tag
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

	local tag_type: types.tag_type = text:sub(tag_pos + 1, next_whitespace - 1):upper() :: types.tag_type

	return {
		type = tag_type,
		text = text:sub(next_whitespace + 1, #text),
		trivia = comment,
	}
end

schema.generate_markdown = function(self: doc_parser): { [string]: string }
	local result: { [string]: string } = {}

	for name, class in self.classes do
		local source = ([[
---
title: %s
description: %s
---
        ]]):format(name, class.description)

		result[name] = source
	end

	return result
end

return interface
