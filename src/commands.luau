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

module.license = function()
	print([[MIT License

Copyright (c) 2026 chocolate_bar2410

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]])
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
