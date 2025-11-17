local M = {}

function M.register()
    vim.api.nvim_create_user_command("NewNote", function()
        local cfg = require("katasync.config").get()
        require("katasync.note.create").create_blank_note(cfg.inbox_dir)
    end, { desc = "Create blank note in inbox" })

    vim.api.nvim_create_user_command("SortNote", function()
        require("katasync.note.sort").sort_current_note()
    end, { desc = "Sort/move current note with required rename" })

    vim.api.nvim_create_user_command("CreateNote", function()
        require("katasync.note.create_at").create_note_at()
    end, { desc = "Create note in chosen location with optional label" })

    vim.api.nvim_create_user_command("ListInbox", function(opts)
        local args = {}

        if opts.args and opts.args ~= "" then
            -- Parse arguments
            local parts = vim.split(opts.args, " ")
            args.sort = parts[1]
        end

        require("katasync.note.list_inbox").list_inbox(args)
    end, {
        nargs = "*",
        desc = "Display list of inbox notes for sorting",
        complete = function()
            return { "newest", "oldest" }
        end,
    })
end

return M

