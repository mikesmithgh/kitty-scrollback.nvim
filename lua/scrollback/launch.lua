local M = {}

-- options
vim.o.loadplugins = false -- preferred
vim.o.hidden = true -- optional
vim.o.laststatus = 0 -- preferred
vim.o.virtualedit = 'all' -- all or onemore for correct position
vim.o.clipboard = 'unnamedplus' -- optional
vim.o.scrolloff = 0 -- preferred
vim.o.termguicolors = true -- required
vim.o.lazyredraw = true -- optional
vim.o.cmdheight = 0 -- preferred
vim.o.number = false -- preferred
vim.o.relativenumber = false -- preferred
vim.o.modifiable = true -- optional
vim.o.scrollback = 100000 -- preferred
vim.o.list = false -- preferred
vim.o.showtabline = 0 -- preferred

M.bufid = vim.api.nvim_get_current_buf()
M.term_chanid = vim.api.nvim_open_term(M.bufid, {})

-- optional keymaps
vim.api.nvim_set_keymap('n', '<esc>', ':qa!<cr>', { silent = true, noremap = true })
vim.api.nvim_set_keymap('n', '<c-c>', ':qa!<cr>', { silent = true, noremap = true })
vim.api.nvim_set_keymap('n', 'q', ':qa!<cr>', { silent = true, noremap = true })
vim.api.nvim_set_keymap('n', '<cr>', ':qa!<cr>', { silent = true, noremap = true })

-- required, it doesn't make sense to enter the terminal since it is readonly
-- optional, TextYankPost quickly return to terminal after yank - might not want this depending on use case
vim.api.nvim_create_autocmd({ 'TermEnter' },
  {
    callback = vim.schedule_wrap(function(e)
      if e.buf == M.bufid then
        vim.cmd('quitall!')
      end
    end)
  }
)
local popup_winid

