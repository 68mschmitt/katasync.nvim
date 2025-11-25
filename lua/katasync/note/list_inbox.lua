local M = {}

local fs = require("katasync.core.fs")
local timestamp = require("katasync.core.timestamp")

-- Scan inbox directory for note files
local function scan_inbox_files(inbox_dir, file_ext, allow_non_md)
    if not fs.dir_exists(inbox_dir) then
        return {}
    end

    local files = {}
    local handle = vim.loop.fs_scandir(inbox_dir)
    if not handle then
        return files
    end

    while true do
        local name, type = vim.loop.fs_scandir_next(handle)
        if not name then
            break
        end

        -- Only include files (not directories)
        if type == "file" then
            -- Check file extension
            if allow_non_md or vim.endswith(name, file_ext) then
                table.insert(files, inbox_dir .. "/" .. name)
            end
        end
    end

    return files
end

-- Format relative time for display
local function format_relative_time(unix_timestamp)
    local now = os.time()
    local diff = now - unix_timestamp

    if diff < 60 then
        return "just now"
    elseif diff < 3600 then
        local minutes = math.floor(diff / 60)
        return string.format("%d minute%s ago", minutes, minutes > 1 and "s" or "")
    elseif diff < 86400 then
        local hours = math.floor(diff / 3600)
        return string.format("%d hour%s ago", hours, hours > 1 and "s" or "")
    elseif diff < 172800 then -- Less than 2 days
        return "yesterday"
    elseif diff < 604800 then -- Less than 7 days
        local days = math.floor(diff / 86400)
        return string.format("%d day%s ago", days, days > 1 and "s" or "")
    elseif diff < 1209600 then -- Less than 2 weeks
        return "1 week ago"
    elseif diff < 2592000 then -- Less than 30 days
        local weeks = math.floor(diff / 604800)
        return string.format("%d week%s ago", weeks, weeks > 1 and "s" or "")
    elseif diff < 5184000 then -- Less than 60 days
        return "1 month ago"
    else
        local months = math.floor(diff / 2592000)
        return string.format("%d month%s ago", months, months > 1 and "s" or "")
    end
end

-- Parse timestamp string to Unix timestamp
local function parse_timestamp(timestamp_str)
    if not timestamp_str then
        return nil
    end

    -- Parse format: YYYY-MM-DD_HH-MM-SS
    local year, month, day, hour, min, sec = timestamp_str:match("(%d%d%d%d)%-(%d%d)%-(%d%d)_(%d%d)%-(%d%d)%-(%d%d)")
    if not year then
        return nil
    end

    return os.time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = tonumber(hour),
        min = tonumber(min),
        sec = tonumber(sec),
    })
end

-- Extract note metadata from filepath
local function extract_note_metadata(filepath)
    local filename = vim.fn.fnamemodify(filepath, ":t")

    -- Extract timestamp from filename
    local timestamp_str = timestamp.extract_timestamp_from_filename(filename)
    local unix_timestamp = parse_timestamp(timestamp_str)

    -- Fallback to file modification time if no timestamp in filename
    if not unix_timestamp then
        local stat = vim.loop.fs_stat(filepath)
        if stat then
            unix_timestamp = stat.mtime.sec
        else
            unix_timestamp = os.time() -- Fallback to now
        end
    end

    local relative_time = format_relative_time(unix_timestamp)
    local display_text = string.format("[%s] %s", relative_time, filename)

    return {
        filepath = filepath,
        filename = filename,
        timestamp = unix_timestamp,
        relative_time = relative_time,
        display_text = display_text,
    }
end

-- Get all inbox notes with metadata
local function get_inbox_notes(inbox_dir, file_ext, allow_non_md)
    local filepaths = scan_inbox_files(inbox_dir, file_ext, allow_non_md)
    local notes = {}

    for _, filepath in ipairs(filepaths) do
        local metadata = extract_note_metadata(filepath)
        table.insert(notes, metadata)
    end

    return notes
end

-- Sort notes by timestamp
local function sort_notes(notes, sort_order)
    sort_order = sort_order or "newest"

    table.sort(notes, function(a, b)
        if sort_order == "newest" then
            return a.timestamp > b.timestamp
        elseif sort_order == "oldest" then
            return a.timestamp < b.timestamp
        else
            return a.timestamp > b.timestamp -- Default to newest
        end
    end)

    return notes
end

-- Handle note selection (open in buffer)
local function handle_note_selection(note)
    if not note or not note.filepath then
        vim.notify("Invalid note selection", vim.log.levels.ERROR)
        return
    end

    if not fs.file_exists(note.filepath) then
        vim.notify("Note file not found: " .. note.filename, vim.log.levels.ERROR)
        return
    end

    vim.cmd.edit(note.filepath)
end

-- Show picker with inbox notes
local function show_inbox_picker(notes)
    if #notes == 0 then
        vim.notify("Inbox is empty! Great work!", vim.log.levels.INFO)
        return
    end

    local items = {}
    for _, note in ipairs(notes) do
        table.insert(items, note.display_text)
    end

    vim.ui.select(items, {
        prompt = string.format("Inbox (%d note%s)", #notes, #notes == 1 and "" or "s"),
        format_item = function(item)
            return item
        end,
    }, function(choice, idx)
        if not choice then
            return
        end
        handle_note_selection(notes[idx])
    end)
end

-- Main entry point
function M.list_inbox(args)
    args = args or {}

    local config = require("katasync.config").get()
    local inbox_dir = config.inbox_dir

    -- Check inbox exists
    if not fs.dir_exists(inbox_dir) then
        vim.notify(
            string.format(
                "Inbox directory not found: %s\nCreate it with: mkdir -p %s",
                inbox_dir,
                inbox_dir
            ),
            vim.log.levels.ERROR
        )
        return
    end

    -- Get notes with error handling
    local success, notes = pcall(get_inbox_notes, inbox_dir, config.file_ext, config.allow_non_md)
    if not success then
        vim.notify(
            "Error loading inbox notes: " .. tostring(notes),
            vim.log.levels.ERROR
        )
        return
    end

    -- Sort notes
    local sort_order = args.sort or "newest"
    notes = sort_notes(notes, sort_order)

    -- Show picker
    show_inbox_picker(notes)
end

return M
