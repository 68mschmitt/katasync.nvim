local M = {}

local fs = require("katasync.core.fs")

function M.build(timestamp, slug, ext)
    return timestamp .. "--" .. slug .. ext
end

function M.build_sorted_filename(label, timestamp, ext, marker)
    if label and label ~= "" then
        return label .. "-" .. timestamp .. marker .. ext
    else
        return timestamp .. marker .. ext
    end
end

function M.parse_existing_filename(filename)
    local basename = vim.fn.fnamemodify(filename, ":t:r")

    local label, timestamp = basename:match("^(.-)%-(%d%d%d%d%-%d%d%-%d%d_%d%d%-%d%d%-%d%d)")

    if label and timestamp then
        return label, timestamp
    end

    timestamp = basename:match("(%d%d%d%d%-%d%d%-%d%d_%d%d%-%d%d%-%d%d)")

    return nil, timestamp
end

function M.rebuild_filename_with_new_label(old_filename, new_label, ext, marker)
    local _, timestamp = M.parse_existing_filename(old_filename)

    if timestamp then
        return M.build_sorted_filename(new_label, timestamp, ext, marker)
    end

    return nil
end

function M.extract_label_and_remainder(filename)
    local basename = vim.fn.fnamemodify(filename, ":t:r")

    -- Try to match label-timestamp pattern
    local label, timestamp = basename:match("^(.-)%-(%d%d%d%d%-%d%d%-%d%d_%d%d%-%d%d%-%d%d)")

    if label and timestamp then
        return label, timestamp
    end

    -- Try to match just timestamp pattern
    timestamp = basename:match("^(%d%d%d%d%-%d%d%-%d%d_%d%d%-%d%d%-%d%d)")

    if timestamp then
        return nil, timestamp
    end

    -- No timestamp found, return the whole basename as label
    return basename, nil
end

function M.build_sorted_filename_preserving_original(new_label, original_filename, timestamp, ext, marker)
    local original_label, _ = M.extract_label_and_remainder(original_filename)

    local combined_label
    if new_label and new_label ~= "" then
        if original_label and original_label ~= "" then
            combined_label = new_label .. "-" .. original_label
        else
            combined_label = new_label
        end
    else
        combined_label = original_label
    end

    return M.build_sorted_filename(combined_label, timestamp, ext, marker)
end

function M.ensure_unique(dir, filename)
    local path = dir .. "/" .. filename

    if not fs.file_exists(path) then
        return filename
    end

    local ext = filename:match("(%.[^%.]+)$") or ".md"
    local base = filename:gsub("%.[^%.]+$", "")
    local counter = 2

    while true do
        local new_filename = string.format("%s--%d%s", base, counter, ext)
        local new_path = dir .. "/" .. new_filename

        if not fs.file_exists(new_path) then
            return new_filename
        end

        counter = counter + 1
    end
end

return M

