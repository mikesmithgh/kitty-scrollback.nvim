local M = {}

M.config = function(kitty_data)
  return {
    highlight_overrides = {
      KittyScrollbackNvimNormal = {
        fg = '#ee82ee',
        bg = '#ee82ee',
      },
      KittyScrollbackNvimHeart = {
        fg = '#ff0000',
        bg = '#4b0082',
      },
      KittyScrollbackNvimSpinner = {
        fg = '#000099',
        bg = '#4b0082',
      },
      KittyScrollbackNvimReady = {
        fg = '#4b0082',
        bg = '#ffa500',
      },
      KittyScrollbackNvimKitty = {
        fg = '#ffa500',
        bg = '#000099',
      },
      KittyScrollbackNvimVim = {
        fg = '#008000',
        bg = '#000099',
      },
      KittyScrollbackNvimPasteWinNormal = {
        link = 'Pmenu',
      },
      KittyScrollbackNvimPasteWinFloatBorder = {
        link = 'Pmenu',
      },
      KittyScrollbackNvimPasteWinFloatTitle = {
        link = 'Title',
      },
    },
  }
end

return M
