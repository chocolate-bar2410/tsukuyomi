--!strict
local fs = require("@std/fs")
local cli_util = require("./cli")
local file_util = require("./utility/file")
local document = require("./document")
local path = require("@std/path")

local module = {}

module.version = function()
	print(cli_util.name .. " " .. cli_util.version)
end

module.help = function()
	cli_util.print_help()
end

module.unimplemented = function()
	print("feature not implemented")
end

module.build = function(arguments: { string })
	assert(#arguments == 2, "wrong argument count, usage: build <target> <output>")
	local target_path = path.parse(arguments[1])
	local output_path = path.parse(arguments[2])

	local target_valid, target_err = file_util.validate_file_path(target_path)
	local output_valid, output_err = file_util.validate_file_path(output_path)

	assert(target_valid == true, target_err:format(target_path))
	assert(output_valid == true, output_err:format(output_path))

	assert(file_util.is_folder(output_path) == true, `expected folder got {fs.type(output_path)}`)
	assert(file_util.is_folder(target_path) == true, `expected folder got {fs.type(target_path)}`)

	local documents = document.from_directory(target_path)

	for i, v in documents do
		local new_file = fs.open(path.join(output_path, `{i}.md`), "w")
		fs.write(new_file, v)
	end
end

return module
