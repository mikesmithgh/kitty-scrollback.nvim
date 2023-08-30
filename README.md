<img src="https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/a7357844-e0e4-4053-8c77-6d129528504f" alt="kitty-scrollback" style="width: 20%" align="right" />

# 😽 kitty-scrollback.nvim
Neovim plugin/Kitten to integrate Neovim with Kitty's scrollback buffer

![nvim loves kitty](https://img.shields.io/static/v1?style=fl&label=%E2%9D%A4%EF%B8%8F&message=%F0%9F%90%B1&logo=neovim&labelColor=282828&logoColor=8faa80&color=282828)
> [!WARNING]  
> This project is still a work in progress and not considered stable

https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/5aba1ba2-1883-4ac0-bad3-7ecd12f46a7e

Installation
```sh
git clone git@github.com:mikesmithgh/kitty-scrollback.nvim.git
cd kitty-scrollback.nvim
./scripts/kittyscrollbackgeneratekittens.sh # copy desired configs to kitty config
```

Example:
```sh
# Browse scrollback buffer in nvim
map ctrl+shift+h kitten /Users/mike/gitrepos/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py
# Browse output of the last shell command in nvim
map ctrl+shift+g kitten /Users/mike/gitrepos/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py --config-file /Users/mike/gitrepos/kitty-scrollback.nvim/lua/kitty-scrollback/configs/get_text_last_cmd_output.lua
# Show clicked command output in nvim
mouse_map ctrl+shift+right press ungrabbed combine : mouse_select_command_output : kitten /Users/mike/gitrepos/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py --config-file /Users/mike/gitrepos/kitty-scrollback.nvim/lua/kitty-scrollback/configs/last_visited_cmd_output.lua
```

## Configuration
- anything preceding `--nvim-args` will be passed to nvim, do no use --cmd or an error will occur
- `--nvim-no-args` to disable default and pass no args
- `--nvim-appname` to set `NVIM_APPNAME` environment variable
- `--config-file` to set lua file with `config` function to set plugin options

## Roadmap
- add quick setup to allow user to test easily before installing
- add documentation and examples
- release v1
- ci/cd
- add support for https://github.com/m00qek/baleia.nvim

## Recommendations
- [vim-kitty](https://github.com/fladson/vim-kitty) - for Kitty config syntax highlighting
- [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) - for Kitty and Neovim split window management 

## Acknowledgements
- Kitty [custom kitten](https://sw.kovidgoyal.net/kitty/kittens/custom/) documentation
- [baleia.nvim](https://github.com/m00qek/baleia.nvim) - very nice plugin to colorize Neovim buffer containing ANSI escape seqeunces. I plan to add integration with this plugin 🤝
- Kitty issue [Feature Request: Ability to select text with the keyboard (vim-like) #719](https://github.com/kovidgoyal/kitty/issues/719) - ideas for passing the scrollback buffer to Neovim
- Kitty discussion [Vi mode for kitty #6485](https://github.com/kovidgoyal/kitty/discussions/6485) - inpiration to leverage Neovim's terminal for the scrollback buffer
- [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) - referenced for color darkening, thank you folke!
- [lazy.nvim](https://github.com/folke/lazy.nvim) - referenced for window sizing, thank you folke!
- [fzf-lua](https://github.com/ibhagwan/fzf-lua) - inspiration/reference for displaying keymapping footer
- [cellular-automaton.nvim](https://github.com/Eandrju/cellular-automaton.nvim) - included in a fun example config
- StackExchange [CamelCase2snake_case()](https://codegolf.stackexchange.com/a/177958/119424) - for converting Neovim highlight names to `SCREAMING_SNAKE_CASE`
