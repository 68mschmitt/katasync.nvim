local M = {}

function M.now_stamp(fmt)
    fmt = fmt or "%Y-%m-%d_%H-%M-%S"
    return os.date(fmt)
end

return M

