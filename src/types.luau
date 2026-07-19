local syntax = require("@std/syntax")
export type tag_type = "CLASS" | "WITHIN" | "METHOD" | "PARAM" | "RETURN" | "DESCRIPTION"

export type tag = {
	type: tag_type,
	text: string,
	trivia: syntax.Trivia,
}

export type property = {
	declaration: syntax.Trivia,
	name: string,
	type: string,
	description: string,
}

export type method = {
	declaration: syntax.Trivia,
	name: string,
	returns: string,
	params: { string },
	description: string,
}

export type class_declaration = {
	declaration: syntax.Trivia?,
	properties: { [string]: property },
	methods: { [string]: method },
	description: string,
}

export type document_block = {
	comments: { syntax.Trivia },
	declaration: syntax.AstNode?,
}

return nil
