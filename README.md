# scrollback.nvim
![nvim loves kitty](https://img.shields.io/static/v1?style=fl&label=%E2%9D%A4%EF%B8%8F&message=%F0%9F%90%B1&logo=neovim&labelColor=282828&logoColor=8faa80&color=282828)
> [!WARNING]  
> This project is still a work in progress and not considered stable


https://github.com/mikesmithgh/scrollback.nvim/assets/10135646/549c04e9-a251-41fa-b3cd-1dffda73a2e7


```sh
git clone git@github.com:mikesmithgh/scrollback.nvim.git
cd scrollback.nvim
./scripts/generate-kitty-conf.sh >> ~/.config/kitty/kitty.conf # TODO: improve generation and avoid duplicates
```

## Ideas
- create callback to populate terminal or execute command
- add support for https://github.com/m00qek/baleia.nvim
- add pre/post hooks for user
- allow user to custom flags sent to nvim 

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

