local M = {}

-- Cache the loaded env to avoid repeated file I/O
local cached_env = nil

function M.Load_env()
    -- Return cached version if already loaded
    if cached_env then
        return cached_env
    end

    local env = {}
    local env_file_path = vim.fn.stdpath("config") .. "/.env"
    local file = io.open(env_file_path, "r")
    if not file then
        vim.notify("Warning: .env file not found at " .. env_file_path, vim.log.levels.WARN)
        cached_env = env
        return env
    end

    for line in file:lines() do
        if line ~= "" and line:sub(1, 1) ~= "#" then
            local key, value = line:match("^(%S+)=(.+)$")
            if key and value then
                env[key] = value
            end
        end
    end
    file:close()

    -- Cache the result
    cached_env = env
    return env
end

return M
