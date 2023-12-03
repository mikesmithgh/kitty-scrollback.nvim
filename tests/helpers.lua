local M = {}
local current_tmpsocket

M.setup_backport = function()
  if vim.fn.has('nvim-0.10') <= 0 then
    vim.opt.runtimepath:append('/Users/mike/gitrepos/kitty-scrollback.nvim')
    require('kitty-scrollback.backport').setup()
  end
end

M.now = function()
  return vim.fn.strftime('%m-%d-%Y %H:%M:%S', vim.fn.localtime())
end

M.tempsocket = function()
  local tmpdir = vim.system({ 'mktemp', '-d' }):wait().stdout:gsub('\n', '')
  current_tmpsocket = tmpdir .. '/kitty-scrollback-nvim.sock'
  return current_tmpsocket
end

M.kitty_remote_cmd = function(tmpsock)
  return { 'kitty', '@', '--to', 'unix:' .. (tmpsock or current_tmpsocket) }
end

M.kitty_remote_get_text_cmd = function(args)
  return vim.list_extend(M.kitty_remote_cmd(), vim.list_extend({ 'get-text' }, args or {}))
end

M.kitty_remote_get_text = function(args, ...)
  return vim.system(M.kitty_remote_get_text_cmd(args or {}), ...):wait()
end

M.kitty_remote_send_text_cmd = function(txt)
  return vim.list_extend(M.kitty_remote_cmd(), { 'send-text', txt })
end

M.kitty_remote_send_text = function(txt, ...)
  return vim.system(M.kitty_remote_send_text_cmd(txt), ...):wait()
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
  return vim.system(M.kitty_remote_close_window_cmd()):wait()
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
  local kitten_args = vim.list_extend(
    { '/Users/mike/gitrepos/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py' },
    ksb_args or {}
  )
  return vim.list_extend(M.kitty_remote_kitten_cmd(), kitten_args)
end

M.kitty_remote_kitten_kitty_scrollback_nvim = function(ksb_args, ...)
  return vim.system(M.kitty_remote_kitten_kitty_scrollback_nvim_cmd(ksb_args), ...)
end

M.kitty_remote_kitten_kitty_scroll_prompt_cmd = function(direction, select_cmd_output)
  local kitten_args = {
    '/Users/mike/gitrepos/kitty-scrollback.nvim/python/kitty_scroll_prompt.py',
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
  local result = vim
    .system(M.kitty_remote_kitten_kitty_scroll_prompt_cmd(direction, select_cmd_output), ...)
    :wait()
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

M.feed_kitty = function(input)
  for _, line in pairs(input) do
    if line == 'pause' then
      M.pause()
    elseif line == '__open_ksb' then
      M.pause()
      M.kitty_remote_kitten_kitty_scrollback_nvim()
      M.pause()
    elseif line:match('^\\') then
      M.pause(0.2)
      M.kitty_remote_send_text(line)
      M.pause(0.2)
    else
      line:gsub('.', function(c)
        M.kitty_remote_send_text(c)
        M.pause(0.03)
      end)
    end
  end
  M.pause(1)
  return M.kitty_remote_get_text().stdout
end

M.assert_screen_equals = function(actual, expected, ...)
  assert(actual:gsub('%s*$', '') == expected:gsub('%s*$', ''), ...)
end

return M
