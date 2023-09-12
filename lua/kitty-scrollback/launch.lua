---@mod kitty-scrollback.launch

---@module 'kitty-scrollback.windows'
local ksb_win
---@module 'kitty-scrollback.footer_win'
local ksb_footer_win
---@module 'kitty-scrollback.highlights'
local ksb_hl
---@module 'kitty-scrollback.api'
local ksb_api
---@module 'kitty-scrollback.keymaps'
local ksb_keymaps
---@module 'kitty-scrollback.kitty_commands'
local ksb_kitty_cmds
---@module 'kitty-scrollback.util'
local ksb_util
---@module 'kitty-scrollback.autocommands'
local ksb_autocmds
---@module 'kitty-scrollback.health'
local ksb_health

local M = {}

---@class KsbKittyOpts
---@field shell_integration table
---@field scrollback_fill_enlarged_window boolean
---@field scrollback_lines integer
---@field scrollback_pager table
---@field scrollback_pager_history_size integer
---@field allow_remote_control string 'password' | 'socket-only' | 'socket' | 'no' | 'n' | 'false' | 'yes' | 'y' | 'true'
---@field listen_on string

---@class KsbKittyData
---@field scrolled_by integer the number of lines currently scrolled in kitty
---@field cursor_x integer position of the cusor in the column in kitty
---@field cursor_y integer position of the cursor in the row in kitty
---@field lines integer the number of rows of the screen in kitty
---@field columns integer the number of columns of the screen in kitty
---@field window_id integer the id of the window to get scrollback text
---@field ksb_dir string the base runtime path of kitty-scrollback.nvim
---@field config_files table<string> the file containing a config function with user defined options
---@field kitty_opts KsbKittyOpts relevent kitty configuration values
---@field kitty_config_dir string kitty configuration directory path
---@field kitty_version table kitty version

---@class KsbPrivate
---@field orig_columns number
---@field bufid number?
---@field paste_bufid number?
---@field kitty_loading_winid number?
---@field kitty_colors table
---@field kitty_data KsbKittyData
---@field paste_winid number?
---@field footer_winid number?
---@field footer_bufid number?
---@field pos table?
local p = {}

---@type KsbOpts
local opts = {}

---@class KsbCallbacks
---@field after_setup fun(kitty_data:KsbKittyData, opts:KsbOpts)? callback executed after initializing kitty-scrollback.nvim
---@field after_launch fun(kitty_data:KsbKittyData, opts:KsbOpts)? callback executed after launch started to process the scrollback buffer
---@field after_ready fun(kitty_data:KsbKittyData, opts:KsbOpts)? callback executed after scrollback buffer is loaded and cursor is positioned

---@class KsbKittyGetText
---@field ansi boolean If true, the text will include the ANSI formatting escape codes for colors, bold, italic, etc.
---@field clear_selection boolean If true, clear the selection in the matched window, if any.
---@field extent string | 'screen' | 'all' | 'selection' | 'first_cmd_output_on_screen' | 'last_cmd_output' | 'last_visited_cmd_output' | 'last_non_empty_output'     What text to get. The default of screen means all text currently on the screen. all means all the screen+scrollback and selection means the currently selected text. first_cmd_output_on_screen means the output of the first command that was run in the window on screen. last_cmd_output means the output of the last command that was run in the window. last_visited_cmd_output means the first command output below the last scrolled position via scroll_to_prompt. last_non_empty_output is the output from the last command run in the window that had some non empty output. The last four require shell_integration to be enabled. Choices: screen, all, first_cmd_output_on_screen, last_cmd_output, last_non_empty_output, last_visited_cmd_output, selection

---@class KsbStatusWindowOpts
---@field enabled boolean If true, show status window in upper right corner of the screen
---@field style_simple boolean If true, use plaintext instead of nerd font icons
---@field autoclose boolean If true, close the status window after kitty-scrollback.nvim is ready
---@field show_timer boolean If true, show a timer in the status window while kitty-scrollback.nvim is loading

---@alias KsbWinOpts table<string, any>

---@class KsbPasteWindowOpts
---@field highlight_as_normal_win? fun(): boolean If function returns true, use Normal highlight group. If false, use NormalFloat
---@field filetype string? The filetype of the paste window
---@field hide_footer? boolean If true, hide the footer when the paste window is initially opened
---@field winblend? integer The winblend setting of the window, see :help winblend
---@field winopts_overrides? fun(paste_winopts:KsbWinOpts): KsbWinOpts Paste float window overrides, see nvim_open_win() for configuration
---@field footer_winopts_overrides? fun(footer_winopts:KsbWinOpts, paste_winopts:KsbWinOpts): KsbWinOpts Paste footer window overrides, see nvim_open_win() for configuration

