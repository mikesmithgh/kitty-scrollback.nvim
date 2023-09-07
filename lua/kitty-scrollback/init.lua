---@mod kitty-scrollback
local M = {}

---Create commands for generating kitty-scrollback.nvim kitten configs
M.setup = function()
  ---@brief [[
  ---:KittyScrollbackGenerateKittens something.
  ---
  ---    See: ~
  ---        |render.api.explore|
  ---@brief ]]
  vim.api.nvim_create_user_command('KittyScrollbackGenerateKittens', function(o)
    require('kitty-scrollback.api').generate_kittens(o.bang)
  end, {
    bang = true,
  })

  vim.api.nvim_create_user_command('KittyScrollbackCheckHealth', function()
    require('kitty-scrollback.api').checkhealth()
  end, {})
end

return M
