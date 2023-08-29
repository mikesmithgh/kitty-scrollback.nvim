local M = {}

M.config = function(kitty_data)
  return {
    paste_window = {
      winblend = 10,
      winopts_overrides = function(paste_winopts)
        return {
          border = 'solid',
          row = 0,
          col = 0,
          height = vim.o.lines - 5, -- minus paste win border and footer win
          width = vim.o.columns,
        }
      end,
      footer_winopts_overrides = function(footer_winopts, paste_winopts)
        return {
          border = 'single',
          title = ' kitty-scrollback.nvim ',
          title_pos = 'center',
        }
      end,
    },
  }
end

return M
