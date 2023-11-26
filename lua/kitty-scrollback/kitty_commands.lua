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
  'ERROR: failed to execute remote Kitty command',
  '',
}

local display_error = function(cmd, r)
  local msg = vim.list_extend({}, error_header)
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
  vim.api.nvim_set_current_buf(error_bufid)
  vim.o.conceallevel = 2
  vim.o.concealcursor = 'n'
  vim.o.foldenable = false
  vim.api.nvim_set_option_value('filetype', 'checkhealth', {
    buf = error_bufid,
  })
  ksb_util.restore_and_redraw()
  local prompt_msg = 'kitty-scrollback.nvim: Fatal error, see logs.'
  if stderr:match('.*allow_remote_control.*') then
    vim.list_extend(msg, ksb_health.advice().allow_remote_control)
  end
  if stderr:match('.*/dev/tty.*') then
    vim.list_extend(msg, ksb_health.advice().listen_on)
  end
  vim.api.nvim_buf_set_lines(error_bufid, 0, -1, false, vim.list_extend(msg, err))
  M.close_kitty_loading_window() -- cannot use ignore parameter or will be infinite recursion
  ksb_util.restore_and_redraw()
  local response = vim.fn.confirm(prompt_msg, '&Quit\n&Continue')
  if response ~= 2 then
    M.signal_term_to_kitty_child_process(true)
  end
end

local system_handle_error = function(cmd, sys_opts, ignore_error)
  local proc = vim.system(cmd, sys_opts or {})
  local result = proc:wait()
  local ok = result.code == 0

  if not ignore_error and not ok then
    display_error(table.concat(cmd, ' '), {
      entrypoint = 'vim.system()',
      pid = proc.pid,
      code = result.code,
      signal = result.signal,
      stdout = result.stdout,
      stderr = result.stderr,
    })
  end

  return ok, result
end

M.get_text_term = function(kitty_data, get_text_opts, on_exit_cb)
  local esc = vim.fn.eval([["\e"]])
  local kitty_get_text_cmd =
    string.format([[kitty @ get-text --match="id:%s" %s]], kitty_data.window_id, get_text_opts)
  local sed_cmd = string.format(
    [[sed -E ]]
      .. [[-e 's/%s\[\?25.%s\[.*;.*H%s\[.*//g' ]] -- remove control sequence added by --add-cursor flag
      .. [[-e 's/$/%s[0m/g' ]], -- append all lines with reset to avoid unintended colors
    esc,
    esc,
    esc,
    esc
  )
  local flush_stdout_cmd = [[kitty +runpy 'sys.stdout.flush()']]
  -- start to set title but do not complete see https://github.com/kovidgoyal/kitty/issues/719#issuecomment-952039731
  local start_set_title_cmd = string.format([[printf '%s]2;']], esc)
  local full_cmd = kitty_get_text_cmd
    .. ' | '
    .. sed_cmd
    -- TODO: find scenario where I needed sed and possibly remove?
    -- - reproduced on v1.0.0 but can't repro on this with: bat --no-pager ~/.bashrc; printf "before \x1b[1;1H after\n"
    -- - may not need, but need to write tests first
    .. ' && '
    .. flush_stdout_cmd
    .. ' && '
    .. start_set_title_cmd
  local stdout
  local stderr
  local tail_max = 10

  -- set the shell used for termopen to sh to avoid imcompatabiliies with other shells (e.g., nushell, fish, etc)
  vim.o.shell = 'sh'

  vim.fn.termopen(full_cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      stdout = data
    end,
    on_stderr = function(_, data)
      stderr = data
    end,
    on_exit = function(id, exit_code, event)
      if exit_code == 0 then
        -- no need to check allow_remote_control or dev/tty because earlier commands would have reported the error
        if #stdout >= 2 then
          -- the exit code may have been lost while piping the command through sed
          -- so search last lines for and error reported by Kitty
          local error_index = -1
          local tail_diff = #stdout - tail_max
          local tail_count = tail_diff < 1 and 1 or math.min(tail_diff, #stdout)
          for i = #stdout, tail_count, -1 do
            -- see for match kitty/tools/cli/markup/prettify.go ans.Err = fmt_ctx.SprintFunc("bold fg=bright-red") -- cspell:disable-linea
            if stdout[i]:match('^' .. esc .. '%[1;91mError' .. esc .. '%[221;39m: .*') then
              error_index = i
              break
            end
          end

          if error_index > 0 then
            display_error(kitty_get_text_cmd, {
              entrypoint = 'termopen() :: exit_code = 0 and error_index > 0',
              full_cmd = full_cmd,
              code = 1, -- exit code is not returned through pipe but we can assume 1 due to error message
              channel_id = id,
              stdout = table.concat(
                vim.tbl_map(function(line)
                  return line
                    :gsub('[\27\155][][()#:;?%d]*[A-PRZcf-ntqry=><~]', '')
                    :gsub(esc .. '\\', '')
                    :gsub(';k=s', '')
                end, stdout),
                '\n'
              ),
              stderr = stderr and table.concat(stderr, '\n') or nil,
            })
          end
        end
        on_exit_cb(id, exit_code, event)
      else
        local out = stdout
            and table
              .concat(stdout, '\n', math.max(#stdout - tail_max, 1), #stdout)
              :gsub('[\27\155][][()#:;?%d]*[A-PRZcf-ntqry=><~]', '')
              :gsub('' .. esc .. '\\', '')
              :gsub(';k=s', '')
          or nil
        display_error(full_cmd, {
          entrypoint = 'termopen() :: exit_code ~= 0',
          code = exit_code,
          channel_id = id,
          stdout = out,
          stderr = stderr and table.concat(stderr, '\n') or nil,
        })
      end
    end,
  })

  -- restore the original shell after processing termopen
  vim.o.shell = p.orig_options.shell
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
    M.close_kitty_loading_window(true)
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
    '--env',
    'KITTY_SCROLLBACK_NVIM_KITTY_ICON=' .. tostring(opts.status_window.icons.kitty),
    '--env',
    'KITTY_SCROLLBACK_NVIM_HEART_ICON=' .. tostring(opts.status_window.icons.heart),
    '--env',
    'KITTY_SCROLLBACK_NVIM_NVIM_ICON=' .. tostring(opts.status_window.icons.nvim),
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

return M
