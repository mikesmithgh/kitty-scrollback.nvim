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
---@module 'kitty-scrollback.tmux_commands'
local ksb_tmux_cmds
---@module 'kitty-scrollback.util'
local ksb_util
---@module 'kitty-scrollback.autocommands'
local ksb_autocmds
---@module 'kitty-scrollback.health'
local ksb_health
---@module 'kitty-scrollback.configs.defaults'
local ksb_configs_defaults

local M = {}

---@class KsbKittyOpts
---@field shell_integration table
---@field scrollback_fill_enlarged_window boolean
---@field scrollback_lines integer
---@field scrollback_pager table
---@field scrollback_pager_history_size integer
---@field allow_remote_control string 'password' | 'socket-only' | 'socket' | 'no' | 'n' | 'false' | 'yes' | 'y' | 'true'
---@field listen_on string

---@class KsbTmuxData
---@field socket_path string server socket path
---@field pid string server PID
---@field session_id string unique session ID
---@field pane_id string unique pane ID

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
---@field tmux KsbTmuxData|nil tmux data
---@field shell string kitty shell program to execute

---@class KsbPrivate
---@field orig_columns number
---@field orig_normal_hl table|nil
---@field bufid integer|nil the buffer ID of the scrollback buffer
---@field winid integer|nil the initial window ID of the scrollback buffer, this ID is not always guaranteed to be correct if the user has modified the window layout
---@field kitty_loading_winid number|nil the ID of the kitty overlay loading window, this is kitty window not a nvim window
---@field kitty_colors table
---@field kitty_data KsbKittyData
---@field paste_winid integer|nil the window ID of the paste window
---@field paste_bufid integer|nil the buffer ID of the paste window
---@field footer_winid integer|nil the window ID of the paste window footer
---@field footer_bufid integer|nil the buffer ID of the paste window footer
---@field pos table|nil
local p = {}

---@type KsbOpts
local opts = {}

local block_input_timer

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
  vim.opt.shortmess:append('AI') -- no existing swap file or intro message
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
  local tab_offset = ksb_util.line_offset()
  local x = d.cursor_x - 1
  local y = d.cursor_y - 1 - tab_offset
  local scrolled_by = d.scrolled_by
  local lines = d.lines - tab_offset
  if p.kitty_data.tmux and next(p.kitty_data.tmux) then
    local ok, status_option = ksb_tmux_cmds.show_status_option()
    if ok then
      lines = lines - status_option
    end
  end
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
  ---@diagnostic disable-next-line: param-type-mismatch
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
  ksb_tmux_cmds = require('kitty-scrollback.tmux_commands')
  ksb_util = require('kitty-scrollback.util')
  ksb_autocmds = require('kitty-scrollback.autocommands')
  ksb_health = require('kitty-scrollback.health')
  ksb_configs_defaults = require('kitty-scrollback.configs.defaults')
end

local function config_to_opts(config)
  if type(config) == 'function' then
    config = config(p.kitty_data)
  end
  return type(config) == 'table' and config or {}
end

---Setup and configure kitty-scrollback.nvim
---@param kitty_data_str string
M.setup = function(kitty_data_str)
  -- block user input for a short period of time during startup to prevent unwanted mode changes and unexpected behavior
  block_input_timer = vim.fn.timer_start(25, function()
    pcall(vim.fn.getchar, 0)
  end, { ['repeat'] = 80 }) -- 2 seconds

  p.kitty_data = vim.fn.json_decode(kitty_data_str)
  load_requires() -- must be after p.kitty_data initialized

  -- if a config at the first index found, that will be applied to all configurations regardless of prefix
  -- if a config name is prefixed 'ksb_builtin_', the user's config will be merged with configs/builtin.lua
  -- if a config does not meet the above criteria, check if a user had defined a configuration with the given config name and use that

  local config_name = p.kitty_data.kitty_scrollback_config or 'ksb_builtin_get_text_all'
  local config_source = require('kitty-scrollback')
  local global_opts = config_to_opts(config_source.configs[1])
  local user_config = config_source.configs[config_name]
  if not user_config and not config_name:match('^ksb_builtin_.*') then
    local orig_config_name = config_name
    vim.defer_fn(function()
      vim.notify(
        'kitty-scrollback.nvim: no configuration found with the name "' .. orig_config_name .. '"',
        vim.log.levels.ERROR,
        {}
      )
    end, 1000)
    config_name = 'ksb_builtin_get_text_all'
    user_config = config_source.configs[config_name]
  end
  local user_opts = config_to_opts(user_config)
  local builtin_opts = {}
  if config_name:match('^ksb_builtin_.*') then
    builtin_opts = config_to_opts(require('kitty-scrollback.configs.builtin')[config_name])
  end
  opts = vim.tbl_deep_extend('force', ksb_configs_defaults, global_opts, builtin_opts, user_opts)

  ksb_health.setup(p, opts)
  if opts.checkhealth then
    vim.o.foldenable = false
    vim.cmd('checkhealth kitty-scrollback') -- prefer vim.cmd('checkhealth') over vim.cmd.checkhealth to support older versions of neovim
    return
  end
  if not ksb_health.check_nvim_version('nvim-0.10', true) then
    local prompt_msg = 'kitty-scrollback.nvim: Fatal error, on version NVIM '
      .. ksb_health.nvim_version()
      .. '. '
      .. table.concat(ksb_health.advice.nvim_version)
    vim.fn.confirm(prompt_msg, '&Quit')
    ksb_util.quitall()
  end
  if not ksb_health.check_kitty_version(true) then
    local prompt_msg = 'kitty-scrollback.nvim: Fatal error, on version kitty '
      .. table.concat(p.kitty_data.kitty_version, '.')
      .. '.\n\n'
      .. table.concat(ksb_health.advice.kitty_version, '\n')
      .. '\n'
    vim.fn.confirm(prompt_msg, '&Quit')
    ksb_util.quitall()
  end

  set_env()
  set_options()

  ksb_util.setup(p, opts)
  ksb_kitty_cmds.setup(p, opts)
  ksb_tmux_cmds.setup(p, opts)
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