---@class KsbOpts
---@field callbacks KsbCallbacks? fire and forget callback functions
---@field keymaps_enabled boolean? if true, enabled all default keymaps
---@field restore_options boolean? if true, restore options that were modified while processing the scrollback buffer
---@field highlight_overrides KsbHighlights? kitty-scrollback.nvim highlight overrides
---@field status_window KsbStatusWindowOpts? options for status window indicating that kitty-scrollback.nvim is ready
---@field paste_window KsbPasteWindowOpts?  options for paste window that sends commands to Kitty
---@field kitty_get_text KsbKittyGetText? options passed to get-text when reading scrollback buffer, see `kitty @ get-text --help`
---@field checkhealth boolean? if true execute :checkhealth kitty-scrollback and skip setup
local default_opts = {
  callbacks = nil,
  keymaps_enabled = true,
  restore_options = false,
  highlight_overrides = nil,
  status_window = {
    enabled = true,
    style_simple = false,
    autoclose = false,
    show_timer = false,
  },
  paste_window = {
    highlight_as_normal_win = nil,
    filetype = nil,
    hide_footer = false,
    winblend = 0,
    winopts_overrides = nil,
    footer_winopts_overrides = nil,
  },
  kitty_get_text = {
    ansi = true,
    extent = 'all',
    clear_selection = true,
  },
  checkhealth = false,
}

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
    report = vim.o.report,
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
  vim.o.report = 999999 -- arbitrary large number to hide yank messages
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
    p.pos = {
      cursor_line = vim.fn.line('.'),
      buf_last_line = vim.fn.line('$'),
      win_first_line = vim.fn.line('w0'),
      win_last_line = vim.fn.line('w$'),
      col = x,
    }

    vim.o.scrolloff = orig_scrollof
    vim.o.showtabline = orig_showtabline
    vim.o.laststatus = orig_laststatus
    vim.o.virtualedit = orig_virtualedit
  end
)

local function load_requires()
  -- add to runtime to allow loading modules via require
  vim.opt.runtimepath:append(p.kitty_data.ksb_dir)
  ksb_win = require('kitty-scrollback.windows')
  ksb_footer_win = require('kitty-scrollback.footer_win')
  ksb_hl = require('kitty-scrollback.highlights')
  ksb_api = require('kitty-scrollback.api')
  ksb_keymaps = require('kitty-scrollback.keymaps')
  ksb_kitty_cmds = require('kitty-scrollback.kitty_commands')
  ksb_util = require('kitty-scrollback.util')
  ksb_autocmds = require('kitty-scrollback.autocommands')
  ksb_health = require('kitty-scrollback.health')
end

---Setup and configure kitty-scrollback.nvim
---@param kitty_data_str string
M.setup = function(kitty_data_str)
  p.kitty_data = vim.fn.json_decode(kitty_data_str)
  load_requires() -- must be after p.kitty_data initialized

  local user_opts = {}
  if p.kitty_data.config_files and next(p.kitty_data.config_files) then
    for _, config in pairs(p.kitty_data.config_files) do
      user_opts = vim.tbl_extend('keep', user_opts, dofile(config).config(p.kitty_data) or {})
      vim.print(user_opts)
    end
  end
  opts = vim.tbl_deep_extend('force', default_opts, user_opts)

  ksb_health.setup(p, opts)
  if opts.checkhealth then
    vim.o.foldenable = false
    vim.cmd.checkhealth('kitty-scrollback')
    return
  end
  if not ksb_health.check_nvim_version(true) then
    local prompt_msg = 'kitty-scrollback.nvim: Fatal error, on version NVIM ' ..
      ksb_util.nvim_version_tostring() .. '. ' .. table.concat(ksb_health.advice().nvim_version)
    local response = vim.fn.confirm(prompt_msg, '&Quit\n&Continue')
    if response ~= 2 then
      ksb_kitty_cmds.signal_term_to_kitty_child_process(true)
    end
  end
  if not ksb_health.check_kitty_version(true) then
    local prompt_msg = 'kitty-scrollback.nvim: Fatal error, on version kitty ' ..
      table.concat(p.kitty_data.kitty_version, '.') .. '. ' .. table.concat(ksb_health.advice().kitty_version)
    local response = vim.fn.confirm(prompt_msg, '&Quit\n&Continue')
    if response ~= 2 then
      ksb_kitty_cmds.signal_term_to_kitty_child_process(true)
    end
  end

  ksb_util.setup(p, opts)
  ksb_kitty_cmds.setup(p, opts)
  ksb_win.setup(p, opts)
  ksb_footer_win.setup(p, opts)
  ksb_autocmds.setup(p, opts)
  ksb_api.setup(p, opts)
  ksb_keymaps.setup(p, opts)
  local ok = ksb_hl.setup(p, opts)
  if ok then
    ksb_hl.set_highlights()
    ksb_kitty_cmds.open_kitty_loading_window(ksb_hl.get_highlights_as_env()) -- must be after opts and set highlights
  end
  set_options()

  if opts.callbacks and opts.callbacks.after_setup and type(opts.callbacks.after_setup) == 'function' then
    opts.callbacks.after_setup(p.kitty_data, opts)
  end

  return true
