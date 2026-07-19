local fs = require("@std/fs")
local path = require("@std/path")
local syntax = require("@std/syntax")
local syntax_query = require("@std/syntax/query")
local types = require("../types")

local tableext = require("@std/tableext")
local pretty_print = require("./prettyprint")

local module = {}

local get_doc_comments = function(token: syntax.Token): {}
	local comments = {}
	if token == nil or token.leadingTrivia == nil then return {} end

	for i, _trivia in token.leadingTrivia do
		if _trivia.tag == "whitespace" then continue end
		if _trivia.tag == "comment" and _trivia.text:sub(1, 3) ~= "---" then continue end

		if _trivia.tag == "blockcomment" and _trivia.text:match("^%-%-%[=%[(.-)%]=%]$") == nil then continue end

		table.insert(comments, _trivia)
	end

	return comments
end

module.get_CST = function(_path: path.Path): syntax.ParseResult
	local source = fs.readFileToString(_path)

	local CST = syntax.parse(source)

	return CST
end

module.extract_doc_comments = function(CST: syntax.ParseResult): { types.document_block }

	--[[local new_file = fs.open(path.join(`./testing.json`), "w")
	fs.write(new_file, pretty_print(CST.root))]]
	local processed = {}

	local result = syntax_query.findAllFromRoot(CST, function<T>(node: syntax.AstNode): T?
		if processed[node] == true then return end
		if node.kind == "stat" and node.tag == "function" then
			local name_expr = node.name
			local method_name = ""
			if name_expr and name_expr.tag == "indexname" then method_name = name_expr.index.text end

			local comments = get_doc_comments(node.func.functionKeyword)
			if method_name == nil or #comments == 0 then return end
			processed[node.func.functionKeyword] = true

			return { comments = comments, declaration = node }
		end

		local comments = get_doc_comments(node)
		if #comments == 0 then return end

		return { comments = get_doc_comments(node), declaration = node }
	end).nodes

	return result
end

return module
