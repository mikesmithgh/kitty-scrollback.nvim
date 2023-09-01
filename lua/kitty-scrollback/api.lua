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

---@tag kitty-scrollback.api.close_or_quit_all
---Attempt to gracefully quit Neovim. How do you exit vim? Why would you exit vim?
M.quit_all = function()
  -- quit causes nvim to exit early sometime interrupting underlying copy child process (.e.g, xclip)
  -- send sigterm to gracefully terminate
  vim.schedule(ksb_kitty_cmds.signal_term_to_kitty_child_process)
end

---@tag kitty-scrollback.api.close_or_quit_all
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

---@tag kitty-scrollback.api.execute_command
---If the current buffer is the paste buffer, then quit and execute the paste
---window contents in Kitty. Otherwise, no operation
M.execute_command = function()
  if vim.api.nvim_get_current_buf() == p.paste_bufid then
    ksb_kitty_cmds.send_paste_buffer_text_to_kitty_and_quit(false)
  end
end

---@tag kitty-scrollback.api.paste_command
---If the current buffer is the paste buffer, then quit and paste the paste
---window contents to Kitty. Otherwise, no operation
M.paste_command = function()
  if vim.api.nvim_get_current_buf() == p.paste_bufid then
    ksb_kitty_cmds.send_paste_buffer_text_to_kitty_and_quit(true)
  end
end

---@tag kitty-scrollback.api.toggle_footer
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

return M