local function show_status_window()
  local function size(max, value)
    return value > 1 and math.min(value, max) or math.floor(max * value)
  end
  vim.api.nvim_set_hl(0, 'KittyScrollbackNormal', {
    default = true,
    link = 'Normal',
  })
  vim.api.nvim_set_hl(0, 'KittyScrollbackHeart', {
    default = true,
    fg = '#ff6961',
  })
  vim.api.nvim_set_hl(0, 'KittyScrollbackSpinner', {
    default = true,
    fg = '#d3869b',
  })
  vim.api.nvim_set_hl(0, 'KittyScrollbackReady', {
    default = true,
    fg = '#8faa80',
  })
  vim.api.nvim_set_hl(0, 'KittyScrollbackKitty', {
    default = true,
    fg = '#754b33',
  })
  vim.api.nvim_set_hl(0, 'KittyScrollbackVim', {
    default = true,
    fg = '#188b25',
  })
  local popup_bufid = vim.api.nvim_create_buf(false, true)
  local winopts = function()
    return {
      relative = 'editor',
      zindex = 10,
      style = 'minimal',
      focusable = false,
      width = size(vim.o.columns, 8),
      height = 1,
      row = 0,
      col = vim.o.columns,
      border = 'none',
    }
  end
  popup_winid = vim.api.nvim_open_win(popup_bufid, false,
    vim.tbl_extend('force', winopts(), {
      noautocmd = true,
    })
  )
  vim.api.nvim_set_option_value('winhighlight', 'NormalFloat:KittyScrollbackNormal', {
    win = popup_winid,
  })
  local count = 0
  local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏', '✔' }
  local kitty_icon = '󰄛'
  local love_icon = ''
  local vim_icon = ''
  vim.fn.timer_start(
    80,
    function(status_window_timer)
      count = count + 1
      local spinner_icon = count > #spinner and spinner[#spinner] or spinner[count]
      local fmt_msg = ' ' .. spinner_icon .. ' ' .. kitty_icon .. ' ' .. love_icon .. ' ' .. vim_icon
      vim.defer_fn(function()
        vim.api.nvim_buf_set_lines(popup_bufid, 0, -1, false, {})
        vim.api.nvim_buf_set_lines(popup_bufid, 0, -1, false, {
          fmt_msg
        })

        local nid = vim.api.nvim_create_namespace('scrollbacknvim')
        local startcol = 0
        local endcol = #spinner_icon + 2
        vim.api.nvim_buf_set_extmark(popup_bufid, nid, 0, startcol, {
          hl_group = count >= #spinner and 'KittyScrollbackReady' or 'KittyScrollbackSpinner',
          end_col = endcol,
        })
        startcol = endcol
        endcol = endcol + #kitty_icon
        vim.api.nvim_buf_set_extmark(popup_bufid, nid, 0, startcol, {
          hl_group = 'KittyScrollbackKitty',
          end_col = endcol,
        })
        startcol = endcol
        endcol = endcol + #love_icon
        vim.api.nvim_buf_set_extmark(popup_bufid, nid, 0, startcol, {
          hl_group = 'KittyScrollbackHeart',
          end_col = endcol,
        })
        startcol = endcol
        endcol = #fmt_msg
        vim.api.nvim_buf_set_extmark(popup_bufid, nid, 0, startcol, {
          hl_group = 'KittyScrollbackVim',
          end_col = endcol
        })
        if count > #spinner then
          vim.fn.timer_start(60, function(close_window_timer)
            local ok, current_winopts = pcall(vim.api.nvim_win_get_config, popup_winid)
            if not ok then
              vim.fn.timer_stop(close_window_timer)
              vim.fn.timer_stop(status_window_timer)
              return
            end
            if current_winopts.width > 2 then
              ok, _ = pcall(vim.api.nvim_win_set_config, popup_winid, vim.tbl_extend('force', winopts(), {
                width = size(vim.o.columns, current_winopts.width - 1)
              }))
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
          end, {
            ['repeat'] = -1,
          })
        end
      end, count > #spinner and 200 or 0)
    end, {
      ['repeat'] = #spinner + 1,
    }
  )
  vim.api.nvim_create_autocmd('WinResized', {
    group = vim.api.nvim_create_augroup('ScrollbackResized', { clear = true }),
    callback = function()
      local ok, current_winopts = pcall(vim.api.nvim_win_get_config, popup_winid)
      if not ok then
        return true
      end
      ok, _ = pcall(vim.api.nvim_win_set_config, popup_winid, vim.tbl_extend('force', winopts(), {
        width = size(vim.o.columns, current_winopts.width)
      }))
      return not ok
    end,
  })
end

ksbnvim = {
  get_buf = function()
    return M.bufid
  end,
  get_term_chanid = function()
    return M.term_chanid
  end,
  term_chan_send = vim.schedule_wrap(
    function(data)
      vim.api.nvim_chan_send(M.term_chanid, data)
    end),
  set_cursor_position = vim.schedule_wrap(
    function(kitty_pipe_data)
      local d = vim.fn.json_decode(kitty_pipe_data)
      local x = d.cursor_x - 1
      local y = d.cursor_y - 1
      local top_line = d.input_line_number
      if top_line > d.lines then
        top_line = top_line + 1
      end
      local total_lines = top_line + d.lines
      if total_lines > vim.o.scrollback then
        total_lines = vim.o.scrollback + vim.o.lines
        top_line = total_lines - vim.o.lines + 1
      end
      local last_line = vim.fn.line('$')
      if total_lines < last_line then
        total_lines = last_line
        top_line = total_lines - vim.o.lines + 1
      end

      if top_line <= 0 then
        top_line = 1
      end

      local target_top_row = top_line
      local target_row = target_top_row + y
      if target_row > last_line then
        target_top_row = target_top_row - 1
        target_row = last_line
      end
      local target_col = x

      local orig_scrollof = vim.o.scrolloff
      local orig_showtabline = vim.o.showtabline
      vim.o.scrolloff = 0
      vim.o.showtabline = 0
      vim.api.nvim_win_set_cursor(0, { target_top_row, 0 })
      -- send normal scroll top command, there is no api equivalent at the moment
      vim.cmd.normal({ 'zt', bang = true })
      vim.api.nvim_win_set_cursor(0, { target_row, target_col })

      if d.scrolled_by > 0 then
        -- send normal scroll up command, there is no api equivalent at the moment
        vim.cmd.normal({
          vim.api.nvim_replace_termcodes(d.scrolled_by .. '<C-y>', true, false, true),
          bang = true
        })
      end

      vim.o.scrolloff = orig_scrollof
      vim.o.showtabline = orig_showtabline
    end),
  finalize =
    function(kitty_data)
      vim.schedule(function()
        vim.fn.system({
          'kitty',
          '@',
          'close-window',
          '--match=id:' .. kitty_data.loading_winid
        })
        show_status_window()
      end)
    end,
}

return M
