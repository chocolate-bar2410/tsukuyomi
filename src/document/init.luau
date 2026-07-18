--!strict
local syntax = require("@std/syntax")
local path = require("@std/path")
local fs = require("@std/fs")

local syntax_util = require("./utility/syntax")
local file_util = require("./utility/file")

local pretty_print = require("./utility./prettyprint")

local module = {}

module.from_directory = function(target_directory: path.Path): string
	local it = fs.walk(target_directory, { recursive = true })
	local walker = it()

	while walker ~= nil do
		if file_util.is_source(walker) == false then
			walker = it()
			continue
		end

		local CST = syntax_util.get_CST(walker)
		local DocComments = syntax_util.extract_doc_comments(CST)

		walker = it()
	end

	return ""
end

return module
