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
---@module 'kitty-scrollback.backport'
local ksb_backport

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
---@field window_title string the title of the window to get scrollback text
---@field ksb_dir string the base runtime path of kitty-scrollback.nvim
---@field kitty_scrollback_config string the config name of user config options
---@field kitty_opts KsbKittyOpts relevant kitty configuration values
---@field kitty_config_dir string kitty configuration directory path
---@field kitty_version table kitty version
---@field kitty_path string kitty executable path

---@class KsbPrivate
---@field orig_columns number
---@field orig_normal_hl table|nil
---@field bufid number|nil
---@field paste_bufid number|nil
---@field kitty_loading_winid number|nil
---@field kitty_colors table
---@field kitty_data KsbKittyData
---@field paste_winid number|nil
---@field footer_winid number|nil
---@field footer_bufid number|nil
---@field pos table|nil
local p = {}

---@type KsbOpts
local opts = {}

---@class KsbCallbacks
---@field after_setup fun(kitty_data:KsbKittyData, opts:KsbOpts)|nil callback executed after initializing kitty-scrollback.nvim
---@field after_launch fun(kitty_data:KsbKittyData, opts:KsbOpts)|nil callback executed after launch started to process the scrollback buffer
---@field after_ready fun(kitty_data:KsbKittyData, opts:KsbOpts)|nil callback executed after scrollback buffer is loaded and cursor is positioned

---@class KsbKittyGetText
---@field ansi boolean If true, the text will include the ANSI formatting escape codes for colors, bold, italic, etc.
---@field clear_selection boolean If true, clear the selection in the matched window, if any.
---@field extent string | 'screen' | 'all' | 'selection' | 'first_cmd_output_on_screen' | 'last_cmd_output' | 'last_visited_cmd_output' | 'last_non_empty_output'     What text to get. The default of screen means all text currently on the screen. all means all the screen+scrollback and selection means the currently selected text. first_cmd_output_on_screen means the output of the first command that was run in the window on screen. last_cmd_output means the output of the last command that was run in the window. last_visited_cmd_output means the first command output below the last scrolled position via scroll_to_prompt. last_non_empty_output is the output from the last command run in the window that had some non empty output. The last four require shell_integration to be enabled. Choices: screen, all, first_cmd_output_on_screen, last_cmd_output, last_non_empty_output, last_visited_cmd_output, selection

---@class KsbStatusWindowIcons
---@field kitty string kitty status window icon, defaults to 󰄛
---@field heart string heart status window icon, defaults to 󰣐
---@field nvim string nvim status window icon, defaults to 

---@class KsbStatusWindowOpts
---@field enabled boolean If true, show status window in upper right corner of the screen
---@field style_simple boolean If true, use plaintext instead of nerd font icons
---@field autoclose boolean If true, close the status window after kitty-scrollback.nvim is ready
---@field show_timer boolean If true, show a timer in the status window while kitty-scrollback.nvim is loading
---@field icons KsbStatusWindowIcons Icons displayed in the status window, defaults to 󰄛 󰣐 

---@alias KsbWinOpts table<string, any>

---@alias KsbWinOptsOverrideFunction fun(paste_winopts:KsbWinOpts):KsbWinOpts
---@alias KsbFooterWinOptsOverrideFunction fun(footer_winopts:KsbWinOpts, paste_winopts:KsbWinOpts):KsbWinOpts

---@class KsbPasteWindowOpts
---@field highlight_as_normal_win nil|fun():boolean If function returns true, use Normal highlight group. If false, use NormalFloat
---@field filetype string|nil The filetype of the paste window
---@field hide_footer boolean|nil If true, hide mappings in the footer when the paste window is initially opened
---@field winblend integer|nil The winblend setting of the window, see :help winblend
---@field winopts_overrides KsbWinOptsOverrideFunction|nil Paste float window overrides, see nvim_open_win() for configuration
---@field footer_winopts_overrides KsbFooterWinOptsOverrideFunction|nil Paste footer window overrides, see nvim_open_win() for configuration
---@field yank_register string|nil register used during yanks to paste window, see :h registers
---@field yank_register_enabled boolean|nil If true, the `yank_register` copies content to the paste window. If false, disable yank to paste window

