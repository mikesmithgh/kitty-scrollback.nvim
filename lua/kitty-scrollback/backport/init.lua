---@mod kitty-scrollback.backport
-- NOTE(#58): nvim v0.9 support

local ksb_health = require('kitty-scrollback.health')

local M = {}

local function backport_version()
  if type(vim.version().__tostring) ~= 'function' then
    -- NOTE: copied __tostring from
    -- https://github.com/neovim/neovim/blob/ae3eed53d6100598b6d26fe58e3e97541e03f3c1/runtime/lua/vim/version.lua#L123

    local Version = {}
    function Version:__tostring()
      local ret = table.concat({ self.major, self.minor, self.patch }, '.')
      if self.prerelease then
        ret = ret .. '-' .. self.prerelease
      end
      if self.build and self.build ~= vim.NIL then
        ret = ret .. '+' .. self.build
      end
      return ret
    end

    if type(vim.version) == 'function' then -- nvim 0.8 vim.version is a table instead of function
      vim.version = vim.version()
    end

    -- NOTE: copied setmetatable from
    -- https://github.com/neovim/neovim/blob/ae3eed53d6100598b6d26fe58e3e97541e03f3c1/runtime/lua/vim/version.lua#L444
    setmetatable(vim.version, {
      --- Returns the current Nvim version.
      ---@return Version
      __call = function()
        local version = vim.fn.api_info().version
        -- Workaround: vim.fn.api_info().version reports "prerelease" as a boolean.
        version.prerelease = version.prerelease and 'dev' or nil
        return setmetatable(version, Version)
      end,
    })
  end
end

local function backport_health()
  vim.health.start = vim.health.start or vim.health.report_start
  vim.health.info = vim.health.info or vim.health.report_info
  vim.health.ok = vim.health.ok or vim.health.report_ok
  vim.health.warn = vim.health.warn or vim.health.report_warn
  vim.health.error = vim.health.error or vim.health.report_error
end

local function backport_uv()
  if not vim.uv then
    vim.uv = vim.loop
  end
end

local function backport_system()
  -- copied from _editor.lua
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.system = function(cmd, opts, on_exit)
    if type(opts) == 'function' then
      on_exit = opts
      opts = nil
    end
    return require('kitty-scrollback.backport._system').run(cmd, opts, on_exit)
  end
end

M.setup = function()
  backport_uv()
  backport_health()
  if ksb_health.check_nvim_version('nvim-0.10', true) then
    return
  end
  backport_version()
  backport_system()
end

return M
