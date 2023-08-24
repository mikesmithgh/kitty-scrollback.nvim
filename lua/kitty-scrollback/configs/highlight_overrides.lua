local M = {}

M.config = function(kitty_data)
  return {
    highlight_overrides = {
      KittyScrollbackNvimNormal = '#ee82ee',
      KittyScrollbackNvimHeart = '#ff0000',
      KittyScrollbackNvimSpinner = '#0000ff',
      KittyScrollbackNvimReady = '#4b0082',
      KittyScrollbackNvimKitty = '#ffa500',
      KittyScrollbackNvimVim = '#008000',
    },
  }
end

return M
