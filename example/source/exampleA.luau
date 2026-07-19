---Class for doing stuff
---@class hello
---The ratio between a circle's circumference and its diameter.
---@prop PI number
local hello = {}
hello.PI = 3.1459

---prints the message given to the output box.
---@within hello
---@param message string
function hello:echo(message: string)
	print(message)
end

---returns the sum of 2 numbers.
---@within hello
---@param a number
---@param b number
---@return number
function hello:add(a: number, b: number): number
	return a + b
end
