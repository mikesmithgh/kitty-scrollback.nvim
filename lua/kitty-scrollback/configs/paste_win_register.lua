local M = {}

M.config = function(kitty_data)
  return {
    paste_window = {
      yank_register = '*',
    },
  }
end

return M
