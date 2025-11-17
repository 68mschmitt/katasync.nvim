local M = {}

local time = require("katasync.core.time")

function M.extract_timestamp_from_filename(filename)
    local basename = vim.fn.fnamemodify(filename, ":t")

    local patterns = {
        "(%d%d%d%d%-%d%d%-%d%d_%d%d%-%d%d%-%d%d)",
        "^[^%-]*%-(%d%d%d%d%-%d%d%-%d%d_%d%d%-%d%d%-%d%d)",
    }

    for _, pattern in ipairs(patterns) do
        local timestamp = basename:match(pattern)
        if timestamp then
            return timestamp
        end
    end

    return nil
end

function M.get_file_mtime_as_timestamp(filepath, fmt)
    local stat = vim.loop.fs_stat(filepath)
    if not stat then
        return nil
    end

    return os.date(fmt, stat.mtime.sec)
end

function M.preserve_or_fallback_timestamp(filename, filepath, fmt)
    local timestamp = M.extract_timestamp_from_filename(filename)

    if timestamp then
        return timestamp
    end

    timestamp = M.get_file_mtime_as_timestamp(filepath, fmt)

    if timestamp then
        return timestamp
    end

    return time.now_stamp(fmt)
end

return M

