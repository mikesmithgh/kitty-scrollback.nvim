local ksb_win = require('kitty-scrollback.windows')
local ksb_kitty_cmds = require('kitty-scrollback.kitty_commands')

local M = {}

M.setup = function(p, opts)
  if opts.keymaps_enabled then
    vim.keymap.set('n', '<esc>', function()
      if vim.api.nvim_get_current_buf() == p.bufid then
        vim.cmd.quitall({ bang = true })
        return
      end
      if vim.api.nvim_get_current_buf() == p.paste_bufid then
        vim.cmd.close({ bang = true })
        return
      end
      return '<esc>'
    end)
    vim.keymap.set({ 'n', 't' }, '<c-c>', function() vim.cmd.quitall({ bang = true }) end)
    vim.keymap.set({ 'n', 'i' }, '<c-cr>', function()
      if vim.api.nvim_get_current_buf() == p.paste_bufid then
        ksb_kitty_cmds.send_paste_buffer_text_to_kitty_and_quit(false)
        return
      end
      return '<c-cr>'
    end)
    vim.keymap.set({ 'n', 'i' }, '<s-cr>', function()
      if vim.api.nvim_get_current_buf() == p.paste_bufid then
        ksb_kitty_cmds.send_paste_buffer_text_to_kitty_and_quit(true)
        return
      end
      return '<s-cr>'
    end)
    vim.keymap.set({ 'v' }, '<leader>Y', '"+Y', {})
    vim.keymap.set({ 'v' }, '<leader>y', '"+y', {})
    vim.keymap.set({ 'n' }, '<leader>Y', '"+y$', {})
    vim.keymap.set({ 'n' }, '<leader>y', '"+y', {})
    vim.keymap.set({ 'n' }, '<leader>yy', '"+yy', {})

    vim.keymap.set({ 'n' }, 'g?', function()
      if vim.api.nvim_get_current_buf() == p.paste_bufid then
        if p.legend_winid then
          pcall(vim.api.nvim_win_close, p.legend_winid, true)
          p.legend_winid = nil
        else
          local winopts = vim.api.nvim_win_get_config(p.paste_winid)
          vim.schedule_wrap(ksb_win.open_legend_window)(winopts)
        end
        vim.schedule_wrap(vim.cmd.doautocmd)('WinResized')
        return
      end
      return 'g?'
    end)
  end
end

return M
