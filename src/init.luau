--!strict
local cli_util = require("@self/cli")
local commands = require("@self/commands")
cli_util.version = "v0.1.0"
cli_util.name = "tsukuyomi"

cli_util.define_command("build", "Generates markdown files from luau doc comments.", commands.build)
cli_util.define_command("license", "Displays the license info for tsukuyomi.", commands.license)

cli_util.define_option("--version", "Displays the version.", "-v", commands.version)
cli_util.define_option("--help", "Displays this usage message.", "-h", commands.help)

local args = cli_util.get_args()

if #args == 0 then
	cli_util.print_help()
	return
end

cli_util.parse_args(args)
