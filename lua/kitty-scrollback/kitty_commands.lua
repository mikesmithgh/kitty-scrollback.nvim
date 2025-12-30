---@mod kitty-scrollback.kitty_commands
local ksb_tmux = require('kitty-scrollback.tmux_commands')
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

---@param get_text_args KsbKittyGetTextArguments
local function get_scrollback_cmd(get_text_args)
  local scrollback_cmd = ([[%s @ get-text --match="id:%s" %s]]):format(
    p.kitty_data.kitty_path,
    p.kitty_data.window_id,
    get_text_args.kitty
  )
  local sed_cmd = [[sed -E ]]
    .. [[-e 's/\r//g' ]] -- added to remove /r added by --add-wrap-markers, (--add-wrap-markers is used to add empty lines at end of screen)
    .. [[-e 's/$/\x1b[0m/g']] -- append all lines with reset to avoid unintended colors
  local flush_stdout_cmd = p.kitty_data.kitty_path .. [[ +runpy 'sys.stdout.flush()']]
  -- start to set title but do not complete see https://github.com/kovidgoyal/kitty/issues/719#issuecomment-952039731
  local start_set_title_cmd = 'printf "\x1b]2;"'
  local full_cmd = scrollback_cmd
    .. ' | '
    .. sed_cmd
    .. ' && '
    .. flush_stdout_cmd
    .. ' && '
    .. start_set_title_cmd

  if p.kitty_data.tmux and next(p.kitty_data.tmux) then
    scrollback_cmd = ksb_tmux.get_scrollback_cmd(get_text_args)
    full_cmd = scrollback_cmd .. ' | ' .. sed_cmd .. ' && ' .. start_set_title_cmd
  end

  return scrollback_cmd, full_cmd
end

local function defer_resize_term(min_cols)
  local orig_columns = vim.o.columns
  if vim.o.columns < min_cols then
    vim.defer_fn(function()
      vim.o.columns = min_cols
      vim.api.nvim_set_option_value('columns', min_cols, { scope = 'global' })
    end, 0)
  end
  return orig_columns
end

M.open_term_command = vim.fn.has('nvim-0.11') <= 0 and 'termopen' or 'jobstart'

