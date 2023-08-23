local M = {}

M.config = function(kitty_data)
  return {
    kitty_get_text = {
      extent = 'screen',
      ansi = true,
    },
  }
end

return M
