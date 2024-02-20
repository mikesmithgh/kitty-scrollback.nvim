---@class KsbBufWinData
---@field bufid integer|nil
---@field winid integer|nil

---@class KsbPasteWindowData
---@field scrollback_buffer KsbBufWinData data for the scrollback buffer
---@field paste_window KsbBufWinData data for the paste window
---@field paste_window_footer KsbBufWinData data for the paste window footer

---@class KsbCallbacks
---@field after_setup fun(kitty_data:KsbKittyData, opts:KsbOpts)|nil callback executed after initializing kitty-scrollback.nvim
---@field after_launch fun(kitty_data:KsbKittyData, opts:KsbOpts)|nil callback executed after launch started to process the scrollback buffer
---@field after_ready fun(kitty_data:KsbKittyData, opts:KsbOpts)|nil callback executed after scrollback buffer is loaded and cursor is positioned
---@field after_paste_window_ready fun(paste_window_data:KsbPasteWindowData, kitty_data:KsbKittyData, opts:KsbOpts)|nil callback executed after the paste window is opened or resized

---@class KsbKittyGetText
---@field ansi boolean|nil If true, the text will include the ANSI formatting escape codes for colors, bold, italic, etc.
---@field clear_selection boolean|nil If true, clear the selection in the matched window, if any.
---@field extent string|nil | 'screen' | 'all' | 'selection' | 'first_cmd_output_on_screen' | 'last_cmd_output' | 'last_visited_cmd_output' | 'last_non_empty_output'     What text to get. The default of screen means all text currently on the screen. all means all the screen+scrollback and selection means the currently selected text. first_cmd_output_on_screen means the output of the first command that was run in the window on screen. last_cmd_output means the output of the last command that was run in the window. last_visited_cmd_output means the first command output below the last scrolled position via scroll_to_prompt. last_non_empty_output is the output from the last command run in the window that had some non empty output. The last four require shell_integration to be enabled. Choices: screen, all, first_cmd_output_on_screen, last_cmd_output, last_non_empty_output, last_visited_cmd_output, selection

---@class KsbStatusWindowIcons
---@field kitty string kitty status window icon, defaults to 󰄛
---@field heart string heart status window icon, defaults to 󰣐
---@field nvim string nvim status window icon, defaults to 

---@class KsbStatusWindowOpts
---@field enabled boolean If true, show status window in upper right corner of the screen
---@field style_simple boolean If true, use plaintext instead of nerd font icons
---@field autoclose boolean If true, close the status window after kitty-scrollback.nvim is ready
---@field show_timer boolean If true, show a timer in the status window while kitty-scrollback.nvim is loading
---@field icons KsbStatusWindowIcons Icons displayed in the status window, defaults to 󰄛 󰣐 

---@alias KsbWinOpts table<string, any>

---@alias KsbWinOptsOverrideFunction fun(paste_winopts:KsbWinOpts):KsbWinOpts
---@alias KsbFooterWinOptsOverrideFunction fun(footer_winopts:KsbWinOpts, paste_winopts:KsbWinOpts):KsbWinOpts

---@class KsbPasteWindowOpts
---@field highlight_as_normal_win nil|fun():boolean If function returns true, use Normal highlight group. If false, use NormalFloat
---@field filetype string|nil The filetype of the paste window
---@field hide_footer boolean|nil If true, hide mappings in the footer when the paste window is initially opened
---@field winblend integer|nil The winblend setting of the window, see :help winblend
---@field winopts_overrides KsbWinOptsOverrideFunction|nil Paste float window overrides, see nvim_open_win() for configuration
---@field footer_winopts_overrides KsbFooterWinOptsOverrideFunction|nil Paste footer window overrides, see nvim_open_win() for configuration
---@field yank_register string|nil register used during yanks to paste window, see :h registers
---@field yank_register_enabled boolean|nil If true, the `yank_register` copies content to the paste window. If false, disable yank to paste window

---@class KsbOpts
---@field callbacks KsbCallbacks|nil fire and forget callback functions
---@field keymaps_enabled boolean|nil if true, enabled all default keymaps
---@field restore_options boolean|nil if true, restore options that were modified while processing the scrollback buffer
---@field highlight_overrides KsbHighlights|nil kitty-scrollback.nvim highlight overrides
---@field status_window KsbStatusWindowOpts|nil options for status window indicating that kitty-scrollback.nvim is ready
---@field paste_window KsbPasteWindowOpts|nil  options for paste window that sends commands to Kitty
---@field kitty_get_text KsbKittyGetText|nil options passed to get-text when reading scrollback buffer, see `kitty @ get-text --help`
---@field checkhealth boolean|nil if true execute :checkhealth kitty-scrollback and skip setup
---@field visual_selection_highlight_mode string | 'darken' | 'kitty' | 'nvim' | 'reverse' | nil
local default_opts = {
  callbacks = nil,
  keymaps_enabled = true,
  restore_options = false,
  highlight_overrides = nil,
  status_window = {
    enabled = true,
    style_simple = false,
    autoclose = false,
    show_timer = false,
    icons = {
      kitty = '󰄛',
      heart = '󰣐', -- variants 󰣐 |  |  | ♥ |  | 󱢠 | 
      nvim = '', -- variants  |  |  | 
    },
  },
  paste_window = {
    highlight_as_normal_win = nil,
    filetype = nil,
    hide_footer = false,
    winblend = 0,
    winopts_overrides = nil,
    footer_winopts_overrides = nil,
    yank_register = '',
    yank_register_enabled = true,
  },
  kitty_get_text = {
    ansi = true,
    extent = 'all',
    clear_selection = true,
  },
  checkhealth = false,
  visual_selection_highlight_mode = 'darken',
}

return default_opts
