---@mod kitty-scrollback.util
local ksb_health = require('kitty-scrollback.health')

local M = {}

---@type KsbPrivate
local p
local opts ---@diagnostic disable-line: unused-local

M.setup = function(private, options)
  p = private
  opts = options ---@diagnostic disable-line: unused-local
end

---@param c  string
M.hexToRgb = function(c)
  c = string.lower(c)
  return { tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) }
end

---@param foreground string foreground color
---@param background string background color
---@param alpha number|string number between 0 and 1. 0 results in bg, 1 results in fg
M.blend = function(foreground, background, alpha)
  alpha = type(alpha) == 'string' and (tonumber(alpha, 16) / 0xff) or alpha
  local bg = M.hexToRgb(background)
  local fg = M.hexToRgb(foreground)

  local blendChannel = function(i)
    local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
    return math.floor(math.min(math.max(0, ret), 255) + 0.5)
  end

  return string.format('#%02x%02x%02x', blendChannel(1), blendChannel(2), blendChannel(3))
end

M.darken = function(hex, amount, bg)
  local default_bg = '#ffffff'
  if vim.o.background == 'dark' then
    default_bg = '#000000'
  end
  return M.blend(hex, bg or default_bg, amount)
end

---Convert camelCase to SCREAMING_SNAKECASE
---@param s string
---@return string
M.screaming_snakecase = function(s)
  -- copied and modified from https://codegolf.stackexchange.com/a/177958
  return s:gsub('%f[^%l]%u', '_%1')
    :gsub('%f[^%a]%d', '_%1')
    :gsub('%f[^%d]%a', '_%1')
    :gsub('(%u)(%u%l)', '%1_%2')
    :upper()
end

M.restore_and_redraw = function()
  if p.orig_columns then
    vim.o.columns = p.orig_columns
  end
  vim.cmd.redraw()
end

M.tab_offset = function()
  -- if always displaying a tabline or if displaying a tabline when more than one tab exists
  if vim.o.showtabline >= 2 or (vim.o.showtabline == 1 and vim.fn.tabpagenr('$') > 1) then
    return 1
  end
  return 0
end

M.winbar_offset = function()
  if vim.o.winbar ~= '' then
    return 1
  end
  return 0
end

M.line_offset = function()
  return M.tab_offset() + M.winbar_offset()
end

M.clear_yank_autocommand_and_get_visual_selection = function()
  vim.api.nvim_clear_autocmds({
    group = vim.api.nvim_create_augroup('KittyScrollBackNvimTextYankPost', { clear = true }),
  })
  -- vim.cmd.yank requires entering and exiting visual mode, so just use vim.cmd.normal
  vim.cmd.normal({ 'y', bang = true })
  local reginfo = vim.fn.getreginfo('"') or { regcontents = {} }
  return reginfo.regcontents
end

M.quitall = function()
  if vim.fn.getcmdwintype() == '' then
    vim.cmd.quitall({ bang = true })
  else
    -- in command-line window, we have to exit both the command-line window and neovim
    vim.cmd.quit({ bang = true })
    vim.defer_fn(function()
      vim.cmd.quitall({ bang = true })
    end, 250)
  end
end

M.plug_mapping_names = {
  VISUAL_YANK_LINE = '<Plug>(KsbVisualYankLine)',
  VISUAL_YANK = '<Plug>(KsbVisualYank)',
  NORMAL_YANK_END = '<Plug>(KsbNormalYankEnd)',
  NORMAL_YANK = '<Plug>(KsbNormalYank)',
  YANK_LINE = '<Plug>(KsbYankLine)',

  CLOSE_OR_QUIT_ALL = '<Plug>(KsbCloseOrQuitAll)',
  QUIT_ALL = '<Plug>(KsbQuitAll)',

  EXECUTE_VISUAL_CMD = '<Plug>(KsbExecuteVisualCmd)',
  PASTE_VISUAL_CMD = '<Plug>(KsbPasteVisualCmd)',

  TOGGLE_FOOTER = '<Plug>(KsbToggleFooter)',
  EXECUTE_CMD = '<Plug>(KsbExecuteCmd)',
  PASTE_CMD = '<Plug>(KsbPasteCmd)',
}

M.display_error = function(cmd, r, header)
  local msg = vim.list_extend({}, header or {})
  local stdout = r.stdout or ''
  local stderr = r.stderr or ''
  local err = {}
  if r.entrypoint then
    table.insert(err, '*entrypoint:* |' .. r.entrypoint:gsub('(%s+)', '|%1|') .. '| ')
  end
  table.insert(err, '*command:* ' .. cmd)
  if r.pid then
    table.insert(err, '*pid:* ' .. r.pid)
  end
  if r.channel_id then
    table.insert(err, '*channel_id:* ' .. r.channel_id)
  end
  if r.code then
    table.insert(err, '*code:* ' .. r.code)
  end
  if r.signal then
    table.insert(err, '*signal:* ' .. r.signal)
  end

  if r.full_cmd then
    table.insert(err, '*full_command:* ')
    table.insert(err, '>sh')
    table.insert(err, '    ' .. r.full_cmd)
    table.insert(err, '<')
  end

  table.insert(err, '*stdout:*')

  local out = {}
  for line in stdout:gmatch('[^\r\n]+') do
    table.insert(out, '  ' .. line)
  end
  if next(out) then
    table.insert(err, '')
    vim.list_extend(err, out)
  else
    table.insert(err, '  <none>')
  end
  table.insert(err, '')
  table.insert(err, '*stderr:*')
  if #stderr > 0 then
    for line in stderr:gmatch('[^\r\n]+') do
      table.insert(err, '')
      table.insert(err, '  ' .. line)
    end
  else
    table.insert(err, '  <none>')
  end
  table.insert(err, '')
  local error_bufid = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(error_bufid, vim.fn.tempname() .. '.ksb_errorbuf')
  vim.api.nvim_set_current_buf(error_bufid)
  vim.o.conceallevel = 2
  vim.o.concealcursor = 'n'
  vim.o.foldenable = false
  vim.api.nvim_set_option_value('filetype', 'checkhealth', {
    buf = error_bufid,
  })
  M.restore_and_redraw()
  local prompt_msg = 'kitty-scrollback.nvim: Fatal error, see logs.'
  if stderr:match('.*allow_remote_control.*') then
    vim.list_extend(msg, ksb_health.advice.allow_remote_control)
  end
  if stderr:match('.*/dev/tty.*') then
    vim.list_extend(msg, ksb_health.advice.listen_on)
  end
  vim.api.nvim_buf_set_lines(error_bufid, 0, -1, false, vim.list_extend(msg, err))
  M.restore_and_redraw()
  local response = vim.fn.confirm(prompt_msg, '&Quit\n&Continue')
  if response ~= 2 then
    M.quitall()
  end
end

M.system_handle_error = function(cmd, error_header, sys_opts, ignore_error)
  local proc = vim.system(cmd, sys_opts or {})
  local result = proc:wait()
  local ok = result.code == 0

  if not ignore_error and not ok then
    M.display_error(table.concat(cmd, ' '), {
      entrypoint = 'vim.system()',
      pid = proc.pid,
      code = result.code,
      signal = result.signal,
      stdout = result.stdout,
      stderr = result.stderr,
    }, error_header)
  end

  return ok, result
end

return M
