local M = {}

local recent = require("katasync.core.recent")
local config = require("katasync.config")

function M.show_recent_picker(callback)
    local cfg = config.get()
    local recent_list = recent.get_recent_list()

    if #recent_list == 0 then
        callback({ use_recent = false })
        return
    end

    local items = {}
    local entries = {}

    for _, entry in ipairs(recent_list) do
        local display = recent.format_recent_display(entry, cfg.base_dir)
        table.insert(items, "→ " .. display)
        table.insert(entries, entry)
    end

    table.insert(items, "─────────────")
    table.insert(items, "📁 Browse directories...")

    vim.ui.select(items, {
        prompt = "Select destination:",
    }, function(choice, idx)
        if not choice then
            return
        end

        if choice == "📁 Browse directories..." then
            callback({ use_recent = false })
            return
        end

        if choice == "─────────────" then
            return
        end

        local entry = entries[idx]
        if entry then
            callback({
                use_recent = true,
                dir = entry.dir,
                template = entry.template,
                label = entry.label,
            })
        end
    end)
end

return M
