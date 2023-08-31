---@mod kitty-scrollback.autocommands
local ksb_kitty_cmds = require('kitty-scrollback.kitty_commands')
local ksb_win = require('kitty-scrollback.windows')
local ksb_footer_win = require('kitty-scrollback.footer_win')
local ksb_util = require('kitty-scrollback.util')
local ksb_hl = require('kitty-scrollback.highlights')

local M = {}

local p
local opts ---@diagnostic disable-line: unused-local

M.setup = function(private, options)
  p = private
  opts = options ---@diagnostic disable-line: unused-local
end

M.load_autocmds = function()
  M.set_term_enter_autocmd(p.bufid)
  M.set_yank_post_autocmd()
  M.set_paste_window_resized_autocmd()
  M.set_paste_buffer_write_autocmd()
  M.set_scrollback_buffer_enter_autocmd()
  M.set_colorscheme_autocmd()
  M.set_paste_window_closed()
end

M.set_paste_buffer_write_autocmd = function()
  vim.api.nvim_create_autocmd({ 'BufWriteCmd' }, {
    group = vim.api.nvim_create_augroup('KittyScrollBackNvimPasteBufWriteCmd', { clear = true }),
    callback = function(paste_event)
      if paste_event.buf == p.paste_bufid then
        ksb_kitty_cmds.send_paste_buffer_text_to_kitty_and_quit(true)
      end
    end
  })
end

M.set_scrollback_buffer_enter_autocmd = function()
  vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    group = vim.api.nvim_create_augroup('KittyScrollBackNvimScrollbackBufEnter', { clear = true }),
    callback = function(e)
      if e.buf == p.bufid then
        pcall(vim.api.nvim_win_close, p.paste_winid, true)
        pcall(vim.api.nvim_win_close, p.footer_winid, true)
      end
    end
  })
end

M.set_paste_window_resized_autocmd = function()
  vim.api.nvim_create_autocmd({ 'WinResized' }, {
    group = vim.api.nvim_create_augroup('KittyScrollBackNvimPasteWindowResized', { clear = true }),
    callback = function()
      if p.paste_winid then
        local lnum = p.pos.cursor_line - p.pos.win_first_line - 1
        local col = p.pos.col + 1
        local ok, current_winopts = pcall(vim.api.nvim_win_get_config, p.paste_winid)
        if ok then
          local height_offset = 0
          if not p.footer_winid then
            height_offset = 3
          end
          pcall(vim.api.nvim_win_set_config, p.paste_winid, ksb_win.paste_winopts(lnum, col, height_offset))
          vim.schedule(function()
            local len_winopts = ksb_footer_win.footer_winopts(current_winopts)
            pcall(vim.api.nvim_win_set_config, p.footer_winid, len_winopts)
            ksb_footer_win.open_footer_window(len_winopts, true)
          end)
        end
      end
    end,
  })
end

M.set_paste_window_closed = function()
  -- could have multiple paste windows due to opening and closing, so pass as a parameter
  vim.api.nvim_create_autocmd('WinClosed', {
    group = vim.api.nvim_create_augroup('KittyScrollBackNvimPasteWindowClosed', { clear = true }),
    pattern = '*',
    callback = function(e)
      if e.match == tostring(p.paste_winid) then
        pcall(vim.api.nvim_win_close, p.footer_winid, true)
      end
    end,
  })
end


M.set_term_enter_autocmd = function(bufid)
  vim.api.nvim_create_autocmd({ 'TermEnter' }, {
    group = vim.api.nvim_create_augroup('KittyScrollBackNvimTermEnter', { clear = true }),
    callback = function(e)
      if e.buf == bufid then
        ksb_win.open_paste_window(true)

        -- when performing last cmd or visited output, every time termenter is triggered it
        -- is restoring the process exited message, this may be a bug in neovim
        vim.fn.timer_start(20, function(t) ---@diagnostic disable-line: redundant-parameter
          if ksb_util.remove_process_exited() then
            vim.fn.timer_stop(t)
          end
        end, {
          ['repeat'] = 100,
        })
      end
    end
  })
end

M.set_colorscheme_autocmd = function()
  vim.api.nvim_create_autocmd({ 'Colorscheme' }, {
    group = vim.api.nvim_create_augroup('KittyScrollBackNvimColorscheme', { clear = true }),
    callback = ksb_hl.set_highlights
  })
end

M.set_yank_post_autocmd = function()
  vim.api.nvim_create_autocmd({ 'TextYankPost' }, {
    group = vim.api.nvim_create_augroup('KittyScrollBackNvimTextYankPost', { clear = true }),
    pattern = '*',
    callback = function(e)
      local yankevent = vim.v.event
      if yankevent.operator ~= 'y' then
        return
      end

      -- contents are copied to clipboard, return to kitty
      if yankevent.regname == '+' then
        -- xclip on linux may take longer to copy contents add a delay before quitting to workaround
        -- TODO: could copy contents with kitty remote command as well
        vim.defer_fn(function()
          vim.cmd.quitall({ bang = true })
        end, 100)
        return
      end

      -- send contents to paste window
      if yankevent.regname == '' then
        if e.buf ~= p.bufid then
          return
        end

        local contents = {}
        for _, line in pairs(yankevent.regcontents) do
          line = line:gsub('%s+$', '')
          table.insert(contents, line)
        end
        if type(contents) == 'table' then
          vim.schedule(function()
            ksb_win.open_paste_window()
            vim.fn.cursor({ vim.fn.line('$'), 0 })
            local lastline = vim.fn.search('.', 'bnc')
            if lastline > 0 then
              table.insert(contents, 1, '')
            end
            vim.api.nvim_buf_set_lines(p.paste_bufid, lastline, lastline, false, contents)
          end)
        end
      end
    end
  })
end

return M
