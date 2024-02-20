---@mod kitty-scrollback.autocommands
local ksb_footer_win = require('kitty-scrollback.footer_win')
local ksb_hl = require('kitty-scrollback.highlights')
local ksb_kitty_cmds = require('kitty-scrollback.kitty_commands')
local ksb_util = require('kitty-scrollback.util')
local ksb_win = require('kitty-scrollback.windows')

local M = {}

---@type KsbPrivate
local p
---@type KsbOpts
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
    pattern = '*.ksb_pastebuf',
    callback = function(paste_event)
      if paste_event.buf == p.paste_bufid then
        ksb_kitty_cmds.send_paste_buffer_text_to_kitty_and_quit(false)
      end
    end,
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
    end,
  })
  vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    group = vim.api.nvim_create_augroup(
      'KittyScrollBackNvimScrollbackBufEnterError',
      { clear = true }
    ),
    pattern = { '*.ksb_errorbuf' },
    callback = function()
      ksb_kitty_cmds.close_kitty_loading_window(true)
    end,
  })
end

M.set_paste_window_resized_autocmd = function()
  vim.api.nvim_create_autocmd({ 'WinResized' }, {
    group = vim.api.nvim_create_augroup('KittyScrollBackNvimPasteWindowResized', { clear = true }),
    callback = function()
      if p.paste_winid then
        local lnum = (p.pos.cursor_line - p.pos.win_first_line - 1) + ksb_util.tab_offset()
        local col = p.pos.col + 1
        local ok, current_winopts = pcall(vim.api.nvim_win_get_config, p.paste_winid)
        if ok then
          local height_offset = 0
          if not p.footer_winid then
            height_offset = 3
          end
          pcall(
            vim.api.nvim_win_set_config,
            p.paste_winid,
            ksb_win.paste_winopts(lnum, col, height_offset)
          )
          vim.schedule(function()
            local cur_winopts = ksb_footer_win.footer_winopts(current_winopts)
            pcall(vim.api.nvim_win_set_config, p.footer_winid, cur_winopts)
            if
              opts.callbacks
              and opts.callbacks.after_paste_window_ready
              and type(opts.callbacks.after_paste_window_ready) == 'function'
            then
              local paste_window_data = {
                scrollback_buffer = { bufid = p.bufid, winid = p.winid },
                paste_window = { bufid = p.paste_bufid, winid = p.paste_winid },
                paste_window_footer = { bufid = p.footer_bufid, winid = p.footer_winid },
              }
              opts.callbacks.after_paste_window_ready(paste_window_data, p.kitty_data, opts)
            end
            ksb_footer_win.open_footer_window(cur_winopts, true)
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
      end
    end,
  })
end

M.set_colorscheme_autocmd = function()
  vim.api.nvim_create_autocmd({ 'Colorscheme' }, {
    group = vim.api.nvim_create_augroup('KittyScrollBackNvimColorscheme', { clear = true }),
    callback = ksb_hl.set_highlights,
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

      if yankevent.regname == '+' then
        if vim.fn.has('clipboard') > 0 then
          -- Contents should be copied to clipboard, return to Kitty
          local clipboard_tool = vim.api.nvim_call_function('provider#clipboard#Executable', {})
          local defer_ms = 0
          if clipboard_tool == 'xclip' then
            -- The xclip child process was not spawning quick enough in the TextYankPost autocommand, resulting
            -- in content not being copied to the clipboard so add a delay
            -- see issue https://github.com/astrand/xclip/issues/38#ref-commit-b042f6d
            defer_ms = 200
          end
          vim.defer_fn(function()
            ksb_util.quitall()
          end, defer_ms)
        else
          vim.schedule(function()
            local prompt_msg =
              'kitty-scrollback.nvim: Error, failed to find clipboard tool. See :help clipboard-tool'
            vim.cmd.execute([['silent noautocmd keepalt edit ]] .. vim.o.helpfile .. [[']]) -- logic from :help help-curwin
            vim.o.conceallevel = 2
            vim.o.concealcursor = 'n'
            vim.api.nvim_set_option_value(
              'buftype',
              'help',
              { buf = vim.api.nvim_get_current_buf() }
            )
            vim.api.nvim_set_option_value(
              'filetype',
              'help',
              { buf = vim.api.nvim_get_current_buf() }
            )
            vim.cmd.help('clipboard-tool')
            ksb_util.restore_and_redraw()
            local response = vim.fn.confirm(prompt_msg, '&Quit\n&Continue')
            if response ~= 2 then
              ksb_util.quitall()
            end
          end)
        end
        return
      end

      -- send contents to paste window
      if
        opts.paste_window.yank_register_enabled
        and yankevent.regname == opts.paste_window.yank_register
      then
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
    end,
  })
end

return M