---@class KsbKittyGetTextArguments
---@field kitty string kitty args for get-text
---@field tmux string tmux args for capture-pane

---@return KsbKittyGetTextArguments
local function get_text_opts()
  local ansi = '--ansi'
  local tmux_ansi = '-e'
  if not opts.kitty_get_text.ansi then
    ansi = ''
    tmux_ansi = ''
  end

  local clear_selection = '--clear-selection'
  if not opts.kitty_get_text.clear_selection then
    clear_selection = ''
  end

  local extent = '--extent=all'
  local tmux_extent = '-S - -E -'
  local extent_opt = opts.kitty_get_text.extent
  if extent_opt then
    extent = '--extent=' .. extent_opt
    if extent_opt == 'screen' then
      tmux_extent = '-S 0 -E -'
    end
  end

  -- always add wrap markers, wrap markers are important to add blank lines with /r to
  -- fill the screen when setting the cursor position
  local add_wrap_markers = '--add-wrap-markers'
  local tmux_add_wrap_markers = '-J'

  return {
    kitty = ansi .. ' ' .. clear_selection .. ' ' .. add_wrap_markers .. ' ' .. extent,
    tmux = tmux_ansi .. ' ' .. tmux_add_wrap_markers .. ' ' .. tmux_extent,
  }
end

---Launch kitty-scrollack.nvim with configured scrollback buffer
M.launch = function()
  vim.schedule(function()
    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, 1, false)
    local no_buf_content = vim.api.nvim_buf_line_count(0) == 1 and buf_lines[1] == ''
    if no_buf_content then
      p.bufid = vim.api.nvim_get_current_buf()
    else
      -- buffer must be empty for the terminal, dashboard plugins may write to the first buffer before kitty-scrollback.nvim loads
      p.bufid = vim.api.nvim_create_buf(true, true)
      vim.api.nvim_set_current_buf(p.bufid)
    end
    vim.api.nvim_set_option_value('swapfile', false, { buf = p.bufid })
    p.winid = vim.api.nvim_get_current_win()

    ksb_autocmds.load_autocmds()

    vim.schedule(function()
      ksb_kitty_cmds.get_text_term(get_text_opts(), function()
        ksb_kitty_cmds.signal_winchanged_to_kitty_child_process()
        if opts.kitty_get_text.extent == 'screen' or opts.kitty_get_text.extent == 'all' then
          set_cursor_position(p.kitty_data)
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

        local alternate_file_bufnr = vim.fn.bufnr('#')
        if alternate_file_bufnr > 0 then
          vim.api.nvim_buf_delete(alternate_file_bufnr, { force = true }) -- delete alt buffer after rename
        else
          ksb_util.display_error({
            [[- ERROR alternate file not found]],
            [[  `vim.fn.bufnr('#')` is ]]
              .. alternate_file_bufnr
              .. [[. Most likely `]]
              .. ksb_kitty_cmds.open_term_command
              .. [[` failed. ]],
            [[  Please report the issue at https://github.com/mikesmithgh/kitty-scrollback.nvim/issues]],
            [[  and provide the `KittyScrollbackCheckHealth` report.]],
          })
          ksb_api.close_kitty_loading_window()
          if block_input_timer then
            vim.fn.timer_stop(block_input_timer)
          end
          return
        end

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
            opts.callbacks.after_ready(p.kitty_data, opts)
          end)
        end
        if ksb_util.command_line_editing_mode then
          vim.schedule(function()
            local input = ksb_util.command_line_editing_mode_input
            if input == nil or input == '' then
              vim.notify(
                'kitty-scrollback.nvim: no input file found in environment variable KITTY_SCROLLBACK_NVIM_EDIT_INPUT',
                vim.log.levels.ERROR,
                {}
              )
            else
              local input_lines = vim.fn.readfile(input)
              ksb_win.open_paste_window(#input_lines == 1 and input_lines[1] == '')
              vim.api.nvim_buf_set_lines(p.paste_bufid, 0, -1, false, input_lines)
            end
          end)
        end
        ksb_api.close_kitty_loading_window()
        if block_input_timer then
          vim.fn.timer_stop(block_input_timer)
        end
      end)
    end)
    if
      opts.callbacks
      and opts.callbacks.after_launch
      and type(opts.callbacks.after_launch) == 'function'
    then
      vim.schedule(function()
        opts.callbacks.after_launch(p.kitty_data, opts)
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
