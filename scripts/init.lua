local plugin_name = 'kitty-scrollback.nvim'
-- add temp path from scripts/mini.sh in case this is running locally
local tempdir = vim.trim(vim.fn.system([[sh -c "dirname $(mktemp -u)"]])) ---@diagnostic disable-line: param-type-mismatch
local packpath = os.getenv('PACKPATH') or tempdir .. '/' .. plugin_name .. '.tmp/nvim/site'
vim.cmd('set packpath=' .. packpath)

local mini_opts = {
  status_window = {
    style_simple = true, -- user may not have Nerd Fonts installed
  },
}
-- TODO: verify mini.sh still works before merging
require('kitty-scrollback').setup({
  function()
    return mini_opts
  end,
  -- TODO: this config may no longer be needed now that we can defined a global config
  last_cmd_output = function()
    local builtin = require('kitty-scrollback.configs.builtin').ksb_builtin_last_cmd_output
    return vim.tbl_deep_extend('force', builtin(), mini_opts)
  end,
  last_visited_cmd_output = function()
    local builtin = require('kitty-scrollback.configs.builtin').ksb_builtin_last_visited_cmd_output
    return vim.tbl_deep_extend('force', builtin(), mini_opts)
  end,
})
