local M = {}
local current_tmpsocket
local assert = require('luassert.assert')

M.debug_enabled = vim.env.RUNNER_DEBUG == '1'
M.is_github_action = vim.env.GITHUB_ACTIONS == 'true'
M.is_headless = (#vim.api.nvim_list_uis() == 0)

--- @return any # given arguments.
M.debug = function(...)
  if M.debug_enabled then
    return vim.print(...)
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
local color_string = function(color, str)
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

M.ignore = function(desc, ...)
  print(color_string('yellow', 'Ignored'), '||', desc)
end

M.setup_backport = function()
  if vim.fn.has('nvim-0.10') <= 0 then
    require('kitty-scrollback.backport').setup()
  end
end

M.now = function()
  return vim.fn.strftime('%m-%d-%Y %H:%M:%S', vim.fn.localtime())
end

M.tempsocket = function(tmp_dir)
  local tmpdir = M.debug(
    vim.system(vim.list_extend({ 'mktemp', '-d' }, tmp_dir and { '-p', tmp_dir } or {})):wait()
  ).stdout
    :gsub('\n', '')
  current_tmpsocket = M.debug(tmpdir .. '/kitty-scrollback-nvim.sock')
  return current_tmpsocket
end

M.kitty_remote_cmd = function(tmpsock)
  return { 'kitty', '@', '--to', 'unix:' .. (tmpsock or current_tmpsocket) }
end

M.kitty_remote_get_text_cmd = function(args)
  return vim.list_extend(
    M.kitty_remote_cmd(),
    vim.list_extend({ 'get-text', '--add-cursor', '--extent=all' }, args or {})
  )
end

M.kitty_remote_get_text = function(args, ...)
  return M.debug(vim.system(M.debug(M.kitty_remote_get_text_cmd(args or {})), ...):wait())
end

M.kitty_remote_send_text_cmd = function(txt)
  return vim.list_extend(M.kitty_remote_cmd(), { 'send-text', txt })
end

M.kitty_remote_send_text = function(txt, ...)
  return M.debug(vim.system(M.kitty_remote_send_text_cmd(txt), ...):wait())
end

M.kitty_remote_set_title_cmd = function(title)
  return vim.list_extend(M.kitty_remote_cmd(), { 'set-window-title', title })
end

M.kitty_remote_set_title = function(title, ...)
  return vim.system(M.kitty_remote_set_title_cmd(title), ...)
end

M.kitty_remote_close_window_cmd = function()
  return vim.list_extend(M.kitty_remote_cmd(), { 'close-window' })
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
  return vim.list_extend(M.kitty_remote_cmd(), { 'kitten' })
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
  return vim.system(M.kitty_remote_kitten_kitty_scrollback_nvim_cmd(ksb_args), ...)
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

M.pause = function(delay)
  vim.uv.sleep((delay or 0.5) * 1000)
end

M.kitty_remote_kitten_kitty_scroll_prompt_and_pause = function(direction, select_cmd_output, ...)
  local result = M.debug(
    vim
      .system(M.kitty_remote_kitten_kitty_scroll_prompt_cmd(direction, select_cmd_output), ...)
      :wait()
  )
  M.pause(1)
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

M.ksb = function(config_type, ksb_args, opts)
  local o = opts or {}
  M.kitty_remote_kitten_kitty_scrollback_nvim(ksb_args)
  M.pause(o.before)
  if o.show_text == nil or o.show_text then
    M.kitty_remote_send_text([[a]])
    M.pause()
    M.kitty_remote_send_text(
      [[# ]] .. config_type .. [[ > kitty_scrollback_nvim ]] .. vim.fn.join(ksb_args or {}, ' ')
    )
    M.kitty_remote_send_text([[\e0]])
  end
  M.pause()
  if o.msg then
    M.pause()
    M.kitty_remote_send_text([[o]])
    M.pause()
    M.kitty_remote_send_text(o.msg)
    M.kitty_remote_send_text([[\egg0]])
  end
  M.pause(o.after or 4)
  if not o.keep_open then
    M.kitty_remote_close_window()
  end
  M.pause()
end

M.ksb_b = function(...)
  M.ksb('builtin', ...)
end

M.ksb_e = function(...)
  M.ksb('example', ...)
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

local next_as_line = false

M.feed_kitty = function(input)
  for _, line in pairs(input) do
    if line == 'pause' then
      M.pause()
    elseif line == '__open_ksb' then
      M.pause()
      M.kitty_remote_kitten_kitty_scrollback_nvim()
      M.pause()
    elseif line == '__next_as_line' then
      next_as_line = true
    elseif line:match('^\\') or next_as_line then
      M.pause(0.2)
      M.kitty_remote_send_text(line)
      M.pause(0.2)
      if next_as_line then
        next_as_line = false
      end
    else
      line:gsub('.', function(c)
        M.kitty_remote_send_text(c)
        M.pause(0.03)
      end)
    end
  end
  M.pause(3) -- longer pause for linux

  local stdout = M.debug(M.kitty_remote_get_text()).stdout
  local last_line = stdout:match('.*\n(.*)\n')
  local start_of_line, cursor_y, cursor_x =
    last_line:match('^(.*)\x1b%[%?25h\x1b%[(%d+);(%d+)H\x1b.*$')
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
        actual_result = actual_result .. color_string('red', actual:sub(i, i))
        expected_result = expected_result .. color_string('green', expected:sub(i, i))
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
      color_string(
        'red',
        '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
      )
    )
    print(color_string('green', 'Expected:'))
    print(expected_result)
    print(color_string('red', 'Actual:'))
    print(actual_result)
    print(
      color_string(
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

M.assert_screen_equals = function(actual, expected, ...)
  local actual_rstrip = actual.stdout:gsub('%s*\n', '\n')
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
  local actual_rstrip = actual.stdout:gsub('%s*\n', '\n'):sub(1, #expected_rstrip)
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
  local actual_rstrip = actual.stdout:gsub('%s*\n', '\n')
  M.debug({
    actual_stdout = actual.stdout,
    actual_stdout_rstrip = actual_rstrip,
    actual_stdout_length = #actual.stdout,
    actual_rstrip_length = #actual_rstrip,
    match = expected.pattern,
  })
  assert.is_true(actual_rstrip:match(expected.pattern), ...)
  assert.is_not_true(actual_rstrip:match(expected.pattern), ...)
  if expected.cursor_y then
    assert.are.equal(expected.cursor_y, actual.cursor_y, ...)
  end
  if expected.cursor_x then
    assert.are.equal(expected.cursor_x, actual.cursor_x, ...)
  end
end

M.assert_screen_not_match = function(actual, expected, ...)
  local actual_rstrip = actual.stdout:gsub('%s*\n', '\n')
  M.debug({
    actual_stdout = actual.stdout,
    actual_stdout_rstrip = actual_rstrip,
    actual_stdout_length = #actual.stdout,
    actual_rstrip_length = #actual_rstrip,
    match = expected,
  })
  assert.is_not_true(actual_rstrip:match(expected.pattern), ...)
  if expected.cursor_y then
    assert.are.equal(expected.cursor_y, actual.cursor_y, ...)
  end
  if expected.cursor_x then
    assert.are.equal(expected.cursor_x, actual.cursor_x, ...)
  end
end

return M
