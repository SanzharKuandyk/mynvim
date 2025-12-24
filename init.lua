-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load basic settings before plugins
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- Setup lazy.nvim and load all plugin specs from lua/plugins/
require("lazy").setup("plugins", {
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "tohtml",
                "tarPlugin",
                "tutor",
                "zipPlugin",
            },
        },
    },
})
