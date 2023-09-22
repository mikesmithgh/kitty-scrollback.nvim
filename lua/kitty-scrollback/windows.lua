---@mod kitty-scrollback.windows
local ksb_footer_win = require('kitty-scrollback.footer_win')
local ksb_keymaps = require('kitty-scrollback.keymaps')
local ksb_util = require('kitty-scrollback.util')
local M = {}

---@type KsbPrivate
local p

---@type KsbOpts
local opts ---@diagnostic disable-line: unused-local

M.setup = function(private, options)
  p = private
  opts = options ---@diagnostic disable-line: unused-local
end

-- copied from https://github.com/folke/lazy.nvim/blob/dac844ed617dda4f9ec85eb88e9629ad2add5e05/lua/lazy/view/float.lua#L70
M.size = function(max, value)
  return value > 1 and math.min(value, max) or math.floor(max * value)
end

M.paste_winopts = function(row, col, height_offset)
  local target_height =
    math.floor(M.size(vim.o.lines, math.floor(M.size(vim.o.lines, (vim.o.lines + 2) / 3))))
  local line_height_diff = vim.o.lines - row - target_height - 5 -- TODO: magic number, 3 for footer and 2 for border
  if line_height_diff < 0 then
    target_height = target_height - math.abs(line_height_diff)
    if target_height <= 10 + 2 then -- TODO: magic number 2 for border
      target_height = M.size(vim.o.lines - 3, 10) -- TODO: magic number, 3 for footer
    end
    row = vim.o.lines - 5 - target_height -- TODO: magic number, 3 for footer and 2 for border
  end
  if vim.o.lines <= 5 then
    row = 0
    target_height = 1
  end
  local winopts = {
    relative = 'editor',
    zindex = 40,
    focusable = true,
    border = { '🭽', '▔', '🭾', '▕', '🭿', '▁', '🭼', '▏' },
    height = target_height + (height_offset or 0),
  }
  if row then
    winopts.row = row
  end
  if col then
    winopts.col = col
    winopts.width = M.size(vim.o.columns, vim.o.columns - col)
    if winopts.width < 0 then
      -- current line is larger than window, put window below current line
      vim.fn.setcursorcharpos({ vim.fn.line('.'), 0 })
      vim.cmd.redraw()
      winopts.width = vim.o.columns - 1
      winopts.col = 0
    end
  end

  if opts.paste_window.winopts_overrides then
    winopts =
      vim.tbl_deep_extend('force', winopts, opts.paste_window.winopts_overrides(winopts) or {})
  end

  return winopts
end

M.open_paste_window = function(start_insert)
  vim.cmd.stopinsert()

  if not p.pos then
    if opts.kitty_get_text.extent == 'screen' or opts.kitty_get_text.extent == 'all' then
      vim.notify(
        'kitty-scrollback.nvim: missing position with extent=' .. opts.kitty_get_text.extent,
        vim.log.levels.WARN,
        {}
      )
    end
    local last_nonempty_line = vim.fn.search('.', 'nb')
    p.pos = {
      cursor_line = last_nonempty_line + 3, -- TODO: magic number footer
      buf_last_line = vim.fn.line('$'),
      win_first_line = vim.fn.line('w0'),
      win_last_line = vim.fn.line('w$'),
      col = 0,
    }
  end

  vim.fn.cursor(p.pos.win_first_line, 1)
  local lnum = p.pos.cursor_line - p.pos.win_first_line - 1
  local col = p.pos.col + 1
  if not p.paste_bufid then
    p.paste_bufid = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_buf_set_name(p.paste_bufid, vim.fn.tempname() .. '.ksb_pastebuf')
    local ft = opts.paste_window.filetype or vim.fn.fnamemodify(vim.o.shell, ':t:r')
    vim.api.nvim_set_option_value('filetype', ft, {
      buf = p.paste_bufid,
    })
    ksb_keymaps.set_buffer_local_keymaps(p.paste_bufid)
  end
  if not p.paste_winid or vim.fn.win_id2win(p.paste_winid) == 0 then
    local winopts = M.paste_winopts(lnum, col)
    p.paste_winid = vim.api.nvim_open_win(p.paste_bufid, true, winopts)
    vim.api.nvim_set_option_value('scrolloff', 2, {
      win = p.paste_winid,
    })

    if not opts.paste_window.hide_footer then
      vim.schedule_wrap(ksb_footer_win.open_footer_window)(winopts)
    end

    vim.api.nvim_set_option_value(
      'winhighlight',
      'Normal:KittyScrollbackNvimPasteWinNormal,FloatBorder:KittyScrollbackNvimPasteWinFloatBorder,FloatTitle:KittyScrollbackNvimPasteWinFloatTitle',
      { win = p.paste_winid }
    )
    vim.api.nvim_set_option_value('winblend', opts.paste_window.winblend or 0, {
      win = p.paste_winid,
    })
  end
  if start_insert then
    vim.schedule(function()
      vim.fn.cursor(vim.fn.line('$', p.paste_winid), 1)
      vim.cmd.startinsert({ bang = true })
    end)
  end
  vim.cmd.redraw()
  vim.schedule_wrap(vim.cmd.doautocmd)('WinResized')
