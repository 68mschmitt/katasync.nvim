local M = {}

local label_module = require("katasync.core.label")

function M.prompt_for_label(callback)
    vim.ui.input({ prompt = "Enter a descriptive name (optional, press Enter to skip): " }, function(input)
        if not input then
            return
        end

        if input == "" then
            callback(nil)
            return
        end

        local sanitized = label_module.sanitize_label(input)

        if not label_module.validate_label(sanitized) then
            vim.notify("Label invalid after sanitization. Try again or press Enter to skip.", vim.log.levels.WARN)
            M.prompt_for_label(callback)
            return
        end

        callback(sanitized)
    end)
end

function M.prompt_for_directory_name(callback)
    vim.ui.input({ prompt = "New directory name: " }, function(name)
        callback(name)
    end)
end

function M.confirm_cross_filesystem_move(callback)
    vim.ui.select({ "Yes", "No" }, {
        prompt = "This is a cross-filesystem move. Continue?"
    }, function(choice)
        if choice == "Yes" then
            callback(true)
        else
            callback(false)
        end
    end)
end

function M.prompt_for_template(templates, default_key, callback)
    local template_keys = {}

    for key, _ in pairs(templates) do
        table.insert(template_keys, key)
    end

    table.sort(template_keys)

    local default_idx = nil
    for i, key in ipairs(template_keys) do
        if key == default_key then
            default_idx = i
            break
        end
    end

    if default_idx and default_idx > 1 then
        table.remove(template_keys, default_idx)
        table.insert(template_keys, 1, default_key)
    end

    vim.ui.select(template_keys, {
        prompt = "Select template:",
        format_item = function(item)
            if item == default_key then
                return item .. " (default)"
            end
            return item
        end,
    }, function(choice)
        if not choice then
            return
        end
        callback(choice)
    end)
end

return M
