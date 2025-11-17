local M = {}

function M.setup(opts)
    require("katasync.config").setup(opts)
    require("katasync.commands").register()
end

function M.new_note()
    local cfg = require("katasync.config").get()
    return require("katasync.note.create").create_blank_note(cfg.inbox_dir)
end

function M.sort_note()
    return require("katasync.note.sort").sort_current_note()
end

function M.create_note_at()
    return require("katasync.note.create_at").create_note_at()
end

return M

