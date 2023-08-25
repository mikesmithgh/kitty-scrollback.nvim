---@mod kitty-scrollback.launch

---@type KsbOpts
---@diagnostic disable-next-line: missing-fields
local M = {
  opts = {},
}

---@class KsbOpts
---@field callbacks KsbCallbacks
local default_opts = {
  keymaps_enabled = true,
  restore_options = false,
  status_window = {
    enabled = true,
    style_simple = false,
    autoclose = false,
    show_timer = false,
  },
  ---@class KsbKittyGetText see `kitty @ get-text --help`
  ---@field ansi boolean If true, the text will include the ANSI formatting escape codes for colors, bold, italic, etc.
  ---@field clear_selection boolean If true, clear the selection in the matched window, if any.
  ---@field extent string | 'screen' | 'selection' | 'first_cmd_output_on_screen' | 'last_cmd_output' | 'last_visited_cmd_output' | 'last_non_empty_output'     What text to get. The default of screen means all text currently on the screen. all means all the screen+scrollback and selection means the currently selected text. first_cmd_output_on_screen means the output of the first command that was run in the window on screen. last_cmd_output means the output of the last command that was run in the window. last_visited_cmd_output means the first command output below the last scrolled position via scroll_to_prompt. last_non_empty_output is the output from the last command run in the window that had some non empty output. The last four require shell_integration to be enabled. Choices: screen, all, first_cmd_output_on_screen, last_cmd_output, last_non_empty_output, last_visited_cmd_output, selection
  kitty_get_text = {
    ansi = true,
    extent = 'all',
    clear_selection = true,
  },
  highlight_overrides = {
    -- KittyScrollbackNvimNormal = '#968c81',
    -- KittyScrollbackNvimHeart = '#ff6961',
    -- KittyScrollbackNvimSpinner = '#d3869b',
    -- KittyScrollbackNvimReady = '#8faa80',
    -- KittyScrollbackNvimKitty = '#754b33',
    -- KittyScrollbackNvimVim = '#188b25',
    -- TODO: add paste window highlight overrides
  },
  ---@class KsbCallbacks
  ---@field after_setup function
  ---@field after_launch function
  ---@field after_ready function
  callbacks = {
    -- after_setup = function(kitty_data, opts) end,
    -- after_launch = function(kitty_data, opts) end,
    -- after_ready = function(kitty_data, opts) end,
  },
}

---@class KsbPrivate
---@field orig_columns number
---@field bufid number?
---@field paste_bufid number?
---@field kitty_loading_winid number?
local p = {
  orig_columns = vim.o.columns
}

---@class KsbModules
---@field util table
local m = {}

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

---Format nvim highlights to arguments passed to kitty launch command
---E.g., KittyScrollbackNvimVim with #188b25 to --env KITTY_SCROLLBACK_NVIM_VIM=#188b25
---@return table list of environment variable arguments
local function get_highlights_as_env()
  local env = {}
  for name, _ in pairs(highlight_definitions) do
    table.insert(env, '--env')
    table.insert(env,
      string.format('%s=#%06x',
        m.util.screaming_snakecase(name),
        vim.api.nvim_get_hl(0, { name = name, link = false, }).fg or 16777215 -- default to #ffffff
      )
    )
  end
  return env
end

---Set nvim default highlights
local function set_highlights()
  for name, definition in pairs(highlight_definitions) do
    vim.api.nvim_set_hl(0, name, definition)
    local override = M.opts.highlight_overrides[name]
    if override then
      vim.api.nvim_set_hl(0, name, { fg = override, })
    end
  end
end

local function restore_orig_options()
  for option, value in pairs(p.orig_options) do
    vim.o[option] = value
  end
end

