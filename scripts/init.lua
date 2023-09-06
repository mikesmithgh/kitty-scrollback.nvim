local plugin_name = 'kitty-scrollback.nvim'
-- add temp path from scripts/mini.sh in case this is running locally
local tempdir = vim.trim(vim.fn.system([[sh -c "dirname $(mktemp -u)"]]))
local packpath = os.getenv('PACKPATH') or tempdir .. '/' .. plugin_name .. '.tmp/nvim/site'

vim.cmd('set packpath=' .. packpath)
require('kitty-scrollback').setup()

local mini_config_file = vim.fn.fnamemodify(vim.fn.fnamemodify(packpath, ':h'), ':h') .. '/mini_config.lua'
if vim.fn.filereadable(mini_config_file) == 0 then
  local style_mini = not require('kitty-scrollback.kitty_commands').try_detect_nerd_font()
  vim.cmd.edit(mini_config_file)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, {
    [[return { ]],
    [[  config = function() ]],
    [[    return { ]],
    [[      status_window = { ]],
    [[        style_simple = ]] .. tostring(style_mini) .. [[,]],
    [[      } ]],
    [[    } ]],
    [[  end, ]],
    [[}]],
  })
  vim.cmd.write({ bang = true })
end
