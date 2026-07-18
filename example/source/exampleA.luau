---Class for doing stuff
---@class hello
local hello = {}

-- wildcard

--- This does stuff
---@within hello
---@method dostuff
---@return number
function hello:dostuff()
	print("hello world")
end
