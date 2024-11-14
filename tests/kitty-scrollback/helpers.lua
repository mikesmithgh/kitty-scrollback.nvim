local M = {}
local current_tmpsocket
local current_tmux_tmpsocket
local assert = require('luassert.assert')

M.kitty = 'kitty'
M.debug_enabled = vim.env.RUNNER_DEBUG == '1'
M.is_github_action = vim.env.GITHUB_ACTIONS == 'true'
M.is_headless = (#vim.api.nvim_list_uis() == 0)

--- @return any # given arguments.
M.debug = function(...)
  local first = select(1, ...)
  if M.debug_enabled or (first.code and first.code ~= 0) then
    print(vim.inspect(...))
    if first.code then
      assert.is.equal(first.code, 0)
    end
    return ...
  end
  return ...
end
M.debug({
  debug_enabled = M.debug_enabled,
  is_github_action = M.is_github_action,
})

-- copied from plenary.busted
local color_table = {
  yellow = 33,
  green = 32,
  red = 31,
}

-- copied from plenary.busted
M.color_string = function(color, str)
  if not M.is_headless then
    return '[' .. str .. ']'
  end

  return string.format(
    '%s[%sm%s%s[%sm',
    string.char(27),
    color_table[color] or 0,
    str,
    string.char(27),
    0
  )
end

---@diagnostic disable-next-line: unused-vararg
M.ignore = function(desc, ...)
  print(M.color_string('yellow', 'Ignored'), '||', desc)
end

M.setup_backport = function()
  if vim.fn.has('nvim-0.10') <= 0 then
    require('kitty-scrollback.backport').setup()
  end
end

M.now = function()
  return vim.fn.strftime('%m-%d-%Y %H:%M:%S', vim.fn.localtime())
end

M.temp_tmux_socket = function(tmp_dir)
  vim.fn.mkdir(tmp_dir, 'p')
  local tmpdir_proc = M.debug(
    vim.system(vim.list_extend({ 'mktemp', '-d' }, tmp_dir and { '-p', tmp_dir } or {})):wait()
  )
  if tmpdir_proc.code ~= 0 then
    print(vim.inspect(tmpdir_proc))
  end
  assert.is.equal(tmpdir_proc.code, 0)
  local tmpdir = tmpdir_proc.stdout:gsub('\n', '')
  current_tmux_tmpsocket = M.debug(tmpdir .. '/tmux.sock')
  return current_tmux_tmpsocket
end

M.tempsocket = function(tmp_dir)
  vim.fn.mkdir(tmp_dir, 'p')
  local tmpdir_proc = M.debug(
    vim.system(vim.list_extend({ 'mktemp', '-d' }, tmp_dir and { '-p', tmp_dir } or {})):wait()
  )
  if tmpdir_proc.code ~= 0 then
    print(vim.inspect(tmpdir_proc))
  end
  assert.is.equal(tmpdir_proc.code, 0)
  local tmpdir = tmpdir_proc.stdout:gsub('\n', '')
  current_tmpsocket = M.debug(tmpdir .. '/kitty-scrollback-nvim.sock')
  return current_tmpsocket
end

M.kitty_remote_cmd = function(tmpsock)
  return { 'kitty', '@', '--to', 'unix:' .. (tmpsock or current_tmpsocket) }
end

M.kitty_remote_get_text_cmd = function(args)
  return vim.list_extend(
    M.kitty_remote_cmd(),
    vim.list_extend({ 'get-text', '--match=recent:0', '--add-cursor', '--extent=all' }, args or {})
  )
end

M.kitty_remote_get_text = function(args, ...)
  return M.debug(vim.system(M.debug(M.kitty_remote_get_text_cmd(args or {})), ...):wait())
end

M.kitty_remote_send_text_cmd = function(txt)
  return vim.list_extend(M.kitty_remote_cmd(), { 'send-text', '--match=recent:0', txt })
end

M.kitty_remote_send_text = function(txt, ...)
  return M.debug(vim.system(M.debug(M.kitty_remote_send_text_cmd(txt)), ...):wait())
end

M.kitty_remote_set_title_cmd = function(title)
  return vim.list_extend(M.kitty_remote_cmd(), { 'set-window-title', title })
end

M.kitty_remote_set_title = function(title, ...)
  return vim.system(M.kitty_remote_set_title_cmd(title), ...)
end

M.kitty_remote_close_window_cmd = function()
  return vim.list_extend(M.kitty_remote_cmd(), { 'close-window', '--match=recent:0' })
end

M.kitty_remote_close_window = function()
  return M.debug(vim.system(M.kitty_remote_close_window_cmd()):wait())
end

M.kitty_remote_ls_cmd = function()
  return vim.list_extend(M.kitty_remote_cmd(), { 'ls' })
end

M.kitty_remote_ls = function()
  return vim.system(M.kitty_remote_ls_cmd())
end

M.kitty_remote_kitten_cmd = function()
  return vim.list_extend(M.kitty_remote_cmd(), { 'kitten', '--match=recent:0' })
end

M.kitty_remote_kitten_kitty_scrollback_nvim_cmd = function(ksb_args)
  local kitty_scrollback_nvim_kitten = vim.fn.fnamemodify(
    vim.api.nvim_get_runtime_file('python/kitty_scrollback_nvim.py', false)[1],
    ':p'
  )
  local kitten_args = vim.list_extend({ kitty_scrollback_nvim_kitten }, ksb_args or {})
  return vim.list_extend(M.kitty_remote_kitten_cmd(), kitten_args)
end

M.kitty_remote_kitten_kitty_scrollback_nvim = function(ksb_args, ...)
  return M.debug(
    vim.system(M.debug(M.kitty_remote_kitten_kitty_scrollback_nvim_cmd(ksb_args), ...)):wait()
  )
end

M.kitty_remote_kitten_kitty_scroll_prompt_cmd = function(direction, select_cmd_output)
  local kitty_scroll_prompt_kitten = vim.fn.fnamemodify(
    vim.api.nvim_get_runtime_file('python/kitty_scroll_prompt.py', false)[1],
    ':p'
  )
  local kitten_args = {
    kitty_scroll_prompt_kitten,
    direction or 0,
  }
  if select_cmd_output then
    table.insert(kitten_args, 'true')
  end
  return vim.list_extend(M.kitty_remote_kitten_cmd(), kitten_args)
end

M.kitty_remote_kitten_kitty_scroll_prompt = function(direction, select_cmd_output, ...)
  return vim.system(
    M.kitty_remote_kitten_kitty_scroll_prompt_cmd(direction, select_cmd_output),
    ...
  )
end

M.pause_seconds = function(delay)
  vim.uv.sleep((delay or 0.5) * 1000)
end

M.kitty_remote_kitten_kitty_scroll_prompt_and_pause = function(direction, select_cmd_output, ...)
  local result = M.debug(
    vim
      .system(M.kitty_remote_kitten_kitty_scroll_prompt_cmd(direction, select_cmd_output), ...)
      :wait()
  )
  M.pause_seconds(1)
  return result
end

M.move_forward_one_prompt = function()
  M.kitty_remote_kitten_kitty_scroll_prompt_and_pause(1)
end

M.move_backward_one_prompt = function()
  M.kitty_remote_kitten_kitty_scroll_prompt_and_pause(-1)
end

M.move_to_first_prompt = function()
  M.kitty_remote_kitten_kitty_scroll_prompt_and_pause(0)
  M.kitty_remote_kitten_kitty_scroll_prompt_and_pause(-3)
end

M.move_to_last_prompt = function()
  M.kitty_remote_kitten_kitty_scroll_prompt_and_pause(0)
  M.kitty_remote_kitten_kitty_scroll_prompt_and_pause(3)
end

M.ksb_builtin_last_visited_cmd_output_and_move_forward = function()
  M.ksb_b({ '--config', 'ksb_builtin_last_visited_cmd_output' }, {
    msg = [[
default configuration for the mousemap `ctrl+shift+right`

Show clicked command output in kitty-scrollback.nvim
]],
  })
  M.move_forward_one_prompt()
end

M.ksb_example_last_visited_cmd_output_plain_and_move_forward = function()
  M.ksb_b(
    { '--config', 'ksb_example_get_text_last_visited_cmd_output_plain' },
    { msg = [[
Show clicked command plaintext output in kitty-scrollback.nvim
]] }
  )
  M.move_forward_one_prompt()
end

M.with_pause_seconds_before = function(input, delay)
  if input == nil then
    input = ''
  end
  if type(input) == 'string' then
    return {
      input,
      opts = {
        pause_before = delay or true,
      },
    }
  else
    return {
      input[1],
      opts = vim.tbl_extend('force', input.opts, {
        pause_before = delay or true,
      }),
    }
  end
end

M.send_as_string = function(input)
  if input == nil then
    input = ''
  end
  if type(input) == 'string' then
    return {
      input,
      opts = {
        send_by = 'string',
      },
    }
  else
    return {
      input[1],
      opts = vim.tbl_extend('force', input.opts, {
        send_by = 'string',
      }),
    }
  end
end

M.send_without_newline = function(input)
  if input == nil then
    input = ''
  end
  if type(input) == 'string' then
    return {
      input,
      opts = {
        newline = false,
      },
    }
  else
    return {
      input[1],
      opts = vim.tbl_extend('force', input.opts, {
        newline = false,
      }),
    }
  end
end

M.open_kitty_scrollback_nvim = function(config)
  return {
    opts = {
      open_kitty_scrollback_nvim = config or true,
    },
  }
end

M.open_tmux_kitty_scrollback_nvim = function()
  return {
    opts = {
      open_tmux_kitty_scrollback_nvim = true,
    },
  }
end

M.control_enter = function()
  return {
    [[\x1b[13;5u]],
    opts = {
      send_by = 'string',
    },
  }
end

M.shift_enter = function()
  return {
    [[\x1b[13;2u]],
    opts = {
      send_by = 'string',
    },
  }
end

M.enter = function()
  return {
    [[\n]],
    opts = {
      send_by = 'string',
    },
  }
end

M.control_v = function()
  return {
    [[\x16]],
    opts = {
      send_by = 'string',
    },
  }
end

M.control_f = function()
  return {
    [[\x06]],
    opts = {
      send_by = 'string',
    },
  }
end

M.esc = function()
  return {
    [[\x1b]],
    opts = {
      send_by = 'string',
    },
  }
end

M.control_b = function()
  return {
    [[\x02]],
    opts = {
      send_by = 'string',
    },
  }
end

M.control_c = function()
  return {
    [[\x03]],
    opts = {
      send_by = 'string',
    },
  }
end

M.control_d = function()
  return {
    [[\x04]],
    opts = {
      send_by = 'string',
    },
  }
end

M.clear = function()
  return {
    [[\f]],
    opts = {
      send_by = 'string',
    },
  }
end

M.feed_kitty = function(input, pause_seconds_after)
  input = input or {}
  for _, line in pairs(input) do
    local feed_opts = vim.tbl_extend('force', {
      send_by = 'char',
      newline = true,
      open_kitty_scrollback_nvim = false,
      open_tmux_kitty_scrollback_nvim = false,
    }, (type(line) == 'table' and line.opts) and line.opts or {})

    if feed_opts.pause_before then
      if type(feed_opts.pause_before) == 'boolean' then
        M.pause_seconds()
      else
        M.pause_seconds(feed_opts.pause_before)
      end
    end

    local open_ksb = feed_opts.open_kitty_scrollback_nvim
    if open_ksb then
      M.pause_seconds()
      M.kitty_remote_kitten_kitty_scrollback_nvim(type(open_ksb) == 'table' and open_ksb or {})
      M.pause_seconds()
    elseif feed_opts.open_tmux_kitty_scrollback_nvim then
      M.pause_seconds()
      M.debug(M.kitty_remote_send_text(M.control_b()[1]))
      M.pause_seconds(0.03)
      M.debug(M.kitty_remote_send_text('['))
      M.pause_seconds()
    else
      local content = line
      if type(line) == 'table' then
        content = line[1]
      end

      if feed_opts.send_by == 'string' then
        M.pause_seconds(0.2)
        M.debug(M.kitty_remote_send_text(content))
        M.pause_seconds(0.2)
      elseif feed_opts.send_by == 'char' then
        content:gsub('.', function(c)
          M.debug(M.kitty_remote_send_text(c))
          M.pause_seconds(0.03)
        end)
      end
      if feed_opts.newline then
        M.debug(M.kitty_remote_send_text('\n'))
      end
    end
  end
  M.pause_seconds(pause_seconds_after or 3) -- longer pause for linux

  local stdout = M.kitty_remote_get_text().stdout
  local last_line = stdout:match('.*\n(.*)\n')
  local start_of_line, cursor_y, cursor_x =
    last_line:match('^(.*)\x1b%[%?25[hl]\x1b%[(%d+);(%d+)H\x1b.*$')

  if start_of_line == nil then
    print(M.color_string('red', 'last_line is ' .. last_line:gsub('\x1b', '^[')))
    assert.is_not_nil(start_of_line)
  end

  return {
    stdout = stdout:gsub('[^\n]*\n$', start_of_line .. '\n'),
    cursor_x = tonumber(cursor_x),
    cursor_y = tonumber(cursor_y),
  }
end

local function debug_print_differences(actual, expected)
  if M.debug_enabled then
    local minLength = math.min(#actual, #expected)
    local maxLength = math.max(#actual, #expected)

    local actual_result = ''
    local expected_result = ''

    for i = 1, minLength do
      if actual:sub(i, i) ~= expected:sub(i, i) then
        actual_result = actual_result .. M.color_string('red', actual:sub(i, i))
        expected_result = expected_result .. M.color_string('green', expected:sub(i, i))
      else
        actual_result = actual_result .. actual:sub(i, i)
        expected_result = expected_result .. expected:sub(i, i)
      end
    end

    for i = minLength + 1, maxLength do
      actual_result = actual_result .. string.format('[%s]', actual:sub(i, i))
      expected_result = expected_result .. string.format('[%s]', expected:sub(i, i))
    end

    print(
      M.color_string(
        'red',
        '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
      )
    )
    print(M.color_string('green', 'Expected:'))
    print(expected_result)
    print(M.color_string('red', 'Actual:'))
    print(actual_result)
    print(
      M.color_string(
        'red',
        '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
      )
    )
  end
end

M.with_status_win = function(scrollback_buffer, width, status_win)
  width = width or 114
  status_win = status_win or '󰄛 󰣐 '
  local _, _, first_line, rest = scrollback_buffer:find('(.-)\n(.*)')
  local first_line_with_status_win = first_line
    .. string.rep(' ', width - (#first_line + #status_win))
    .. status_win
  return first_line_with_status_win .. '\n' .. rest
end

M.replace_spinner_with_space = function(text)
  -- create a helper function because matching with [⠋⠙⠹⠸⠼⠴✔] replaces with three instances
  local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '✔' }
  for _, icon in ipairs(spinner) do
    text = text:gsub(icon, ' ')
  end
  return text
end

M.assert_screen_equals = function(actual, expected, ...)
  local actual_rstrip = M.replace_spinner_with_space(actual.stdout):gsub('%s*\n', '\n')
  local expected_rstrip = expected.stdout:gsub('%s*\n', '\n')
  M.debug({
    actual_stdout = actual.stdout,
    actual_stdout_rstrip = actual_rstrip,
    actual_stdout_length = #actual.stdout,
    actual_rstrip_length = #actual_rstrip,
    expected_stdout = expected.stdout,
    expected_stdout_rstrip = expected_rstrip,
    expected_length = #expected.stdout,
    expected_rstrip_length = #expected_rstrip,
  })
  if actual_rstrip ~= expected_rstrip then
    debug_print_differences(actual_rstrip, expected_rstrip)
  end
  assert.are.equal(expected_rstrip, actual_rstrip, ...)
  if expected.cursor_y then
    assert.are.equal(expected.cursor_y, actual.cursor_y, ...)
  end
  if expected.cursor_x then
    assert.are.equal(expected.cursor_x, actual.cursor_x, ...)
  end
end

M.assert_screen_starts_with = function(actual, expected, ...)
  local expected_rstrip = expected.stdout:gsub('%s*\n', '\n'):gsub('\n$', '')
  local actual_rstrip =
    M.replace_spinner_with_space(actual.stdout):gsub('%s*\n', '\n'):sub(1, #expected_rstrip)
  M.debug({
    actual_stdout = actual.stdout,
    actual_stdout_rstrip = actual_rstrip,
    actual_stdout_length = #actual.stdout,
    actual_rstrip_length = #actual_rstrip,
    expected_stdout = expected.stdout,
    expected_stdout_rstrip = expected_rstrip,
    expected_length = #expected.stdout,
    expected_rstrip_length = #expected_rstrip,
  })
  if actual_rstrip ~= expected_rstrip then
    debug_print_differences(actual_rstrip, expected_rstrip)
  end
  assert.are.equal(expected_rstrip, actual_rstrip, ...)
  if expected.cursor_y then
    assert.are.equal(expected.cursor_y, actual.cursor_y, ...)
  end
  if expected.cursor_x then
    assert.are.equal(expected.cursor_x, actual.cursor_x, ...)
  end
end

M.assert_screen_match = function(actual, expected, ...)
  local actual_rstrip = M.replace_spinner_with_space(actual.stdout):gsub('%s*\n', '\n')
  M.debug({
    actual_stdout = actual.stdout,
    actual_stdout_rstrip = actual_rstrip,
    actual_stdout_length = #actual.stdout,
    actual_rstrip_length = #actual_rstrip,
    match = expected.pattern,
  })
  assert.is_true(actual_rstrip:match(expected.pattern) ~= nil, ...)
  if expected.cursor_y then
    assert.are.equal(expected.cursor_y, actual.cursor_y, ...)
  end
  if expected.cursor_x then
    assert.are.equal(expected.cursor_x, actual.cursor_x, ...)
  end
end

M.assert_screen_not_match = function(actual, expected, ...)
  local actual_rstrip = M.replace_spinner_with_space(actual.stdout):gsub('%s*\n', '\n')
  M.debug({
    actual_stdout = actual.stdout,
    actual_stdout_rstrip = actual_rstrip,
    actual_stdout_length = #actual.stdout,
    actual_rstrip_length = #actual_rstrip,
    match = expected,
  })
  assert.is_true(actual_rstrip:match(expected.pattern) == nil, ...)
  if expected.cursor_y then
    assert.are.equal(expected.cursor_y, actual.cursor_y, ...)
  end
  if expected.cursor_x then
    assert.are.equal(expected.cursor_x, actual.cursor_x, ...)
  end
end

M.wait_for_kitty_remote_connection = function(
  kitty_cmd,
  tmpsock,
  kitty_opts,
  timeout,
  interval,
  retries
)
  if not retries then
    retries = 3
  end
  if not timeout then
    timeout = 15000
  end
  if not interval then
    interval = 500
  end
  local kitty_instance
  local ready
  local tmpsock_ftype
  for i = 1, retries, 1 do
    if i > 1 then
      print('Failed to start and connect to Kitty, retry attempt #' .. (i - 1))
      if not M.debug_enabled then
        print('Automatically enabling debug logging')
        M.debug_enabled = true
      end
    end
    M.debug('Kitty starting...')
    kitty_opts = vim.tbl_extend('force', {
      env = {
        KSB_DIR = M.ksb_dir(),
      },
    }, kitty_opts)
    kitty_instance = M.debug(vim.system(kitty_cmd, kitty_opts, function(obj)
      M.debug('Kitty exiting...')
      M.debug(obj)
    end))
    ready = false
    tmpsock_ftype = nil
    vim.fn.wait(timeout, function()
      tmpsock_ftype = vim.fn.getftype(tmpsock)
      ready = tmpsock_ftype == 'socket' and (M.debug(M.kitty_remote_ls():wait()).code == 0)
      return ready
    end, interval)
    if ready then
      break
    end
    kitty_instance:kill(9)
    kitty_instance = nil
    vim.fn.delete(vim.fn.fnamemodify(tmpsock, ':p'), 'rf')
    M.pause_seconds(i * 2)
  end

  -- additional logging to track down issues with flaky tests
  if not ready then
    local current_debug_enabled = M.debug_enabled
    M.debug_enabled = true
    ready = tmpsock_ftype == 'socket' and (M.debug(M.kitty_remote_ls():wait()).code == 0)
    M.debug(string.format("tmpsock: '%s', tmpsock_ftype: '%s'", tmpsock, tmpsock_ftype))
    M.debug_enabled = current_debug_enabled
  end

  assert.is.equal(
    tmpsock_ftype,
    'socket',
    tmpsock .. ' does not or exist or is not a socket: ' .. tmpsock_ftype .. ', exiting'
  )
  assert.is_true(ready, 'kitty is not ready for remote connections, exiting')
  M.pause_seconds()
  return kitty_instance
end

M.ksb_dir = function()
  return vim.fn.fnamemodify(
    vim.fn.fnamemodify(vim.api.nvim_get_runtime_file('lua/kitty-scrollback', false)[1], ':h:h'),
    ':p'
  )
end

M.init_nvim = function(config_override)
  local config_dir = vim.fn.fnamemodify(vim.fn.fnamemodify(vim.fn.stdpath('config'), ':h'), ':p')
  local nvim_config_dir = config_dir .. 'ksb-nvim-tests'
  local is_directory = vim.fn.isdirectory(nvim_config_dir) > 0
  if is_directory then
    vim.system({ 'rm', '-rf', nvim_config_dir }):wait()
  end
  vim.fn.mkdir(nvim_config_dir, 'p')
  local init_lua = nvim_config_dir .. '/init.lua'
  local example_lua = M.ksb_dir() .. [[tests/example.lua]]
  vim.uv.fs_copyfile(example_lua, init_lua)

  if config_override then
    local init_config = {}
    local example_config = vim.fn.readfile(example_lua)
    for _, line in pairs(example_config) do
      if string.match(line, [[^require%('kitty%-scrollback'%)%.setup]]) then
        break
      end
      table.insert(init_config, line)
    end
    table.insert(init_config, [[require('kitty-scrollback').setup(]])
    for line in config_override:gmatch('[^\r\n]+') do
      table.insert(init_config, line)
    end
    table.insert(init_config, [[)]])
    vim.fn.writefile(init_config, init_lua)
  end
end

return M
