--!strict
local ANSI = require("./ansi")
local process = require("@std/process")

local module = {}

local commands: { [string]: { description: string, [number]: string } } = {}
local options: { [string]: string } = {
	["--version"] = "Displays the version.",
	["--help"] = "Displays this usage message.",
	["-v"] = "Displays the version.",
	["-h"] = "Displays this usage message.",
}

module.version = ""
module.name = ""

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

	result ..= `{ANSI.TEXT_UNDERLINE}{ANSI.TEXT_BOLD}Options:{ANSI.TEXT_DEFAULT}\n\t`
	result ..= `{ANSI.TEXT_BOLD}-h, --help{ANSI.TEXT_DEFAULT}\tDisplays this usage message.\n\t`
	result ..= `{ANSI.TEXT_BOLD}-v, --version{ANSI.TEXT_DEFAULT}\tDisplays the version.\n`

	for i in options do
		if i == "-v" or i == "-h" or i == "--version" or i == "--help" then
			continue
		end

		result ..= `\t{ANSI.TEXT_BOLD}{i}{ANSI.TEXT_DEFAULT}\t{options[i]}\n`
	end

	print(result)
end

module.define_command = function(command_name: string, description: string, ...: string)
	if commands[command_name] then
		error(`internal error: already defined command {command_name}`)
	end

	commands[command_name] = { ["description"] = description, ... }
end

return module
