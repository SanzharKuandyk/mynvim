return {
    {
        "zhuldyz.nvim",
        dev = true,
        dir = vim.fn.stdpath("data") .. "/lazy/zhuldyz.nvim",
        cmd = "Zhuldyz",
        keys = {
            { "<leader>cg", "<cmd>Zhuldyz<cr>", desc = "Code graph (zhuldyz)" },
        },
        opts = {
            -- root = nil,          -- nil → cwd at open time
            -- debug = false,       -- set true to enable :Zhuldyz debug
            -- focus_depth = 2,
            -- layout = { direction = "TB", vertical_spacing = 3 },
        },
    },
}
