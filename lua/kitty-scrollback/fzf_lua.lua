---@mod kitty-scrollback.fzf_lua
local M = {}

---@type KsbPrivate
local p
---@type KsbOpts
local opts ---@diagnostic disable-line: unused-local

local patched = false
local original_grep_curbuf
local original_lgrep_curbuf

local function is_tempfile_enabled()
  return opts
    and opts.scrollback_buffer
    and opts.scrollback_buffer.tempfile
    and opts.scrollback_buffer.tempfile.enabled
end

local function scrollback_bufid()
  if not p or not p.bufid or not vim.api.nvim_buf_is_valid(p.bufid) then
    return nil
  end
  return p.bufid
end

local function scrollback_winid()
  local bufnr = scrollback_bufid()
  if not bufnr then
    return nil
  end
  if
    p.winid
    and vim.api.nvim_win_is_valid(p.winid)
    and vim.api.nvim_win_get_buf(p.winid) == bufnr
  then
    return p.winid
  end
  local winids = vim.fn.win_findbuf(bufnr)
  return winids[1]
end

local function is_active_scrollback_tempfile_buffer()
  local bufnr = scrollback_bufid()
  return bufnr
    and is_tempfile_enabled()
    and p.scrollback_tempfile
    and vim.api.nvim_get_current_buf() == bufnr
end

local function refresh_scrollback_position(col)
  p.pos = {
    cursor_line = vim.fn.line('.'),
    buf_last_line = vim.fn.line('$'),
    win_first_line = vim.fn.line('w0'),
    win_last_line = vim.fn.line('w$'),
    col = math.max((col or 1) - 1, 0),
  }
end

local function jump_to_scrollback_match(selected, picker_opts)
  if not selected or not selected[1] then
    return
  end
  local bufnr = scrollback_bufid()
  if not bufnr then
    return
  end

  local ok_path, fzf_path = pcall(require, 'fzf-lua.path')
  if not ok_path then
    return
  end
  local entry = fzf_path.entry_to_file(selected[1], picker_opts)
  local lnum = math.max(1, entry.line or 1)
  local col = math.max(1, entry.col or 1)

  vim.schedule(function()
    local target_bufnr = scrollback_bufid()
    if not target_bufnr then
      return
    end

    local target_winid = scrollback_winid()
    if target_winid and vim.api.nvim_win_is_valid(target_winid) then
      p.winid = target_winid
      vim.api.nvim_set_current_win(target_winid)
      vim.api.nvim_win_call(target_winid, function()
        if vim.api.nvim_get_current_buf() ~= target_bufnr then
          vim.api.nvim_set_current_buf(target_bufnr)
        end
        pcall(vim.cmd.stopinsert)
        vim.fn.cursor(lnum, col)
        pcall(vim.cmd.normal, { 'zz', bang = true })
        refresh_scrollback_position(col)
      end)
    else
      pcall(vim.api.nvim_set_current_buf, target_bufnr)
      pcall(vim.cmd.stopinsert)
      vim.fn.cursor(lnum, col)
      refresh_scrollback_position(col)
    end

    pcall(vim.cmd.redraw)
  end)
end

local function wrap_grep_curbuf(orig_fn)
  return function(user_opts, ...)
    if not is_active_scrollback_tempfile_buffer() then
      return orig_fn(user_opts, ...)
    end

    user_opts = user_opts or {}
    user_opts.actions = vim.tbl_deep_extend('keep', user_opts.actions or {}, {
      enter = jump_to_scrollback_match,
    })
    return orig_fn(user_opts, ...)
  end
end

M.setup = function(private, options)
  p = private
  opts = options ---@diagnostic disable-line: unused-local

  if not is_tempfile_enabled() or patched then
    return
  end

  local ok, grep_provider = pcall(require, 'fzf-lua.providers.grep')
  if not ok then
    return
  end

  original_grep_curbuf = original_grep_curbuf or grep_provider.grep_curbuf
  original_lgrep_curbuf = original_lgrep_curbuf or grep_provider.lgrep_curbuf
  grep_provider.grep_curbuf = wrap_grep_curbuf(original_grep_curbuf)
  grep_provider.lgrep_curbuf = wrap_grep_curbuf(original_lgrep_curbuf)
  patched = true
end

return M
