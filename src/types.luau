local syntax = require("@std/syntax")
export type tag_type = "CLASS" | "WITHIN" | "METHOD" | "PARAM" | "RETURN" | "PROP" | "DESCRIPTION"

export type tag = {
	type: tag_type,
	text: string,
	location: syntax.Span,
}

export type property = {
	declaration: syntax.Span,
	name: string,
	type: string,
	description: string,
}

export type method = {
	declaration: syntax.Span,
	name: string,
	returns: string,
	params: { string },
	description: string,
	accessor: ":" | ".",
}

export type class_declaration = {
	declaration: syntax.Span?,
	properties: { [string]: property },
	methods: { [string]: method },
	description: string,
}

export type document_block = {
	comments: { syntax.Trivia },
	declaration: syntax.AstNode?,
}

return nil
