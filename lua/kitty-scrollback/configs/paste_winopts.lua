local M = {}

M.config = function(kitty_data)
  return {
    paste_window = {
      winblend = 20,
      winopts_overrides = function(paste_winopts)
        return {
          border = 'rounded',
          title = ' kitty-scrollback.nvim ',
          title_pos = 'center',
          row = 0,
          col = 0,
          height = vim.o.lines - 5, -- minus paste win border and footer win
          width = vim.o.columns,
        }
      end,
      footer_winopts_overrides = function(footer_winopts, paste_winopts)
        return {
          border = paste_winopts.border,
          title = ' mappings ',
          title_pos = 'center',
        }
      end,
    },
  }
end

return M
