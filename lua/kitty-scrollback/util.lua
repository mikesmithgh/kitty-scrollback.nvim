---@mod kitty-scrollback.util
local M = {}

---@type KsbPrivate
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

M.restore_and_redraw = function()
  if p.orig_columns then
    vim.o.columns = p.orig_columns
  end
  vim.cmd.redraw()
end

M.tab_offset = function()
  -- if always displaying a tabline or if displaying a tabline when more than one tab exists
  if vim.o.showtabline == 2 or (vim.o.showtabline == 1 and vim.fn.tabpagenr('$') > 1) then
    return 1
  end
  return 0
end

function M.clear_yank_autocommand_and_get_visual_selection()
  vim.api.nvim_clear_autocmds({
    group = vim.api.nvim_create_augroup('KittyScrollBackNvimTextYankPost', { clear = true }),
  })
  -- vim.cmd.yank requires entering and exiting visual mode, so just use vim.cmd.normal
  vim.cmd.normal({ 'y', bang = true })
  local reginfo = vim.fn.getreginfo('"') or { regcontents = {} }
  return reginfo.regcontents
end

return M
