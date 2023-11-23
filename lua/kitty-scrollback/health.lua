local ksb_util = require('kitty-scrollback.util')
---@mod kitty-scrollback.health
local M = {}

---@type KsbPrivate
local p

---@type KsbOpts
local opts ---@diagnostic disable-line: unused-local

M.setup = function(private, options)
  p = private
  opts = options ---@diagnostic disable-line: unused-local
end

local start_health = vim.health.start or vim.health.report_start
local ok_health = vim.health.ok or vim.health.report_ok
local warn_health = vim.health.warn or vim.health.report_warn
local error_health = vim.health.error or vim.health.report_error

local function check_kitty_remote_control()
  start_health('kitty-scrollback: Kitty remote control')
  local cmd = {
    'kitty',
    '@',
    'ls',
  }
  local sys_opts = {}
  local proc = vim.system(cmd, sys_opts or {})
  local result = proc:wait()
  local ok = result.code == 0
  local code_msg = '`kitty @ ls` exited with code *' .. result.code .. '*'
  if ok then
    ok_health(code_msg)
    return true
  else
    local stderr = result.stderr:gsub('\n', '') or ''
    local msg = {}
    if stderr:match('.*/dev/tty.*') then
      msg = M.advice().listen_on
    end
    if stderr:match('.*allow_remote_control.*') then
      msg = M.advice().allow_remote_control
    end
    local advice = {
      table.concat(msg, '\n'),
    }
    local kitty_opts = {}
    if type(p) == 'table' and next(p.kitty_data) then
      kitty_opts = p.kitty_data.kitty_opts
      table.insert(
        advice,
        table.concat({
          '*allow_remote_control* and *listen_on* are currently configured as:',
          '  `allow_remote_control ' .. kitty_opts.allow_remote_control .. '`',
          '  `listen_on ' .. kitty_opts.listen_on .. '`',
        }, '\n')
      )
    else
      table.insert(advice, 'ERROR Failed to read `allow_remote_control` and `listen_on`')
    end
    error_health(code_msg .. '\n      `' .. stderr .. '` ', advice)
  end
  return false
end

local function check_has_kitty_data()
  start_health('kitty-scrollback: Kitty data')
  if type(p) == 'table' and next(p.kitty_data) then
    ok_health('Kitty data available\n>lua\n' .. vim.inspect(p.kitty_data) .. '\n')
    return true
  else
    local kitty_scrollback_kitten =
      vim.api.nvim_get_runtime_file('python/kitty_scrollback_nvim.py', false)[1]
    local checkhealth_command = '`kitty @ kitten '
      .. kitty_scrollback_kitten
      .. ' --config ksb_builtin_checkhealth`'
    warn_health('No Kitty data available unable to perform a complete healthcheck', {
      'Add the config options `checkhealth = true` to your *config* or execute the command `:KittyScrollbackCheckHealth` '
        .. 'to run `checkhealth` within the context of a Kitten',
      checkhealth_command,
    })
  end
  return false
end

local function check_clipboard()
  local function is_blank(s)
    return s:find('^%s*$') ~= nil
  end
  start_health('kitty-scrollback: clipboard')
  local clipboard_tool = vim.fn['provider#clipboard#Executable']() -- copied from health.lua
  if vim.fn.has('clipboard') > 0 and not is_blank(clipboard_tool) then
    ok_health('Clipboard tool found: *' .. clipboard_tool .. '*')
  else
    warn_health(
      'Neovim does not have a clipboard provider.\n        Some functionality will not work when there is no clipboard '
        .. 'provider, such as copying Kitty scrollback buffer text to the system clipboard.',
      'See `:help` |provider-clipboard| for more information on enabling system clipboard integration.'
    )
  end
end

local function check_kitty_shell_integration()
  start_health('kitty-scrollback: Kitty shell integration')
  if not next(p or {}) then
    error_health('No Kitty data')
    return
  end
  -- use last_cmd_output because it is valid and requires shell integration
  if M.is_valid_extent_keyword('last_cmd_output') then
    ok_health('Kitty shell integration is enabled')
  else
    warn_health(
      'Kitty shell integration is disabled and/or `no-prompt-mark` is set.\n        Some functionality will not work when Kitty shell '
        .. 'integration is disabled or `no-prompt-mark` is set, such as capturing the last command output.',
      table.concat(M.advice().kitty_shell_integration, '\n')
    )
  end
end

