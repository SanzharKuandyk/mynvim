local M = {}
local uploading = false

local function notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO, { title = "Transfer list" })
end

function M.upload_trouble(view)
    if uploading then
        notify("A list upload is already running", vim.log.levels.WARN)
        return
    end

    local files, seen = {}, {}
    -- Section items are the active view's filtered items, including folded rows.
    for _, section in ipairs(view.sections) do
        for _, item in ipairs(section.items or {}) do
            local path = item.filename
            if path and path ~= "" then
                path = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
                local key = vim.fn.has("win32") == 1 and path:lower() or path
                if not seen[key] then
                    seen[key] = true
                    if vim.fn.filereadable(path) == 1 then
                        files[#files + 1] = path
                    end
                end
            end
        end
    end

    if #files == 0 then
        notify("No readable files in this Trouble list", vim.log.levels.WARN)
        return
    end

    -- Loading through lazy also initializes Transfer's configuration and commands.
    require("lazy").load({ plugins = { "transfer.nvim" } })
    local transfer = require("transfer.transfer")
    uploading = true
    notify(("Uploading %d files"):format(#files))

    -- Transfer has no quiet option. Hide its routine notices during the batch,
    -- while preserving errors and notifications from other plugins.
    local original_notify = vim.notify
    local function batch_notify(message, level, opts)
        local title = opts and opts.title
        if title == "Uploading file..." or title == "File uploaded" then
            return
        end
        return original_notify(message, level, opts)
    end
    vim.notify = batch_notify

    local function finish()
        uploading = false
        if vim.notify == batch_notify then
            vim.notify = original_notify
        end
        notify(("File uploading finished"))
    end

    local index = 0
    local function next_file()
        index = index + 1
        if index > #files then
            finish()
            return
        end
        local ok, err = pcall(transfer.upload_file, files[index], function()
            vim.schedule(next_file)
        end)
        if not ok then
            finish()
            notify("List upload stopped: " .. tostring(err), vim.log.levels.ERROR)
        end
    end
    next_file()
end

return M
