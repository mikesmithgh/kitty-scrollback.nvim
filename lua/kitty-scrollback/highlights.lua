local ksb_util = require('kitty-scrollback.util')

local M = {}

local p
local opts


---@class KsbHighlights
---@field KittyScrollbackNvimNormal table?
---@field KittyScrollbackNvimHeart table?
---@field KittyScrollbackNvimSpinner table?
---@field KittyScrollbackNvimReady table?
---@field KittyScrollbackNvimKitty table?
---@field KittyScrollbackNvimVim table?
---@field KittyScrollbackNvimPasteWinNormal table?
---@field KittyScrollbackNvimPasteWinFloatBorder table?
---@field KittyScrollbackNvimPasteWinFloatTitle table?

---@return KsbHighlights
local function highlight_definitions()
  local hl_name = opts.paste_window.highlight_as_normal_win() and 'Normal' or 'NormalFloat'
  local hormal_hl = vim.api.nvim_get_hl(0, { name = hl_name, link = false, })
  local normal_bg_color = hormal_hl.bg or p.kitty_colors.background
  local floatborder_fg_color = ksb_util.darken(p.kitty_colors.foreground, 0.3, p.kitty_colors.background)
  return {
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
    KittyScrollbackNvimPasteWinNormal = {
      default = true,
      bg = normal_bg_color,
      blend = opts.paste_window.winblend or 0,
    },
    KittyScrollbackNvimPasteWinFloatBorder = {
      default = true,
      bg = normal_bg_color,
      fg = floatborder_fg_color,
      blend = opts.paste_window.winblend or 0,
    },
    KittyScrollbackNvimPasteWinFloatTitle = {
      default = true,
      bg = floatborder_fg_color,
      fg = normal_bg_color,
      blend = opts.paste_window.winblend or 0,
    },
  }
end

local function get_kitty_colors(kitty_data)
  local kitty_colors = {}
  local kitty_colors_str = vim.fn.system({
    'kitty',
    '@',
    'get-colors',
    '--match=id:' .. kitty_data.window_id,
  }) or ''
  for color_kv in kitty_colors_str:gmatch('[^\r\n]+') do
    local split_kv = color_kv:gmatch('%S+')
    kitty_colors[split_kv()] = split_kv()
  end
  return kitty_colors
end

M.setup = function(private, options)
  p = private
  opts = options
  p.kitty_colors = get_kitty_colors(p.kitty_data)
end


---Format nvim highlights to arguments passed to kitty launch command
---E.g., KittyScrollbackNvimVim with #188b25 to --env KITTY_SCROLLBACK_NVIM_VIM=#188b25
---@return table list of environment variable arguments
M.get_highlights_as_env = function()
  local env = {}
  for name, _ in pairs(highlight_definitions()) do
    table.insert(env, '--env')
    table.insert(env,
      string.format('%s=#%06x',
        ksb_util.screaming_snakecase(name),
        vim.api.nvim_get_hl(0, { name = name, link = false, })['fg'] or 16777215 -- default to #ffffff
      )
    )
  end
  return env
end

---Set nvim default highlights
M.set_highlights = function()
  for name, definition in pairs(highlight_definitions()) do
    vim.api.nvim_set_hl(0, name, definition)
    local override = opts.highlight_overrides[name]
    if override then
      vim.api.nvim_set_hl(0, name, override)
    end
  end
end

return M
