---@mod kitty-scrollback.keymaps
local ksb_api = require('kitty-scrollback.api')
local ksb_util = require('kitty-scrollback.util')
local plug = ksb_util.plug_mapping_names

---@type KsbPrivate
local p ---@diagnostic disable-line: unused-local

---@type KsbOpts
local opts ---@diagnostic disable-line: unused-local

local M = {}

local function set_default(modes, lhs, rhs, keymap_opts)
  for _, mode in pairs(modes) do
    if vim.fn.hasmapto(rhs, mode) == 0 then
      vim.keymap.set(mode, lhs, rhs, keymap_opts)
    end
  end
end

local function set_global_defaults()
  set_default({ 'v' }, '<Leader>Y', plug.VISUAL_YANK_LINE, {})
  set_default({ 'v' }, '<Leader>y', plug.VISUAL_YANK, {})
  set_default({ 'n' }, '<Leader>Y', plug.NORMAL_YANK_END, {})
  set_default({ 'n' }, '<Leader>y', plug.NORMAL_YANK, {})
  set_default({ 'n' }, '<Leader>yy', plug.YANK_LINE, {})

  set_default({ 'v' }, '<LocalLeader>Y', plug.REMOVE_NEWLINE_VISUAL_YANK_LINE, {}) -- TODO
  set_default({ 'v' }, '<LocalLeader>y', plug.REMOVE_NEWLINE_VISUAL_YANK, {})
  set_default({ 'n' }, '<LocalLeader>Y', plug.REMOVE_NEWLINE_NORMAL_YANK_END, {}) -- TODO
  set_default({ 'n' }, '<LocalLeader>y', plug.REMOVE_NEWLINE_NORMAL_YANK, {}) -- TODO
  set_default({ 'n' }, '<LocalLeader>yy', plug.REMOVE_NEWLINE_YANK_LINE, {}) -- TODO

  set_default({ 'n' }, 'q', plug.CLOSE_OR_QUIT_ALL, {})
  set_default({ 'n', 't', 'i' }, '<c-c>', plug.QUIT_ALL, {})

  set_default({ 'v' }, '<C-CR>', plug.EXECUTE_VISUAL_CMD, {})
  set_default({ 'v' }, '<S-CR>', plug.PASTE_VISUAL_CMD, {})

  set_default({ 'v' }, '<LocalLeader><C-CR>', plug.REMOVE_NEWLINE_EXECUTE_VISUAL_CMD, {}) -- TODO
  set_default({ 'v' }, '<LocalLeader><S-CR>', plug.REMOVE_NEWLINE_PASTE_VISUAL_CMD, {})
end

local function set_local_defaults()
  set_default({ '' }, 'g?', plug.TOGGLE_FOOTER, {})
  set_default({ 'n', 'i' }, '<C-CR>', plug.EXECUTE_CMD, {})
  set_default({ 'n', 'i' }, '<S-CR>', plug.PASTE_CMD, {})
end

M.setup = function(private, options)
  p = private ---@diagnostic disable-line: unused-local
  opts = options

  if opts.keymaps_enabled then
    vim.keymap.set(
      { 'n' },
      plug.CLOSE_OR_QUIT_ALL,
      vim.schedule_wrap(ksb_api.close_or_quit_all),
      {}
    )
    vim.keymap.set({ 'n', 't', 'i' }, plug.QUIT_ALL, ksb_api.quit_all, {})

    vim.keymap.set({ 'v' }, plug.YANK_LINE, '"+Y', {})
    vim.keymap.set({ 'v' }, plug.VISUAL_YANK, '"+y', {})
    vim.keymap.set({ 'v' }, plug.REMOVE_NEWLINE_VISUAL_YANK, '"zy', {})
    vim.keymap.set({ 'v' }, plug.EXECUTE_VISUAL_CMD, ksb_api.execute_visual_command, {})
    vim.keymap.set({ 'v' }, plug.PASTE_VISUAL_CMD, ksb_api.paste_visual_command, {})
    vim.keymap.set(
      { 'v' },
      plug.REMOVE_NEWLINE_PASTE_VISUAL_CMD,
      ksb_api.remove_newline_paste_visual_command,
      {}
    )
    vim.keymap.set({ 'n' }, plug.NORMAL_YANK_END, '"+y$', {})
    vim.keymap.set({ 'n' }, plug.NORMAL_YANK, '"+y', {})
    vim.keymap.set({ 'n' }, plug.YANK_LINE, '"+yy', {})

    set_global_defaults()
  end
end

M.set_buffer_local_keymaps = function(bufid)
  if not opts.keymaps_enabled then
    return
  end
  bufid = bufid or true

  if opts.keymaps_enabled then
    set_local_defaults()
    vim.keymap.set({ 'n', 'i' }, plug.EXECUTE_CMD, ksb_api.execute_command, { buffer = bufid })
    vim.keymap.set({ 'n', 'i' }, plug.PASTE_CMD, ksb_api.paste_command, { buffer = bufid })
    vim.keymap.set({ '' }, plug.TOGGLE_FOOTER, ksb_api.toggle_footer, { buffer = bufid })
  end
end

return M
