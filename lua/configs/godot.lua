vim.api.nvim_create_autocmd("FileType", {
    pattern = "gdscript",
    callback = function()
        vim.opt_local.expandtab = false
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.softtabstop = 4
        vim.opt_local.indentexpr = ""
    end,
})

local function get_godot_address()
    local env_utils = require("utils.env")
    local env = env_utils.Load_env() or {}
    return env["GODOT_ADDRESS"] or "127.0.0.1:55432"
end

local function is_address_in_use(address)
    local ip, port = address:match("(.+):(%d+)")
    local command = vim.fn.has("win32") == 1 and ("netstat -ano | findstr :" .. port)
        or ("ss -tuln | grep " .. ip .. ":" .. port)
    local result = vim.fn.system(command)
    return result ~= ""
end

local godot_connected = false

local function start_godot_connection(address)
    if godot_connected then
        return
    end
    local godot_project_file = vim.fn.getcwd() .. "/project.godot"
    local gdproject = io.open(godot_project_file, "r")
    if not gdproject then
        return
    end
    io.close(gdproject)
    local godot_address = address or get_godot_address()
    if is_address_in_use(godot_address) then
        print("Address " .. godot_address .. " is already in use. Aborting connection.")
        return
    end
    vim.fn.serverstart(godot_address)
    godot_connected = true
    print("Godot connection started at " .. godot_address)
end

local function stop_godot_connection()
    local godot_address = get_godot_address()
    vim.fn.serverstop(godot_address)
    for _, client in pairs(vim.lsp.get_clients({ name = "gdscript" })) do
        vim.lsp.stop_client(client.id)
    end
    godot_connected = false
    print("Godot connection and LSP stopped at " .. godot_address)
end

vim.api.nvim_create_user_command("StartGodotConnection", function(opts)
    local address = opts.args ~= "" and opts.args or nil
    start_godot_connection(address)
end, { nargs = "?" })

vim.api.nvim_create_user_command("StopGodotConnection", stop_godot_connection, {})

vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
    callback = function()
        if not godot_connected then
            start_godot_connection()
        end
    end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*.gd",
    callback = function()
        local clients = vim.lsp.get_clients({ name = "gdscript" })
        if
            #clients == 0
            or vim.tbl_contains(clients, function(c)
                return c.is_stopped()
            end, { predicate = true })
        then
            print("GDScript LSP not running or stopped, starting connection...")
            start_godot_connection()
        end
    end,
})

vim.api.nvim_create_autocmd("VimLeave", {
    callback = function()
        if godot_connected then
            stop_godot_connection()
        end
    end,
})
