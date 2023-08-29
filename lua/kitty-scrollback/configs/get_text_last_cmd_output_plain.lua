local M = {}

M.config = function(kitty_data)
  return {
    kitty_get_text = {
      extent = 'last_cmd_output',
      ansi = false,
    },
  }
end

return M
