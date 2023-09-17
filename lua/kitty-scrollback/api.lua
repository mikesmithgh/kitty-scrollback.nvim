---@mod kitty-scrollback.api
local ksb_footer_win = require('kitty-scrollback.footer_win')
local ksb_kitty_cmds = require('kitty-scrollback.kitty_commands')

---@type KsbPrivate
local p

---@type KsbOpts
local opts ---@diagnostic disable-line: unused-local

local M = {}

M.setup = function(private, options)
  p = private
  opts = options ---@diagnostic disable-line: unused-local
end

---Attempt to gracefully quit Neovim. How do you exit vim? Why would you exit vim?
M.quit_all = function()
  -- quit causes nvim to exit early sometime interrupting underlying copy child process (.e.g, xclip)
  -- send sigterm to gracefully terminate
  vim.schedule(ksb_kitty_cmds.signal_term_to_kitty_child_process)
end

---If the current buffer is the paste buffer, then close the window
---If the current buffer is the scrollback buffer, then quitall
---Otherwise, no operation
M.close_or_quit_all = function()
  if vim.api.nvim_get_current_buf() == p.bufid then
    M.quit_all()
    return
  end
  if vim.api.nvim_get_current_buf() == p.paste_bufid then
    vim.cmd.close({ bang = true })
    return
  end
end

---If the current buffer is the paste buffer, then quit and execute the paste
---window contents in Kitty. Otherwise, no operation
M.execute_command = function()
  if vim.api.nvim_get_current_buf() == p.paste_bufid then
    ksb_kitty_cmds.send_paste_buffer_text_to_kitty_and_quit(false)
  end
end

---If the current buffer is the paste buffer, then quit and paste the paste
---window contents to Kitty. Otherwise, no operation
M.paste_command = function()
  if vim.api.nvim_get_current_buf() == p.paste_bufid then
    ksb_kitty_cmds.send_paste_buffer_text_to_kitty_and_quit(true)
  end
end

---If the current buffer is the paste buffer, toggle the footer window
---open or closed. Otherwise, no operation
M.toggle_footer = function()
  if vim.api.nvim_get_current_buf() == p.paste_bufid then
    if p.footer_winid then
      pcall(vim.api.nvim_win_close, p.footer_winid, true)
      p.footer_winid = nil
    else
      local winopts = vim.api.nvim_win_get_config(p.paste_winid)
      vim.schedule_wrap(ksb_footer_win.open_footer_window)(winopts)
    end
    vim.schedule_wrap(vim.cmd.doautocmd)('WinResized')
    return
  end
end

M.generate_kittens = function(all)
  local kitty_scrollback_kitten =
    vim.api.nvim_get_runtime_file('python/kitty_scrollback_nvim.py', false)[1]
  local kitty_scrollback_configs =
    vim.api.nvim_get_runtime_file('lua/kitty-scrollback/configs', false)[1]

  local ksb_configs = { '' }
  local action_alias = 'kitty_scrollback_nvim'
  local top_ksb_configs = {
    '# kitty-scrollback.nvim Kitten alias',
    'action_alias '
      .. action_alias
      .. ' kitten '
      .. kitty_scrollback_kitten
      .. ' --cwd '
      .. kitty_scrollback_configs,
    '',
    '# Browse scrollback buffer in nvim',
    'map ctrl+shift+h ' .. action_alias,
  }
  for _, c in pairs(vim.api.nvim_get_runtime_file('lua/kitty-scrollback/configs/*.lua', true)) do
    local name = vim.fn.fnamemodify(c, ':t:r')
    local ksb_config = require('kitty-scrollback.configs.' .. name).config() or {}
    local keymap = ksb_config.kitty_keymap
    local config = (keymap or 'map f1')
      .. ' '
      .. action_alias
      .. ' --config-file '
      .. name
      .. '.lua'
    table.insert(top_ksb_configs, ksb_config.kitty_keymap_description)
    if keymap then
      table.insert(top_ksb_configs, config)
    else
      table.insert(ksb_configs, config)
    end
  end

  local nvim_args = vim.tbl_map(function(c)
    return 'map f1 ' .. action_alias .. ' ' .. c
  end, {
    [[--no-nvim-args --env NVIM_APPNAME=ksb-nvim]],
    [[--nvim-args +'colorscheme tokyonight']],
    [[--nvim-args +'lua vim.defer_fn(function() vim.api.nvim_set_option_value("filetype", "markdown", { buf = 0 }); vim.cmd("silent! CellularAutomaton make_it_rain") end, 1000)']],
  })

  local kitten_configs = vim.list_extend(
    vim.list_extend(vim.tbl_extend('force', top_ksb_configs, {}), ksb_configs),
    nvim_args
  )
  local bufid = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_set_option_value('filetype', 'kitty', {
    buf = bufid,
  })
  vim.api.nvim_set_current_buf(bufid)
  if all then
    vim.api.nvim_buf_set_lines(bufid, 0, -1, false, kitten_configs)
  else
    vim.api.nvim_buf_set_lines(bufid, 0, -1, false, top_ksb_configs)
  end
end

M.checkhealth = function()
  local kitty_scrollback_kitten =
    vim.api.nvim_get_runtime_file('python/kitty_scrollback_nvim.py', false)[1]
  local checkhealth_config =
    vim.api.nvim_get_runtime_file('lua/kitty-scrollback/configs/checkhealth.lua', false)[1]
  if vim.fn.has('nvim-0.10') > 0 then
    vim.system({
      'kitty',
      '@',
      'kitten',
      kitty_scrollback_kitten,
      '--config-file',
      checkhealth_config,
    })
  else
    -- fallback on checkhealth for earlier versions of nvim
    vim.cmd.checkhealth('kitty-scrollback')
  end
end

return M
