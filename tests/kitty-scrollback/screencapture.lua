local h = require('tests.kitty-scrollback.helpers')

local M = {
  screencapture_count = -1,
  record_enabled = vim.env.KSB_RECORD_DEMO == 'true',
  screencapture_jobid = nil,
}

M.wrap_it = function(it, tmpsock, start)
  if start then
    M.screencapture_count = start
  end
  return function(description, fn)
    it(description, function()
      M.with_socket(tmpsock)
      M.start(description)
      fn()
      M.stop()
    end)
  end
end

M.with_socket = function(socket)
  if not M.record_enabled then
    return
  end
  M.tmpsock = socket
  local kitty_win_pid =
    vim.system({ 'pgrep', '-f', 'listen-on=unix:' .. socket }):wait().stdout:gsub('\n', '')
  local pdubs_stdout = vim.system({ 'pdubs', kitty_win_pid }):wait().stdout
  ---@diagnostic disable-next-line: param-type-mismatch
  M.window_info = vim.json.decode(pdubs_stdout)[1].kCGWindowBounds
end

M.start_at = function(start)
  M.screencapture_count = start
end

M.start = function(name)
  if not M.record_enabled then
    return
  end
  M.screencapture_count = M.screencapture_count + 1

  local fname = '../kitty-scrollback.nvim.wiki/assets/kitty_scrollback_screencapture_'
    .. string.format('%02d', M.screencapture_count)
    .. '_'
    .. name
    .. '.mov'
  print('Recording screencapture to ' .. vim.fn.fnamemodify(fname, ':p'))

  local screencapture_cmd = {
    'screencapture',
    '-R'
      .. M.window_info.X
      .. ','
      .. M.window_info.Y
      .. ','
      .. M.window_info.Width
      .. ','
      .. M.window_info.Height,
    '-x',
    '-o',
    '-v',
    fname,
  }
  vim.fn.delete(fname)
  M.screencapture_jobid = vim.fn.jobstart(screencapture_cmd)
  h.pause_seconds(1.5)
end

M.stop = function()
  if not M.record_enabled then
    return
  end
  if M.screencapture_jobid then
    h.pause_seconds()
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.uv.kill(vim.fn.jobpid(M.screencapture_jobid), 'sigint')
    M.screencapture_jobid = nil
    h.pause_seconds()
  end
end

return M
