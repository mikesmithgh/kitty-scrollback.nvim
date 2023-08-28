local M = {}

M.config = function(kitty_data)
  return {
    paste_window = {
      highlight_as_normal_win = function() return false end,
    },
  }
end

return M
