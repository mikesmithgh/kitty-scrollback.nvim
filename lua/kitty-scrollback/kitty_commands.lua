---@mod kitty-scrollback.kitty_commands
local M = {}

local p
local opts ---@diagnostic disable-line: unused-local

M.setup = function(private, options)
  p = private
  opts = options ---@diagnostic disable-line: unused-local
end

local system_handle_error = function(cmd, sys_opts)
  local proc = vim.system(cmd, sys_opts or {})
  local result = proc:wait()
  local ok = result.code == 0

  if not ok then
    local msg = {
      '',
      '`kitty-scrollback.nvim`',
      '---------------------',
      '',
    }
    local stdout = result.stdout or ''
    local stderr = result.stderr or ''
    local err = {
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
    vim.api.nvim_set_option_value('filetype', 'help', {
      buf = error_bufid,
    })
    local prompt_msg = 'kitty-scrollback.nvim: Fatal error, see logs.'
    vim.api.nvim_set_current_buf(error_bufid)
    if stderr:match('.*allow_remote_control.*') then
      table.insert(msg, 'Kitty must be configured to allow remote control connections. Add the configuration')
      table.insert(msg, '*allow_remote_control* to Kitty. For example, `allow_remote_control socket-only`')
      table.insert(msg, 'Changing *allow_remote_control* by reloading the config is not supported so you must ')
      table.insert(msg, 'completely close and reopen Kitty for the change to take effect.')
      table.insert(msg, '')
      table.insert(msg, 'Compatible values with kitty-scrollback.nvim for the option *allow_remote_control* are')
      table.insert(msg, '`yes`, `socket`, or `socket-only`.')
      table.insert(msg, '')
      table.insert(msg, 'See https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.allow_remote_control for additional')
      table.insert(msg, 'information on configuring the *allow_remote_control* option.')
      table.insert(msg, '')
    end
    if stderr:match('.*/dev/tty.*') then
      table.insert(msg, 'Kitty must be configured to listen on a Unix socket for remote control connections.')
      table.insert(msg, 'Add the configuration *listen_on* to Kitty. For example, `listen_on unix:/tmp/mykitty`')
      table.insert(msg, 'Changing *listen_on* by reloading the config is not supported so you must completely')
      table.insert(msg, 'close and reopen Kitty for the change to take effect.')
      table.insert(msg, '')
      table.insert(msg, 'See https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.listen_on for additional information')
      table.insert(msg, 'on configuring the *listen_on* option.')
      table.insert(msg, '')
      table.insert(msg, 'If *listen_on* is properly configured, check that the option *allow_remote_control* is')
      table.insert(msg, 'set to either `yes`, `socket`, or `socket-only`.')
      table.insert(msg, '')
      table.insert(msg, 'See https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.allow_remote_control for additional')
      table.insert(msg, 'information on configuring the *allow_remote_control* option.')
      table.insert(msg, '')
    end
    vim.api.nvim_buf_set_lines(error_bufid, 0, -1, false, vim.list_extend(msg, err))
    vim.cmd.redraw()
    local response = vim.fn.confirm(prompt_msg, '&Quit\n&Continue')
    if response ~= 2 then
      vim.cmd.quitall({ bang = true })
    end
  end

  return ok, result
end


M.send_paste_buffer_text_to_kitty_and_quit = function(bracketed_paste_mode)
  -- convert table to string separated by carriage returns
  local cmd_str = table.concat(
    vim.tbl_filter(function(l) return #l > 0 end, vim.api.nvim_buf_get_lines(p.paste_bufid, 0, -1, false)
    ), '\r')
  -- wrap in bracketed paste mode
  cmd_str = '\\x1b[200~' .. cmd_str .. '\r\\x1b[201~' -- see https://cirw.in/blog/bracketed-paste
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
  vim.cmd.quitall({ bang = true })
end

M.close_kitty_loading_window = function()
  if p.kitty_loading_winid then
    system_handle_error({
      'kitty',
      '@',
      'close-window',
      '--match=id:' .. p.kitty_loading_winid,
    })
  end
  p.kitty_loading_winid = nil
end

M.signal_winchanged_to_kitty_child_process = function()
  system_handle_error({
    'kitty',
    '@',
    'signal-child',
    'SIGWINCH'
  })
end

M.open_kitty_loading_window = function(env)
  if p.kitty_loading_winid then
    M.close_kitty_loading_window()
  end
  local kitty_cmd = vim.list_extend({ 'kitty',
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
    },
    vim.list_extend(
      env or {},
      { p.kitty_data.ksb_dir .. '/python/loading.py', }
    )
  )
  local ok, result = system_handle_error(kitty_cmd)
  if ok then
    p.kitty_loading_winid = tonumber(result.stdout)
  end
end


M.get_kitty_colors = function(kitty_data)
  local ok, result = system_handle_error({
    'kitty',
    '@',
    'get-colors',
    '--match=id:' .. kitty_data.window_id,
  })
  if not ok then
    return ok
  end
  local kitty_colors_str = result.stdout or ''
  local kitty_colors = {}
  for color_kv in kitty_colors_str:gmatch('[^\r\n]+') do
    local split_kv = color_kv:gmatch('%S+')
    kitty_colors[split_kv()] = split_kv()
  end
  return ok, kitty_colors
end


return M
