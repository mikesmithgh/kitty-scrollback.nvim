<img src="https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/a7357844-e0e4-4053-8c77-6d129528504f" alt="kitty-scrollback" style="width: 20%" align="right" />

# 😽 kitty-scrollback.nvim
Neovim plugin/Kitten to integrate Neovim with Kitty's scrollback buffer

![nvim loves kitty](https://img.shields.io/static/v1?style=fl&label=%E2%9D%A4%EF%B8%8F&message=%F0%9F%90%B1&logo=neovim&labelColor=282828&logoColor=8faa80&color=282828)
> [!WARNING]  
> This project is still a work in progress and not considered stable

https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/ceeff852-2e95-452d-8b4b-c05e65b38607

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
map ctrl+shift+g kitten /Users/mike/gitrepos/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py --config-file /Users/mike/gitrepos/kitty-scrollback.nvim/lua/kitty-scrollback/configs/last_cmd_output.lua
# Show clicked command output in nvim
mouse_map ctrl+shift+right press ungrabbed combine : mouse_select_command_output : kitten /Users/mike/gitrepos/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py --config-file /Users/mike/gitrepos/kitty-scrollback.nvim/lua/kitty-scrollback/configs/last_visited_cmd_output.lua
```

## Configuration
anything preceding `--nvim-args` will be passed to nvim, do no use --cmd or an error will occur
`--nvim-no-args` to disable default and pass no args
`--nvim-appname` to set `NVIM_APPNAME` environment variable
`--config-file` to set lua file with `config` function to set plugin options

## Roadmap
- add quick setup to allow user to test easily before installing
- add documentation and examples
- release v1
- ci/cd
- add support for https://github.com/m00qek/baleia.nvim

## Recommendations
-  `fladson/vim-kitty` for config syntax highlighting
- `smart-splits`

## Acknowledgements
- https://github.com/Eandrju/cellular-automaton.nvim/tree/main
- tokyonight
- lazy.nvim
