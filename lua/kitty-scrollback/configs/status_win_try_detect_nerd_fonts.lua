local M = {}

M.config = function(kitty_data)
  return {
    status_window = {
      style_simple = not require('kitty-scrollback.kitty_commands').try_detect_nerd_font(),
    },
  }
end

return M
