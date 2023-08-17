---@type KsbOpts
---@diagnostic disable-next-line: missing-fields
local M = {
  opts = {}
}

local kitty_loading_window_id = nil

---@class KsbOpts
---@field termenter string|function
---@field callbacks KsbCallbacks
local default_opts = {
  keymaps_enabled = true,
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
  },
  ---@class KsbCallbacks
  ---@field after_setup function
  ---@field after_launch function
  ---@field after_ready function
  callbacks = {
    -- after_setup = function(kitty_data, M.opts) end,
    -- after_launch = function(kitty_data, M.opts) end,
    -- after_ready = function(kitty_data, M.opts) end,
  },
  termenter = 'stopinsert'
}

local orig_columns = vim.o.columns

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
    local override = M.opts.highlight_overrides[name]
    if override then
      vim.api.nvim_set_hl(0, name, { fg = override, })
    end
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

local function set_yank_post(kitty_data)
  vim.api.nvim_create_autocmd({ 'TextYankPost' }, {
    group = vim.api.nvim_create_augroup('KittyScrollBackNvimTextYankPost', { clear = true }),
    pattern = '*',
    callback = function()
      local e = vim.v.event
      local contents = e.regcontents
      if type(contents) == 'table' then
        -- contents = table.concat(contents, ' \\\r')
        contents = table.concat(contents, '\n')
      end
      vim.fn.system({
        'kitty',
        '@',
        'send-text',
        '--match=id:' .. kitty_data.window_id,
        contents,
      })
      vim.schedule(function()
        vim.cmd.quit({ bang = true })
      end)
    end
  })
end


local function set_term_enter(buf_id)
  vim.api.nvim_create_autocmd({ 'TermEnter' }, {
    group = vim.api.nvim_create_augroup('KittyScrollBackNvimTermEnter', { clear = true }),
    callback = vim.schedule_wrap(function(e)
      if e.buf == buf_id then
        local termenter = M.opts.termenter
        if type(termenter) == 'function' then
          return termenter(e, buf_id)
        end
        if termenter == 'stopinsert' then
          vim.cmd.stopinsert()
        elseif termenter == 'quit' then
          vim.cmd.quit({ bang = true })
        end
      end
    end)
  }
  )
end

local function set_keymaps()
  if M.opts.keymaps_enabled then
    -- optional keymaps
    vim.api.nvim_set_keymap('n', '<esc>', ':qa!<cr>', { silent = true, noremap = true })
    vim.api.nvim_set_keymap('n', '<c-c>', ':qa!<cr>', { silent = true, noremap = true })
    vim.api.nvim_set_keymap('n', 'q', ':qa!<cr>', { silent = true, noremap = true })
    vim.api.nvim_set_keymap('n', '<cr>', ':qa!<cr>', { silent = true, noremap = true })
  end
end

---@param c  string
local function hexToRgb(c)
  c = string.lower(c)
  return { tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) }
end

---@param foreground string foreground color
---@param background string background color
---@param alpha number|string number between 0 and 1. 0 results in bg, 1 results in fg
local function blend(foreground, background, alpha)
  alpha = type(alpha) == 'string' and (tonumber(alpha, 16) / 0xff) or alpha
  local bg = hexToRgb(background)
  local fg = hexToRgb(foreground)

  local blendChannel = function(i)
    local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
    return math.floor(math.min(math.max(0, ret), 255) + 0.5)
  end

  return string.format('#%02x%02x%02x', blendChannel(1), blendChannel(2), blendChannel(3))
end

