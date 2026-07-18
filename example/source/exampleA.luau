
--[=[
    @class hello
    Class for doing stuff
]=]
local hello = {}

-- wildcard

---@within hello
---@method dostuff
---This does stuff
function hello:dostuff()
	print("hello world")
end