local function set_options()
  p.orig_options = {
    virtualedit = vim.o.virtualedit,
    termguicolors = vim.o.termguicolors,
    laststatus = vim.o.laststatus,
    scrolloff = vim.o.scrolloff,
    cmdheight = vim.o.cmdheight,
    ruler = vim.o.ruler,
    number = vim.o.number,
    relativenumber = vim.o.relativenumber,
    scrollback = vim.o.scrollback,
    list = vim.o.list,
    showtabline = vim.o.showtabline,
    showmode = vim.o.showmode,
    ignorecase = vim.o.ignorecase,
    smartcase = vim.o.smartcase,
    cursorline = vim.o.cursorline,
    cursorcolumn = vim.o.cursorcolumn,
    fillchars = vim.o.fillchars,
    lazyredraw = vim.o.lazyredraw,
    hidden = vim.o.hidden,
    modifiable = vim.o.modifiable,
    wrap = vim.o.wrap,
  }

  -- required opts
  vim.o.virtualedit = 'all' -- all or onemore for correct position
  vim.o.termguicolors = true

  -- preferred optional opts
  vim.o.laststatus = 0
  vim.o.scrolloff = 0
  vim.o.cmdheight = 0
  vim.o.ruler = false
  vim.o.number = false
  vim.o.relativenumber = false
  vim.o.scrollback = 100000
  vim.o.list = false
  vim.o.showtabline = 0
  vim.o.showmode = false
  vim.o.ignorecase = true
  vim.o.smartcase = true
  vim.o.cursorline = false
  vim.o.cursorcolumn = false
  vim.opt.fillchars = {
    eob = ' ',
  }
  vim.o.lazyredraw = false -- conflicts with noice
  vim.o.hidden = true
  vim.o.modifiable = true
  vim.o.wrap = false
end

local paste_winopts = function(lnum, col, noautocmd)
  local keymap_title = M.opts.keymaps_enabled and ' or CTRL-Enter' or ''
  local h            = m.util.size(vim.o.lines, math.floor(m.util.size(vim.o.lines, (vim.o.lines + 2) / 3)))
  local diff         = vim.o.lines - lnum - h
  if diff < 0 then
    lnum = lnum - h - 2
  end
  local winopts = {
    relative = 'editor',
    zindex = 40,
    focusable = true,
    border = { '🭽', '▔', '🭾', '▕', '🭿', '▁', '🭼', '▏' },
    -- border = 'rounded',
    -- title = ' Write' .. keymap_title .. ' to execute command ',
    -- title_pos = 'center',
    height = h,
    -- height = math.floor(m.util.size(vim.o.lines, (vim.o.lines + 2) / 2)),
  }
  if type(noautocmd) == 'boolean' then
    winopts.noautocmd = noautocmd
  end
  if type(lnum) == 'number' then
    winopts.row = lnum
  end
  if type(col) == 'number' then
    winopts.col = col
    local offset = 1
    winopts.width = m.util.size(vim.o.columns, vim.o.columns - col) - offset
    if winopts.width < 0 then
      -- current line is larger than window, put window below current line
      vim.fn.setcursorcharpos({ vim.fn.line('.'), 0 })
      vim.cmd.redraw()
      winopts.width = vim.o.columns - 1
      winopts.col = 0
    end
  end
  return winopts
end

local legend_winopts = function(paste_winopts)
  return {
    relative = 'win',
    win = p.paste_winid,
    zindex = paste_winopts.zindex + 1,
    focusable = false,
    -- border = { ' ', ' ', '▕', '▕', '🭿', '▁', '▁', ' ' },
    border = { '▏', ' ', '▕', '▕', '🭿', '▁', '🭼', '▏' },
    -- border = 'rounded',
    height = 1,
    width = paste_winopts.width,
    row = paste_winopts.height + 1,
    col = -1,
    style = 'minimal',
    -- title = 'Mappings',
    -- title_pos = 'center',
    -- anchor = 'NE',
  }
end

