--!strict
local syntax = require("@std/syntax")

local types = require("../types")

local templates = require("./doc_templates")

local interface = {}
local schema = {}
local meta = { __index = schema }

export type doc_parser = setmetatable<{
	classes: { [string]: types.class_declaration },
	methods: { [string]: types.method },
}, typeof(meta)>

interface.new = function(): doc_parser
	local parser = {}
	parser.classes = {}
	parser.methods = {}

	return setmetatable(parser, meta)
end

schema.processTags = function(self: doc_parser, tags: { types.tag })
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

			current_class.declaration = tag.location
			current_class.description = description

			description = ""
		elseif tag.type == "METHOD" then
			if current_class ~= nil then
				current_class.methods[tag.text] = {
					name = tag.text,
					declaration = tag.location,
					params = {},
					returns = "()",
					description = description,
				}
				current_method = current_class.methods[tag.text]
			end

			description = ""

		elseif tag.type == "RETURN" then
			assert(current_method ~= nil, "error with parsing: ---@return can only be used with method declarations")

			current_method.returns = tag.text
		elseif tag.type == "PARAM" then
			assert(current_method ~= nil, "error with parsing: ---@param can only be used with method declarations")

			local param_content = tag.text:split(" ")
			table.insert(current_method.params, param_content[1] .. " : " .. (param_content[2] or "unknown"))
		elseif tag.type == "PROP" then
			assert(
				current_class ~= nil,
				"error with parsing: forgot to declare class when defining property, use ---@within <classname> to declare class"
			)

			local division: number = tag.text:find(" ") :: number

			if division == nil then
				current_class.properties[tag.text] = {
					declaration = tag.location,
					name = tag.text,
					type = "unknown",
					description = description,
				}
				description = ""
			end

			local type_start: number = tag.text:find("%S", division) :: number

			local prop_name = tag.text:sub(1, division - 1)
			local type_def = tag.text:sub(type_start, #tag.text)

			current_class.properties[prop_name] = {
				declaration = tag.location,
				name = prop_name,
				type = type_def,
				description = description,
			}

			description = ""

		end

	end
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

	self:processTags(sorted_tags)
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

schema.generate_markdown = function(self: doc_parser): { [string]: string }
	local result: { [string]: string } = {}

	for class_name, class in self.classes do
		local methods_string = ""
		for method_name, method in class.methods do
			local parameters = table.concat(method.params, ",\n")

			methods_string ..= templates.method_preset(
				method_name,
				class_name,
				parameters,
				method.returns,
				method.description
			)
		end

		local properties_string = ""
		for property_name, property in class.properties do
			properties_string ..= templates.property_preset(
				property_name,
				class_name,
				property.type,
				property.description
			)
		end

		local source = templates.class_preset(class_name, class.description, properties_string, methods_string)

		result[class_name] = source
	end

	return result
end

return interface
