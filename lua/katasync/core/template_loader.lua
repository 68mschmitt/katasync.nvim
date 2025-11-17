local M = {}
local fs = require("katasync.core.fs")

--- Extract template key from filepath
--- @param filepath string The full path to the template file
--- @return string The template key (filename without extension)
local function extract_template_key(filepath)
    -- Get the filename from the full path
    local filename = vim.fn.fnamemodify(filepath, ":t")
    -- Remove the extension
    local key = vim.fn.fnamemodify(filename, ":r")
    return key
end

--- Read template file contents
--- @param filepath string The path to the template file
--- @return string|nil The file contents or nil on error
local function read_template_file(filepath)
    local file = io.open(filepath, "r")
    if not file then
        return nil
    end

    local content = file:read("*all")
    file:close()

    -- Basic validation that we got something
    if content == nil then
        return nil
    end

    return content
end

--- Validate file size (warn on large files)
--- @param filepath string The path to check
--- @return boolean True if size is acceptable
local function validate_file_size(filepath)
    local max_size = 1024 * 1024 -- 1MB limit
    local stat = vim.loop.fs_stat(filepath)

    if stat and stat.size > max_size then
        vim.notify(
            string.format("Template file is very large (%d KB): %s",
                math.floor(stat.size / 1024),
                filepath),
            vim.log.levels.WARN
        )
        return false
    end

    return true
end

--- Scan directory for template files
--- @param dir_path string The directory to scan
--- @return table List of template file paths
local function scan_template_files(dir_path)
    -- Use vim.fn.glob to find all .md files
    local pattern = dir_path .. "/*.md"
    local files_str = vim.fn.glob(pattern, false, false)

    -- glob returns a string with newline-separated paths, or empty string if none found
    if files_str == "" then
        return {}
    end

    -- Split by newlines to get individual paths
    local files = {}
    for file in files_str:gmatch("[^\n]+") do
        -- Validate that it's a markdown file (double-check extension)
        if file:match("%.md$") then
            table.insert(files, file)
        end
    end

    return files
end

--- Load templates from a directory
--- @param dir_path string The directory containing template files
--- @param should_warn boolean Whether to show warning if directory doesn't exist
--- @return table Table of template key-value pairs
function M.load_templates_from_dir(dir_path, should_warn)
    -- Return empty table if no directory path provided
    if not dir_path or dir_path == "" then
        return {}
    end

    -- Check if directory exists
    if not fs.dir_exists(dir_path) then
        -- Only warn if explicitly requested (user configured the directory or enabled create_templates_dir)
        if should_warn then
            vim.notify(
                string.format("Template directory not found: %s", dir_path),
                vim.log.levels.WARN
            )
        end
        return {}
    end

    local templates = {}
    local files = scan_template_files(dir_path)

    for _, filepath in ipairs(files) do
        -- Validate file size before reading
        if not validate_file_size(filepath) then
            -- Skip files that are too large
            goto continue
        end

        local key = extract_template_key(filepath)

        -- Check for duplicate keys (shouldn't happen with filesystem, but be safe)
        if templates[key] then
            vim.notify(
                string.format("Duplicate template key '%s' found in: %s", key, filepath),
                vim.log.levels.WARN
            )
            goto continue
        end

        local content = read_template_file(filepath)

        if content then
            templates[key] = content
        else
            vim.notify(
                string.format("Failed to read template: %s", filepath),
                vim.log.levels.WARN
            )
        end

        ::continue::
    end

    return templates
end

--- Merge config-based and file-based templates
--- Config templates take precedence over file templates
--- @param config_templates table Templates from configuration
--- @param file_templates table Templates from files
--- @return table Merged template table
function M.merge_templates(config_templates, file_templates)
    -- Start with file templates as base
    local merged = vim.tbl_extend("force", {}, file_templates)

    -- Override with config templates (config takes precedence)
    merged = vim.tbl_extend("force", merged, config_templates)

    -- Ensure "none" template always exists
    if not merged.none then
        merged.none = ""
    end

    return merged
end

--- Load all templates from both files and config
--- @param config table The plugin configuration
--- @param should_warn boolean Whether to warn if template directory doesn't exist
--- @return table Final merged template table
function M.load_all_templates(config, should_warn)
    local file_templates = {}

    -- Load file-based templates if templates_dir is configured
    if config.templates_dir and config.templates_dir ~= "" then
        file_templates = M.load_templates_from_dir(config.templates_dir, should_warn)
    end

    -- Get config-based templates
    local config_templates = config.templates or {}

    -- Merge with config taking precedence
    local merged = M.merge_templates(config_templates, file_templates)

    return merged
end

return M