---@param get_text_opts KsbKittyGetTextArguments
---@param on_exit_cb function
M.get_text_term = function(get_text_opts, on_exit_cb)
  local scrollback_cmd, full_cmd = get_scrollback_cmd(get_text_opts)
  local stdout
  local stderr
  local tail_max = 10

  -- increase the number of columns temporary so that the width is used during the
  -- terminal command kitty @ get-text. this avoids hard wrapping lines to the
  -- current window size. Note: a larger min_cols appears to impact performance
  -- defer is used as a timing workaround because this is expected to be called right before
  -- opening the terminal
  p.orig_columns = defer_resize_term(opts.scrollback_buffer_cols)

  -- set the shell used to sh to avoid imcompatabiliies with other shells (e.g., nushell, fish, etc)
  vim.o.shell = 'sh'

  local open_term_fn = vim.fn[M.open_term_command]
  local open_term_options = {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      stdout = data
    end,
    on_stderr = function(_, data)
      stderr = data
    end,
    on_exit = function(id, exit_code, event)
      -- NOTE(#58): nvim v0.9 support
      -- vim.o.columns is resized automatically in nvim v0.9.1 when we trigger kitty so send a SIGWINCH signal
      -- vim.o.columns is explicitly set to resize appropriately on v0.9.0
      -- see https://github.com/neovim/neovim/pull/23503
      vim.o.columns = p.orig_columns
      if exit_code == 0 then
        -- no need to check allow_remote_control or dev/tty because earlier commands would have reported the error
        if #stdout >= 2 then
          -- the exit code may have been lost while piping the command through sed
          -- so search last lines for and error reported by Kitty
          local error_index = -1
          local tail_diff = #stdout - tail_max
          local tail_count = tail_diff < 1 and 1 or math.min(tail_diff, #stdout)
          for i = #stdout, tail_count, -1 do
            -- see for match kitty/tools/cli/markup/prettify.go ans.Err = fmt_ctx.SprintFunc("bold fg=bright-red") -- cspell:disable-line
            if stdout[i]:match([[^\x1b%[1;91mError\x1b%[221;39m: .*]]) then
              error_index = i
              break
            end
          end

          if error_index > 0 then
            ksb_util.display_cmd_error(scrollback_cmd, {
              entrypoint = 'open_term_fn() :: exit_code = 0 and error_index > 0',
              full_cmd = full_cmd,
              code = 1, -- exit code is not returned through pipe but we can assume 1 due to error message
              channel_id = id,
              stdout = table.concat(
                vim.tbl_map(function(line)
                  return line
                    :gsub('[\27\155][][()#:;?%d]*[A-PRZcf-ntqry=><~]', '')
                    :gsub([[\x1b\\]], '')
                    :gsub(';k=s', '')
                end, stdout),
                '\n'
              ),
              stderr = stderr and table.concat(stderr, '\n') or nil,
            }, error_header)
          end
        end
        on_exit_cb(id, exit_code, event)
      else
        local out = stdout
            and table
              .concat(stdout, '\n', math.max(#stdout - tail_max, 1), #stdout)
              :gsub('[\27\155][][()#:;?%d]*[A-PRZcf-ntqry=><~]', '')
              :gsub([[\x1b\\]], '')
              :gsub(';k=s', '')
          or nil
        ksb_util.display_cmd_error(full_cmd, {
          entrypoint = 'open_term_fn() :: exit_code ~= 0',
          code = exit_code,
          channel_id = id,
          stdout = out,
          stderr = stderr and table.concat(stderr, '\n') or nil,
        }, error_header)
      end
    end,
  }
  if M.open_term_command == 'jobstart' then
    open_term_options.term = true
  end

  local success, error = pcall(open_term_fn, full_cmd, open_term_options)
  if not success then
    ksb_util.display_cmd_error(full_cmd, {
      entrypoint = 'open_term_fn() :: pcall(open_term_fn) error returned',
      stderr = error or nil,
    }, error_header)
  end

  -- restore the original shell after processing
  vim.o.shell = p.orig_options.shell
end

M.send_lines_to_kitty_and_quit = function(lines, execute_command)
  local bracketed_paste = 'auto' -- used only if the program running in the window has turned on bracketed paste mode

  -- convert table to string separated by carriage returns
  local cmd_str = table.concat(
    vim.tbl_filter(function(l)
      return #l > 0 -- remove empty lines
    end, lines),
    '\r'
  )
  cmd_str = cmd_str

  ksb_util.system_handle_error({
    p.kitty_data.kitty_path,
    '@',
    'send-text',
    '--match=id:' .. p.kitty_data.window_id,
    '--bracketed-paste=' .. bracketed_paste,
    cmd_str,
  }, error_header)

  if execute_command then
    -- add a carriage return to execute command
    cmd_str = '\r'
    bracketed_paste = 'disable'
  else
    cmd_str = ''
  end

  ksb_util.system_handle_error({
    p.kitty_data.kitty_path,
    '@',
    'send-text',
    '--match=id:' .. p.kitty_data.window_id,
    '--bracketed-paste=' .. bracketed_paste,
    cmd_str,
  }, error_header)

  ksb_util.quitall()
end

M.send_paste_buffer_text_to_kitty_and_quit = function(execute_command)
  local paste_buffer_lines = vim.api.nvim_buf_get_lines(p.paste_bufid, 0, -1, false)
  M.send_lines_to_kitty_and_quit(paste_buffer_lines, execute_command)
end

M.list_kitty_windows = function()
  return ksb_util.system_handle_error({
    p.kitty_data.kitty_path,
    '@',
    'ls',
  }, error_header)
end

M.close_kitty_loading_window = function(ignore_error)
  if p and p.kitty_loading_winid then
    local winid = p.kitty_loading_winid
    p.kitty_loading_winid = nil
    return ksb_util.system_handle_error({
      p.kitty_data.kitty_path,
      '@',
      'close-window',
      '--match=id:' .. winid,
    }, error_header, {}, ignore_error)
  end
  return true
end

M.signal_winchanged_to_kitty_child_process = function()
  ksb_util.system_handle_error({
    p.kitty_data.kitty_path,
    '@',
    'signal-child',
    'SIGWINCH',
  }, error_header)
end

M.open_kitty_loading_window = function(env)
  if p.kitty_loading_winid then
    M.close_kitty_loading_window(true)
  end
  local kitty_cmd = vim.list_extend({
    p.kitty_data.kitty_path,
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
  local ok, result = ksb_util.system_handle_error(kitty_cmd, error_header)
  if ok then
    p.kitty_loading_winid = tonumber(result.stdout)
  end
end

M.get_kitty_colors = function(kitty_data, ignore_error, no_window_id)
  local match = no_window_id and nil or '--match=id:' .. kitty_data.window_id
  local ok, result = ksb_util.system_handle_error({
    p.kitty_data.kitty_path,
    '@',
    'get-colors',
    match,
  }, error_header, { text = true }, ignore_error)
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
  return ksb_util.system_handle_error(
    {
      p.kitty_data.kitty_path,
      '+kitten',
      'clipboard',
      '/dev/stdin',
    },
    error_header,
    {
      stdin = text,
    }
  )
end

return M
