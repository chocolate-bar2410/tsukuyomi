--!strict
local ANSI = require("./ansi")
local process = require("@std/process")

local module = {}

local commands: { [string]: { description: string, [number]: string } } = {}
local options: { [string]: { description: string, alias: string? } } = {}

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

module.parse_args = function(arguments: { string })
	local command = arguments[1]

	if commands[command] == nil and isvalidoption(command) == false then
		print(
			`{ANSI.BRIGHT_RED}error:{ANSI.RESET} could not recognise command '{ANSI.BRIGHT_YELLOW}{command}{ANSI.RESET}'`
		)
		module.print_help()
		return
	end

	if commands[command] then
		print(command)
		return
	end

	if options[command] == nil then command = from_alias(command) end

	print(command)

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

module.define_command = function(command_name: string, description: string, ...: string)
	if commands[command_name] then error(`internal error: already defined command {command_name}`) end

	commands[command_name] = { ["description"] = description, ... }
end

module.define_option = function(option_name: string, description: string, alias: string?)
	if options[option_name] then error(`internal error: already defined option {option_name}`) end

	options[option_name] = {
		["description"] = description,
		["alias"] = alias,
	}
end

return module
