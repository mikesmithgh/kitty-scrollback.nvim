---@mod kitty-scrollback.highlights
local ksb_util = require('kitty-scrollback.util')
local ksb_kitty_cmds = require('kitty-scrollback.kitty_commands')

local M = {}

local p
local opts ---@diagnostic disable-line: unused-local

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
---@see nvim_set_hl

---@return KsbHighlights
local function highlight_definitions()
  if not p.kitty_colors or not next(p.kitty_colors) then
    return {}
  end
  local hl_as_normal_fn = opts.paste_window.highlight_as_normal_win
    or function()
      return vim.g.colors_name == nil or vim.g.colors_name == 'default'
    end
  local hl_name = hl_as_normal_fn() and 'Normal' or 'NormalFloat'
  local hl_def = vim.api.nvim_get_hl(0, { name = hl_name, link = false })
  hl_def = next(hl_def) and hl_def or {} -- nvim_get_hl can return vim.empty_dict() so convert to lua table
  local normal_bg_color = hl_def.bg or p.kitty_colors.background
  local floatborder_fg_color =
    ksb_util.darken(p.kitty_colors.foreground, 0.3, p.kitty_colors.background)
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

M.setup = function(private, options)
  p = private
  opts = options ---@diagnostic disable-line: unused-local
  local ok, colors = ksb_kitty_cmds.get_kitty_colors(p.kitty_data)
  if ok then
    p.kitty_colors = colors
  end
  return ok
end

---Format nvim highlights to arguments passed to kitty launch command
---E.g., KittyScrollbackNvimVim with #188b25 to --env KITTY_SCROLLBACK_NVIM_VIM=#188b25
---@return table list of environment variable arguments
M.get_highlights_as_env = function()
  local env = {}
  for name, _ in pairs(highlight_definitions()) do
    table.insert(env, '--env')
    local hl_def = vim.api.nvim_get_hl(0, { name = name, link = false })
    hl_def = next(hl_def) and hl_def or {} -- nvim_get_hl can return vim.empty_dict() so convert to lua table
    table.insert(
      env,
      string.format(
        '%s=#%06x',
        ksb_util.screaming_snakecase(name),
        hl_def.fg or 16777215 -- default to #ffffff
      )
    )
  end
  return env
end

---Set nvim default highlights
M.set_highlights = function()
  local overrides = opts.highlight_overrides or {}
  for name, definition in pairs(highlight_definitions()) do
    vim.api.nvim_set_hl(0, name, definition)
    local override = overrides[name]
    if override then
      vim.api.nvim_set_hl(0, name, override)
    end
  end
end

return M
