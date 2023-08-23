local M = {}

M.config = function(kitty_data)
  return {
    kitty_get_text = {
      extent = 'selection',
      ansi = true,
      clear_selection = false,
    },
  }
end

return M
