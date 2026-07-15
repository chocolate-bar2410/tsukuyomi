local fs = require("@std/fs")
local process = require("@std/process")
local syntax = require("@std/syntax/")

local arguments = process.args

for i = 2, #arguments do
	print(arguments[i])
end
