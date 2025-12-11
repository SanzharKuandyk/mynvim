local harpoon = require("harpoon")
harpoon:setup({})

-- Jump to harpoon marks
vim.keymap.set("n", "<leader>ja", function()
    harpoon:list():add()
end)
vim.keymap.set("n", "<leader>jm", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
end)

-- Jump to harpooned buffers
vim.keymap.set("n", "<leader>j1", function()
    harpoon:list():select(1)
end)
vim.keymap.set("n", "<leader>j2", function()
    harpoon:list():select(2)
end)
vim.keymap.set("n", "<leader>j3", function()
    harpoon:list():select(3)
end)
vim.keymap.set("n", "<leader>j4", function()
    harpoon:list():select(4)
end)

-- Toggle previous & next harpooned buffers
vim.keymap.set("n", "<leader>jp", function()
    harpoon:list():prev()
end)
vim.keymap.set("n", "<leader>jn", function()
    harpoon:list():next()
end)

-- Basic Telescope configuration
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
    end

    require("telescope.pickers")
        .new({}, {
            prompt_title = "Harpoon",
            finder = require("telescope.finders").new_table({ results = file_paths }),
            previewer = conf.file_previewer({}),
            sorter = conf.generic_sorter({}),
        })
        :find()
end

vim.keymap.set("n", "<leader>hv", function()
    toggle_telescope(harpoon:list())
end, { desc = "Open harpoon window" })
