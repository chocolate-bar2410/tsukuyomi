--!strict

local function table_tostring(tab: { unknown }, depth: number)
	local result = "{\n"

	local indent = string.rep(" ", 4 * depth)

	for i, v in tab do
		if typeof(v) ~= "table" then

			local value = v
			if typeof(v) == "string" then value = ("%q"):format(v) end

			result ..= `{indent}[{i}] : {value}\n`
		else
			local inner = table_tostring(v :: { unknown }, depth + 1)

			result ..= `{indent}[{i}] : {inner}\n`
		end
	end

	return result .. string.rep(" ", 4 * (depth - 1)) .. "}"
end

return function(tab: { unknown })
	print(table_tostring(tab, 1))
end
