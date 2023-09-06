local plugin_name = 'kitty-scrollback.nvim'
-- add temp path from scripts/mini.sh in case this is running locally
local tempdir = vim.trim(vim.fn.system([[sh -c "dirname $(mktemp -u)"]]))
local packpath = os.getenv('PACKPATH') or tempdir .. '/' .. plugin_name .. '.tmp/nvim/site'

vim.cmd('set packpath=' .. packpath)
require('kitty-scrollback').setup()
