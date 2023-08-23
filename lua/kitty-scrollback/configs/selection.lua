local M = {}

M.config = function(kitty_data)
  return {
    kitty_get_text = {
      extent = 'selection',
      ansi = true,
    },
  }
end

return M
