local module = {}

---@within hello
function module:testing123()
	print("hi")
end

---@within hello
---@param x number
---@return result
function module:factorial(x)
	local result = 1
	for i = 1, x + 1 do
		result *= i
	end

	return result
end