local function check_sed()
  start_health('kitty-scrollback: sed')
  local sed_path = vim.fn.exepath('sed')
  if not sed_path or sed_path == '' then
    error_health('*sed* : command not found\n')
    return
  end

  local esc = vim.fn.eval([["\e"]])
  local cmd = {
    'sed',
    '-E',
    '-e',
    's/$/' .. esc .. '[0m/g',
    '-e',
    's/' .. esc .. '\\[\\?25.' .. esc .. '\\[.*;.*H' .. esc .. '\\[.*//g',
  }
  local ok, sed_proc = pcall(vim.system, cmd, {
    stdin = 'expected' .. esc .. '[?25h' .. esc .. '[1;1H' .. esc .. '[notexpected',
  })
  local result = {}
  if ok then
    result = sed_proc:wait()
  else
    result.code = -999
    result.stdout = ''
    result.stderr = sed_proc
  end
  ok = ok and result.code == 0 and result.stdout == 'expected'
  if ok then
    ok_health(
      '`'
        .. table.concat(cmd, ' ')
        .. '` exited with code *'
        .. result.code
        .. '* and stdout `'
        .. result.stdout
        .. '`\n'
        .. '   `sed: '
        .. sed_path
        .. '`'
    )
  else
    local result_err = result.stderr:gsub('\n', '')
    if result_err ~= '' then
      result_err = '      `' .. result_err .. '`'
    end
    error_health(
      '`'
        .. table.concat(cmd, ' ')
        .. '` exited with code *'
        .. result.code
        .. '* and stdout `'
        .. result.stdout
        .. '` (should be `expected`)\n'
        .. result_err
        .. '`\n'
        .. '   `sed: '
        .. sed_path
        .. '`'
    )
  end
end

M.check_nvim_version = function(check_only)
  -- fallback to older health report calls if using < 0.10
  if not check_only then
    start_health('kitty-scrollback: Neovim version 0.10+')
  end
  local nvim_version = 'NVIM ' .. ksb_util.nvim_version_tostring()
  if vim.fn.has('nvim-0.10') > 0 then
    if not check_only then
      ok_health(nvim_version)
    end
    return true
  else
    if not check_only then
      error_health(nvim_version, M.advice().nvim_version)
    end
  end
  return false
end

M.check_kitty_version = function(check_only)
  if not check_only then
    start_health('kitty-scrollback: Kitty version 0.29+')
  end
  local kitty_version = p.kitty_data.kitty_version
  local kitty_version_str = 'kitty ' .. table.concat(kitty_version, '.')
  if vim.version.cmp(kitty_version, { 0, 29, 0 }) >= 0 then
    if not check_only then
      ok_health(kitty_version_str)
    end
    return true
  else
    if not check_only then
      error_health(kitty_version_str, M.advice().kitty_version)
    end
  end
  return false
end

local function check_kitty_debug_config()
  start_health('kitty-scrollback: Kitty debug config')
  local kitty_debug_config_kitten =
    vim.api.nvim_get_runtime_file('python/kitty_debug_config.py', false)[1]
  local debug_config_log = vim.fn.stdpath('data') .. '/kitty-scrollback.nvim/debug_config.log'
  local result =
    vim.system({ 'kitty', '@', 'kitten', kitty_debug_config_kitten, debug_config_log }):wait()
  if result.code == 0 then
    if vim.fn.filereadable(debug_config_log) then
      ok_health(table.concat(vim.fn.readfile(debug_config_log), '\n   '))
    else
      error_health('cannot read ' .. debug_config_log)
    end
  else
    local stderr = result.stderr:gsub('\n', '') or ''
    error_health(stderr)
  end
end

local function check_kitty_scrollback_nvim_version()
  local current_version = nil
  local tag_cmd = { 'git', 'describe', '--exact-match', '--tags' }
  local ksb_dir =
    vim.fn.fnamemodify(vim.api.nvim_get_runtime_file('lua/kitty-scrollback', false)[1], ':h:h')
  local tag_cmd_result = vim.system(tag_cmd, { cwd = ksb_dir }):wait()
  if tag_cmd_result.code == 0 then
    current_version = tag_cmd_result.stdout
  else
    local commit_cmd = { 'git', 'rev-parse', '--short', 'HEAD' }
    local commit_cmd_result = vim.system(commit_cmd, { cwd = ksb_dir }):wait()
    if commit_cmd_result.code == 0 then
      current_version = commit_cmd_result.stdout
    end
  end
  local version_found = current_version and current_version ~= ''
  local header = '*kitty-scrollback.nvim* @ '
    .. (
      version_found and '`' .. current_version:gsub('%s$', '`\n') ---@diagnostic disable-line: need-check-nil
      or 'ERROR failed to determine version\n'
    )
  local health_fn = not version_found and warn_health
    or function(msg)
      ok_health('     ' .. msg)
    end
  start_health('kitty-scrollback: kitty-scrollback.nvim version')
  health_fn([[  `|`\___/`|`       ]] .. header .. [[
         =) `^`Y`^` (=
          \  *^*  /       If you have any issues or questions using *kitty-scrollback.nvim* then     
          ` )=*=( `       please create an issue at                                                    
          /     \       https://github.com/mikesmithgh/kitty-scrollback.nvim/issues and              
          |     |       provide the `KittyScrollbackCheckHealth` report.                               
         /| | | |\                                                                                    
         \| | `|`_`|`/\
          /_// ___/     *Bonus* *points* *for* *cat* *memes*
             \_)       ]])

  -- Always consider true even if git version is not found to provide additional health checks
  return true