end

M.show_status_window = function()
  if opts.status_window.enabled then
    local kitty_icon = '󰄛'
    local love_icon = ''
    local vim_icon = ''
    local width = 9
    if opts.status_window.style_simple then
      kitty_icon = 'kitty-scrollback.nvim'
      love_icon = ''
      vim_icon = ''
      width = 25
    end
    local popup_bufid = vim.api.nvim_create_buf(false, true)
    local winopts = function()
      return {
        relative = 'editor',
        zindex = 39,
        style = 'minimal',
        focusable = false,
        width = M.size(p.orig_columns or vim.o.columns, width),
        height = 1,
        row = 0,
        col = vim.o.columns,
        border = 'none',
      }
    end

    local popup_winid = vim.api.nvim_open_win(
      popup_bufid,
      false,
      vim.tbl_deep_extend('force', winopts(), {
        noautocmd = true,
      })
    )
    vim.api.nvim_set_option_value('winhighlight', 'NormalFloat:KittyScrollbackNvimNormal', {
      win = popup_winid,
    })
    local count = 0
    local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏', '✔' }
    if opts.status_window.style_simple then
      spinner = { '-', '-', '\\', '\\', '|', '|', '/', '/', '-', '-', '*' }
    end
    vim.fn.timer_start(
      80,
      function(status_window_timer) ---@diagnostic disable-line: redundant-parameter
        count = count + 1
        local spinner_icon = count > #spinner and spinner[#spinner] or spinner[count]
        local fmt_msg = ' '
          .. spinner_icon
          .. ' '
          .. kitty_icon
          .. ' '
          .. love_icon
          .. ' '
          .. vim_icon
          .. ' '
        vim.defer_fn(function()
          if spinner_icon == '' then
            vim.fn.timer_stop(status_window_timer)
            fmt_msg = ' ' .. kitty_icon .. ' ' .. love_icon .. ' ' .. vim_icon .. ' '
            local ok, _ = pcall(vim.api.nvim_win_get_config, popup_winid)
            if ok then
              vim.schedule(function()
                pcall(
                  vim.api.nvim_win_set_config,
                  popup_winid,
                  vim.tbl_deep_extend('force', winopts(), {
                    width = M.size(p.orig_columns or vim.o.columns, winopts().width - 2),
                  })
                )
              end)
            end
          end
          vim.api.nvim_buf_set_lines(popup_bufid, 0, -1, false, {})
          vim.api.nvim_buf_set_lines(popup_bufid, 0, -1, false, {
            fmt_msg,
          })

          local nid = vim.api.nvim_create_namespace('scrollbacknvim')
          local startcol = 0
          local endcol = 0
          if spinner_icon ~= '' then
            endcol = #spinner_icon + 2
            vim.api.nvim_buf_set_extmark(popup_bufid, nid, 0, startcol, {
              hl_group = count >= #spinner and 'KittyScrollbackNvimReady'
                or 'KittyScrollbackNvimSpinner',
              end_col = endcol,
            })
          end
          if not opts.status_window.style_simple then
            startcol = endcol
            endcol = endcol + #kitty_icon + 1
            vim.api.nvim_buf_set_extmark(popup_bufid, nid, 0, startcol, {
              hl_group = 'KittyScrollbackNvimKitty',
              end_col = endcol,
            })
            startcol = endcol
            endcol = endcol + #love_icon + 1
            vim.api.nvim_buf_set_extmark(popup_bufid, nid, 0, startcol, {
              hl_group = 'KittyScrollbackNvimHeart',
              end_col = endcol,
            })
            startcol = endcol
            endcol = #fmt_msg
            vim.api.nvim_buf_set_extmark(popup_bufid, nid, 0, startcol, {
              hl_group = 'KittyScrollbackNvimVim',
              end_col = endcol,
            })
          end
          if opts.status_window.autoclose then
            if count > #spinner then
              vim.fn.timer_start(
                60,
                function(close_window_timer) ---@diagnostic disable-line: redundant-parameter
                  local ok, current_winopts = pcall(vim.api.nvim_win_get_config, popup_winid)
                  if not ok then
                    vim.fn.timer_stop(close_window_timer)
                    vim.fn.timer_stop(status_window_timer)
                    return
                  end
                  if current_winopts.width > 2 then
                    ok, _ = pcall(
                      vim.api.nvim_win_set_config,
                      popup_winid,
                      vim.tbl_deep_extend('force', winopts(), {
                        width = M.size(p.orig_columns or vim.o.columns, current_winopts.width - 1),
                      })
                    )
                    if not ok then
                      vim.fn.timer_stop(close_window_timer)
                      vim.fn.timer_stop(status_window_timer)
                      return
                    end
                  else
                    pcall(vim.api.nvim_win_close, popup_winid, true)
                    vim.fn.timer_stop(close_window_timer)
                    vim.fn.timer_stop(status_window_timer)
                  end
                end,
                {
                  ['repeat'] = -1,
                }
              )
            end
          else
            if count > #spinner then
              local hl_def = vim.api.nvim_get_hl(0, {
                name = 'KittyScrollbackNvimReady',
                link = false,
              })
              hl_def = next(hl_def) and hl_def or {} -- nvim_get_hl can return vim.empty_dict() so convert to lua table
              local fg_dec = hl_def.fg or 16777215 -- default to #ffffff
              local fg_hex = string.format('#%06x', fg_dec)
              local darken_hex = ksb_util.darken(fg_hex, 0.7)
              vim.api.nvim_set_hl(0, 'KittyScrollbackNvimReady', {
                fg = darken_hex,
              })
              if count > #spinner + (#spinner / 2) then
                spinner[#spinner] = ''
              end
            end
          end
        end, count > #spinner and 200 or 0)
      end,
      {
        ['repeat'] = -1,
      }
    )
    vim.api.nvim_create_autocmd('WinResized', {
      group = vim.api.nvim_create_augroup(
        'KittyScrollBackNvimStatusWindowResized',
        { clear = true }
      ),
      callback = function()
        local ok, current_winopts = pcall(vim.api.nvim_win_get_config, popup_winid)
        if not ok then
          return true
        end
        ok, _ = pcall(
          vim.api.nvim_win_set_config,
          popup_winid,
          vim.tbl_deep_extend('force', winopts(), {
            width = M.size(vim.o.columns, current_winopts.width),
          })
        )
        return not ok
      end,
    })
  end
end

return M
