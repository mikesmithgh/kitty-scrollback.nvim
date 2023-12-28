---@mod kitty-scrollback.highlights
local ksb_api = require('kitty-scrollback.api')
local ksb_util = require('kitty-scrollback.util')

local M = {}

---@type KsbPrivate
local p
---@type KsbOpts
local opts

---see `:help nvim_set_hl()` for highlight group definition format
---@class KsbHighlights
---@field KittyScrollbackNvimStatusWinNormal table|nil status window Normal highlight group
---@field KittyScrollbackNvimStatusWinHeartIcon table|nil status window heart icon highlight group
---@field KittyScrollbackNvimStatusWinSpinnerIcon table|nil status window spinner icon highlight group
---@field KittyScrollbackNvimStatusWinReadyIcon table|nil status window ready icon highlight group
---@field KittyScrollbackNvimStatusWinKittyIcon table|nil status window kitty icon highlight group
---@field KittyScrollbackNvimStatusWinNvimIcon table|nil status window vim icon highlight group
---@field KittyScrollbackNvimPasteWinNormal table|nil paste window Normal highlight group
---@field KittyScrollbackNvimPasteWinFloatBorder table|nil paste window FloatBorder highlight group
---@field KittyScrollbackNvimPasteWinFloatTitle table|nil paste window FloatTitle highlight group
---@field KittyScrollbackNvimVisual table|nil scrollback buffer window visual selection highlight group
---@field KittyScrollbackNvimNormal table|nil scrollback buffer window normal highlight group

-- local function has_vim_colorscheme()
--   return vim.fn.getcompletion('vim$', 'color')[1] ~= nil
-- end

M.has_default_or_vim_colorscheme = function()
  return vim.g.colors_name == nil or vim.g.colors_name == 'default' or vim.g.colors_name == 'vim'
end

local function fg_or_fallback(hl_def)
  local fg = type(hl_def.fg) == 'number' and string.format('#%06x', hl_def.fg) or hl_def.fg
  return hl_def.fg and fg or (vim.o.background == 'dark' and '#ffffff' or '#000000')
end

local function bg_or_fallback(hl_def)
  local bg = type(hl_def.bg) == 'number' and string.format('#%06x', hl_def.bg) or hl_def.bg
  return hl_def.bg and bg or (vim.o.background == 'dark' and '#000000' or '#ffffff')
end

local function normal_color()
  local hl_def = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  hl_def = next(hl_def) and hl_def or {} -- can return vim.empty_dict() so convert to lua table
  local normal_fg_color = M.has_default_or_vim_colorscheme() and p.kitty_colors.foreground
    or fg_or_fallback(hl_def)
  local normal_bg_color = M.has_default_or_vim_colorscheme() and p.kitty_colors.background
    or bg_or_fallback(hl_def)
  return {
    fg = normal_fg_color,
    bg = normal_bg_color,
  }
end

local function pastewin_color()
  local hl_as_normal = M.has_default_or_vim_colorscheme()
  if opts.paste_window.highlight_as_normal_win then
    hl_as_normal = opts.paste_window.highlight_as_normal_win()
  end
  vim.print(hl_as_normal)
  local hl_name = hl_as_normal and 'Normal' or 'NormalFloat'
  local hl_def = vim.api.nvim_get_hl(0, { name = hl_name, link = false })
  local pastewin_hl = next(hl_def) and hl_def or {} -- can return vim.empty_dict() so convert to lua table
  if hl_as_normal then
    pastewin_hl = normal_color()
  end
  return pastewin_hl
end

---@return KsbHighlights
local function highlight_definitions()
  if not p.kitty_colors or not next(p.kitty_colors) then
    return {}
  end
  local floatborder_fg_color =
    ksb_util.darken(p.kitty_colors.foreground, 0.3, p.kitty_colors.background)

  local visual_hl_def = vim.api.nvim_get_hl(0, { name = 'Visual', link = false })
  visual_hl_def = next(visual_hl_def) and visual_hl_def or {} -- can return vim.empty_dict() so convert to lua table
  local pastewin_hl = pastewin_color()
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
      bg = ksb_util.darken(fg_or_fallback(pastewin_hl), 0.2, bg_or_fallback(pastewin_hl)),
    },
    nvim = visual_hl_def,
  }
  local visual_hl = visual_hl_configs[opts.visual_selection_highlight_mode]
    or visual_hl_configs.nvim
  local normal_hl = normal_color()

  return {
    KittyScrollbackNvimVisual = visual_hl,
    KittyScrollbackNvimNormal = {
      default = true,
      fg = normal_hl.fg,
      bg = normal_hl.bg,
    },
    -- status window
    KittyScrollbackNvimStatusWinNormal = {
      default = true,
      fg = '#968c81',
      bg = normal_hl.bg,
    },
    KittyScrollbackNvimStatusWinHeartIcon = {
      default = true,
      fg = '#d55b54',
      bg = normal_hl.bg,
    },
    KittyScrollbackNvimStatusWinSpinnerIcon = {
      default = true,
      fg = '#d3869b',
      bg = normal_hl.bg,
    },
    KittyScrollbackNvimStatusWinReadyIcon = {
      default = true,
      fg = '#8faa80',
      bg = normal_hl.bg,
    },
    KittyScrollbackNvimStatusWinKittyIcon = {
      default = true,
      fg = '#754b33',
      bg = normal_hl.bg,
    },
    KittyScrollbackNvimStatusWinNvimIcon = {
      default = true,
      fg = '#87987e',
      bg = normal_hl.bg,
    },
    -- paste window
    KittyScrollbackNvimPasteWinNormal = {
      default = true,
      bg = pastewin_hl.bg,
      blend = opts.paste_window.winblend or 0,
    },
    KittyScrollbackNvimPasteWinFloatBorder = {
      default = true,
      bg = pastewin_hl.bg,
      fg = floatborder_fg_color,
      blend = opts.paste_window.winblend or 0,
    },
    KittyScrollbackNvimPasteWinFloatTitle = {
      default = true,
      bg = floatborder_fg_color,
      fg = pastewin_hl.bg,
      blend = opts.paste_window.winblend or 0,
    },
  }
end

---@param private KsbPrivate
---@param options KsbOpts
---@return true|false
M.setup = function(private, options)
  p = private
  opts = options ---@diagnostic disable-line: unused-local
  p.orig_normal_hl = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  if M.has_default_or_vim_colorscheme() then
    -- clear Normal highlight to avoid flicker when bg color is set
    vim.api.nvim_set_hl(0, 'Normal', {})
  end
  local ok, colors = ksb_api.get_kitty_colors(p.kitty_data)
  if ok then
    p.kitty_colors = colors
  end
  return ok
end

---Format nvim highlights to arguments passed to kitty launch command
---E.g., KittyScrollbackNvimStatusWinNvimIcon with #188b25 to --env KITTY_SCROLLBACK_NVIM_VIM=#188b25
---@return table list of environment variable arguments
M.get_highlights_as_env = function()
  local env = {}
  for name, _ in pairs(highlight_definitions()) do
    table.insert(env, '--env')
    local hl_def = vim.api.nvim_get_hl(0, { name = name, link = false })
    hl_def = next(hl_def) and hl_def or {} -- nvim_get_hl can return vim.empty_dict() so convert to lua table
    table.insert(
      env,
      string.format('%s_HIGHLIGHT=%s', ksb_util.screaming_snakecase(name), fg_or_fallback(hl_def))
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
