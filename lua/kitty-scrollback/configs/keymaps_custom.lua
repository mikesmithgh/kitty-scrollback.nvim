local M = {}

M.config = function(kitty_data)
  vim.keymap.set({ 'v' }, 'sY', '<Plug>(KsbVisualYankLine)', {})
  vim.keymap.set({ 'v' }, 'sy', '<Plug>(KsbVisualYank)', {})
  vim.keymap.set({ 'n' }, 'sY', '<Plug>(KsbNormalYankEnd)', {})
  vim.keymap.set({ 'n' }, 'sy', '<Plug>(KsbNormalYank)', {})
  vim.keymap.set({ 'n' }, 'syy', '<Plug>(KsbYankLine)', {})

  vim.keymap.set({ 'n' }, 'q', '<Plug>(KsbCloseOrQuitAll)', {})
  vim.keymap.set({ 'n', 't', 'i' }, 'ZZ', '<Plug>(KsbQuitAll)', {})

  vim.keymap.set({ 'n' }, '<tab>', '<Plug>(KsbToggleFooter)', {})
  vim.keymap.set({ 'n', 'i' }, '<cr>', '<Plug>(KsbExecuteCmd)', {})
  vim.keymap.set({ 'n', 'i' }, '<c-v>', '<Plug>(KsbPasteCmd)', {})
end

return M
