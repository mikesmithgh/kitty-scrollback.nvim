<img src="https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/a7357844-e0e4-4053-8c77-6d129528504f" alt="kitty-scrollback" style="width: 20%" align="right" />

# 😽 kitty-scrollback.nvim
Neovim plugin/Kitten to integrate Neovim with Kitty's scrollback buffer

![nvim loves kitty](https://img.shields.io/static/v1?style=fl&label=%E2%9D%A4%EF%B8%8F&message=%F0%9F%90%B1&logo=neovim&labelColor=282828&logoColor=8faa80&color=282828)
> [!WARNING]  
> This project is still a work in progress and not considered stable

https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/5aba1ba2-1883-4ac0-bad3-7ecd12f46a7e

## ✨ Features
- 😻 Navigate Kitty's scrollback buffer with Neovim

## 🏃 Quickstart

To quickly test this plugin without changing your configuration run the command:
```sh
sh -c "$(curl -s https://raw.githubusercontent.com/mikesmithgh/kitty-scrollback.nvim/main/scripts/mini.sh)"
```
> [!NOTE]  
> It is good practice to first
> [read the script](https://github.com/mikesmithgh/kitty-scrollback.nvim/blob/main/scripts/mini.sh)
> before running `sh -c` directly from the web

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
  {
    'mikesmithgh/kitty-scrollback.nvim',
    enabled = true,
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    config = function()
      require('kitty-scrollback').setup()
    end,
  }
```

### Using Neovim's built-in package support [pack](https://neovim.io/doc/user/usr_05.html#05.4)
```bash
mkdir -p "$HOME/.local/share/nvim/site/pack/mikesmithgh/start/"
cd $HOME/.local/share/nvim/site/pack/mikesmithgh/start
git clone git@github.com:mikesmithgh/kitty-scrollback.nvim.git
nvim -u NONE -c "helptags kitty-scrollback.nvim/doc" -c q
mkdir -p "$HOME/.config/nvim"
echo "require('kitty-scrollback').setup()" >> "$HOME/.config/nvim/init.lua"
```

## ✍️ Configuration

### Kitty
- Enable `allow_remote_control` in `kitty.conf`
  - Valid values are `yes`, `socket`, `socket-only`
  - See Kitty [allow_remote_control](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.allow_remote_control) for additional details
  - If `kitty-scrollback.nvim` is the only application controlling Kitty then `socket-only` is the preferred to continue denying TTY requests.
- Set `listen_on` to a unix socket
  - For example, `listen_on unix:/tmp/kitty`
- Enable `shell_integration`
  - Set `shell_integration` to `enabled` and do not add the option `no-prompt-mark`
- Add `kitty-scrollback.nvim` mappings
  - Generate default Kitten mappings
  ```sh
  nvim --headless +'KittyScrollbackGenerateKittens' +'set nonumber' +'set norelativenumber' +'%print' +'quit!' 2>&1
  ```
  - Add results to `kitty.conf`

Example `kitty.conf`
```kitty
allow_remote_control yes
listen_on unix:/tmp/kitty
shell_integration enabled

# kitty-scrollback.nvim Kitten alias
action_alias kitty_scrollback_nvim kitten /Users/mike/gitrepos/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py --cwd /Users/mike/gitrepos/kitty-scrollback.nvim/lua/kitty-scrollback/configs
 
# Browse scrollback buffer in nvim
map ctrl+shift+h kitty_scrollback_nvim
# Browse output of the last shell command in nvim
map ctrl+shift+g kitty_scrollback_nvim --config-file get_text_last_cmd_output.lua
# Show clicked command output in nvim
mouse_map ctrl+shift+right press ungrabbed combine : mouse_select_command_output : kitty_scrollback_nvim --config-file get_text_last_visited_cmd_output.lua
```

- Completely close Kitty and reopen
- Check the health of `kitty-scrollback.nvim`
  - Run `nvim +'KittyScrollbackCheckHealth' +'quit!'`
  - Follow the instructions of any `ERROR` or `WARNINGS` reported during the healthcheck
- Test `kitty-scrollback.nvim` is working by pressing `ctrl+shift+h`

## 🫡 Commands and Lua API
| Command                              | API                                                              | Description                                                             |
| ------------------------------------ | ---------------------------------------------------------------- | ----------------------------------------------------------------------- |
| `:KittyScrollbackGenerateKittens[!]` | `require('kitty-scrollback.api').generate_kittens(boolean\|nil)` | Generate Kitten commands used as reference for configuring `kitty.conf` |                 
| `:KittyScrollbackCheckHealth`        | `require('kitty-scrollback.api').checkhealth()`                  | Run `:checkhealth kitty-scrollback` in the context of Kitty             |

## ⌨️ Keymaps and Lua API
| `<Plug>` Mapping          | Default Mapping | Default Mapping Mode     | API                                                   | Description          |
| ------------------------- | --------------- | ------------------------ | ----------------------------------------------------- | -------------------- |
| `<Plug>KsbExecuteCmd`     | `<C-CR>`        | Normal, Insert           | `require('kitty-scrollback.api').execute_command()`   |                      |
| `<Plug>KsbPasteCmd`       | `<S-CR>`        | Normal, Insert           | `require('kitty-scrollback.api').paste_command()`     |                      |
| `<Plug>KsbToggleFooter`   | `g?`            | Normal                   | `require('kitty-scrollback.api').toggle_footer()`     |                      |
| `<Plug>KsbCloseOrQuitAll` | `<Esc>`         | Normal                   | `require('kitty-scrollback.api').close_or_quit_all()` |                      |
| `<Plug>KsbQuitAll`        | `<C-c>`         | Normal, Insert, Terminal | `require('kitty-scrollback.api').close_or_quit_all()` |                      |
| `<Plug>KsbVisualYankLine` | `<Leader>Y`     | Visual                   |                                                       | Equivalent to `"+Y`  |
| `<Plug>KsbVisualYank`     | `<Leader>y`     | Visual                   |                                                       | Equivalent to `"+y`  |
| `<Plug>KsbNormalYankEnd`  | `<Leader>Y`     | Normal                   |                                                       | Equivalent to `"+y$` |
| `<Plug>KsbNormalYank`     | `<Leader>y`     | Normal                   |                                                       | Equivalent to `"+y`  |
| `<Plug>KsbNormalYankLine` | `<Leader>yy`    | Normal                   |                                                       | Equivalent to `"+yy` |

## 🛣️ Roadmap
- [ ] document setup with remote control and shell integration
- [x] add quick setup to allow user to test easily before installing
- [ ] add documentation and examples
- [ ] add details about relevant kitty config ( `scrollback_lines`, `scrollback_pager`, `scrollback_pager_history_size`, `scrollback_fill_enlarged_window`)
- [ ] release v1
- [ ] ci/cd
- [ ] add support for https://github.com/m00qek/baleia.nvim

## 👏 Recommendations
- [vim-kitty](https://github.com/fladson/vim-kitty) - for Kitty config syntax highlighting
- [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) - for Kitty and Neovim split window management 

## 🤝 Ackowledgements
- Kitty [custom kitten](https://sw.kovidgoyal.net/kitty/kittens/custom/) documentation
- [baleia.nvim](https://github.com/m00qek/baleia.nvim) - very nice plugin to colorize Neovim buffer containing ANSI escape seqeunces. I plan to add integration with this plugin 🤝
- [kovidgoyal/kitty#719 Feature Request: Ability to select text with the keyboard (vim-like)](https://github.com/kovidgoyal/kitty/issues/719) - ideas for passing the scrollback buffer to Neovim
- [kovidgoyal/kitty#2426 'Failed to open controlling terminal' error when trying to remote control from vim](https://github.com/kovidgoyal/kitty/issues/2426) - workaround for issuing kitty remote commands without a tty `listen_on unix:/tmp/mykitty`
- [kovidgoyal/kitty#6485 Vi mode for kitty](https://github.com/kovidgoyal/kitty/discussions/6485) - inpiration to leverage Neovim's terminal for the scrollback buffer
- [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) - referenced for color darkening, thank you folke!
- [lazy.nvim](https://github.com/folke/lazy.nvim) - referenced for window sizing, thank you folke!
- [fzf-lua](https://github.com/ibhagwan/fzf-lua) - quickstart `mini.sh` and inspiration/reference for displaying keymapping footer
- [cellular-automaton.nvim](https://github.com/Eandrju/cellular-automaton.nvim) - included in a fun example config
- StackExchange [CamelCase2snake_case()](https://codegolf.stackexchange.com/a/177958/119424) - for converting Neovim highlight names to `SCREAMING_SNAKE_CASE`

- TODO doc up:
  - see :help clipboard
  - pbcopy and pbpaste on macos
  - xclip or wayland on linux
  - nerdfonts
  - anything preceding `--nvim-args` will be passed to nvim, do no use --cmd or an error will occur
  - `--nvim-no-args` to disable default and pass no args
  - `--env` to set environment variables e.g., `--env NVIM_APPNAME=altnvim`
  - `--config-file` to set lua file with `config` function to set plugin options
