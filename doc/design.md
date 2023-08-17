## Design (In-progress)
kitty
```
┌─────────────────────────────────┐
│                                 │
│ kitten kitty_scrollback_nvim.py │
│                                 │
└─────────────────────────────────┘


kitty_scrollback_nvim.py
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│ @result_handler                                                         │
│ def handle_result(args, result, target_window_id, boss)                 │
│                                                                         │
│   kitty_pipe_data = $KITTY_PIPE_DATA                                    │
│                                                                         │
│   kitty_data = { kitty_pipe_data, target_window_id }                    │
│                                                                         │
│   kitty @ launch --type overlay                                         │
│                                                                         │
│          nvim --cmd ' lua ksbnvim=dofile('kitty_scrollback_nvim.lua') ' │
│                       lua ksbnvim.setup()                               │
│                       lua ksbnvim.launch(kitty_data)                    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘



nvim
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│ function setup(opts)                                                            │
- set options
- set keymaps
- set autocommands
│                                                                                 │
│ end                                                                             │
│                                                                                 │
│ function launch(kitty_data)                                                     │

  - open empty buffer
│
│   vim.fn.termopen(                                                              │
│                                                                                 │
│     kitty @ get-text --ansi --match=id:kitty_data.target_window_id --extend=all │
│                                                                                 │
│   )                                                                             │
  - delete last line with process terminated

│                                                                                 │
  - loading popup
  - set position of cursor                                                
│                                                                                 │
│                                                                                 │
│                                                                                 │
│ end                                                                             │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```
```
kitty @ launch --type overlay nvim --cmd 'lua vim.o.scrollback = 100000; vim.fn.termopen([[kitty @ get-text --ansi --match="id:4" --extent=all | sed "s/$/\x1b[0m/g"]])'
```
