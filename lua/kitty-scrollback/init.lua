---@mod kitty-scrollback
local M = {}

---@type table<string, KsbOpts|fun(KsbKittyData):KsbOpts>
M.configs = {}

---Create commands for generating kitty-scrollback.nvim kitten configs
M.setup = function(configs)
  if configs then
    M.configs = configs
  end
  ---@brief [[
  ---:KittyScrollbackGenerateKittens Generate Kitten commands used as reference for configuring `kitty.conf`
  ---
  ---    See: ~
  ---        |kitty.api.generate_kittens|
  ---@brief ]]
  vim.api.nvim_create_user_command('KittyScrollbackGenerateKittens', function(o)
    require('kitty-scrollback.api').generate_kittens(o.fargs)
  end, {
    nargs = '*',
    complete = function()
      return { 'maps', 'commands' }
    end,
  })

  ---@brief [[
  ---:KittyScrollbackCheckHealth Run `:checkhealth kitty-scrollback` in the context of Kitty
  ---
  ---    See: ~
  ---        |kitty.api.checkhealth|
  ---@brief ]]
  vim.api.nvim_create_user_command('KittyScrollbackCheckHealth', function()
    require('kitty-scrollback.api').checkhealth()
  end, {})

  vim.api.nvim_create_autocmd('User', {
    pattern = 'KittyScrollbackCheckLaunch',
    once = true,
    callback = function() end,
  })
end

return M
