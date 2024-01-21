return {
  ksb_builtin_get_text_all = function()
    return {
      kitty_get_text = {
        extent = 'all',
        ansi = true,
      },
    }
  end,
  ksb_builtin_last_cmd_output = function()
    return {
      kitty_get_text = {
        extent = 'last_cmd_output',
        ansi = true,
      },
    }
  end,
  ksb_builtin_last_visited_cmd_output = function()
    return {
      kitty_get_text = {
        extent = 'last_visited_cmd_output',
        ansi = true,
      },
    }
  end,
  ksb_builtin_checkhealth = function()
    return {
      checkhealth = true,
    }
  end,
}
