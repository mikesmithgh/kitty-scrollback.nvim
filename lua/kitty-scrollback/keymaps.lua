local ksb_footer_win = require('kitty-scrollback.footer_win')
local ksb_kitty_cmds = require('kitty-scrollback.kitty_commands')

---@type KsbPrivate
local p

---@type KsbOpts
local opts

local M = {}

M.setup = function(private, options)
  p = private
  opts = options

  if opts.keymaps_enabled then
    local set_default = function(modes, lhs, rhs, keymap_opts)
      for _, mode in pairs(modes) do
        if vim.fn.hasmapto(rhs, mode) == 0 then
          vim.keymap.set(mode, lhs, rhs, keymap_opts)
        end
      end
    end

    vim.keymap.set({ 'n' }, '<Plug>(KsbCloseOrQuitAll)', vim.schedule_wrap(function()
      if vim.api.nvim_get_current_buf() == p.bufid then
        vim.cmd.quitall({ bang = true })
        return
      end
      if vim.api.nvim_get_current_buf() == p.paste_bufid then
        vim.cmd.close({ bang = true })
        return
      end
    end), {})

    vim.keymap.set({ 'n', 't', 'i' }, '<Plug>(KsbQuitAll)', function() vim.cmd.quitall({ bang = true }) end, {})

    vim.keymap.set({ 'v' }, '<Plug>(KsbVisualYankLine)>', '"+Y', {})
    vim.keymap.set({ 'v' }, '<Plug>(KsbVisualYank)', '"+y', {})
    vim.keymap.set({ 'n' }, '<Plug>(KsbNormalYankEnd)', '"+y$', {})
    vim.keymap.set({ 'n' }, '<Plug>(KsbNormalYank)', '"+y', {})
    vim.keymap.set({ 'n' }, '<Plug>(KsbYankLine)', '"+yy', {})



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
end

M.set_buffer_local_keymaps = function(bufid)
  if not opts.keymaps_enabled then
    return
  end
  bufid = bufid or true
  vim.keymap.set({ 'n', 'i' }, '<Plug>(KsbExecuteCmd)', function()
    if vim.api.nvim_get_current_buf() == p.paste_bufid then
      ksb_kitty_cmds.send_paste_buffer_text_to_kitty_and_quit(false)
    end
  end, {
    buffer = bufid,
  })
  vim.keymap.set({ 'n', 'i' }, '<Plug>(KsbPasteCmd)', function()
    if vim.api.nvim_get_current_buf() == p.paste_bufid then
      ksb_kitty_cmds.send_paste_buffer_text_to_kitty_and_quit(true)
    end
  end, {
    buffer = bufid,
  })

  vim.keymap.set({ 'n' }, '<Plug>(KsbToggleFooter)', function()
    if vim.api.nvim_get_current_buf() == p.paste_bufid then
      if p.footer_winid then
        pcall(vim.api.nvim_win_close, p.footer_winid, true)
        p.footer_winid = nil
      else
        local winopts = vim.api.nvim_win_get_config(p.paste_winid)
        vim.schedule_wrap(ksb_footer_win.open_footer_window)(winopts)
      end
      vim.schedule_wrap(vim.cmd.doautocmd)('WinResized')
      return
    end
  end, {
    buffer = bufid
  })
end

return M
