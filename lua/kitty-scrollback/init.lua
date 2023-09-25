---@mod kitty-scrollback
local M = {}

---Create commands for generating kitty-scrollback.nvim kitten configs
M.setup = function()
  ---@brief [[
  ---:KittyScrollbackGenerateKittens Generate Kitten commands used as reference for configuring `kitty.conf`
  ---
  ---    See: ~
  ---        |kitty.api.generate_kittens|
  ---@brief ]]
  vim.api.nvim_create_user_command('KittyScrollbackGenerateKittens', function(o)
    require('kitty-scrollback.api').generate_kittens(o.bang)
  end, {
    bang = true,
  })

  ---@brief [[
  ---:KittyScrollbackGenerateKittens Run `:checkhealth kitty-scrollback` in the context of Kitty
  ---
  ---    See: ~
  ---        |kitty.api.checkhealth|
  ---@brief ]]
  vim.api.nvim_create_user_command(
    'KittyScrollbackCheckHealth',
    vim.schedule_wrap(require('kitty-scrollback.api').checkhealth),
    {}
  )
end

return M
