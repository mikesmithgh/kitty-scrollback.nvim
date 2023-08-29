local M = {}

M.config = function(kitty_data)
  return {
    kitty_get_text = {
      extent = 'first_cmd_output_on_screen',
      ansi = false,
    },
  }
end

return M
