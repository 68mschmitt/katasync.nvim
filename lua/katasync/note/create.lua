local M = {}

local time = require("katasync.core.time")
local slug = require("katasync.core.slug")
local filename = require("katasync.core.filename")
local fs = require("katasync.core.fs")
local notify = require("katasync.ui.notify")
local config = require("katasync.config")

function M.create_blank_note(inbox_dir)
    fs.ensure_dir(inbox_dir)

    local timestamp = time.now_stamp()
    local note_slug = slug.slugify()
    local cfg = config.get()

    local base_filename = filename.build(timestamp, note_slug, cfg.file_ext)
    local unique_filename = filename.ensure_unique(inbox_dir, base_filename)

    local full_path = inbox_dir .. "/" .. unique_filename

    if cfg.auto_save_new_note then
        local success = fs.write_file(full_path, "")

        if not success then
            notify.warn("Failed to create note: " .. full_path)
            return nil
        end
    end

    if cfg.open_after_create then
        vim.cmd.edit(full_path)
    end

    if cfg.notify then
        notify.info("Created note: " .. full_path)
    end

    return full_path
end

return M

