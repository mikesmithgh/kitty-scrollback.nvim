-- mini.sh nvim config
local plugin_name = 'kitty-scrollback.nvim'
-- add temp path from scripts/mini.sh in case this is running locally
local tempdir = vim.trim(vim.fn.system([[sh -c "dirname $(mktemp -u)"]])) ---@diagnostic disable-line: param-type-mismatch
local packpath = os.getenv('PACKPATH') or tempdir .. '/' .. plugin_name .. '.tmp/nvim/site'
vim.cmd('set packpath=' .. packpath)

require('kitty-scrollback').setup({
  {
    status_window = {
      style_simple = true, -- user may not have Nerd Fonts installed
    },
  },
})
