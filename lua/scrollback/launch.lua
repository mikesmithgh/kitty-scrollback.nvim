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


-- read env vars
local sbnvim_input_file = vim.env.SBNVIM_INPUT_FILE
local kitty_pipe_data = vim.env.KITTY_PIPE_DATA
if not sbnvim_input_file then
  vim.notify('missing environment variable: SBNVIM_INPUT_FILE', vim.log.levels.ERROR, {})
  return
end
if not kitty_pipe_data then
  vim.notify('missing environment variable: KITTY_PIPE_DATA', vim.log.levels.ERROR, {})
  return
end


-- read input
local scrollback_input = vim.fn.readfile(sbnvim_input_file)
local line_count = #scrollback_input


-- parse cursor position information
local scrolled_by, cursor_x, cursor_y, lines, columns = kitty_pipe_data:match('(.+):(.+),(.+):(.+),(.+)') ---@diagnostic disable-line: unused-local
local x = cursor_x - 1
local y = cursor_y + 1
local target_top_row = (line_count - lines)
local target_row = target_top_row + y


-- read scrollback buffer to terminal
local bufid = vim.api.nvim_create_buf(true, true)
local term_chanid = vim.api.nvim_open_term(bufid, {})
local color_reset = '\x1b[0m'
local crlf = '\r\n'
for i, l in pairs(scrollback_input) do
  local line = l .. (i > line_count and color_reset or crlf)
  vim.api.nvim_chan_send(term_chanid, line)
end
vim.api.nvim_buf_delete(0, {
  force = true,
})
vim.api.nvim_set_current_buf(bufid)


-- optional keymaps
vim.api.nvim_set_keymap('n', '<esc>', ':qa!<cr>', { silent = true, noremap = true })
vim.api.nvim_set_keymap('n', '<c-c>', ':qa!<cr>', { silent = true, noremap = true })
vim.api.nvim_set_keymap('n', 'q', ':qa!<cr>', { silent = true, noremap = true })
vim.api.nvim_set_keymap('n', '<cr>', ':qa!<cr>', { silent = true, noremap = true })

-- wait for cursorline to become visible before positioning
local line_count_timer = vim.fn.timer_start(
  10,
  function(timer_id)
    local last_focus_line = vim.fn.line('$')
    if last_focus_line >= line_count then
      if target_row > line_count then
        last_focus_line = line_count
        target_row = line_count
      end
      if vim.o.laststatus > 1 then
        last_focus_line = last_focus_line - 1
      end
      if vim.o.cmdheight > 0 then
        last_focus_line = last_focus_line - vim.o.cmdheight
      end

      vim.api.nvim_win_set_cursor(0, { last_focus_line, 0 })

      local orig_scrollof = vim.o.scrolloff
      vim.o.scrolloff = 0
      vim.cmd.normal('zb')
      vim.o.scrolloff = orig_scrollof

      vim.api.nvim_win_set_cursor(0, { target_row, x })
      vim.fn.timer_stop(timer_id)
    end
  end, {
    ['repeat'] = -1, -- forever
  })
vim.defer_fn(function() vim.fn.timer_stop(line_count_timer) end, 3000) -- max of 3 seconds


-- required, it doesn't make sense to enter the terminal since it is readonly
-- optional, TextYankPost quickly return to terminal after yank - might not want this depending on use case
vim.api.nvim_create_autocmd({ 'TermEnter' },
  {
    callback = vim.schedule_wrap(function(e)
      if e.buf == bufid then
        vim.cmd('quitall!')
      end
    end)
  }
)


-- optional title window
vim.schedule(
  function()
    local function size(max, value)
      return value > 1 and math.min(value, max) or math.floor(max * value)
    end
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
    local popup_winid = vim.api.nvim_open_win(popup_bufid, false,
      vim.tbl_extend('force', winopts(), {
        noautocmd = true,
      })
    )
    vim.api.nvim_win_set_option(popup_winid, 'winhighlight', 'NormalFloat:WarningMsg')
    local count = 0
    local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
    local kitty_icon = '󰄛'
    local love_icon = ''
    local vim_icon = ''
    vim.fn.timer_start(
      80,
      function()
        count = count + 1
        if count > #spinner then
          count = 1
        end
        local fmt_msg = ' ' .. spinner[count] .. ' ' .. kitty_icon .. ' ' .. love_icon .. ' ' .. vim_icon

        vim.api.nvim_buf_set_lines(popup_bufid, 0, -1, false, {})
        vim.api.nvim_buf_set_lines(popup_bufid, 0, -1, false, {
          fmt_msg
        })

        local nid = vim.api.nvim_create_namespace('scrollbacknvim')
        local startcol = 0
        local endcol = #spinner[count] + 2
        vim.api.nvim_buf_set_extmark(popup_bufid, nid, 0, startcol, {
          hl_group = 'Comment',
          end_col = endcol,
        })
        startcol = endcol
        endcol = endcol + #kitty_icon
        vim.api.nvim_buf_set_extmark(popup_bufid, nid, 0, startcol, {
          hl_group = 'Constant',
          end_col = endcol,
        })
        startcol = endcol
        endcol = endcol + #love_icon
        vim.api.nvim_buf_set_extmark(popup_bufid, nid, 0, startcol, {
          hl_group = 'DiagnosticError',
          end_col = endcol,
        })
        startcol = endcol
        endcol = #fmt_msg
        vim.api.nvim_buf_set_extmark(popup_bufid, nid, 0, startcol, {
          hl_group = 'MoreMsg',
          end_col = endcol
        })
      end, {
        ['repeat'] = -1,
      }
    )
    vim.api.nvim_create_autocmd('WinResized', {
      group = vim.api.nvim_create_augroup('ScrollbackResized', { clear = true }),
      callback = function()
        vim.api.nvim_win_set_config(popup_winid, winopts())
      end,
    })
  end
)
