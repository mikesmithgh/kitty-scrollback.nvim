local M = {}

M.config = function(kitty_data)
  return {
    kitty_keymap = 'map ctrl+shift+g',
    kitty_keymap_description = '# Browse output of the last shell command in nvim',
    kitty_get_text = {
      extent = 'last_cmd_output',
      ansi = true,
    },
  }
end

return M
