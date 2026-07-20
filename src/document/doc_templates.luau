--!strict
local templates = {}

templates.class_preset = function(title: string, description: string, properties_string: string, methods_string: string)
	return `\z
    ---\n\z
    icon: octicons/note-16\n\z
    ---\n\z
    <h1 class = "tsukuyomi-api-header" markdown> \n\z
        <span class="tsukuyomi-api-icon" markdown>:octicons-note-24:</span> \n\z
        <span class="tsukuyomi-api-name">{title}</span> \n\z
    </h1> \n\z
    {description} \n\z
    ---\n\z
    ## properties \n\z
    {properties_string} \n\z
    ---\n\z
    ## methods \n\z
    {methods_string} \n\z
`
end

templates.method_preset = function(
	method_name: string,
	class_name: string,
	parameters: string,
	type_def: string,
	description: string
)
	return `\z
    <h3 markdown>\n\z
    {method_name} \n\z
    <span class = "tsukyyomi-api-type"> -> () </span> \n\z 
    </h3>\n\z
    \`\`\`luau\n\z
    {class_name}.{method_name}(\n\z
        \t{parameters:gsub("\n","\n\t")}\n\z
    ): {type_def}\n\z
    \`\`\`\n\z

    {description}  \n\z
`
end

templates.property_preset = function(
	method_name: string,
	class_name: string,
	type_def: string,
	description: string
)
	return `\z
    <h3> \n\z
    {method_name}\n\z
    <span class = "tsukyyomi-api-type"> : {type_def} </span> \n\z 
    </h3> \n\z
    {description} \n\z
`
end


return templates
