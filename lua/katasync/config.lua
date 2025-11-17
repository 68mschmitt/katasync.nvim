local M = {}

local default_config = {
    inbox_dir = "~/notes/inbox",
    base_dir = "~/notes",
    file_ext = ".md",
    timestamp_fmt = "%Y-%m-%d_%H-%M-%S",
    open_after_create = true,
    auto_save_new_note = false,
    notify = true,
    trailing_marker = "--note",
    exclude_dirs = { ".git", ".obsidian" },
    confirm_on_cross_fs = false,
    allow_non_md = true,
    templates_dir = nil, -- Will be derived from base_dir if nil
    create_templates_dir = false,
    templates = {
        none = "",
    },
    default_template = "none",
    enable_recent_dirs = true,
    max_recent_dirs = 5,
    recent_state_file = vim.fn.stdpath("state") .. "/katasync-mru.json",
}

local config = {}

function M.setup(opts)
    config = vim.tbl_deep_extend("force", default_config, opts or {})
    config.inbox_dir = vim.fn.expand(config.inbox_dir)
    config.base_dir = vim.fn.expand(config.base_dir)

    -- Track if templates_dir was explicitly set by user
    local templates_dir_explicit = opts and opts.templates_dir ~= nil

    -- Derive templates_dir if not provided
    if not config.templates_dir then
        config.templates_dir = config.base_dir .. "/templates"
    end

    -- Expand tilde and environment variables
    config.templates_dir = vim.fn.expand(config.templates_dir)

    -- Create directory if configured
    if config.create_templates_dir then
        local fs = require("katasync.core.fs")
        fs.ensure_dir(config.templates_dir)
    end

    -- Load and merge templates
    local template_loader = require("katasync.core.template_loader")
    config.templates = template_loader.load_all_templates(config, templates_dir_explicit or config.create_templates_dir)
end

function M.get()
    return config
end

return M