local function darken(hex, amount, bg)
  local default_bg = '#ffffff'
  if vim.o.background == 'dark' then
    default_bg = '#000000'
  end
  return blend(hex, bg or default_bg, amount)
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
        width = size(orig_columns or vim.o.columns, width),
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
      ---@diagnostic disable-next-line: redundant-parameter
      function(status_window_timer)
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
                  width = size(orig_columns or vim.o.columns, winopts().width - 2)
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
              ---@diagnostic disable-next-line: redundant-parameter
              vim.fn.timer_start(60, function(close_window_timer)
                local ok, current_winopts = pcall(vim.api.nvim_win_get_config, popup_winid)
                if not ok then
                  vim.fn.timer_stop(close_window_timer)
                  vim.fn.timer_stop(status_window_timer)
                  return
                end
                if current_winopts.width > 2 then
                  ok, _ = pcall(vim.api.nvim_win_set_config, popup_winid, vim.tbl_deep_extend('force', winopts(), {
                    width = size(orig_columns or vim.o.columns, current_winopts.width - 1)
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
              local darken_hex = darken(fg_hex, 0.7)
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
      group = vim.api.nvim_create_augroup('ScrollbackResized', { clear = true }),
      callback = function()
        local ok, current_winopts = pcall(vim.api.nvim_win_get_config, popup_winid)
        if not ok then
          return true
        end
        ok, _ = pcall(vim.api.nvim_win_set_config, popup_winid, vim.tbl_deep_extend('force', winopts(), {
          width = size(vim.o.columns, current_winopts.width)
        }))
        return not ok
      end,
    })
  end
end

local function close_kitty_loading_window()
  if kitty_loading_window_id then
    vim.fn.system({
      'kitty',
      '@',
      'close-window',
      '--match=id:' .. kitty_loading_window_id,
    })
  end
  kitty_loading_window_id = nil
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
  if kitty_loading_window_id then
    close_kitty_loading_window()
  end
  kitty_loading_window_id = tonumber(
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

M.setup = function(kitty_data_str)
  local kitty_data = vim.fn.json_decode(kitty_data_str)
  local opts = {}
  if kitty_data.config_file then
    opts = dofile(kitty_data.config_file).config(kitty_data)
  end
  M.opts = vim.tbl_deep_extend('force', default_opts, opts)
  set_highlights()
  open_kitty_loading_window(kitty_data.ksb_dir) -- must be after opts and highlights set
  set_options()
  set_keymaps()
  if M.opts.callbacks.after_setup and type(M.opts.callbacks.after_setup) == 'function' then
    M.opts.after_setup(kitty_data, M.opts)
  end
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


M.launch = vim.schedule_wrap(function(kitty_data_str)
  local kitty_data = vim.fn.json_decode(kitty_data_str)
  local buf_id = vim.api.nvim_get_current_buf()
  set_term_enter(buf_id)
  set_yank_post(kitty_data)

  local ansi = '--ansi'
  if not M.opts.kitty_get_text.ansi then
    ansi = ''
  end

  local extent = '--extent=all'
  local extent_opt = M.opts.kitty_get_text.extent
  if extent_opt then
    extent = '--extent=' .. extent_opt
  end

  -- increase the number of columns temporary so that the width is used during the
  -- terminal command kitty @ get-text. this avoids hard wrapping lines to the
  -- current window size. Note: a larger min_cols appears to impact performance
  -- do not worry about setting vim.o.columns back to original value that is taken
  -- care of when we trigger kitty to send a SIGWINCH to the nvim process
  local min_cols = 300
  if vim.o.columns < min_cols then
    vim.o.columns = min_cols
  end
  vim.fn.termopen(
    [[kitty @ get-text ]] .. ansi .. [[ --match="id:]] .. kitty_data.window_id .. [[" ]] .. extent .. [[ --add-cursor | ]] ..
    [[sed -e "s/$/\x1b[0m/g" ]] .. -- .. -- append all lines with reset to avoid unintended colors
    [[-e "s/\x1b\[\?25.\x1b\[.*;.*H\x1b\[.*//g"]], -- remove control sequence added by --add-cursor flag
    {
      stdout_buffered = true,
      on_stdout = function(_, lines)
        signal_winchanged_to_kitty_child_process()
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
              show_status_window()

              -- improve buffer name to avoid displaying complex command to user
              local term_buf_name = vim.api.nvim_buf_get_name(buf_id)
              term_buf_name = term_buf_name:gsub(':kitty.*$', ':kitty-scrollback.nvim')
              vim.api.nvim_buf_set_name(buf_id, term_buf_name)

              if M.opts.callbacks.after_ready and type(M.opts.callbacks.after_ready) == 'function' then
                M.opts.after_ready(kitty_data, M.opts)
              end

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
  if M.opts.callbacks.after_launch and type(M.opts.callbacks.after_launch) == 'function' then
    M.opts.after_launch(kitty_data, M.opts)
  end
end)


return M
