---@type table<string, KsbOpts|fun(KsbKittyData):KsbOpts>
return {
  ksb_builtin_get_text_all = {
    kitty_get_text = {
      extent = 'all',
    },
  },
  ksb_builtin_last_cmd_output = {
    kitty_get_text = {
      extent = 'last_cmd_output',
    },
  },
  ksb_builtin_last_visited_cmd_output = {
    kitty_get_text = {
      extent = 'last_visited_cmd_output',
    },
  },
  ksb_builtin_checkhealth = {
    checkhealth = true,
  },
}
