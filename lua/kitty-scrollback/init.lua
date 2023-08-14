local M = {
  opts = {}
}

local default_opts = {
  status_window = {
    enabled = true,
    style_simple = false,
  }
}

local p = {
  orig_columns = vim.o.columns,
  buf_id = nil,
}

local highlight_definitions = {
  KittyScrollbackNvimNormal = {
    default = true,
    fg = '#968c81',
  },
  KittyScrollbackNvimHeart = {
    default = true,
    fg = '#ff6961',
  },
  KittyScrollbackNvimSpinner = {
    default = true,
    fg = '#d3869b',
  },
  KittyScrollbackNvimReady = {
    default = true,
    fg = '#8faa80',
  },
  KittyScrollbackNvimKitty = {
    default = true,
    fg = '#754b33',
  },
  KittyScrollbackNvimVim = {
    default = true,
    fg = '#188b25',
  },
}

-- copied from https://codegolf.stackexchange.com/a/177958
local function screaming_snakecase(s)
  return s:gsub('%f[^%l]%u', '_%1'):gsub('%f[^%a]%d', '_%1'):gsub('%f[^%d]%a', '_%1'):gsub('(%u)(%u%l)', '%1_%2'):upper()
end

local function get_highlights_as_env()
  local env = {}
  for name, _ in pairs(highlight_definitions) do
    table.insert(env, '--env')
    table.insert(env, string.format('%s=#%06x',
      screaming_snakecase(name),
      vim.api.nvim_get_hl(0, { name = name, link = false, }).fg or 16777215 -- default to #ffffff
    ))
  end
  return env
end

local function set_highlights()
  for name, definition in pairs(highlight_definitions) do
    vim.api.nvim_set_hl(0, name, definition)
  end
end

local function set_options()
  -- options
  vim.o.loadplugins = nil -- control this via cli
  vim.o.hidden = true -- optional
  vim.o.laststatus = 0 -- preferred
  vim.o.virtualedit = 'all' -- all or onemore for correct position
  vim.o.clipboard = 'unnamedplus' -- optional
  vim.o.scrolloff = 0 -- preferred
  vim.o.termguicolors = true -- required
  vim.o.lazyredraw = false -- conflicts with noice
  vim.o.cmdheight = 0 -- preferred
  vim.o.number = false -- preferred
  vim.o.relativenumber = false -- preferred
  vim.o.modifiable = true -- optional
  vim.o.scrollback = 100000 -- preferred
  vim.o.list = false -- preferred
  vim.o.showtabline = 0 -- preferred
  vim.o.ignorecase = true -- preferred
  vim.o.smartcase = true -- preferred
  vim.o.cursorline = false -- preferred
  vim.o.cursorcolumn = false -- preferred
  vim.opt.fillchars = { -- preferred
    eob = ' ',
  }
end

local function set_autocommands()
  -- required, it doesn't make sense to enter the terminal since it is readonly
  -- optional, TextYankPost quickly return to terminal after yank - might not want this depending on use case
  vim.api.nvim_create_autocmd({ 'TermEnter' },
    {
      group = vim.api.nvim_create_augroup('ScrollBackNvimTermEnter', { clear = true }),
      callback = vim.schedule_wrap(function(e)
        if e.buf == p.buf_id then
          vim.cmd.quit({ bang = true })
        end
      end)
    }
  )

  vim.api.nvim_create_autocmd({ 'VimEnter' },
    {
      group = vim.api.nvim_create_augroup('ScrollBackNvimVimEnter', { clear = true }),
      callback = vim.schedule_wrap(function()
        set_options()
        return true
      end)
    }
  )
end

local function set_keymaps()
  -- optional keymaps
  vim.api.nvim_set_keymap('n', '<esc>', ':qa!<cr>', { silent = true, noremap = true })
  vim.api.nvim_set_keymap('n', '<c-c>', ':qa!<cr>', { silent = true, noremap = true })
  vim.api.nvim_set_keymap('n', 'q', ':qa!<cr>', { silent = true, noremap = true })
  vim.api.nvim_set_keymap('n', '<cr>', ':qa!<cr>', { silent = true, noremap = true })
end


local function show_status_window()
  if M.opts.status_window.enabled then
    local kitty_icon = '󰄛'
    local love_icon = ''
    local vim_icon = ''
    local width = 8
    if M.opts.status_window.style_simple then
      kitty_icon = ''
      love_icon = ''
      vim_icon = ''
      width = 24
    end
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
        width = size(p.orig_columns or vim.o.columns, width),
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
    vim.api.nvim_set_option_value('winhighlight', 'NormalFloat:KittyScrollbackNvimNormal', {
      win = popup_winid,
    })
    local count = 0
    local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏', '✔' }
    if M.opts.status_window.style_simple then
      spinner = vim.tbl_map(function(v) return v .. ' kitty-scrollback.nvim' end, { '-', '-', '\\', '\\', '|', '|', '/', '/', '-', '-', '*' })
    end
    vim.fn.timer_start(
      80,
      ---@diagnostic disable-next-line: redundant-parameter
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
            hl_group = count >= #spinner and 'KittyScrollbackNvimReady' or 'KittyScrollbackNvimSpinner',
            end_col = endcol,
          })
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
            end_col = endcol
          })
          if count > #spinner then
            ---@diagnostic disable-next-line: redundant-parameter
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
end