local open_paste_window = function(start_insert)
  vim.cmd.stopinsert()
  vim.fn.cursor({ vim.fn.line('$'), 0 })
  if M.opts.kitty_get_text.extent == 'screen' or M.opts.kitty_get_text.extent == 'all' then
    vim.fn.search('.', 'b')
  end

  local lnum = m.util.size(vim.o.lines, vim.fn.winline() - 2 - vim.o.cmdheight)
  local col = vim.fn.wincol()
  if not p.paste_bufid then
    p.paste_bufid = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_buf_set_name(p.paste_bufid, vim.fn.tempname())
    vim.api.nvim_set_option_value('filetype', 'sh', {
      buf = p.paste_bufid,
    })
  end
  if not p.paste_winid or vim.fn.win_id2win(p.paste_winid) == 0 then
    local winopts = paste_winopts(lnum, col, false)
    p.paste_winid = vim.api.nvim_open_win(p.paste_bufid, true, winopts)
    vim.api.nvim_set_option_value('scrolloff', 2, {
      win = p.paste_winid,
    })

    vim.schedule(function()
      p.legend_bufid = vim.api.nvim_create_buf(false, false)
      vim.api.nvim_set_option_value('filetype', 'help', {
        buf = p.legend_bufid,
      })

      p.legend_winid = vim.api.nvim_open_win(p.legend_bufid, false, legend_winopts(winopts))
      vim.api.nvim_create_autocmd('WinClosed', {
        group = vim.api.nvim_create_augroup('KittyScrollBackNvimPasteWindowClosed', { clear = true }),
        pattern = tostring(p.paste_winid),
        callback = function()
          pcall(vim.api.nvim_win_close, p.legend_winid, true)
        end,
      })

      vim.api.nvim_set_option_value('conceallevel', 2, {
        win = p.legend_winid,
      })
      local legend_msg = { '<leader>|y| Copy ', '<ctrl-enter> Execute ', '<shift-enter> Paste ', '*:w[rite]* Paste ', '*g?* Toggle Mappings' }
      local padding = math.floor(winopts.width / #legend_msg)
      local string_with_padding = '%' .. padding .. 's'
      local string_with_half_padding = '%' .. math.floor(padding / 4) .. 's'
      local first = true
      legend_msg =
        vim.tbl_map(function(msg)
          if first then
            first = false
            return string.format(string_with_half_padding .. '%s', ' ', msg)
          end
          return string.format(string_with_padding, msg)
        end, legend_msg)
      vim.api.nvim_buf_set_lines(p.legend_bufid, 0, -1, false,
        { table.concat(legend_msg) }
      )

      vim.api.nvim_set_option_value('winhighlight',
        'Normal:KittyScrollbackNvimPasteWinNormal,FloatBorder:KittyScrollbackNvimPasteWinFloatBorder,FloatTitle:KittyScrollbackNvimPasteWinFloatTitle',
        { win = p.legend_winid, }
      )
    end)

    local normal_hl = vim.api.nvim_get_hl(0, {
      name = 'Normal',
      link = false,
    })
    local normal_bg_color = normal_hl.bg or p.kitty_colors.background
    local floatborder_fg_color = m.util.darken(p.kitty_colors.foreground, 0.3, p.kitty_colors.background)
    local floattitle_fg_color = m.util.darken(p.kitty_colors.foreground, 0.7, p.kitty_colors.background)

    vim.api.nvim_set_hl(0, 'KittyScrollbackNvimPasteWinNormal', {
      bg = normal_bg_color,
      -- blend = 4
    })
    vim.api.nvim_set_hl(0, 'KittyScrollbackNvimPasteWinFloatBorder', {
      bg = normal_bg_color,
      fg = floatborder_fg_color,
      -- blend = 30
    })
    vim.api.nvim_set_hl(0, 'KittyScrollbackNvimPasteWinFloatTitle', {
      bg = floatborder_fg_color,
      fg = normal_bg_color,
      -- blend = 30
    })
    vim.api.nvim_set_option_value('winhighlight',
      'Normal:KittyScrollbackNvimPasteWinNormal,FloatBorder:KittyScrollbackNvimPasteWinFloatBorder,FloatTitle:KittyScrollbackNvimPasteWinFloatTitle',
      { win = p.paste_winid, }
    )
    -- vim.api.nvim_set_option_value('winblend',
    --   4,
    --   { win = p.paste_winid, }
    -- )
  end
  if start_insert then
    vim.schedule(function()
      vim.fn.cursor(vim.fn.line('$', p.paste_winid), 1)
      vim.cmd.startinsert({ bang = true })
    end)
  end
end

local function get_kitty_colors(kitty_data)
  local kitty_colors = {}
  local kitty_colors_str = vim.fn.system({
    'kitty',
    '@',
    'get-colors',
    '--match=id:' .. kitty_data.window_id,
  }) or ''
  for color_kv in kitty_colors_str:gmatch('[^\r\n]+') do
    local split_kv = color_kv:gmatch('%S+')
    kitty_colors[split_kv()] = split_kv()
  end
  return kitty_colors
end

local function send_paste_buffer_text_to_kitty_and_quit(kitty_data, bracketed_paste_mode)
  -- TODO clean up just hacking right now
  local cmd_str = table.concat(
    vim.tbl_filter(function(l)
        return #l > 0 -- remove empty lines
      end,
      vim.api.nvim_buf_get_lines(p.paste_bufid, 0, -1, false)
    ),
    '\r') .. '\r'
  cmd_str = '\x1b[200~' .. cmd_str .. '\x1b[201~' -- see https://cirw.in/blog/bracketed-paste
  if not bracketed_paste_mode then
    cmd_str = cmd_str .. '\r'
  end
  vim.fn.system({
    'kitty',
    '@',
    'send-text',
    '--match=id:' .. kitty_data.window_id,
    cmd_str,
  })
  vim.cmd.quitall({ bang = true })
end

local function remove_process_exited()
  local last_line_range = vim.api.nvim_buf_line_count(p.bufid) - vim.o.lines
  if last_line_range < 1 then
    last_line_range = 1
  end
  local last_lines = vim.api.nvim_buf_get_lines(p.bufid, last_line_range, -1, false)
  for i, line in pairs(last_lines) do
    local match = line:lower():gmatch('%[process exited %d+%]')
    if match() then
      local target_line = last_line_range - 1 + i
      vim.api.nvim_set_option_value('modifiable', true, { buf = p.bufid, })
      vim.api.nvim_buf_set_lines(p.bufid, target_line, target_line + 1, false, {})
      vim.api.nvim_set_option_value('modifiable', false, { buf = p.bufid, })
      return true
    end
  end
  return false
end


local function set_keymaps(kitty_data)
  if M.opts.keymaps_enabled then
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
        send_paste_buffer_text_to_kitty_and_quit(kitty_data, false)
        return
      end
      return '<c-cr>'
    end)
    vim.keymap.set({ 'n', 'i' }, '<s-cr>', function()
      if vim.api.nvim_get_current_buf() == p.paste_bufid then
        send_paste_buffer_text_to_kitty_and_quit(kitty_data, true)
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
          -- TODO move to function this is copypasta
          vim.schedule(function()
            p.legend_bufid = vim.api.nvim_create_buf(false, false)
            vim.api.nvim_set_option_value('filetype', 'help', {
              buf = p.legend_bufid,
            })
            local winopts = vim.api.nvim_win_get_config(p.paste_winid)
            p.legend_winid = vim.api.nvim_open_win(p.legend_bufid, false, legend_winopts(winopts))
            vim.api.nvim_create_autocmd('WinClosed', {
              group = vim.api.nvim_create_augroup('KittyScrollBackNvimPasteWindowClosed', { clear = true }),
              pattern = tostring(p.paste_winid),
              callback = function()
                pcall(vim.api.nvim_win_close, p.legend_winid, true)
              end,
            })

            vim.api.nvim_set_option_value('conceallevel', 2, {
              win = p.legend_winid,
            })
            local legend_msg = { '<leader>|y| Copy ', '<ctrl-enter> Execute ', '<shift-enter> Paste ', '*:w[rite]* Paste ', '*g?* Toggle Mappings' }
            local padding = math.floor(winopts.width / #legend_msg)
            local string_with_padding = '%' .. padding .. 's'
            local string_with_half_padding = '%' .. math.floor(padding / 4) .. 's'
            local first = true
            legend_msg =
              vim.tbl_map(function(msg)
                if first then
                  first = false
                  return string.format(string_with_half_padding .. '%s', ' ', msg)
                end
                return string.format(string_with_padding, msg)
              end, legend_msg)
            vim.api.nvim_buf_set_lines(p.legend_bufid, 0, -1, false,
              { table.concat(legend_msg) }
            )

            vim.api.nvim_set_option_value('winhighlight',
              'Normal:KittyScrollbackNvimPasteWinNormal,FloatBorder:KittyScrollbackNvimPasteWinFloatBorder,FloatTitle:KittyScrollbackNvimPasteWinFloatTitle',
              { win = p.legend_winid, }
            )
          end)
        end
        return
      end
      return 'g?'
    end)
  end
end


local function show_status_window()
  if M.opts.status_window.enabled then
    local kitty_icon = '󰄛'
    local love_icon = ''
    local vim_icon = ''
    local width = 9
    if M.opts.status_window.style_simple then
      kitty_icon = 'kitty-scrollback.nvim'
      love_icon = ''
      vim_icon = ''
      width = 25
    end
    local popup_bufid = vim.api.nvim_create_buf(false, true)
    local winopts = function()
      return {
        relative = 'editor',
        zindex = 40,
        style = 'minimal',
        focusable = false,
        width = m.util.size(p.orig_columns or vim.o.columns, width),
        height = 1,
        row = 0,
        col = vim.o.columns,
        border = 'none',
      }
    end
    local popup_winid = vim.api.nvim_open_win(popup_bufid, false,
      vim.tbl_deep_extend('force', winopts(), {
        noautocmd = true,
      })
    )
    vim.api.nvim_set_option_value('winhighlight', 'NormalFloat:KittyScrollbackNvimNormal', {
      win = popup_winid,
    })
    local count = 0
    local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏', '✔' }
    if M.opts.status_window.style_simple then
      spinner = { '-', '-', '\\', '\\', '|', '|', '/', '/', '-', '-', '*' }
    end
    vim.fn.timer_start(
      80,
      function(status_window_timer) ---@diagnostic disable-line: redundant-parameter
        count = count + 1
        local spinner_icon = count > #spinner and spinner[#spinner] or spinner[count]
        local fmt_msg = ' ' .. spinner_icon .. ' ' .. kitty_icon .. ' ' .. love_icon .. ' ' .. vim_icon .. ' '
        vim.defer_fn(function()
          if spinner_icon == '' then
            vim.fn.timer_stop(status_window_timer)
            fmt_msg = ' ' .. kitty_icon .. ' ' .. love_icon .. ' ' .. vim_icon .. ' '
            local ok, _ = pcall(vim.api.nvim_win_get_config, popup_winid)
            if ok then
              vim.schedule(function()
                pcall(vim.api.nvim_win_set_config, popup_winid, vim.tbl_deep_extend('force', winopts(), {
                  width = m.util.size(p.orig_columns or vim.o.columns, winopts().width - 2)
                }))
              end)
            end
          end
          vim.api.nvim_buf_set_lines(popup_bufid, 0, -1, false, {})
          vim.api.nvim_buf_set_lines(popup_bufid, 0, -1, false, {
            fmt_msg
          })

          local nid = vim.api.nvim_create_namespace('scrollbacknvim')
          local startcol = 0
          local endcol = 0
          if spinner_icon ~= '' then
            endcol = #spinner_icon + 2
            vim.api.nvim_buf_set_extmark(popup_bufid, nid, 0, startcol, {
              hl_group = count >= #spinner and 'KittyScrollbackNvimReady' or 'KittyScrollbackNvimSpinner',
              end_col = endcol,
            })
          end
          if not M.opts.status_window.style_simple then
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
          end
          if M.opts.status_window.autoclose then
            if count > #spinner then
              vim.fn.timer_start(60, function(close_window_timer) ---@diagnostic disable-line: redundant-parameter
                local ok, current_winopts = pcall(vim.api.nvim_win_get_config, popup_winid)
                if not ok then
                  vim.fn.timer_stop(close_window_timer)
                  vim.fn.timer_stop(status_window_timer)
                  return
                end
                if current_winopts.width > 2 then
                  ok, _ = pcall(vim.api.nvim_win_set_config, popup_winid, vim.tbl_deep_extend('force', winopts(), {
                    width = m.util.size(p.orig_columns or vim.o.columns, current_winopts.width - 1)
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
          else
            if count > #spinner then
              local hl_def = vim.api.nvim_get_hl(0, {
                name = 'KittyScrollbackNvimReady',
              })
              local fg_dec = hl_def.fg
              local fg_hex = string.format('#%06x', fg_dec)
              local darken_hex = m.util.darken(fg_hex, 0.7)
              vim.api.nvim_set_hl(0, 'KittyScrollbackNvimReady', {
                fg = darken_hex
              })
              if count > #spinner + (#spinner / 2) then
                spinner[#spinner] = ''
              end
            end
          end
        end, count > #spinner and 200 or 0)
      end, {
        ['repeat'] = -1,
      }
    )
    vim.api.nvim_create_autocmd('WinResized', {
      group = vim.api.nvim_create_augroup('KittyScrollBackNvimStatusWindowResized', { clear = true }),
      callback = function()
        local ok, current_winopts = pcall(vim.api.nvim_win_get_config, popup_winid)
        if not ok then
          return true
        end
        ok, _ = pcall(vim.api.nvim_win_set_config, popup_winid, vim.tbl_deep_extend('force', winopts(), {
          width = m.util.size(vim.o.columns, current_winopts.width)
        }))
        return not ok
      end,
    })
  end
end

local function close_kitty_loading_window()
  if p.kitty_loading_winid then
    vim.fn.system({
      'kitty',
      '@',
      'close-window',
      '--match=id:' .. p.kitty_loading_winid,
    })
  end
  p.kitty_loading_winid = nil
end

local function signal_winchanged_to_kitty_child_process()
  vim.fn.system({
    'kitty',
    '@',
    'signal-child',
    'SIGWINCH'
  })
end

local function open_kitty_loading_window(ksb_dir)
  if p.kitty_loading_winid then
    close_kitty_loading_window()
  end
  p.kitty_loading_winid = tonumber(
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
          '--env',
          'KITTY_SCROLLBACK_NVIM_SHOW_TIMER=' .. tostring(M.opts.status_window.show_timer),
        },
        vim.list_extend(
          get_highlights_as_env(),
          { ksb_dir .. '/python/loading.py', }
        )
      )
    )
  )
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
    vim.cmd.normal({ lines .. 'k', bang = true }) -- cursor up
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

local function set_paste_buffer_write_autocmd(kitty_data)
  vim.api.nvim_create_autocmd({ 'BufWriteCmd' }, {
    group = vim.api.nvim_create_augroup('KittyScrollBackNvimPasteBufWriteCmd', { clear = true }),
    callback = function(paste_event)
      if paste_event.buf == p.paste_bufid then
        send_paste_buffer_text_to_kitty_and_quit(kitty_data, true)
      end
    end
  })
end

local function set_paste_window_resized_autocmd()
  vim.api.nvim_create_autocmd({ 'WinResized' }, {
    group = vim.api.nvim_create_augroup('KittyScrollBackNvimPasteWindowResized', { clear = true }),
    callback = function()
      if p.paste_winid then
        local ok, current_winopts = pcall(vim.api.nvim_win_get_config, p.paste_winid)
        if ok then
          local row = current_winopts.row[vim.val_idx]
          local col = current_winopts.col[vim.val_idx]
          pcall(vim.api.nvim_win_set_config, p.paste_winid, paste_winopts(row, col))
          vim.schedule(function()
            local len_winopts = legend_winopts(current_winopts)
            pcall(vim.api.nvim_win_set_config, p.legend_winid, len_winopts)
            local legend_msg = { '<leader>|y| Copy ', '<ctrl-enter> Execute ', '<shift-enter> Paste ', '*:w[rite]* Paste ', '*g?* Toggle Mappings' }
            local padding = math.floor(len_winopts.width / #legend_msg)
            local string_with_padding = '%' .. padding .. 's'
            local string_with_half_padding = '%' .. math.floor(padding / 4) .. 's'
            local first = true
            legend_msg =
              vim.tbl_map(function(msg)
                if first then
                  first = false
                  return string.format(string_with_half_padding .. '%s', ' ', msg)
                end
                return string.format(string_with_padding, msg)
              end, legend_msg)
            vim.api.nvim_buf_set_lines(p.legend_bufid, 0, -1, false,
              { table.concat(legend_msg) }
            )
          end)
        end
      end
    end,
  })
end

local function set_term_enter_autocmd(bufid)
  vim.api.nvim_create_autocmd({ 'TermEnter' }, {
    group = vim.api.nvim_create_augroup('KittyScrollBackNvimTermEnter', { clear = true }),
    callback = function(e)
      if e.buf == bufid then
        open_paste_window(true)

        -- when performing last cmd or visited output, every time termenter is triggered it
        -- is restoring the process exited message, this may be a bug in neovim
        vim.fn.timer_start(20, function(t) ---@diagnostic disable-line: redundant-parameter
          if remove_process_exited() then
            vim.fn.timer_stop(t)
          end
        end, {
          ['repeat'] = 100,
        })
      end
    end
  })
end

local function set_colorscheme_autocmd()
  vim.api.nvim_create_autocmd({ 'Colorscheme' }, {
    group = vim.api.nvim_create_augroup('KittyScrollBackNvimColorscheme', { clear = true }),
    callback = set_highlights
  })
end

local function set_yank_post_autocmd(kitty_data)
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
        vim.schedule_wrap(vim.cmd.quitall)({ bang = true })
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
            open_paste_window()
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

M.setup = function(kitty_data_str)
  local kitty_data = vim.fn.json_decode(kitty_data_str)
  local ksb_dir = kitty_data.ksb_dir
  m.util = dofile(ksb_dir .. '/lua/kitty-scrollback/util.lua')

  vim.schedule(function()
    p.kitty_colors = get_kitty_colors(kitty_data)
    -- avoid terrible purple floating windows for the default colorscheme
    if not vim.g.colors_name then
      vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'Normal', })
      vim.api.nvim_set_hl(0, 'FloatBorder', { link = 'Normal', })
      vim.api.nvim_set_hl(0, 'FloatTitle', { link = 'Normal', })
      local floatborder_fg_color = m.util.darken(p.kitty_colors.foreground, 0.3, p.kitty_colors.background)
      vim.api.nvim_set_hl(0, 'ModeMsg', { fg = floatborder_fg_color })
    end
  end)

  local opts = {}
  if kitty_data.config_file then
    opts = dofile(kitty_data.config_file).config(kitty_data)
  end
  M.opts = vim.tbl_deep_extend('force', default_opts, opts)

  set_highlights()
  open_kitty_loading_window(ksb_dir) -- must be after opts and highlights set
  set_options()
  set_keymaps(kitty_data)
  if M.opts.callbacks.after_setup and type(M.opts.callbacks.after_setup) == 'function' then
    vim.schedule(function()
      M.opts.callbacks.after_setup(kitty_data, M.opts)
    end)
  end
end

M.launch = function(kitty_data_str)
  local kitty_data = vim.fn.json_decode(kitty_data_str)
  vim.schedule(function()
    p.bufid = vim.api.nvim_get_current_buf()

    set_term_enter_autocmd(p.bufid)
    set_yank_post_autocmd(kitty_data)
    set_paste_window_resized_autocmd()
    set_paste_buffer_write_autocmd(kitty_data)
    set_colorscheme_autocmd()

    local ansi = '--ansi'
    if not M.opts.kitty_get_text.ansi then
      ansi = ''
    end

    local clear_selection = '--clear-selection'
    if not M.opts.kitty_get_text.clear_selection then
      clear_selection = ''
    end

    local extent = '--extent=all'
    local extent_opt = M.opts.kitty_get_text.extent
    if extent_opt then
      extent = '--extent=' .. extent_opt
    end

    local add_cursor = '--add-cursor' -- always add cursor

    local get_text_opts = ansi .. ' ' .. clear_selection .. ' ' .. add_cursor .. ' ' .. extent

    -- increase the number of columns temporary so that the width is used during the
    -- terminal command kitty @ get-text. this avoids hard wrapping lines to the
    -- current window size. Note: a larger min_cols appears to impact performance
    -- do not worry about setting vim.o.columns back to original value that is taken
    -- care of when we trigger kitty to send a SIGWINCH to the nvim process
    local min_cols = 300
    if vim.o.columns < min_cols then
      vim.o.columns = min_cols
    end
    vim.schedule(function()
      vim.fn.termopen(
        [[kitty @ get-text --match="id:]] .. kitty_data.window_id .. [[" ]] .. get_text_opts .. [[ | ]] ..
        [[sed -e "s/$/\x1b[0m/g" ]] .. -- append all lines with reset to avoid unintended colors
        [[-e "s/\x1b\[\?25.\x1b\[.*;.*H\x1b\[.*//g"]], -- remove control sequence added by --add-cursor flag
        {
          stdout_buffered = true,
          on_exit = function()
            signal_winchanged_to_kitty_child_process()
            vim.fn.timer_start(
              20,
              function(t) ---@diagnostic disable-line: redundant-parameter
                local timer_info = vim.fn.timer_info(t)[1] or {}
                local ready = remove_process_exited()
                if ready or timer_info['repeat'] == 0 then
                  vim.fn.timer_stop(t)
                  if M.opts.kitty_get_text.extent == 'screen' or M.opts.kitty_get_text.extent == 'all' then
                    set_cursor_position(kitty_data)
                  end
                  show_status_window()

                  -- improve buffer name to avoid displaying complex command to user
                  local term_buf_name = vim.api.nvim_buf_get_name(p.bufid)
                  term_buf_name = term_buf_name:gsub(':kitty.*$', ':kitty-scrollback.nvim')
                  vim.api.nvim_buf_set_name(p.bufid, term_buf_name)

                  close_kitty_loading_window()
                  if M.opts.restore_options then
                    restore_orig_options()
                  end
                  if M.opts.callbacks.after_ready and type(M.opts.callbacks.after_ready) == 'function' then
                    vim.schedule(function()
                      M.opts.callbacks.after_ready(kitty_data, M.opts)
                    end)
                  end
                end
              end,
              {
                ['repeat'] = 200
              })
          end,
        })
    end)
    if M.opts.callbacks.after_launch and type(M.opts.callbacks.after_launch) == 'function' then
      vim.schedule(function()
        M.opts.callbacks.after_launch(kitty_data, M.opts)
      end)
    end
  end)
end

return M
