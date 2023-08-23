local M = {}

M.config = function(kitty_data)
  return {
    kitty_keymap = 'mouse_map ctrl+shift+right press ungrabbed combine : mouse_select_command_output :',
    kitty_keymap_description = '# Show clicked command output in nvim',
    kitty_get_text = {
      extent = 'last_visited_cmd_output',
      ansi = true,
    },
  }
end

return M
