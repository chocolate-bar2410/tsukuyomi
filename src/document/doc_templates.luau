--!strict
local templates = {}

templates.class_preset = function(title: string, description: string, properties_string: string, methods_string: string)
    local methods_substring = if #methods_string > 0 then `\n---\n\n\z
    ## methods \n\z
    {methods_string}` else "\n"

    local properties_substring = if #properties_string > 0 then `\n---\n\n\z
    ## properties \n\z
    {properties_string}` else "\n"

	return `\z
    ---\n\z
    icon: octicons/note-16\n\z
    ---\n\z
    <h1 class = "tsukuyomi-api-header" markdown> \n\z
        <span class="tsukuyomi-api-icon" markdown>:octicons-note-24:</span> \n\z
        <span class="tsukuyomi-api-name">{title}</span> \n\z
    </h1> \n\z
    {description} \n\z
    {properties_substring} \n\z
    {methods_substring} \n\z
    `
end

templates.method_preset = function(
	method_name: string,
	class_name: string,
	parameters: string,
	type_def: string,
	description: string,
    accessor: string
)   
    local param_def = if parameters ~= "" then `(\n\z
        \t{parameters}\n\z
    ): {type_def}\n\z` else `(): {type_def}\n`


	return `\z
    <h3 markdown>\n\z
    {method_name} \n\z
    <span class = "tsukuyomi-api-type"> -> () </span> \n\z 
    </h3>\n\z
    \`\`\`luau\n\z
    {class_name}{accessor}{method_name}{param_def}\z
    \`\`\`\n\z

    {description}  \n\z
`
end

templates.property_preset = function(
	property_name: string,
	class_name: string,
	type_def: string,
	description: string
)

	return `\z
    <h3> \n\z
    {property_name}\n\z
    <span class = "tsukuyomi-api-type"> : {type_def} </span> \n\z 
    </h3> \n\z
    {description} \n\z
`
end


return templates
