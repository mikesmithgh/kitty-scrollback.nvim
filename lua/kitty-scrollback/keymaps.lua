---@mod kitty-scrollback.keymaps
local ksb_api = require('kitty-scrollback.api')

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

local function set_defaults()
  set_default({ 'v' }, '<leader>Y', '<Plug>(KsbVisualYankLine)', {})
  set_default({ 'v' }, '<leader>y', '<Plug>(KsbVisualYank)', {})
  set_default({ 'n' }, '<leader>Y', '<Plug>(KsbNormalYankEnd)', {})
  set_default({ 'n' }, '<leader>y', '<Plug>(KsbNormalYank)', {})
  set_default({ 'n' }, '<leader>yy', '<Plug>(KsbYankLine)', {})

  set_default({ 'n' }, '<esc>', '<Plug>(KsbCloseOrQuitAll)', {})
  set_default({ 'n', 't', 'i' }, '<c-c>', '<Plug>(KsbQuitAll)', {})

  set_default({ 'n' }, 'g?', '<Plug>(KsbToggleFooter)', {})
  set_default({ 'n', 'i' }, '<c-cr>', '<Plug>(KsbExecuteCmd)', {})
  set_default({ 'n', 'i' }, '<s-cr>', '<Plug>(KsbPasteCmd)', {})
end

M.setup = function(private, options)
  p = private ---@diagnostic disable-line: unused-local
  opts = options ---@diagnostic disable-line: unused-local

  if opts.keymaps_enabled then
    vim.keymap.set(
      { 'n' },
      '<Plug>(KsbCloseOrQuitAll)',
      vim.schedule_wrap(ksb_api.close_or_quit_all),
      {}
    )
    vim.keymap.set({ 'n', 't', 'i' }, '<Plug>(KsbQuitAll)', ksb_api.quit_all, {})

    vim.keymap.set({ 'v' }, '<Plug>(KsbVisualYankLine)>', '"+Y', {})
    vim.keymap.set({ 'v' }, '<Plug>(KsbVisualYank)', '"+y', {})
    vim.keymap.set({ 'n' }, '<Plug>(KsbNormalYankEnd)', '"+y$', {})
    vim.keymap.set({ 'n' }, '<Plug>(KsbNormalYank)', '"+y', {})
    vim.keymap.set({ 'n' }, '<Plug>(KsbYankLine)', '"+yy', {})

    set_defaults()
  end
end

M.set_buffer_local_keymaps = function(bufid)
  if not opts.keymaps_enabled then
    return
  end
  bufid = bufid or true
  vim.keymap.set({ 'n', 'i' }, '<Plug>(KsbExecuteCmd)', ksb_api.execute_command, { buffer = bufid })
  vim.keymap.set({ 'n', 'i' }, '<Plug>(KsbPasteCmd)', ksb_api.paste_command, { buffer = bufid })
  vim.keymap.set({ 'n' }, '<Plug>(KsbToggleFooter)', ksb_api.toggle_footer, { buffer = bufid })
end

return M