---@class KsbOpts
---@field callbacks KsbCallbacks|nil fire and forget callback functions
---@field keymaps_enabled boolean|nil if true, enabled all default keymaps
---@field restore_options boolean|nil if true, restore options that were modified while processing the scrollback buffer
---@field highlight_overrides KsbHighlights|nil kitty-scrollback.nvim highlight overrides
---@field status_window KsbStatusWindowOpts|nil options for status window indicating that kitty-scrollback.nvim is ready
---@field paste_window KsbPasteWindowOpts|nil  options for paste window that sends commands to Kitty
---@field kitty_get_text KsbKittyGetText|nil options passed to get-text when reading scrollback buffer, see `kitty @ get-text --help`
---@field checkhealth boolean|nil if true execute :checkhealth kitty-scrollback and skip setup
---@field visual_selection_highlight_mode string | 'darken' | 'kitty' | 'nvim' | 'reverse' | nil
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
    icons = {
      kitty = '󰄛',
      heart = '󰣐', -- variants 󰣐 |  |  | ♥ |  | 󱢠 | 
      nvim = '', -- variants  |  |  | 
    },
  },
  paste_window = {
    highlight_as_normal_win = nil,
    filetype = nil,
    hide_footer = false,
    winblend = 0,
    winopts_overrides = nil,
    footer_winopts_overrides = nil,
    yank_register = '',
    yank_register_enabled = true,
  },
  kitty_get_text = {
    ansi = true,
    extent = 'all',
    clear_selection = true,
  },
  checkhealth = false,
  visual_selection_highlight_mode = 'darken',
}

local function restore_orig_options()
  for option, value in pairs(p.orig_options) do
    vim.o[option] = value
  end
end

local function set_env()
  -- kitten ssh prompts for the user's password if KITTY_KITTEN_RUN_MODULE is ssh_askpass
  -- which causes kitty-scrollback.nvim to hang waiting on input that is not visible.
  -- Clear KITTY_KITTEN_RUN_MODULE to avoid this issue over kitten ssh.
  -- See:
  --   - https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/99
  --   - https://sw.kovidgoyal.net/kitty/kittens/ssh/
  --   - https://github.com/kovidgoyal/kitty/blob/b2587c1d54ff674d2c925ff28b2e16e394794838/tools/cmd/main.go#L15
  vim.env.KITTY_KITTEN_RUN_MODULE = nil
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
    shell = vim.o.shell,
  }

  -- required opts
  vim.o.virtualedit = 'all' -- all or onemore for correct position
  vim.o.termguicolors = true

  -- preferred optional opts
  vim.opt.shortmess:append('I') -- no intro message
  vim.o.laststatus = 0
  vim.o.scrolloff = 0
  vim.o.cmdheight = 0
  vim.o.ruler = false
  vim.o.number = false
  vim.o.relativenumber = false
  vim.o.scrollback = 100000
  vim.o.list = false
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

  -- not necessary to set vim.o.showtabline because tab offset is taken into account during positioning
end

local set_cursor_position = vim.schedule_wrap(function(d)
  local tab_offset = ksb_util.tab_offset()
  local x = d.cursor_x - 1
  local y = d.cursor_y - 1 - tab_offset
  local scrolled_by = d.scrolled_by
  local lines = d.lines - tab_offset
  if y < 0 then
    -- adjust when on first line of terminal
    lines = lines + math.abs(y)
    y = 0
  end
  local last_line = vim.fn.line('$')

  local orig_virtualedit = vim.o.virtualedit
  local orig_scrolloff = vim.o.scrolloff
  local orig_laststatus = vim.o.laststatus
  vim.o.scrolloff = 0
  vim.o.laststatus = 0
  vim.o.virtualedit = 'all'
  vim.fn.cursor(last_line, 1) -- cursor last line
  -- using normal commands instead of cursor pos due to virtualedit
  if lines ~= 0 then
    vim.cmd.normal({ lines .. 'k', bang = true }) -- cursor up
  end
  if y ~= 0 then
    vim.cmd.normal({ y .. 'j', bang = true }) -- cursor down
  end
  if x ~= 0 then
    vim.cmd.normal({ x .. 'l', bang = true }) -- cursor right
  end
  if scrolled_by > 0 then
    -- scroll up
    vim.cmd.normal({
      vim.api.nvim_replace_termcodes(scrolled_by .. '<C-y>', true, false, true),
      bang = true,
    })
  end
  p.pos = {
    cursor_line = vim.fn.line('.'),
    buf_last_line = vim.fn.line('$'),
    win_first_line = vim.fn.line('w0'),
    win_last_line = vim.fn.line('w$'),
    col = x,
  }

  vim.o.scrolloff = orig_scrolloff
  vim.o.laststatus = orig_laststatus
  vim.o.virtualedit = orig_virtualedit
end)

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
  ksb_backport = require('kitty-scrollback.backport')
end

