local M = {}

M.config = function(kitty_data)
  return {
    kitty_get_text = {
      extent = 'screen',
      ansi = false,
    },
  }
end

return M
