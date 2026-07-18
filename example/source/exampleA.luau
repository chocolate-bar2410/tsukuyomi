---Class for doing stuff
---@class hello
local hello = {}

---prints the message given to the output box.
---@within hello
---@method print
function hello:print(message: string)
	print(message)
end

---returns the sum of 2 numbers.
---@within hello
---@method add
function hello:add(a: number, b: number): number
	return a + b
end
