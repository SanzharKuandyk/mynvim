local GODOT_LSP_HOST = "127.0.0.1"
local GODOT_LSP_PORT = 6005

local godot_state = {
    server_started_by_this_nvim = false,
    server_address = nil,
    probe_pending = false,
}

local function godot_debug_enabled()
    return vim.g.godot_debug == true
end

local function godot_log(msg, level, notify)
    if notify or godot_debug_enabled() then
        vim.notify(msg, level or vim.log.levels.INFO)
    end
end

local function godot_project_root(bufnr)
    return vim.fs.root(bufnr, { "project.godot" })
end

local function cwd_is_godot_project()
    return vim.fn.filereadable(vim.fn.getcwd() .. "/project.godot") == 1
end

local function has_gdscript_client(bufnr)
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "gdscript" })) do
        if client and not client:is_stopped() then
            return true
        end
    end
    return false
end

local function gdscript_capabilities()
    local ok, blink = pcall(require, "blink.cmp")
    if ok and blink.get_lsp_capabilities then
        return blink.get_lsp_capabilities()
    end
end

local function is_port_open(host, port, timeout_ms)
    local tcp = vim.uv.new_tcp()
    if not tcp then
        return false
    end

    local done = false
    local ok = false
    tcp:connect(host, port, function(err)
        ok = not err
        done = true
    end)

    vim.wait(timeout_ms or 120, function()
        return done
    end, 10)

    pcall(tcp.close, tcp)
    return ok
end

local function ensure_gdscript_lsp(bufnr, opts)
    opts = opts or {}
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return false
    end

    local ft = vim.bo[bufnr].filetype
    if ft ~= "gd" and ft ~= "gdscript" and ft ~= "gdscript3" then
        return false
    end

    local root = godot_project_root(bufnr)
    if not root then
        return false
    end

    if has_gdscript_client(bufnr) then
        return true
    end

    if not is_port_open(GODOT_LSP_HOST, GODOT_LSP_PORT) then
        return false
    end

    vim.lsp.start({
        name = "gdscript",
        cmd = vim.lsp.rpc.connect(GODOT_LSP_HOST, GODOT_LSP_PORT),
        root_dir = root,
        filetypes = { "gd", "gdscript", "gdscript3" },
        capabilities = gdscript_capabilities(),
    }, { bufnr = bufnr })

    godot_log("Connected gdscript LSP at " .. GODOT_LSP_HOST .. ":" .. GODOT_LSP_PORT, vim.log.levels.INFO, opts.notify)
    return true
end

local function get_godot_address()
    local env = require("utils.env").Load_env() or {}
    return env["GODOT_ADDRESS"] or "127.0.0.1:55432"
end

local function server_exists(address)
    local servers = vim.fn.serverlist()
    for _, name in ipairs(servers) do
        if name == address then
            return true
        end
    end
    return false
end

local function ensure_godot_server(address, opts)
    opts = opts or {}
    local addr = address or get_godot_address()

    if not cwd_is_godot_project() then
        local current = vim.api.nvim_get_current_buf()
        if not godot_project_root(current) then
            return false
        end
    end

    if server_exists(addr) then
        godot_state.server_started_by_this_nvim = false
        godot_state.server_address = addr
        godot_log("Godot server already running at " .. addr, vim.log.levels.INFO, opts.notify)
        return true
    end

    local started = vim.fn.serverstart(addr)
    if started == "" then
        godot_log("Failed to start Godot server at " .. addr, vim.log.levels.WARN, opts.notify)
        return false
    end

    godot_state.server_started_by_this_nvim = true
    godot_state.server_address = addr
    godot_log("Godot server started at " .. addr, vim.log.levels.INFO, opts.notify)
    return true
end

local function stop_godot_server(opts)
    opts = opts or {}
    local addr = godot_state.server_address or get_godot_address()
    if not addr then
        return false
    end

    if not opts.force and not godot_state.server_started_by_this_nvim then
        godot_log("Skipped stopping external Godot server at " .. addr, vim.log.levels.INFO, opts.notify)
        return false
    end

    pcall(vim.fn.serverstop, addr)
    godot_state.server_started_by_this_nvim = false
    godot_state.server_address = nil
    godot_log("Godot server stopped at " .. addr, vim.log.levels.INFO, opts.notify)
    return true
end

local function stop_all_gdscript_clients()
    for _, client in ipairs(vim.lsp.get_clients({ name = "gdscript" })) do
        vim.lsp.stop_client(client.id)
    end
end

local function schedule_godot_probe(bufnr)
    if godot_state.probe_pending then
        return
    end
    godot_state.probe_pending = true

    vim.defer_fn(function()
        godot_state.probe_pending = false
        local target = bufnr
        if not target or not vim.api.nvim_buf_is_valid(target) then
            target = vim.api.nvim_get_current_buf()
        end
        ensure_godot_server(nil, { notify = false })
        ensure_gdscript_lsp(target, { notify = false })
    end, 120)
end

return {
    -- Godot integration
    {
        "habamax/vim-godot",
        event = "VeryLazy",
        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "gd", "gdscript" },
                callback = function()
                    vim.opt_local.expandtab = false
                    vim.opt_local.tabstop = 4
                    vim.opt_local.shiftwidth = 4
                    vim.opt_local.softtabstop = 4
                    vim.opt_local.indentexpr = ""
                end,
            })

            vim.api.nvim_create_user_command("StartGodotConnection", function(opts)
                local address = opts.args ~= "" and opts.args or nil
                ensure_godot_server(address, { notify = true })
                ensure_gdscript_lsp(vim.api.nvim_get_current_buf(), { notify = true })
            end, { nargs = "?" })

            vim.api.nvim_create_user_command("StopGodotConnection", function()
                stop_all_gdscript_clients()
                stop_godot_server({ notify = true, force = true })
            end, {})

            local aug = vim.api.nvim_create_augroup("GodotLifecycle", { clear = true })
            vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "DirChanged", "FileType" }, {
                group = aug,
                callback = function(ev)
                    schedule_godot_probe(ev.buf)
                end,
            })

            vim.api.nvim_create_autocmd("VimLeave", {
                group = aug,
                callback = function()
                    stop_godot_server({ notify = false, force = false })
                end,
            })
        end,
    },
}
