local M = {}

local kitty_scrollback_kitten = vim.api.nvim_get_runtime_file('python/kitty_scrollback_nvim.py', false)[1]

local ksb_configs = {}
local top_ksb_configs = {
  '# Browse scrollback buffer in nvim',
  'map ctrl+shift+h kitten ' .. kitty_scrollback_kitten,
}
for _, c in pairs(vim.api.nvim_get_runtime_file('lua/kitty-scrollback/configs/*.lua', true)) do
  local name = vim.fn.fnamemodify(c, ':t:r')
  local ksb_config = require('kitty-scrollback.configs.' .. name).config()
  local keymap = ksb_config.kitty_keymap
  local config = (keymap or 'map f1') .. ' kitten ' .. kitty_scrollback_kitten .. ' --config-file ' .. c
  table.insert(top_ksb_configs, ksb_config.kitty_keymap_description)
  if keymap then
    table.insert(top_ksb_configs, config)
  else
    table.insert(ksb_configs, config)
  end
end


local nvim_args = vim.tbl_map(function(c)
  return 'map f1 kitten ' .. kitty_scrollback_kitten .. ' ' .. c
end, {
  [[--no-nvim-args]],
  [[--nvim-args +'colorscheme tokyonight']],
  [[--nvim-args +'lua vim.defer_fn(function() vim.api.nvim_set_option_value("filetype", "markdown", { buf = 0 }); vim.cmd("silent! CellularAutomaton make_it_rain") end, 1000)']],
  [[--nvim-appname altnvimconfig ]],
})

local kitten_configs = vim.list_extend(
  vim.list_extend(
    top_ksb_configs,
    ksb_configs
  ),
  nvim_args
)

M.setup = function()
  vim.api.nvim_create_user_command('KittyScrollbackGenerateKittens', function()
    local bufid = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value('filetype', 'kitty', {
      buf = bufid,
    })
    vim.api.nvim_set_current_buf(bufid)
    vim.api.nvim_buf_set_lines(bufid, 0, -1, false, kitten_configs)
  end, {})
end

return M
