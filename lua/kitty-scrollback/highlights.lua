---@mod kitty-scrollback.highlights
local ksb_api = require('kitty-scrollback.api')
local ksb_kitty_cmds = require('kitty-scrollback.kitty_commands')
local ksb_util = require('kitty-scrollback.util')

local M = {}

---@type KsbPrivate
local p
---@type KsbOpts
local opts

---see `:help nvim_set_hl()` for highlight group definition format
---@class KsbHighlights
---@field KittyScrollbackNvimNormal table|nil status window Normal highlight group
---@field KittyScrollbackNvimHeart table|nil status window heart icon highlight group
---@field KittyScrollbackNvimSpinner table|nil status window spinner icon highlight group
---@field KittyScrollbackNvimReady table|nil status window ready icon highlight group
---@field KittyScrollbackNvimKitty table|nil status window kitty icon highlight group
---@field KittyScrollbackNvimVim table|nil status window vim icon highlight group
---@field KittyScrollbackNvimPasteWinNormal table|nil paste window Normal highlight group
---@field KittyScrollbackNvimPasteWinFloatBorder table|nil paste window FloatBorder highlight group
---@field KittyScrollbackNvimPasteWinFloatTitle table|nil paste window FloatTitle highlight group
---@field KittyScrollbackNvimVisual table|nil scrollback buffer window visual selection highlight group

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
  hl_def = next(hl_def) and hl_def or {} -- can return vim.empty_dict() so convert to lua table
  local normal_bg_color = hl_def.bg and string.format('#%06x', hl_def.bg)
    or p.kitty_colors.background
  local floatborder_fg_color =
    ksb_util.darken(p.kitty_colors.foreground, 0.3, p.kitty_colors.background)

  local visual_hl_def = vim.api.nvim_get_hl(0, { name = 'Visual', link = false })
  visual_hl_def = next(visual_hl_def) and visual_hl_def or {} -- can return vim.empty_dict() so convert to lua table
  local visual_hl_configs = {
    reverse = {
      default = true,
      reverse = true,
    },
    kitty = {
      default = true,
      fg = p.kitty_colors.selection_foreground,
      bg = p.kitty_colors.selection_background,
      reverse = not p.kitty_colors.selection_foreground and not p.kitty_colors.selection_background,
    },
    darken = {
      default = true,
      bg = ksb_util.darken(
        hl_def.fg and string.format('#%06x', hl_def.fg)
          or (vim.o.background == 'dark' and '#ffffff' or '#000000'),
        0.2,
        normal_bg_color
      ),
    },
    nvim = visual_hl_def,
  }
  local visual_hl = visual_hl_configs[opts.visual_selection_highlight_mode]
    or visual_hl_configs.nvim

  return {
    KittyScrollbackNvimNormal = {
      default = true,
      fg = '#968c81',
    },
    KittyScrollbackNvimHeart = {
      default = true,
      fg = '#F57A74',
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
      fg = '#715545',
    },
    KittyScrollbackNvimVim = {
      default = true,
      fg = '#99af8d',
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
    KittyScrollbackNvimVisual = visual_hl,
  }
end

M.setup = function(private, options)
  p = private
  opts = options ---@diagnostic disable-line: unused-local
  local ok, colors = ksb_api.get_kitty_colors(p.kitty_data)
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
        hl_def.fg
          or (vim.o.background == 'dark' and tonumber('ffffff', 16) or tonumber('000000', 16))
      )
    )
  end
  return env
end

---Set nvim default highlights and terminal colors
M.set_highlights = function()
  -- set highlight groups
  local overrides = opts.highlight_overrides or {}
  for name, definition in pairs(highlight_definitions()) do
    vim.api.nvim_set_hl(0, name, definition)
    local override = overrides[name]
    if override then
      vim.api.nvim_set_hl(0, name, override)
    end
  end
  -- set terminal colors (see :help terminal-config)
  for i = 0, 15 do
    vim.b['terminal_color_' .. i] = p.kitty_colors['color' .. i]
  end
end

return M
