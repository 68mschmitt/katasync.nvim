local M = {}

local time = require("katasync.core.time")
local filename = require("katasync.core.filename")
local fs = require("katasync.core.fs")
local notify = require("katasync.ui.notify")
local config = require("katasync.config")
local directory_picker = require("katasync.ui.directory_picker")
local input = require("katasync.ui.input")
local template_module = require("katasync.core.template")
local recent_picker = require("katasync.ui.recent_picker")
local recent = require("katasync.core.recent")

function M.create_with_params(dest_dir, template_key, label)
    local cfg = config.get()
    local timestamp = time.now_stamp()
    local new_filename = filename.build_sorted_filename(
        label,
        timestamp,
        cfg.file_ext,
        cfg.trailing_marker
    )
    local unique_filename = filename.ensure_unique(dest_dir, new_filename)
    local full_path = dest_dir .. "/" .. unique_filename

    local raw_template = cfg.templates[template_key] or ""
    local variables = template_module.get_template_variables(label, timestamp)
    local template_content = template_module.substitute_variables(raw_template, variables)

    if cfg.auto_save_new_note then
        fs.ensure_dir(dest_dir)
        local success = fs.write_file(full_path, template_content)

        if not success then
            notify.warn("Failed to create note: " .. full_path)
            return nil
        end
    end

    if cfg.open_after_create then
        vim.cmd.edit(full_path)

        if not cfg.auto_save_new_note and template_content ~= "" then
            local lines = vim.split(template_content, "\n")
            vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        end
    end

    if cfg.notify then
        local relative = full_path:gsub("^" .. vim.pesc(cfg.base_dir) .. "/", "")
        notify.info("Created → " .. relative)
    end

    recent.add_recent_entry(dest_dir, template_key, label)

    return full_path
end

function M.do_full_workflow()
    local cfg = config.get()

    directory_picker.show_directory_picker(
        cfg.base_dir,
        cfg.base_dir,
        cfg.exclude_dirs,
        function(dest_dir)
            input.prompt_for_label(function(label)
                input.prompt_for_template(
                    cfg.templates,
                    cfg.default_template,
                    function(template_key)
                        M.create_with_params(dest_dir, template_key, label)
                    end
                )
            end)
        end
    )
end

function M.create_note_at()
    local cfg = config.get()

    if not cfg.enable_recent_dirs then
        M.do_full_workflow()
        return
    end

    recent_picker.show_recent_picker(function(selection)
        if selection.use_recent then
            input.prompt_for_label(function(label)
                M.create_with_params(selection.dir, selection.template, label)
            end)
        else
            M.do_full_workflow()
        end
    end)
end

return M
