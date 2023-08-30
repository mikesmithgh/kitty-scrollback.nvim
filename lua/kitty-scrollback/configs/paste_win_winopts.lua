local M = {}

M.config = function(kitty_data)
  return {
    paste_window = {
      winblend = 10,
      winopts_overrides = function(paste_winopts)
        local h = vim.o.lines - 5 -- TODO: magic number 3 for footer and 2 for border
        return {
          border = 'solid',
          row = 0,
          col = 0,
          height = h < 1 and 3 or h, -- TODO: magic number 3 for footer
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
