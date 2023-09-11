local ksb_util = require'kitty-scrollback.util'
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

local function check_kitty_remote_control()
  vim.health.start('kitty-scrollback: Kitty remote control')
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
    vim.health.ok(code_msg)
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
      table.concat(msg, '\n')
    }
    local kitty_opts = {}
    if type(p) == 'table' and next(p.kitty_data) then
      kitty_opts = p.kitty_data.kitty_opts
      table.insert(advice, table.concat({
        '*allow_remote_control* and *listen_on* are currently configured as:',
        '  `allow_remote_control ' .. kitty_opts.allow_remote_control .. '`',
        '  `listen_on ' .. kitty_opts.listen_on .. '`',
      }, '\n'))
    else
      table.insert(advice, 'ERROR Failed to read `allow_remote_control` and `listen_on`')
    end
    vim.health.error(code_msg .. '\n      `' .. stderr .. '` ', advice)
  end
end

local function check_has_kitty_data()
  vim.health.start('kitty-scrollback: Kitty data')
  if type(p) == 'table' and next(p.kitty_data) then
    vim.health.ok('Kitty data available\n>lua\n' .. vim.inspect(p.kitty_data) .. '\n')
  else
    local kitty_scrollback_kitten = vim.api.nvim_get_runtime_file('python/kitty_scrollback_nvim.py', false)[1]
    local checkhealth_config = vim.api.nvim_get_runtime_file('lua/kitty-scrollback/configs/checkhealth.lua', false)[1]
    local checkhealth_command = '`kitty @ kitten ' .. kitty_scrollback_kitten .. ' --config-file ' .. checkhealth_config .. '`'
    vim.health.warn('No Kitty data available unable to perform a complete healthcheck',
      {
        'Add the config options `checkhealth = true` to your *config-file* or execute the command `:KittyScrollbackCheckHealth` ' ..
        'to run `checkhealth` within the context of a Kitten',
        checkhealth_command })
  end
end

local function check_clipboard()
  local function is_blank(s)
    return s:find('^%s*$') ~= nil
  end
  vim.health.start('kitty-scrollback: clipboard')
  local clipboard_tool = vim.fn['provider#clipboard#Executable']() -- copied from health.lua
  if vim.fn.has('clipboard') > 0 and not is_blank(clipboard_tool) then
    vim.health.ok('Clipboard tool found: *' .. clipboard_tool .. '*')
  else
    vim.health.warn(
      'Neovim does not have a clipboard provider.\n        Some functionality will not work when there is no clipboard ' ..
      'provider, such as copying Kitty scrollback buffer text to the system clipboard.',
      'See `:help` |provider-clipboard| for more information on enabling system clipboard integration.')
  end
end

local function check_kitty_shell_integration()
  vim.health.start('kitty-scrollback: Kitty shell integration')
  if not next(p or {}) then
    vim.health.error('No Kitty data')
    return
  end
  -- use last_cmd_output because it is valid and requires shell integration
  if M.is_valid_extent_keyword('last_cmd_output') then
    vim.health.ok('Kitty shell integration is enabled')
  else
    vim.health.warn(
      'Kitty shell integration is disabled and/or `no-prompt-mark` is set.\n        Some functionality will not work when Kitty shell ' ..
      'integration is disabled or `no-prompt-mark` is set, such as capturing the last command output.',
      table.concat(M.advice().kitty_shell_integration, '\n'))
  end
end

local function check_sed()
  vim.health.start('kitty-scrollback: sed')
  local which_sed_result = vim.system({ 'command', '-v', 'sed' }):wait()
  local ok = which_sed_result.code == 0
  if not ok then
    vim.health.error(
      '`command -v sed` exited with code *' .. which_sed_result.code .. '*\n' ..
      '      `' .. which_sed_result.stderr .. '` '
    )
    return
  end

  local cmd = {
    'sed',
    '-e',
    [[s/$/\x1b[0m/g]],
    '-e',
    [[s/\x1b\[\?25.\x1b\[.*;.*H\x1b\[.*//g]],
  }
  local result = vim.system(cmd, {
    stdin = [[[m$ echo 'test' | grep test\n[m[1;31mtest\n[m$]]
  }):wait()
  ok = result.code == 0
  if ok then
    vim.health.ok('`' .. table.concat(cmd, ' ') .. '` exited with code *' .. result.code .. '*\n' ..
      '   `sed: ' .. which_sed_result.stdout:gsub('\n', '') .. '`')
  else
    vim.health.error(
      '`' .. table.concat(cmd, ' ') .. '` exited with code *' .. result.code .. '*\n' ..
      '      `' .. result.stderr:gsub('\n', '') .. '` '
    )
  end
end

M.check_nvim_version = function(check_only)
  if not check_only then
    vim.health.start('kitty-scrollback: Neovim version 0.10+')
  end
  local nvim_version = 'NVIM ' .. ksb_util.nvim_version_tostring()
  if vim.fn.has('nvim-0.10') > 0 then
    if not check_only then
      vim.health.ok(nvim_version)
    end
    return true
  else
    if not check_only then
      vim.health.error(nvim_version, M.advice().nvim_version)
    end
  end
  return false
end

M.check_kitty_version = function(check_only)
  if not check_only then
    vim.health.start('kitty-scrollback: Kitty version 0.29+')
  end
  local kitty_version = p.kitty_data.kitty_version
  local kitty_version_str = 'kitty ' .. table.concat(kitty_version, '.')
  if vim.version.cmp(kitty_version, { 0, 29, 0 }) >= 0 then
    if not check_only then
      vim.health.ok(kitty_version_str)
    end
    return true
  else
    if not check_only then
      vim.health.error(kitty_version_str, M.advice().kitty_version)
    end
  end
  return false
end

M.check = function()
  if M.check_nvim_version() and M.check_kitty_version() then
    check_has_kitty_data()
    check_kitty_remote_control()
    check_clipboard()
    check_kitty_shell_integration()
    check_sed()
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
    nvim_version = { 'Neovim version 0.10 or greater is required to work with kitty-scrollback.nvim' },
    kitty_version = { 'Kitty version 0.29 or greater is required to work with kitty-scrollback.nvim' },
    allow_remote_control =
    {
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
    }
  }
end

---@param extent string
M.is_valid_extent_keyword = function(extent)
  local standard = { 'screen', 'all', 'selection' }
  local shell_integration_required = { 'last_cmd_output', 'first_cmd_output_on_screen', 'last_visited_cmd_output', 'last_non_empty_output' }
  local valid_keywords = { 'enabled', 'no-cursor', 'no-title', 'no-complete', 'no-cwd' }
  local valid = false
  for _, e in pairs(standard) do
    if e == extent:lower() then
      return true
    end
  end
  for _, e in pairs(shell_integration_required) do
    if e == extent:lower() then
      local shell_integration = p.kitty_data.kitty_opts.shell_integration
      for _, keyword in pairs(shell_integration) do
        local k = keyword:lower()
        if k == 'disabled' or k == 'no-prompt-mark' then
          return false
        end
        for _, valid_keyword in pairs(valid_keywords) do
          if k == valid_keyword then
            valid = true
          end
        end
      end
    end
  end
  return valid
end


return M
