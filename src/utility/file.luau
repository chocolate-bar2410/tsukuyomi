--!strict
local path = require("@std/path")
local fs = require("@std/fs")

local module = {}

local valid_ext = {
	[".luau"] = true,
	[".lua"] = true,
}

module.is_folder = function(_path: path.Path): boolean
	return fs.type(_path) == "dir"
end

module.is_source = function(_path: path.Path): boolean
	return fs.type(_path) == "file" and valid_ext[path.extname(_path)] == true
end

module.validate_file_path = function(_path: path.Path): (boolean, string)
	if fs.exists(_path) == false then return false, "path %q does not exist" end
	local file_type = fs.type(_path)

	if file_type == "dir" then return true, "" end
	if file_type ~= "file" then return false, `path %q is a {file_type} not a file ` end

	local extension = path.extname(_path)

	if valid_ext[extension] == nil then return false, `file @ path %q is not a .luau or .lua file` end

	return true, ""
end

return module
