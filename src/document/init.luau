--!strict
local path = require("@std/path")
local fs = require("@std/fs")

local syntax_util = require("./utility/syntax")
local file_util = require("./utility/file")

local doc_parser = require("@self/doc_parser")

local module = {}

module.from_directory = function(target_directory: path.Path): { [string]: string }
	local it = fs.walk(target_directory, { recursive = true })
	local walker = it()

	local parse: doc_parser.doc_parser = doc_parser.new()

	while walker ~= nil do
		if file_util.is_source(walker) == false then
			walker = it()
			continue
		end

		local CST = syntax_util.get_CST(walker)
		local DocComments = syntax_util.extract_doc_comments(CST)

		parse:consume(DocComments)

		walker = it()
	end

	return parse:generate_markdown()
end

return module
