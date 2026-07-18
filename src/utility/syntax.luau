local fs = require("@std/fs")
local path = require("@std/path")
local syntax = require("@std/syntax")
local syntax_query = require("@std/syntax/query")

local tableext = require("@std/tableext")
local pretty_print = require("./prettyprint")

local module = {}

module.get_CST = function(_path: path.Path): syntax.ParseResult
	local source = fs.readFileToString(_path)

	local CST = syntax.parse(source)

	return CST
end

module.extract_doc_comments = function(CST: syntax.ParseResult): { syntax.Trivia }

	local query = syntax_query.findAllFromRoot(CST, function<T>(node: syntax.AstNode): T?

		if node.leadingTrivia == nil then return end
		if #node.leadingTrivia == 0 then return end

		return tableext.filter(node.leadingTrivia, function(_trivia: syntax.Trivia): boolean
			return _trivia.tag ~= "whitespace"
		end)
	end)

	local result = {}

	for _, triv_table in query.nodes do
		for _, _trivia: syntax.Trivia in triv_table do

			if _trivia.tag == "comment" and _trivia.text:sub(1, 3) ~= "---" then continue end

			if _trivia.tag == "blockcomment" and _trivia.text:match("^%-%-%[=%[(.-)%]=%]$") == nil then continue end

			table.insert(result, _trivia)
		end
	end

	return result
end

return module
