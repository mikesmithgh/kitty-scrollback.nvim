local ksb_health = require('kitty-scrollback.health')

local M = {}

local function backport_version()
  if type(vim.version().__tostring) ~= 'function' then
    -- NOTE: copied __tostring from
    -- https://github.com/neovim/neovim/blob/879617c9bbbacb0d0f778ff6dd53cc7c95794abe/runtime/lua/vim/version.lua

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

    setmetatable(vim.version, {
      --- Returns the current Nvim version.
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

M.setup = function()
  if ksb_health.check_nvim_version('nvim-0.10', true) then
    return
  end
  backport_version()
  backport_health()
end

return M
