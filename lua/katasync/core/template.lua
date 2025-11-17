local M = {}

function M.substitute_variables(template, variables)
    local result = template

    for key, value in pairs(variables) do
        local pattern = "{{" .. key .. "}}"
        result = result:gsub(vim.pesc(pattern), value)
    end

    return result
end

function M.get_template_variables(label, timestamp)
    local title = label or "Note"
    local date = os.date("%Y-%m-%d")
    local datetime = os.date("%Y-%m-%d %H:%M:%S")

    return {
        title = title,
        date = date,
        datetime = datetime,
        timestamp = timestamp or os.date("%Y-%m-%d_%H-%M-%S"),
    }
end

function M.get_sort_template_variables(label, timestamp, content)
    local vars = M.get_template_variables(label, timestamp)
    vars.content = content or ""
    return vars
end

function M.apply_template_with_content(template, variables, original_content)
    local result = M.substitute_variables(template, variables)
    
    if not template:match("{{content}}") then
        if result ~= "" and original_content ~= "" then
            result = result .. "\n" .. original_content
        elseif original_content ~= "" then
            result = original_content
        end
    end
    
    return result
end

return M
