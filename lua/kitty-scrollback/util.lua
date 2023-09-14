---@mod kitty-scrollback.util
local M = {}

local p
local opts ---@diagnostic disable-line: unused-local

M.setup = function(private, options)
  p = private
  opts = options ---@diagnostic disable-line: unused-local
end

---@param c  string
M.hexToRgb = function(c)
  c = string.lower(c)
  return { tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) }
end

---@param foreground string foreground color
---@param background string background color
---@param alpha number|string number between 0 and 1. 0 results in bg, 1 results in fg
M.blend = function(foreground, background, alpha)
  alpha = type(alpha) == 'string' and (tonumber(alpha, 16) / 0xff) or alpha
  local bg = M.hexToRgb(background)
  local fg = M.hexToRgb(foreground)

  local blendChannel = function(i)
    local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
    return math.floor(math.min(math.max(0, ret), 255) + 0.5)
  end

  return string.format('#%02x%02x%02x', blendChannel(1), blendChannel(2), blendChannel(3))
end

M.darken = function(hex, amount, bg)
  local default_bg = '#ffffff'
  if vim.o.background == 'dark' then
    default_bg = '#000000'
  end
  return M.blend(hex, bg or default_bg, amount)
end

---Convert camelCase to SCREAMING_SNAKECASE
---@param s string
---@return string
M.screaming_snakecase = function(s)
  -- copied and modified from https://codegolf.stackexchange.com/a/177958
  return s:gsub('%f[^%l]%u', '_%1')
    :gsub('%f[^%a]%d', '_%1')
    :gsub('%f[^%d]%a', '_%1')
    :gsub('(%u)(%u%l)', '%1_%2')
    :upper()
end

M.remove_process_exited = function()
  local last_line_range = vim.api.nvim_buf_line_count(p.bufid) - vim.o.lines
  if last_line_range < 1 then
    last_line_range = 1
  end
  local last_lines = vim.api.nvim_buf_get_lines(p.bufid, last_line_range, -1, false)
  for i, line in pairs(last_lines) do
    local match = line:lower():gmatch('%[process exited %d+%]')
    if match() then
      local target_line = last_line_range - 1 + i
      vim.api.nvim_set_option_value('modifiable', true, { buf = p.bufid })
      vim.api.nvim_buf_set_lines(p.bufid, target_line, target_line + 1, false, {})
      vim.api.nvim_set_option_value('modifiable', false, { buf = p.bufid })
      return true
    end
  end
  return false
end

-- nvim 0.10+ has tostring builtin but need this for previous versions during healthcheck
M.nvim_version_tostring = function()
  local nvim_ver = vim.version()
  local ret = table.concat({ nvim_ver.major, nvim_ver.minor, nvim_ver.patch }, '.')
  if nvim_ver.prerelease then
    ret = ret .. '-' .. nvim_ver.prerelease
  end
  if nvim_ver.build and nvim_ver.build ~= vim.NIL then
    ret = ret .. '+' .. nvim_ver.build
  end
  return ret
end

return M
