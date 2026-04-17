local M = {}

local fzf_lua_actions = require('fzf-lua.actions')

local orig = {
  act = fzf_lua_actions.act,
}

local ksb_act = function(selected, opts)
  -- there appears to be a race condition where we enter into insert mode incorrectly causing issues with kitty-scrollback.nvim
  vim.defer_fn(function()
    orig.act(selected, opts)
  end, 50)
end

M.setup = function()
  fzf_lua_actions.act = ksb_act
end

M.use_tempfile = function(bufid, buf_name)
  -- the temporary file is deleted by Neovim on exit, see :h tempdir
  local tmpfile =
    vim.fs.joinpath(vim.fn.fnamemodify(vim.fn.tempname(), ':h'), vim.fn.fnamemodify(buf_name, ':t'))
  local lines = vim.api.nvim_buf_get_lines(bufid, 0, -1, false)
  vim.fn.writefile(lines, tmpfile)
  vim.api.nvim_buf_set_name(bufid, tmpfile)
end

return M