local function open_kitty_loading_window()
  p.kitty_loading_window_id = tonumber(
    vim.fn.system(
      vim.list_extend({ 'kitty',
          '@',
          'launch',
          '--type',
          'overlay',
          '--title',
          'kitty-scrollback.nvim :: loading...',
          '--env',
          'KITTY_SCROLLBACK_NVIM_STYLE_SIMPLE=' .. tostring(M.opts.status_window.style_simple),
          '--env',
          'KITTY_SCROLLBACK_NVIM_STATUS_WINDOW_ENABLED=' .. tostring(M.opts.status_window.enabled),
        },
        vim.list_extend(
          get_highlights_as_env(),
          { p.ksb_dir .. '/python/loading.py', }
        )
      )
    )
  )
end

M.setup = function(ksb_dir, opts)
  p.ksb_dir = ksb_dir
  M.opts = vim.tbl_extend('force', default_opts, opts or {})
  set_highlights()
  open_kitty_loading_window()
  set_options()
  set_keymaps()
  set_autocommands()
end

local set_cursor_position = vim.schedule_wrap(
  function(d)
    local x = d.cursor_x - 1
    local y = d.cursor_y - 1
    local scrolled_by = d.scrolled_by
    local lines = d.lines
    local last_line = vim.fn.line('$')

    local orig_virtualedit = vim.o.virtualedit
    local orig_scrollof = vim.o.scrolloff
    local orig_showtabline = vim.o.showtabline
    local orig_laststatus = vim.o.laststatus
    vim.o.scrolloff = 0
    vim.o.showtabline = 0
    vim.o.laststatus = 0
    vim.o.virtualedit = 'all'

    vim.fn.cursor(last_line, 1) -- cursor last line
    -- using normal commands instead of cursor pos due to virtualedit
    vim.cmd.normal({ (lines - 1) .. 'k', bang = true }) -- cursor up
    vim.cmd.normal({ y .. 'j', bang = true }) -- cursor down
    vim.cmd.normal({ x .. 'l', bang = true }) -- cursor right
    if scrolled_by > 0 then
      -- scroll up
      vim.cmd.normal({
        vim.api.nvim_replace_termcodes(scrolled_by .. '<C-y>', true, false, true), -- TODO: invesigate if CSI control sequence to scroll is better
        bang = true
      })
    end

    vim.o.scrolloff = orig_scrollof
    vim.o.showtabline = orig_showtabline
    vim.o.laststatus = orig_laststatus
    vim.o.virtualedit = orig_virtualedit
  end
)

local function close_kitty_loading_window()
  vim.fn.system({
    'kitty',
    '@',
    'close-window',
    '--match=id:' .. p.kitty_loading_window_id,
  })
end


M.launch = function(kitty_data_str)
  show_status_window()
  local kitty_data = vim.fn.json_decode(kitty_data_str)
  local buf_id = vim.api.nvim_get_current_buf()
  p.buf_id = buf_id
  vim.fn.termopen(
    [[kitty @ get-text --ansi --match="state:overlay_parent" --extent=all --add-cursor | ]] ..
    [[sed -e "s/$/\x1b[0m/g" ]] .. -- .. -- append all lines with reset to avoid unintended colors
    [[-e "s/\x1b\[\?25.\x1b\[.*;.*H\x1b\[.*//g"]], -- remove control sequence added by --add-cursor flag
    {
      stdout_buffered = true,
      on_stdout = function(_, lines)
        local delete_line_timer = vim.fn.timer_start(
          100,
          function(t) ---@diagnostic disable-line: redundant-parameter
            local process_exited_line = vim.fn.search('\\[process exited \\d\\+\\]', 'bn')
            if process_exited_line > 0 then
              vim.fn.timer_stop(t)
              kitty_data.line_count = #lines - 1
              kitty_data.cursor_y = kitty_data.cursor_y
              vim.api.nvim_set_option_value('modifiable', true, { buf = buf_id, })
              vim.api.nvim_buf_set_lines(buf_id, process_exited_line - 2, process_exited_line, true, {}) -- delete lines
              vim.api.nvim_set_option_value('modifiable', false, { buf = buf_id, })
              set_cursor_position(kitty_data)
              close_kitty_loading_window()
            end
          end,
          { ['repeat'] = -1 } -- repeat indefinitely but will be cancelled after 2 seconds
        )
        -- give at most 2 seconds of an attempt to delete the line
        vim.defer_fn(
          function()
            vim.fn.timer_stop(delete_line_timer)
            close_kitty_loading_window()
          end,
          2000
        )
      end,
    })
end


return M
