local plugin_name = 'kitty-scrollback.nvim'
-- add temp path from scripts/mini.sh in case this is running locally
local tempdir = vim.trim(vim.fn.system([[sh -c "dirname $(mktemp -u)"]]))
local packpath = os.getenv('PACKPATH') or tempdir .. '/' .. plugin_name .. '.tmp/nvim/site'
vim.cmd('set packpath=' .. packpath)

local mini_opts = {
  status_window = {
    style_simple = not require('kitty-scrollback.kitty_commands').try_detect_nerd_font(),
  },
}
require('kitty-scrollback').setup({
  default = function()
    return mini_opts
  end,
  last_cmd_output = function()
    local builtin = require('kitty-scrollback.configs.builtin').configs.ksb_builtin_last_cmd_output
    return vim.tbl_deep_extend('force', builtin(), mini_opts)
  end,
  last_visited_cmd_output = function()
    local builtin =
      require('kitty-scrollback.configs.builtin').configs.ksb_builtin_last_visited_cmd_output
    return vim.tbl_deep_extend('force', builtin(), mini_opts)
  end,
})
