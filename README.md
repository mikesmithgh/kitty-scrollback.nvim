<img src="https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/a7357844-e0e4-4053-8c77-6d129528504f" alt="kitty-scrollback" style="width: 20%" align="right" />

# 😽 kitty-scrollback.nvim
Open your Kitty scrollback buffer with Neovim. Ameowzing!

[![neovim: v0.10+](https://img.shields.io/static/v1?style=flat-square&label=neovim&message=v0.10%2b&logo=neovim&labelColor=282828&logoColor=8faa80&color=414b32)](https://neovim.io/)
![nvim loves kitty](https://img.shields.io/static/v1?style=fl&label=%E2%9D%A4%EF%B8%8F&message=%F0%9F%90%B1&logo=neovim&labelColor=282828&logoColor=8faa80&color=282828)
> [!WARNING]  
> This project is still a work in progress and not considered stable

https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/5aba1ba2-1883-4ac0-bad3-7ecd12f46a7e

## ✨ Features
- 😻 Navigate Kitty's scrollback buffer with Neovim
- 🐱 Copy contents from Neovim to system clipboard
- 😺 Send contents from Neovim to Kitty shell
- 🙀 Execute shell command from Neovim to Kitty shell

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

### Prerequisites
- Neovim [v0.10+](https://github.com/neovim/neovim/releases)
- Kitty [v0.27+](https://github.com/kovidgoyal/kitty/releases) *I quickly tested this version, I still need to verify all functionality*

<details>

<summary>Using <a href="https://github.com/folke/lazy.nvim">lazy.nvim</a></summary>

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

</details>
<details>

<summary>Using Neovim's built-in package support <a href="https://neovim.io/doc/user/usr_05.html#05.4">pack</a></summary>

```bash
mkdir -p "$HOME/.local/share/nvim/site/pack/mikesmithgh/start/"
cd $HOME/.local/share/nvim/site/pack/mikesmithgh/start
git clone git@github.com:mikesmithgh/kitty-scrollback.nvim.git
nvim -u NONE -c "helptags kitty-scrollback.nvim/doc" -c q
mkdir -p "$HOME/.config/nvim"
echo "require('kitty-scrollback').setup()" >> "$HOME/.config/nvim/init.lua"
```

</details>

## ✍️ Configuration

### Kitty 
The following steps outline how to properly configure [kitty.conf](https://sw.kovidgoyal.net/kitty/conf/)

<details>
<summary>Enable <a href="https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.allow_remote_control">allow_remote_control</a></summary>

  - Valid values are `yes`, `socket`, `socket-only`
  - If `kitty-scrollback.nvim` is the only application controlling Kitty then `socket-only` is preferred to continue denying TTY requests.

</details>
<details>
<summary>Set <a href="https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.listen_on">listen_on</a> to a unix socket</summary>

  - For example, `listen_on unix:/tmp/kitty`

</details>
<details>
<summary>Enable <a href="https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.shell_integration">shell_integration</a></summary>

  - Set `shell_integration` to `enabled`
  - Do not add the option `no-prompt-mark`

</details>
<details>
<summary>Add <code>kitty-scrollback.nvim</code> mappings</summary>

  - Generate default Kitten mappings and add to `kitty.conf`
  ```sh
  nvim --headless +'KittyScrollbackGenerateKittens' +'set nonumber' +'set norelativenumber' +'%print' +'quit!' 2>&1
  ```

</details>

<details>
<summary>Completely close and reopen Kitty</summary>
</details>

</details>
<details>
<summary>Check the health of <code>kitty-scrollback.nvim</code></summary>

  ```sh
  nvim +'KittyScrollbackCheckHealth' +'quit!'
  ```
  - Follow the instructions of any `ERROR` or `WARNINGS` reported during the healthcheck

</details>
<details>
<summary>Test <code>kitty-scrollback.nvim</code> is working as expected by pressing <code>ctrl+shift+h</code> to open the scrollback buffer in Neovim</summary>
</details>

<details>
<summary>See example <code>kitty.conf</code> for reference</summary>

  ```sh
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
  
</details>

### Kitten arguments

### Nerd Fonts 
By default, `kitty-scrollback.nvim` uses [Nerd Fonts](https://www.nerdfonts.com) in the status window. If you would like to 
use ASCII instead, set the option `status_window.style_simple` to `true`. 

<details>
  <summary>Status window with Nerd Fonts <code>opts.status_window.style_simple = false</code></summary>
  
  https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/4cf5b303-5061-43da-a857-c99daea82332
  
</details>
<details>
  <summary>Status window with ASCII text <code>opts.status_window.style_simple = true</code></summary>
  
  https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/a0e1b574-59ab-4abf-93a1-f314c7cd47b3
  
</details>


## 🫡 Commands and Lua API
The API is available via the `kitty-scrollback.api` module. e.g., `require('kitty-scrollback.api')`
| Command                              | API                              | Description                                                             |
| :----------------------------------- | :------------------------------- | :---------------------------------------------------------------------- |
| `:KittyScrollbackGenerateKittens[!]` | `generate_kittens(boolean\|nil)` | Generate Kitten commands used as reference for configuring `kitty.conf` |                 
| `:KittyScrollbackCheckHealth`        | `checkhealth()`                  | Run `:checkhealth kitty-scrollback` in the context of Kitty             |

## ⌨️ Keymaps and Lua API
The API is available via the `kitty-scrollback.api` module. e.g., `require('kitty-scrollback.api')`
| `<Plug>` Mapping            | Default Mapping | Mode  | API                   | Description                                                                             |
| --------------------------- | --------------- | ----- | --------------------- | --------------------------------------------------------------------------------------- |
| `<Plug>(KsbExecuteCmd)`     | `<C-CR>`        | n,i   | `execute_command()`   | Execute the contents of the paste window in Kitty                                       |
| `<Plug>(KsbPasteCmd)`       | `<S-CR>`        | n,i   | `paste_command()`     | Paste the contents of the paste window to Kitty without executing                       |
| `<Plug>(KsbToggleFooter)`   | `g?`            | n     | `toggle_footer()`     | Toggle the paste window footer that displays mappings                                   |
| `<Plug>(KsbCloseOrQuitAll)` | `<Esc>`         | n     | `close_or_quit_all()` | If the current buffer is the paste buffer, then close the window. Otherwise quit Neovim |
| `<Plug>(KsbQuitAll)`        | `<C-c>`         | n,i,t | `quit_all()`          | Quit Neovim                                                                             |
| `<Plug>(KsbVisualYankLine)` | `<Leader>Y`     | v     |                       | Maps to `"+Y`                                                                           |
| `<Plug>(KsbVisualYank)`     | `<Leader>y`     | v     |                       | Maps to `"+y`                                                                           |
| `<Plug>(KsbNormalYankEnd)`  | `<Leader>Y`     | n     |                       | Maps to `"+y$`                                                                          |
| `<Plug>(KsbNormalYank)`     | `<Leader>y`     | n     |                       | Maps to `"+y`                                                                           |
| `<Plug>(KsbNormalYankLine)` | `<Leader>yy`    | n     |                       | Maps to `"+yy`                                                                          |

## 🛣️ Roadmap
- [x] document setup with remote control and shell integration
- [x] add quick setup to allow user to test easily before installing
- [ ] add documentation and examples
- [ ] add details about relevant kitty config ( `scrollback_lines`, `scrollback_pager`, `scrollback_pager_history_size`, `scrollback_fill_enlarged_window`)
- [ ] release v1
- [ ] ci/cd
- [ ] add support for https://github.com/m00qek/baleia.nvim

## 👏 Recommendations
The following plugins are nice additions to your Neovim and Kitty setup.
- [vim-kitty](https://github.com/fladson/vim-kitty) - Syntax highlighting for Kitty terminal config files
- [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) - Seamless navigation between Neovim and Kitty split panes 

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
  - anything preceding `--nvim-args` will be passed to nvim, do no use --cmd or an error will occur
  - `--nvim-no-args` to disable default and pass no args
  - `--env` to set environment variables e.g., `--env NVIM_APPNAME=altnvim`
  - `--config-file` to set lua file with `config` function to set plugin options