end

M.check = function()
  if
    M.check_nvim_version() -- always check first to avoid undefined calls in versions < 0.10
    and check_kitty_scrollback_nvim_version()
    and check_kitty_remote_control()
    and check_has_kitty_data()
    and M.check_kitty_version()
  then
    check_clipboard()
    check_kitty_shell_integration()
    check_sed()
    check_kitty_debug_config()
  end
end

---@class KsbAdvice
---@field allow_remote_control table
---@field listen_on table
---@field kitty_shell_integration table
---@field nvim_version table
---@field kitty_version table

---@return KsbAdvice
M.advice = function()
  local extent = 'nil'
  local ansi = 'nil'
  local clear_selection = 'nil'
  if opts then
    extent = opts.kitty_get_text.extent
    ansi = tostring(opts.kitty_get_text.ansi)
    clear_selection = tostring(opts.kitty_get_text.clear_selection)
  end

  local shell_integration = 'nil'
  if p then
    shell_integration = table.concat(p.kitty_data.kitty_opts.shell_integration, ' ')
  end
  return {
    nvim_version = {
      'Neovim version 0.10 or greater is required to work with kitty-scrollback.nvim',
    },
    kitty_version = {
      'Kitty version 0.29 or greater is required to work with kitty-scrollback.nvim',
    },
    allow_remote_control = {
      'Kitty must be configured to allow remote control connections. Add the configuration',
      '*allow_remote_control* to Kitty. For example, `allow_remote_control socket-only`',
      'Changing *allow_remote_control* by reloading the config is not supported so you must ',
      'completely close and reopen Kitty for the change to take effect.',
      '',
      'Compatible values with kitty-scrollback.nvim for the option *allow_remote_control* are',
      '`yes`, `socket`, or `socket-only`.',
      '',
      'See https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.allow_remote_control for additional',
      'information on configuring the *allow_remote_control* option.',
      '',
    },
    listen_on = {
      'Kitty must be configured to listen on a Unix socket for remote control connections.',
      'Add the configuration *listen_on* to Kitty. For example, `listen_on unix:/tmp/mykitty`',
      'Changing *listen_on* by reloading the config is not supported so you must completely',
      'close and reopen Kitty for the change to take effect.',
      '',
      'See https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.listen_on for additional information',
      'on configuring the *listen_on* option.',
      '',
      'If *listen_on* is properly configured, check that the option *allow_remote_control* is',
      'set to either `yes`, `socket`, or `socket-only`.',
      '',
      'See https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.allow_remote_control for additional',
      'information on configuring the *allow_remote_control* option.',
      '',
    },
    kitty_shell_integration = {
      'Remove `disabled` and `no-prompt-mark` from *shell_integration* if present in your Kitty configuration.',
      '',
      'Current *kitty_get_text* options:',
      '`    opts = {`',
      '`        kitty_get_text = {`',
      [[`            extent = ']] .. extent .. [[',`]],
      [[`            ansi = ]] .. ansi .. [[,`]],
      [[`            clear_selection = ]] .. clear_selection .. [[,`]],
      '`        },`',
      '`    }`',
      '',
      'See https://sw.kovidgoyal.net/kitty/remote-control/#cmdoption-kitty-get-text-extent for',
      'more information on *extent* or run `kitty @ get-text --help`',
      '',
      'Current *shell_integration* options:',
      [[`    KITTY_SHELL_INTEGRATION=']] .. shell_integration .. [['`]],
      '',
      'See https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.shell_integration for more information',
      'on *shell_integration*',
    },
  }
end

---@param extent string
M.is_valid_extent_keyword = function(extent)
  local valid = false

  local standard = { 'screen', 'all', 'selection' }
  local standard_extent = vim.tbl_filter(function(e)
    return e == extent:lower()
  end, standard)
  if #standard_extent > 0 then
    return true
  end

  local shell_integration = p.kitty_data.kitty_opts.shell_integration
  for _, keyword in pairs(shell_integration) do
    local k = keyword:lower()
    if k == 'disabled' or k == 'no-prompt-mark' then
      return false
    end
    if k == 'enabled' then
      valid = true
    end
  end
  return valid
end

return M
