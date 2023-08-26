local ksb_util = require('kitty-scrollback.util')

local M = {
  highlight_definitions = {
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
  }
}

local p
local opts

M.setup = function(private, options)
  p = private
  opts = options
end


---Format nvim highlights to arguments passed to kitty launch command
---E.g., KittyScrollbackNvimVim with #188b25 to --env KITTY_SCROLLBACK_NVIM_VIM=#188b25
---@return table list of environment variable arguments
M.get_highlights_as_env = function()
  local env = {}
  for name, _ in pairs(M.highlight_definitions) do
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
  for name, definition in pairs(M.highlight_definitions) do
    vim.api.nvim_set_hl(0, name, definition)
    local override = opts.highlight_overrides[name]
    if override then
      vim.api.nvim_set_hl(0, name, { fg = override, })
    end
  end
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

M.unpinkify_default_colorscheme = function()
  p.kitty_colors = get_kitty_colors(p.kitty_data)
  -- avoid terrible purple floating windows for the default colorscheme
  if not vim.g.colors_name then
    vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'Normal', })
    vim.api.nvim_set_hl(0, 'FloatBorder', { link = 'Normal', })
    vim.api.nvim_set_hl(0, 'FloatTitle', { link = 'Normal', })
    local floatborder_fg_color = ksb_util.darken(p.kitty_colors.foreground, 0.3, p.kitty_colors.background)
    vim.api.nvim_set_hl(0, 'ModeMsg', { fg = floatborder_fg_color })
  end
end

return M
