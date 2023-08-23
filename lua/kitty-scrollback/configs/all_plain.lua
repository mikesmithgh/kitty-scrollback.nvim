local M = {}

M.config = function(kitty_data)
  return {
    kitty_get_text = {
      extent = 'all',
      ansi = false,
    },
  }
end

return M
