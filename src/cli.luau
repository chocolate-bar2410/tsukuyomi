--!strict
local ANSI = require("./ansi")
local process = require("@std/process")

local module = {}

type command = {
	description: string,
	callback: (arguments: { string }) -> (),
	[number]: string,
}

type option = {
	description: string,
	alias: string?,
	callback: (arguments: { string }) -> (),
}

local commands: { [string]: command } = {}
local options: { [string]: option } = {}

local error_string = `{ANSI.BRIGHT_RED}error:{ANSI.RESET} %s '{ANSI.BRIGHT_YELLOW}%s{ANSI.RESET}'`
local internal_error_string = `{ANSI.BRIGHT_RED}internal error:{ANSI.RESET} %s '{ANSI.BRIGHT_YELLOW}%s{ANSI.RESET}'`

module.version = ""
module.name = ""

local function from_alias(alias: string): string?
	for i, v in options do
		if v.alias == nil then continue end
		if v.alias == alias then return i end
	end

	return nil
end

local function isvalidoption(argument: string)
	if options[argument] then return true end

	return from_alias(argument) ~= nil
end

local function dispatch_command(command: string, arguments: { string })
	if commands[command].callback == nil then
		print(internal_error_string:format("could not find callback for command", command))
		return
	end

	commands[command].callback(arguments)
end

local function dispatch_option(command: string, arguments: { string })
	local option_string = if options[command] then command else from_alias(command)

	if option_string == nil or options[option_string] == nil then
		print(internal_error_string:format("could not find callback for command", command))
		return
	end

	options[option_string].callback(arguments)
end

module.parse_args = function(arguments: { string })
	local command: string = arguments[1]

	if commands[command] == nil and isvalidoption(command) == false then
		print(error_string:format("could not find command", command))
		module.print_help()
		return
	end

	if commands[command] then
		dispatch_command(command, table.move(arguments, 2, #arguments, 1, {}))
	else
		dispatch_option(command, table.move(arguments, 2, #arguments, 1, {}))
	end

end

module.get_args = function(): { string }
	local arguments: { string } = process.args

	return table.move(arguments, 2, #arguments, 1, {})
end

module.print_help = function()
	local result =
		`{ANSI.TEXT_UNDERLINE}{ANSI.TEXT_BOLD}Usage:{ANSI.TEXT_UNDERLINE_OFF} {module.name}{ANSI.TEXT_DEFAULT} <command>\n`

	result ..= `{ANSI.TEXT_UNDERLINE}{ANSI.TEXT_BOLD}Commands:{ANSI.TEXT_DEFAULT}\n`

	for i in commands do
		result ..= `\t{ANSI.TEXT_BOLD}{i}{ANSI.RESET}\t{commands[i]["description"]}\n`
	end

	result ..= `{ANSI.TEXT_UNDERLINE}{ANSI.TEXT_BOLD}Options:{ANSI.TEXT_DEFAULT}\n`

	for i, option in options do
		if option.alias then
			result ..= `\t{ANSI.TEXT_BOLD}{option.alias}, {i}{ANSI.TEXT_DEFAULT}\t{option.description}\n`
		else
			result ..= `\t    {ANSI.TEXT_BOLD}{i}{ANSI.TEXT_DEFAULT}\t{option.description}\n`
		end
	end

	print(result)
end

module.define_command = function(
	command_name: string,
	description: string,
	callback: (arguments: { string }) -> (),
	...: string
)
	if commands[command_name] then error(`internal error: already defined command {command_name}`) end

	commands[command_name] = {
		["description"] = description,
		["callback"] = callback,
		...,
	}
end

module.define_option = function(
	option_name: string,
	description: string,
	alias: string?,
	callback: (arguments: { string }) -> ()
)
	if options[option_name] then error(`internal error: already defined option {option_name}`) end

	options[option_name] = {
		["description"] = description,
		["alias"] = alias,
		["callback"] = callback,
	}
end

return module
