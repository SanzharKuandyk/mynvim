local M = {}

function M.Load_env()
    local env = {}
    local env_file_path = vim.fn.stdpath("config") .. "/.env"
    local file = io.open(env_file_path, "r")
    if not file then
        print("Error: .env file not found at " .. env_file_path)
        return env
    end
    for line in file:lines() do
        if line ~= "" and line:sub(1, 1) ~= "#" then
            local key, value = line:match("^(%S+)=(.+)$") -- Changed to capture value with spaces
            if key and value then
                env[key] = value
            end
        end
    end
    file:close()
    return env
end

return M