end

local function validate_extent(extent)
  if ksb_health.is_valid_extent_keyword(extent) then
    return true
  end
  ksb_kitty_cmds.close_kitty_loading_window()
  local msg = vim.list_extend({
    '',
    '==============================================================================',
    'kitty-scrollback.nvim',
    '',
    'ERROR: Kitty shell integration is disabled and/or `no-prompt-mark` is set',
    '',
    'The option *' .. opts.kitty_get_text.extent .. '* requires Kitty shell integration and prompt marks to be enabled. ',
  }, ksb_health.advice().kitty_shell_integration)
  local error_bufid = vim.api.nvim_create_buf(false, true)
  vim.o.conceallevel = 2
  vim.o.concealcursor = 'n'
  vim.api.nvim_set_option_value('filetype', 'checkhealth', {
    buf = error_bufid,
  })
  local prompt_msg = 'kitty-scrollback.nvim: Fatal error, see logs.'
  vim.api.nvim_set_current_buf(error_bufid)
  vim.api.nvim_buf_set_lines(error_bufid, 0, -1, false, msg)
  vim.cmd.redraw()
  local response = vim.fn.confirm(prompt_msg, '&Quit\n&Continue')
  if response ~= 2 then
    ksb_kitty_cmds.signal_term_to_kitty_child_process()
  end
  return false
end

---Launch kitty-scrollack.nvim with configured scrollback buffer
M.launch = function()
  local kitty_data = p.kitty_data
  vim.schedule(function()
    p.bufid = vim.api.nvim_get_current_buf()

    ksb_autocmds.load_autocmds()

    local ansi = '--ansi'
    if not opts.kitty_get_text.ansi then
      ansi = ''
    end

    local clear_selection = '--clear-selection'
    if not opts.kitty_get_text.clear_selection then
      clear_selection = ''
    end

    local extent = '--extent=all'
    local extent_opt = opts.kitty_get_text.extent
    if not validate_extent(extent_opt or 'all') then
      return
    end
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
            ksb_kitty_cmds.signal_winchanged_to_kitty_child_process()
            vim.fn.timer_start(
              20,
              function(t) ---@diagnostic disable-line: redundant-parameter
                local timer_info = vim.fn.timer_info(t)[1] or {}
                local ready = ksb_util.remove_process_exited()
                if ready or timer_info['repeat'] == 0 then
                  vim.fn.timer_stop(t)

                  if opts.kitty_get_text.extent == 'screen' or opts.kitty_get_text.extent == 'all' then
                    set_cursor_position(kitty_data)
                  end
                  ksb_win.show_status_window()

                  -- improve buffer name to avoid displaying complex command to user
                  local term_buf_name = vim.api.nvim_buf_get_name(p.bufid)
                  term_buf_name = term_buf_name:gsub(':kitty.*$', ':kitty-scrollback.nvim')
                  vim.api.nvim_buf_set_name(p.bufid, term_buf_name)
                  vim.api.nvim_buf_delete(vim.fn.bufnr('#'), { force = true }) -- delete alt buffer after rename

                  ksb_kitty_cmds.close_kitty_loading_window()
                  if opts.restore_options then
                    restore_orig_options()
                  end
                  if opts.callbacks and opts.callbacks.after_ready and type(opts.callbacks.after_ready) == 'function' then
                    vim.cmd.redraw()
                    vim.schedule(function()
                      opts.callbacks.after_ready(kitty_data, opts)
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
    if opts.callbacks and opts.callbacks.after_launch and type(opts.callbacks.after_launch) == 'function' then
      vim.schedule(function()
        opts.callbacks.after_launch(kitty_data, opts)
      end)
    end
  end)
end


---Setup and launch kitty-scrollback.nvim
---@param kitty_data_str string
M.setup_and_launch = function(kitty_data_str)
  local ok = M.setup(kitty_data_str)
  if ok then
    M.launch()
  end
end

return M