---Setup and configure kitty-scrollback.nvim
---@param kitty_data_str string
M.setup = function(kitty_data_str)
  p.kitty_data = vim.fn.json_decode(kitty_data_str)
  load_requires() -- must be after p.kitty_data initialized

  -- if a config named 'global' is found, that will be applied to all configurations regardless of prefix
  -- if a config name is prefixed 'ksb_builtin_', only configs in configs/builtin.lua will be referenced. The one exception is the config named 'global'
  -- if a config name is prefixed 'ksb_example_', only configs in configs/example.lua will be referenced. The one exception is the config named 'global'
  -- if a config does not meet the above criteria, check if a user had defined a configuration with the given config name and use that

  local config_name = p.kitty_data.kitty_scrollback_config or 'default'
  local config_source = require('kitty-scrollback')
  local global_fn = config_source.configs['global']
  local global_opts = global_fn and global_fn(p.kitty_data) or {}
  if config_name:match('^ksb_builtin_.*') then
    config_source = require('kitty-scrollback.configs.builtin')
  end
  if config_name:match('^ksb_example_.*') then
    config_source = require('kitty-scrollback.configs.example')
  end
  local config_fn = config_source.configs[config_name]
  local user_opts = config_fn and config_fn(p.kitty_data) or {}
  opts = vim.tbl_deep_extend('force', default_opts, global_opts, user_opts)

  ksb_backport.setup()
  ksb_health.setup(p, opts)
  if opts.checkhealth then
    vim.o.foldenable = false
    vim.cmd.checkhealth('kitty-scrollback')
    return
  end
  if not ksb_health.check_nvim_version('nvim-0.9', true) then
    local prompt_msg = 'kitty-scrollback.nvim: Fatal error, on version NVIM '
      .. tostring(vim.version())
      .. '. '
      .. table.concat(ksb_health.advice().nvim_version)
    local response = vim.fn.confirm(prompt_msg, '&Quit\n&Continue')
    if response ~= 2 then
      ksb_kitty_cmds.signal_term_to_kitty_child_process(true)
    end
  end
  if not ksb_health.check_kitty_version(true) then
    local prompt_msg = 'kitty-scrollback.nvim: Fatal error, on version kitty '
      .. table.concat(p.kitty_data.kitty_version, '.')
      .. '. '
      .. table.concat(ksb_health.advice().kitty_version)
    local response = vim.fn.confirm(prompt_msg, '&Quit\n&Continue')
    if response ~= 2 then
      ksb_kitty_cmds.signal_term_to_kitty_child_process(true)
    end
  end

  set_env()
  set_options()

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
    if ksb_hl.has_default_or_vim_colorscheme() then
      vim.api.nvim_set_hl(0, 'Normal', p.orig_normal_hl)
    end
  end

  if
    opts.callbacks
    and opts.callbacks.after_setup
    and type(opts.callbacks.after_setup) == 'function'
  then
    opts.callbacks.after_setup(p.kitty_data, opts)
  end

  return true
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
    if extent_opt then
      extent = '--extent=' .. extent_opt
    end

    local add_cursor = '--add-cursor' -- always add cursor

    local get_text_opts = ansi .. ' ' .. clear_selection .. ' ' .. add_cursor .. ' ' .. extent

    -- increase the number of columns temporary so that the width is used during the
    -- terminal command kitty @ get-text. this avoids hard wrapping lines to the
    -- current window size. Note: a larger min_cols appears to impact performance
    local min_cols = 300
    p.orig_columns = vim.o.columns
    if vim.o.columns < min_cols then
      vim.o.columns = min_cols
    end
    vim.schedule(function()
      ksb_kitty_cmds.get_text_term(kitty_data, get_text_opts, function()
        -- NOTE(#58): nvim v0.9 support
        -- vim.o.columns is resized automatically in nvim v0.9.1 when we trigger kitty so send a SIGWINCH signal
        -- vim.o.columns is explicitly set to resize appropriatley on v0.9.0
        -- see https://github.com/neovim/neovim/pull/23503
        vim.o.columns = p.orig_columns

        ksb_kitty_cmds.signal_winchanged_to_kitty_child_process()
        if opts.kitty_get_text.extent == 'screen' or opts.kitty_get_text.extent == 'all' then
          set_cursor_position(kitty_data)
        end
        ksb_win.show_status_window()

        -- improve buffer name to avoid displaying complex command to user
        local term_buf_name = vim.api.nvim_buf_get_name(p.bufid)
        term_buf_name = term_buf_name:gsub('^(term://.-:).*', '%1kitty-scrollback.nvim')
        vim.api.nvim_buf_set_name(p.bufid, term_buf_name)
        vim.api.nvim_set_option_value(
          'winhighlight',
          'Normal:KittyScrollbackNvimNormal,Visual:KittyScrollbackNvimVisual',
          {
            scope = 'local',
            win = 0,
          }
        )
        vim.api.nvim_buf_delete(vim.fn.bufnr('#'), { force = true }) -- delete alt buffer after rename

        if opts.restore_options then
          restore_orig_options()
        end
        vim.api.nvim_set_option_value('filetype', 'kitty-scrollback', {
          buf = p.bufid,
        })
        if
          opts.callbacks
          and opts.callbacks.after_ready
          and type(opts.callbacks.after_ready) == 'function'
        then
          ksb_util.restore_and_redraw()
          vim.schedule(function()
            opts.callbacks.after_ready(kitty_data, opts)
          end)
        end
        ksb_api.close_kitty_loading_window()
      end)
    end)
    if
      opts.callbacks
      and opts.callbacks.after_launch
      and type(opts.callbacks.after_launch) == 'function'
    then
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
