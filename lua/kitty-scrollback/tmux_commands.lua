---@mod kitty-scrollback.kitty_commands
local ksb_health = require('kitty-scrollback.health')
local ksb_util = require('kitty-scrollback.util')
local M = {}

---@type KsbPrivate
local p

---@type KsbOpts
local opts

M.setup = function(private, options)
  p = private
  opts = options ---@diagnostic disable-line: unused-local
end

local error_header = {
  '',
  '==============================================================================',
  'kitty-scrollback.nvim',
  '',
  'ERROR: failed to execute tmux command',
  '',
}

---@param get_text_args KsbKittyGetTextArguments
M.get_scrollback_cmd = function(get_text_args)
  return ([[tmux capture-pane -p -t%s %s]]):format(p.kitty_data.tmux.pane_id, get_text_args.tmux)
end

M.show_status_option = function()
  local ok, result = ksb_util.system_handle_error({
    'tmux',
    'show-options',
    ('-t%s'):format(p.kitty_data.tmux.pane_id),
    '-A', -- include inherited options
    '-v', -- value only
    'status',
  }, error_header)
  if not ok then
    return ok, result
  end
  local tmux_status_str = (result.stdout or 'on'):gsub('\n', ''):lower()
  local tmux_status = 0
  if tmux_status_str == 'on' then
    tmux_status = 1
  end
  if tmux_status_str ~= 'off' then
    tmux_status = tonumber(tmux_status_str) or 1
  end
  return ok, tmux_status
end

return M
