---@mod kitty-scrollback.kitty_commands
local ksb_health = require('kitty-scrollback.health')
local M = {}

local p
local opts ---@diagnostic disable-line: unused-local

M.setup = function(private, options)
  p = private
  opts = options ---@diagnostic disable-line: unused-local
end

local system_handle_error = function(cmd, sys_opts, ignore_error)
  local proc = vim.system(cmd, sys_opts or {})
  local result = proc:wait()
  local ok = result.code == 0

  if not ok then
    local msg = {
      '',
      '==============================================================================',
      'kitty-scrollback.nvim',
      '',
      'ERROR: failed to execute remote Kitty command',
      '',
    }
    local stdout = result.stdout or ''
    local stderr = result.stderr or ''
    local err = {
      '*entrypoint:* |vim.system()|',
      '*command:* ' .. table.concat(cmd, ' '),
      '*pid:* ' .. proc.pid,
      '*code:* ' .. result.code,
      '*signal:* ' .. result.signal,
      '*stdout:*',
    }
    local out = {}
    for line in stdout:gmatch('[^\r\n]+') do
      table.insert(out, '  ' .. line)
    end
    if next(out) then
      vim.list_extend(err, out)
    else
      table.insert(err, '  <none>')
    end
    table.insert(err, '*stderr:*')
    for line in stderr:gmatch('[^\r\n]+') do
      table.insert(err, '  ' .. line)
    end
    local error_bufid = vim.api.nvim_create_buf(false, true)
    vim.o.conceallevel = 2
    vim.o.concealcursor = 'n'
    vim.api.nvim_set_option_value('filetype', 'checkhealth', {
      buf = error_bufid,
    })
    local prompt_msg = 'kitty-scrollback.nvim: Fatal error, see logs.'
    if stderr:match('.*allow_remote_control.*') then
      vim.list_extend(msg, ksb_health.advice().allow_remote_control)
      ignore_error = false -- fatal error, always report this error
    end
    if stderr:match('.*/dev/tty.*') then
      vim.list_extend(msg, ksb_health.advice().listen_on)
      ignore_error = false -- fatal error, always report this error
    end
    if ignore_error then
      return ok, result
    end
    vim.api.nvim_set_current_buf(error_bufid)
    vim.api.nvim_buf_set_lines(error_bufid, 0, -1, false, vim.list_extend(msg, err))
    vim.cmd.redraw()
    local response = vim.fn.confirm(prompt_msg, '&Quit\n&Continue')
    if response ~= 2 then
      M.signal_term_to_kitty_child_process(true)
    end
  end

  return ok, result
end

M.send_paste_buffer_text_to_kitty_and_quit = function(bracketed_paste_mode)
  -- convert table to string separated by carriage returns
  local cmd_str = table.concat(
    vim.tbl_filter(function(l)
      return #l > 0
    end, vim.api.nvim_buf_get_lines(p.paste_bufid, 0, -1, false)),
    '\r'
  )
  -- wrap in bracketed paste mode
  local esc = vim.fn.eval([["\e"]])
  cmd_str = esc .. '[200~' .. cmd_str .. '\r' .. esc .. '[201~' -- see https://cirw.in/blog/bracketed-paste
  -- if not bracketed paste mode trigger add a carriage return to execute command
  if not bracketed_paste_mode then
    cmd_str = cmd_str .. '\r'
  end
  system_handle_error({
    'kitty',
    '@',
    'send-text',
    '--match=id:' .. p.kitty_data.window_id,
    cmd_str,
  })
  M.signal_term_to_kitty_child_process()
end

M.list_kitty_windows = function()
  return system_handle_error({
    'kitty',
    '@',
    'ls',
  })
end

M.close_kitty_loading_window = function(ignore_error)
  if p and p.kitty_loading_winid then
    local winid = p.kitty_loading_winid
    p.kitty_loading_winid = nil
    return system_handle_error({
      'kitty',
      '@',
      'close-window',
      '--match=id:' .. winid,
    }, {}, ignore_error)
  end
  return true
end

M.signal_winchanged_to_kitty_child_process = function()
  system_handle_error({
    'kitty',
    '@',
    'signal-child',
    'SIGWINCH',
  })
end

M.signal_term_to_kitty_child_process = function(force)
  if force then
    vim.cmd.quitall({ bang = true })
  else
    system_handle_error({
      'kitty',
      '@',
      'signal-child',
      'SIGTERM',
    })
  end
end

M.open_kitty_loading_window = function(env)
  if p.kitty_loading_winid then
    M.close_kitty_loading_window()
  end
  local kitty_cmd = vim.list_extend({
    'kitty',
    '@',
    'launch',
    '--type',
    'overlay',
    '--title',
    'kitty-scrollback.nvim :: loading...',
    '--env',
    'KITTY_SCROLLBACK_NVIM_STYLE_SIMPLE=' .. tostring(opts.status_window.style_simple),
    '--env',
    'KITTY_SCROLLBACK_NVIM_STATUS_WINDOW_ENABLED=' .. tostring(opts.status_window.enabled),
    '--env',
    'KITTY_SCROLLBACK_NVIM_SHOW_TIMER=' .. tostring(opts.status_window.show_timer),
  }, vim.list_extend(env or {}, { p.kitty_data.ksb_dir .. '/python/loading.py' }))
  local ok, result = system_handle_error(kitty_cmd)
  if ok then
    p.kitty_loading_winid = tonumber(result.stdout)
  end
end

M.get_kitty_colors = function(kitty_data, ignore_error, no_window_id)
  local match = no_window_id and nil or '--match=id:' .. kitty_data.window_id
  local ok, result = system_handle_error({
    'kitty',
    '@',
    'get-colors',
    match,
  }, { text = true }, ignore_error)
  if not ok then
    return ok, result
  end
  local kitty_colors_str = result.stdout or ''
  local kitty_colors = {}
  for color_kv in kitty_colors_str:gmatch('[^\r\n]+') do
    local split_kv = color_kv:gmatch('%S+')
    kitty_colors[split_kv()] = split_kv()
  end
  return ok, kitty_colors
end

M.send_text_to_clipboard = function(text)
  return system_handle_error({
    'kitty',
    '+kitten',
    'clipboard',
    '/dev/stdin',
  }, {
    stdin = text,
  })
end

M.try_detect_nerd_font = function()
  local has_nerd_font = false
  vim
    .system({
      'kitty',
      '--debug-font-fallback',
      '--start-as',
      'minimized',
      '--override',
      'shell=sh',
      'sh',
      '-c',
      'kill $PPID',
    }, {
      text = true,
      stderr = function(_, data)
        if data and data:lower():match('.*nerd.*font.*') then
          has_nerd_font = true
        end
      end,
    })
    :wait()
  return has_nerd_font
end

return M
