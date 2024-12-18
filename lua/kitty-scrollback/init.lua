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
      return { 'maps', 'commands', 'tmux' }
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

  ---@brief [[
  ---:'KittyScrollbackGenerateCommandLineEditing' Generate commands used as reference for command-line editing
  ---
  ---    See: ~
  ---        |kitty.api.generate_edit_commands|
  ---@brief ]]
  vim.api.nvim_create_user_command('KittyScrollbackGenerateCommandLineEditing', function(o)
    require('kitty-scrollback.api').generate_command_line_editing(o.fargs)
  end, {
    nargs = 1,
    complete = function()
      return { 'bash', 'fish', 'zsh' }
    end,
  })
end

return M
