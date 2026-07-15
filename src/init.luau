--!strict
local cli_util = require("@self/cli")
cli_util.version = "v0.1.0"
cli_util.name = "tsukuyomi"

cli_util.define_command("setup", "Sets up a tsukuyomi config toml.")
cli_util.define_command("build", "Generates markdown files from luau doc comments.")
cli_util.define_command("help", "Displays this help message, or help with a command")

cli_util.define_option("--version", "Displays the version.", "-v")
cli_util.define_option("--help", "Displays this usage message.", "-h")

local args = cli_util.get_args()

if #args == 0 then
	cli_util.print_help()
	return
end

cli_util.parse_args(args)
