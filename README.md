<!-- panvimdoc-ignore-start -->

<img src="https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/ddd50e0a-ec10-4507-9134-ad7f136c388a" alt="kitty-scrollback" align="right" width="70px" />

<!-- panvimdoc-ignore-end -->

# 😽 kitty-scrollback.nvim

Navigate your [Kitty](https://sw.kovidgoyal.net/kitty/) scrollback buffer to quickly search, copy, and execute commands in [Neovim](https://neovim.io/).

<!-- panvimdoc-ignore-start -->

[![neovim: v0.10+](https://img.shields.io/static/v1?style=flat-square&label=neovim&message=v0.10%2b&logo=neovim&labelColor=282828&logoColor=8faa80&color=414b32)](https://neovim.io/)
[![kitty v0.43.0+](https://img.shields.io/badge/v0.43.0%2B-352217?style=flat-square&logo=data%3Aimage%2Fjpeg%3Bbase64%2C%2F9j%2F4AAQSkZJRgABAQAAAQABAAD%2F4gHYSUNDX1BST0ZJTEUAAQEAAAHIAAAAAAQwAABtbnRyUkdCIFhZWiAH4AABAAEAAAAAAABhY3NwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAA9tYAAQAAAADTLQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlkZXNjAAAA8AAAACRyWFlaAAABFAAAABRnWFlaAAABKAAAABRiWFlaAAABPAAAABR3dHB0AAABUAAAABRyVFJDAAABZAAAAChnVFJDAAABZAAAAChiVFJDAAABZAAAAChjcHJ0AAABjAAAADxtbHVjAAAAAAAAAAEAAAAMZW5VUwAAAAgAAAAcAHMAUgBHAEJYWVogAAAAAAAAb6IAADj1AAADkFhZWiAAAAAAAABimQAAt4UAABjaWFlaIAAAAAAAACSgAAAPhAAAts9YWVogAAAAAAAA9tYAAQAAAADTLXBhcmEAAAAAAAQAAAACZmYAAPKnAAANWQAAE9AAAApbAAAAAAAAAABtbHVjAAAAAAAAAAEAAAAMZW5VUwAAACAAAAAcAEcAbwBvAGcAbABlACAASQBuAGMALgAgADIAMAAxADb%2F2wBDACodICUgGiolIiUvLSoyP2lEPzo6P4FcYUxpmYagnpaGk5GovfLNqLPltZGT0v%2FV5fr%2F%2F%2F%2F%2Fo8v%2F%2F%2F%2F%2F%2F%2FL%2F%2F%2F%2F%2F2wBDAS0vLz83P3xERHz%2FrpOu%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwAARCAEAAQADASIAAhEBAxEB%2F8QAGgABAAMBAQEAAAAAAAAAAAAAAAECAwQFBv%2FEAC8QAQACAQIEAgkFAQEAAAAAAAABAgMEERIhMVFBYQUTFCIyUnGRoUJTgZLB4SP%2FxAAXAQEBAQEAAAAAAAAAAAAAAAAAAQID%2F8QAGxEBAQEBAQEBAQAAAAAAAAAAAAERAhIhMUH%2F2gAMAwEAAhEDEQA%2FAPHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHXix1ikTtG8rzWs9ax9mfTXlwjrtgpPht9GVtPaPhnddieaxCYmJ2mNhUAiJmdojdpXBefCI%2BppjMbxpu9vwt7NXvKbF81zDp9mr3lWdN2t%2BDYeawGlsF48In6M5iYnnEwupgBETM7RG4A2rp7T8U7NK4KR4b%2FVNi%2Ba5R2xSsdKx9lcuOs0mdoiYhPS%2BXIA0yAAAAAAAAAA7MU746z5LsNNb3Zr2bud%2FXSfgAiotWLRtaN2UaesTvO8x2bC6YiIiI2iNkggAAAAImImNpjdIDGdPWZ3jeI7Na1isbVjZIumACAplnbHafJdhqbbVivdZ%2BpfxzgOjmAAAAAABtunhnsCBPDPZALY7cF4n7u1wOnT5N68M9Y6M9RrmtgGGwAATFLW%2BGsz9IJiYnaYmPqCAAAAAiJmdoiZnyWml6xvNbR9YBUAAABx5b8eSZ8PBvnvw02jrLlb5jHV%2FgCeGezTKBPDPZG2wAAAJisgg3nutwx3TwwmrisWlaJiUcMI4T4fUzWCsTF4267o3mq1bc%2FMHYKY78Uea7DoPQ02krWItkje3afBzaOkX1Fd%2Bkc3qNcxnqit6VvG16xMeaMlprtELVneIknUtxh5uq03qZ4q86T%2BHO9jNSMmK1Z8YeOlmOnN0b6XTzmtvblSOvmwevgpFMNKx25kmnVxalK442pWIjyWRadqzKuO02336r6kuObDU6St4m2ONrdo6S87o9t5mtpFNRO36o3Oo3zXOCmTJFeUdWWnNliZy23RFY8VrW57zzlTebNua0zEKzaThTwwfD6rvPcX4YRwx3NMVEzWUKgAALRXunesdk1cU3nunilbihpSsTG8gzj3vCUxXhtE7dJbgqs0%2FXjlpS3FXdTaazvX7d167Tzjlv1ZrUdWhtFdRG%2FjGz03iRMxMTHKYepp9RXNXaZ2v4wvNZ6i2X4o%2Bi%2BP4ILVi3VPKI7RDM5s6tZRktFMdrT4Ru8Z16zUxf8A86TvXxnu5F6rfMHsYrRfFW0eMPHdWj1MY%2FcvPuz0nsc06mu7J8CuLrLTlaO8SitYrHJLzb3Kws83X2i2o2j9MbOzUaiuGve3hDy7TNrTaZ3mectdVrmKZL8Fd%2FsypT9eWf4a2iN4tPPbpCm02ne327JGqyvXjvNoidlZ93wl0DWMuXilG89296REbwz4oEUF96yiax4GmKgKgAAtjpxz5Kt8HwT9QXisVjlCQRQAAAF6zunp0YZbzSu8TtLL12T5vwnlr09GuqzVjaMk%2FwA81b5smT47zMdnB67J834PXZPm%2FBlNjsb10ma0b8G31l5sZ8kTvFua%2Ftup%2Fev9zyXp3zpM0fo3%2BksJiYnaY2mHP7bqf3r%2FAHUnPlmZmbzMz4nlJ07qZsmP4LzEdl51Wa0bTkn%2BOTzfXZPm%2FB67J834Mq%2Bo7JmZneecomdnJ67J834a4rzeJ4p3lPJ6XmdwGkABBW1K26wsA5r0mk%2BSrfP8H8sFQAAAAXx34J59JUAdUTExyndLkImYneBddYyrm5e9H2JzRtyj7g0m0R1mIVnLWPHdzzMzO89QNTe03neUAIAAAAAAAAJpaazvCAHRXLWevJaLRPSYlykTMTvAuusZVzRt70fYtm5e7H3BqiZiOs7OWZmZ3nqBq%2BS%2FHPLpCgCAAAAAAAAAAAALY8d8s7Y6WtPlCLVtS01tExMdYl6vobJj4L4%2BUZN9%2FrDp12jrqqbxtGSOk%2F5IPAFslLY7zS8TFo6xKoAAAAAAAAAAAAAAAAAAAAAAAAAAAAJpa1LRaszFo6TD3dBra6mvDfaMsdY7vBTW1qWi1ZmLR0mAe9rtHXVU3jaMkdJ%2FyXhZKWx3ml4mLR1h7eg1tdTXhvtGWOsd1tdo66qm8bRkjpP%2BSDwBOSlsd5peJi0dYQAAAAAAAAAAAAAAAAAAAAAAAAAAAACa2tS0WrMxaOkw93QayNVThtyyVjn5%2BbxcGG%2BoyxTHG8z%2BHv6XTU02Phrzmetu4M9fo66jHNo5ZKxynv5PAex6S10Y4nDine88rT2eOAAAAAAAAAAAAAAAAAAAAAAAAAAA0wYb6jLFMcbzP4MGG%2BoyxTHG8z%2BHv6XTU02Lhpzmetu4Gl01NNj4a85nrbu5fSOv9VE4sM%2B%2F4z8v%2FT0jr%2FVb4sM%2B%2FwCNvl%2F68br1A6zzAAF64ct43pjvaO8VmU%2BzZ%2F2cn9ZBmNfZs%2F7OT%2Bsns2f9nJ%2FWQZDT2bP%2Bzk%2FrKLYctI3vjvWO81mAUAAAAAAAAAAAAAAAAAAAB6vobJirjvWZiMkzvz8YX9IekIxxOLBaJvPW0eDxwDr1AAI68%2BgA%2BmwXx2xVnFMTXblsu%2BWAfVIfLAPqVM18dMVpyzEV257vmQCevIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH%2F9k%3D&label=kitty&labelColor=282828)](https://sw.kovidgoyal.net/kitty/)
[![semantic-release: angular](https://img.shields.io/static/v1?style=flat-square&label=semantic-release&message=angular&logo=semantic-release&labelColor=282828&logoColor=d8869b&color=8f3f71)](https://github.com/semantic-release/semantic-release)
[![test status](https://img.shields.io/github/actions/workflow/status/mikesmithgh/kitty-scrollback.nvim/tests.yml?style=flat-square&logo=github&logoColor=c7c7c7&label=tests&labelColor=282828&event=push)](https://github.com/mikesmithgh/kitty-scrollback.nvim/actions/workflows/tests.yml?query=event%3Apush)
[![nightly test status](https://img.shields.io/github/actions/workflow/status/mikesmithgh/kitty-scrollback.nvim/tests.yml?style=flat-square&logo=github&logoColor=c7c7c7&label=nightly%20tests&labelColor=282828&event=schedule)](https://github.com/mikesmithgh/kitty-scrollback.nvim/actions/workflows/tests.yml?query=event%3Aschedule)

<a href="https://github.com/mikesmithgh/kitty-scrollback.nvim/wiki/kitty_scrollback_nvim">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/mikesmithgh/kitty-scrollback.nvim/wiki/assets/kitty_scrollback_screencapture_00_kitty_scrollback_nvim.gif">
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/mikesmithgh/kitty-scrollback.nvim/wiki/assets/kitty_scrollback_screencapture_00_kitty_scrollback_nvim.gif">
    <img alt="kitty-scrollback.nvim demo" src="https://github.com/mikesmithgh/kitty-scrollback.nvim/wiki/assets/kitty_scrollback_screencapture_00_kitty_scrollback_nvim.gif">
  </picture>
</a>

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## 📖 Contents

- ✨ [Features](#-features)
- 🚀 [Migrating to v8.0.0](#-migrating-to-v800)
- 🚀 [Migrating to v7.0.0](#-migrating-to-v700)
- 📚 [Prerequisites](#-prerequisites)
- 🏃 [Quickstart](#-quickstart)
- 📦 [Installation](#-installation)
- 🛠️ [Setup](#%EF%B8%8F-setup)
- ⚙️ [Configuration](#%EF%B8%8F-configuration)
  - [Kitten Arguments](#kitten-arguments)
  - [Plugin Configuration](#plugin-configuration)
    - [Overriding Builtin Configurations](#overriding-builtin-configurations)
    - [Global Configuration](#global-configuration)
    - [Configuration Precedence](#configuration-precedence)
    - [Configuration Options](#configuration-options)
  - [Nerd Fonts](#nerd-fonts)
  - [Separate Neovim Configuration](#separate-neovim-configuration)
    - [No Configuration](#no-configuration)
    - [User Configuration](#user-configuration)
    - [Use `KITTY_SCROLLBACK_NVIM` Environment Variable](#use-kitty_scrollback_nvim-environment-variable)
    - [`NVIM_APPNAME` With Separate Configuration](#nvim_appname-with-separate-configuration)
- 🧬 [Environment Variables](#-environment-variables)
- 📄 [Filetypes](#-filetypes)
- 🫡 [Commands](#-commands)
- ⌨️ [Keymaps](#%EF%B8%8F-keymaps)
- 🪛 [Optional Setup](#-optional-setup)
  - [Command-line editing](#command-line-editing)
- 👏 [Recommendations](#-recommendations)
- 🤝 [Acknowledgements](#-acknowledgements)
- 🐶 [Alternatives](#-alternatives)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

<!-- panvimdoc-ignore-end -->

## ✨ Features

<!-- panvimdoc-ignore-start -->

> [!TIP]\
> Expand each section under the [Features](#-features) section to see a demo.
>
> Check out the [wiki](https://github.com/mikesmithgh/kitty-scrollback.nvim/wiki) for 
> [useful](https://github.com/mikesmithgh/kitty-scrollback.nvim/wiki#useful-configurations) and [recommended](https://github.com/mikesmithgh/kitty-scrollback.nvim/wiki#recommended-configurations-for-other-plugins) configurations.

<!-- panvimdoc-ignore-end -->

<details> 
<summary>😻 Navigate Kitty's scrollback buffer with Neovim</summary>
 
- Open Kitty's scrollback history (default mapping `<C-S-h>`)
- That's it! You are in Neovim, navigate the scrollback buffer.
  
</details>

<details> 
<summary>🐱 Copy scrollback contents to system clipboard</summary>
  
<!-- panvimdoc-ignore-start -->

![copy_visual_selection_to_clipboard](https://github.com/mikesmithgh/kitty-scrollback.nvim/wiki/assets/kitty_scrollback_screencapture_01_should_copy_visual_selection_to_clipboard.gif)

<!-- panvimdoc-ignore-end -->

- Open Kitty's scrollback history (default mapping `<C-S-h>`)
- Search backward for a pattern in Neovim `?{pattern}<CR>`
- Enter Visual mode `v` and select desired text
- Copy selection to clipboard (default mapping `<leader>y`)
- `kitty-scrollback.nvim` automatically closes

</details>

<details> 
<summary>😺 Paste visual selection to Kitty</summary>
  
<!-- panvimdoc-ignore-start -->

![kitty_scrollback_screencapture_03_should_paste_visual_selection_to_kitty.gif](https://github.com/mikesmithgh/kitty-scrollback.nvim/wiki/assets/kitty_scrollback_screencapture_03_should_paste_visual_selection_to_kitty.gif)

<!-- panvimdoc-ignore-end -->

- Open Kitty's scrollback history (default mapping `<C-S-h>`)
- Search backward for a pattern in Neovim `?{pattern}<CR>`
- Enter Visual mode `v` and select desired text
- Paste visual selection to Kitty (default mapping `<S-CR>`)
- `kitty-scrollback.nvim` automatically closes and pastes the contents for further editing

</details>

<details>
<summary>🙀 Execute visual selection in Kitty</summary>
  
<!-- panvimdoc-ignore-start -->

![kitty_scrollback_screencapture_05_should_execute_visual_selection_in_kitty.mov](https://github.com/mikesmithgh/kitty-scrollback.nvim/wiki/assets/kitty_scrollback_screencapture_05_should_execute_visual_selection_in_kitty.gif)

<!-- panvimdoc-ignore-end -->

- Open Kitty's scrollback history (default mapping `<C-S-h>`)
- Search backward for a pattern in Neovim `?{pattern}<CR>`
- Enter Visual mode `v` and select desired text
- Execute visual selection in Kitty (default mapping `<C-CR>`)
- `kitty-scrollback.nvim` automatically closes and executes the visual selection

</details>

<details> 
<summary>😸 Modify and send content from paste window to Kitty</summary>
  
<!-- panvimdoc-ignore-start -->

![kitty_scrollback_screencapture_02_should_paste_paste_window_text_to_kitty.gif](https://github.com/mikesmithgh/kitty-scrollback.nvim/wiki/assets/kitty_scrollback_screencapture_02_should_paste_paste_window_text_to_kitty.gif)

<!-- panvimdoc-ignore-end -->

- Open Kitty's scrollback history (default mapping `<C-S-h>`)
- Search backward for a pattern in Neovim `?{pattern}<CR>`
- Enter Visual mode `v` and select desired text
- Copy selection to the paste window in `kitty-scrollback.nvim` for further edits
    - Alternatively, you could just enter Insert mode (`i` or `a`) to open an empty floating window (similar to `<C-x><C-e>` in Bash)
- Modify the content in the paste window
- Paste the content of the paste window to Kitty (default mapping `<S-CR>`)
- `kitty-scrollback.nvim` automatically closes and pastes the contents for further editing

</details>

<details> 
<summary>😼 Modify and execute content from paste window to Kitty</summary>
  
<!-- panvimdoc-ignore-start -->

![kitty_scrollback_screencapture_04_should_execute_paste_window_text_in_kitty.gif](https://github.com/mikesmithgh/kitty-scrollback.nvim/wiki/assets/kitty_scrollback_screencapture_04_should_execute_paste_window_text_in_kitty.gif)

<!-- panvimdoc-ignore-end -->

- Open Kitty's scrollback history (default mapping `<C-S-h>`)
- Search backward for a pattern in Neovim `?{pattern}<CR>`
- Enter Visual mode `v` and select desired text
- Copy selection to the paste window in `kitty-scrollback.nvim` for further edits
    - Alternatively, you could just enter Insert mode (`i` or `a`) to open an empty floating window (similar to `<C-x><C-e>` in Bash)
- Modify the content in the paste window
- Execute the content of the paste window in Kitty (default mapping `<C-CR>`)
- `kitty-scrollback.nvim` automatically closes and executes the content of the paste window

</details>
<details> 
<summary>😹 Edit the current command line (bash, fish, or zsh)</summary>

https://github.com/user-attachments/assets/6b4f177f-34c2-4ce7-9adb-15e0d3e19498

This requires extra steps to setup. See optional [Command-line editing setup](#command-line-editing).
  
- Start typing a command in your shell
- Open the current command line in kitty-scrollback.nvim with the following keybind
  - bash: `<C-x><C-e>`
  - fish: `<M-e>` or `<M-v>` (where `M` is the alt key)
  - zsh: `<C-x><C-e>`
- Modify the command and do any additional operations that you typically would perform in kitty-scrollback.nvim

</details>
<details> 

## 🚀 Migrating to v8.0.0
> [!IMPORTANT]\
> v8.0.0 has breaking changes.
> 
> You can ignore this section if you have not previously installed any version of kitty-scrollback.nvim

<details>

  <summary>Migration Steps</summary>

  If you have any problems or questions migrating to `v8.0.0`, please open an 
  [issue](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues) or
  [discussion](https://github.com/mikesmithgh/kitty-scrollback.nvim/discussions).
  
  <!-- panvimdoc-ignore-start -->
  
  <img src="media/sad_kitty_thumbs_up.png" alt="sad-kitty-thumps-up" style="width: 20%" align="right" />
  
  <!-- panvimdoc-ignore-end -->

  - kitty-scrollback.nvim v8.0.0 dropped support for Kitty version < 0.43.0.

    If you are using an older version of Kitty, please upgrade to 0.43.0 or greater. 

    If you are using version 0.32.2 through 0.42.2 of Kitty and cannot upgrade, then you can still use tag v7.0.0 of kitty-scrollback.nvim

    See https://github.com/mikesmithgh/kitty-scrollback.nvim/releases/tag/v7.0.0

</details>

## 🚀 Migrating to v7.0.0
> [!IMPORTANT]\
> v7.0.0 has breaking changes.
> 
> You can ignore this section if you have not previously installed any version of kitty-scrollback.nvim

<details>

  <summary>Migration Steps</summary>

  If you have any problems or questions migrating to `v7.0.0`, please open an 
  [issue](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues) or
  [discussion](https://github.com/mikesmithgh/kitty-scrollback.nvim/discussions).
  
  <!-- panvimdoc-ignore-start -->
  
  <img src="media/sad_kitty_thumbs_up.png" alt="sad-kitty-thumps-up" style="width: 20%" align="right" />
  
  <!-- panvimdoc-ignore-end -->

  - kitty-scrollback.nvim v7.0.0 dropped support for Neovim version 0.9.

    If you are using Neovim version 9.0, please upgrade to 10.0 or greater. 

    If you are using Neovim version 9.0 and cannot upgrade, then you can still use tag v6.4.0 of kitty-scrolback.nvim

    See https://github.com/mikesmithgh/kitty-scrollback.nvim/releases/tag/v6.4.0

</details>

## 📚 Prerequisites

- Neovim [v0.10+](https://github.com/neovim/neovim/releases)
- Kitty [v0.43.0+](https://github.com/kovidgoyal/kitty/releases)

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

<details>

<summary>Using <a href="https://github.com/folke/lazy.nvim">lazy.nvim</a></summary>

```lua
  {
    'mikesmithgh/kitty-scrollback.nvim',
    enabled = true,
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth', 'KittyScrollbackGenerateCommandLineEditing' },
    event = { 'User KittyScrollbackLaunch' },
    -- version = '*', -- latest stable version, may have breaking changes if major version changed
    -- version = '^6.0.0', -- pin major version, include fixes and features that do not have breaking changes
    config = function()
      require('kitty-scrollback').setup()
    end,
  }
```

</details>
<details>

<summary>Using <a href="https://github.com/wbthomason/packer.nvim">packer.nvim</a></summary>

```lua
  use({
    'mikesmithgh/kitty-scrollback.nvim',
    disable = false,
    opt = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth', 'KittyScrollbackGenerateCommandLineEditing' },
    event = { 'User KittyScrollbackLaunch' },
    -- tag = '*', -- latest stable version, may have breaking changes if major version changed
    -- tag = 'v6.0.0', -- pin specific tag
    config = function()
      require('kitty-scrollback').setup()
    end,
  })
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

## 🛠️ Setup

This section outlines the required configuration for kitty-scrollback.nvim.

- Enable [allow_remote_control](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.allow_remote_control) in [kitty.conf](https://sw.kovidgoyal.net/kitty/conf/)
  - Valid values are `yes`, `socket`, `socket-only`
  - If kitty-scrollback.nvim is the only application controlling Kitty then `socket-only` is preferred to continue denying TTY requests.
- Set [listen_on](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.listen_on) to a Unix socket in [kitty.conf](https://sw.kovidgoyal.net/kitty/conf/)
  - For example, `listen_on unix:/tmp/kitty`
- Enable [shell_integration](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.shell_integration) in [kitty.conf](https://sw.kovidgoyal.net/kitty/conf/)
  - Set `shell_integration` to `enabled`
  - Do not add the option `no-prompt-mark`
- Generate the default kitty-scrollback.nvim [Kitten](https://sw.kovidgoyal.net/kitty/kittens_intro/) mappings and add them to [kitty.conf](https://sw.kovidgoyal.net/kitty/conf/) 
  ```sh
  nvim --headless +'KittyScrollbackGenerateKittens'
  ```
- Completely close and reopen Kitty
- Check the health of kitty-scrollback.nvim
  ```sh
  nvim +'KittyScrollbackCheckHealth'
  ```
  - Follow the instructions of any `ERROR` or `WARNINGS` reported during the healthcheck

- Test kitty-scrollback.nvim is working as expected by pressing `kitty_mod+h` to open the scrollback history in Neovim
  - [kitty_mod](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.kitty_mod) is a special modifier key alias for default shortcuts. You can change the value of this option to 
alter all default shortcuts that use [kitty_mod](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.kitty_mod). The default value of [kitty_mod](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.kitty_mod) is `ctrl+shift`. In this example, `kitty_mod+h` represents `ctrl+shift+h`.

- See example kitty.conf for reference.
  ```sh
  allow_remote_control yes
  listen_on unix:/tmp/kitty
  shell_integration enabled
  
  # kitty-scrollback.nvim Kitten alias
  action_alias kitty_scrollback_nvim kitten /path/to/your/install/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py
  
  # Browse scrollback buffer in nvim
  map kitty_mod+h kitty_scrollback_nvim
  # Browse output of the last shell command in nvim
  map kitty_mod+g kitty_scrollback_nvim --config ksb_builtin_last_cmd_output
  # Show clicked command output in nvim
  mouse_map ctrl+shift+right press ungrabbed combine : mouse_select_command_output : kitty_scrollback_nvim --config ksb_builtin_last_visited_cmd_output
  ```

## ⚙️ Configuration

This section provides details on how to customize your kitty-scrollback.nvim configuration.

> [!IMPORTANT]\
> Please review the [Recommended Configurations for other plugins](https://github.com/mikesmithgh/kitty-scrollback.nvim/wiki#recommended-configurations-for-other-plugins) 
> section of the wiki to prevent conflicts with other plugins.
>

### Kitten Arguments
Arguments that can be passed to the `kitty_scrollback_nvim` [Kitten](https://sw.kovidgoyal.net/kitty/kittens_intro/) defined in [kitty.conf](https://sw.kovidgoyal.net/kitty/conf/). You can provide 
the arguments to the `action_alias kitty_scrollback_nvim` or each individual mapping referencing `kitty_scrollback_nvim`.

The following examples show you how you could reference a kitty-scrollback.nvim user configuration by name (.e.g, `myconfig`), set the environment variable `NVIM_APPNAME` for Neovim, and pass the argument `-n` to Neovim to disable swap files.
- Example of adding arguments to `action_alias` in [kitty.conf](https://sw.kovidgoyal.net/kitty/conf/). 
  - This will apply the arguments to all the mappings of `kitty_scrollback_nvim`.
  ```kitty
  action_alias kitty_scrollback_nvim kitten /path/to/your/install/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py --env NVIM_APPNAME=mynvim --config myconfig --nvim-args -n
  ```

- Example of adding arguments to a `map` in [kitty.conf](https://sw.kovidgoyal.net/kitty/conf/).
  - This will apply the arguments only to the `kitty_mod+h` mappings of `kitty_scrollback_nvim`.

  ```kitty
  map kitty_mod+h kitty_scrollback_nvim --env NVIM_APPNAME=mynvim --config myconfig --nvim-args -n
  ```

| Argument         | Description                                                                                                                                                                                                                                                            |
| :--------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `--config`       | The name of the `kitty-scrollback.nvim` plugin configuration. The configuration can be defined during plugin setup (i.e., `require('kitty-scrollback').setup({ ... })`).                                 |
| `--nvim-args`    | All arguments after this flag are passed to Neovim. This must be the last of the `kitty_scrollback_nvim` Kitten arguments. Otherwise, you may unintentionally send the wrong arguments to Neovim.        |
| `--env`          | Environment variable that is passed to Neovim. Format is `--env var_name=var_value`. You may specify multiple config files that will merge all configuration options. Useful for setting `NVIM_APPNAME`. |
| `--cwd`          | The current working directory of the Neovim                                                                                                                                                              |

### Plugin Configuration

kitty-scrollback.nvim is configured using the `require('kitty-scrollback').setup()` function. `setup()` accepts an options table in the form of
`table<string, KsbOpts|fun(KsbKittyData):KsbOpts>`. The structure of `KsbOpts` is defined in [lua/kitty-scrollback/configs/defaults.lua](./lua/kitty-scrollback/configs/defaults.lua).

The key for an entry in the options table is the name of a configuration that you wish to define. The key can be referenced as the name of the configuration
that is passed to the [Kitten argument](#kitten-arguments) `--config`. For example, with a configuration named `myconfig` that disables ANSI colors:

```lua
require('kitty-scrollback').setup({
    myconfig = {
      kitty_get_text = {
        ansi = false,
      },
    }
})
```

You can reference this specific configuration as follows in kitty.conf to disable ANSI colors for the `kitty_mod+h` mapping.

```kitty
map kitty_mod+h kitty_scrollback_nvim --config myconfig
```

The value of an entry in the options table can either be a table (`KsbOpts`) or a function (`fun(KsbKittyData):KsbOpts`). `KsbKittyData` contains metadata
about Kitty and the scrollback buffer that may be useful when defining a configuration. The structure of `KsbKittyData` is defined in [lua/kitty-scrollback/launch.lua](./lua/kitty-scrollback/launch.lua).
For example, you could add an additional configuration named `myfnconfig` 😹 that only loads the entire scrollback history if the user scrolled past the number of lines on the screen.

```lua
require('kitty-scrollback').setup({
    myconfig = {
      kitty_get_text = {
        ansi = false,
      },
    },
    myfnconfig = function(kitty_data)
      return {
        kitty_get_text = {
          extent = (kitty_data.scrolled_by > kitty_data.lines) and 'all' or 'screen',
        },
      }
    end,
})
```

If you update the reference in kitty.conf to `myfnconfig` then the `kitty_mod+h` mapping will use the configuration returned by the function defined by `myfnconfig`.

```kitty
map kitty_mod+h kitty_scrollback_nvim --config myfnconfig
```

#### Overriding Builtin Configurations 

The key for an entry in the options table can be any `string`. However, if the key matches a builtin name (prefixed with `ksb_builtin_`) then the configuration 
will be merged with the builtin configuration.
All of the builtin configurations are defined in [lua/kitty-scrollback/configs/builtin.lua](./lua/kitty-scrollback/configs/builtin.lua). The user defined configuration will take precedence and override any fields that are defined in both the builtin and user defined configuration.

Having the ability to merge a user defined configuration with the builtin in configuration is useful for scenarios that you wish to keep the 
default kitten mappings generated by the `:KittyScrollbackGenerateKittens` command. 

For example, imagine a scenario where you wish to modify the configuration for 
the `ksb_builtin_get_text_all` but do not wish to provide you own configuration name `myconfig` and have to update the reference in `kitty.conf` to 
`map kitty_mod+h kitty_scrollback_nvim --config myconfig`. In this scenario, the default mapping is defined in `kitty.conf` as

```
map kitty_mod+h kitty_scrollback_nvim
```

> [!NOTE]\
> When no explicit configuration is passed to `kitty_scrollback_nvim`, the config `ksb_builtin_get_text_all` is used. Effectively, the command becomes
> `map kitty_mod+h kitty_scrollback_nvim --config ksb_builtin_get_text_all`

You can achieve this by creating a user defined configuration with the key `ksb_builtin_get_text_all` as follows.
```lua
  ksb_builtin_get_text_all = {
    kitty_get_text = {
      ansi = false,
    },
  }
```

The builtin configuration for `ksb_builtin_get_text_all` is
```lua
  ksb_builtin_get_text_all = {
    kitty_get_text = {
      extent = 'all',
    },
  },
```

The user and builtin configurations will be merged resulting in 
```lua
  ksb_builtin_get_text_all = {
    kitty_get_text = {
      ansi = false,
      extent = 'all',
    },
  },
```

This approach can be used to modify the builtin configuration (e.g., `ksb_builtin_get_text_all`, `ksb_builtin_last_cmd_output`, and `ksb_builtin_last_visited_cmd_output`).
But, if you have a common configuration that you wish to have applied to all of configurations, then it is better to use a global configuration. 

#### Global Configuration

So far, all entries in the options table have been in the form a key/value pair where the key is a `string` representing the name of the configuration. There is an 
additional reserved entry for the global configuration which is the first element of the options table without a key (technically the key is `1` but it does not have to be defined). 

If you would like to provide a global configuration to automatically hide the status window, this can be achieved as follows. Notice the first entry in the
options table does not define a key, this will be considered global options and applied to all builtin and user defined configurations.

```lua
require('kitty-scrollback').setup({
    -- global configuration
    {
      status_window = {
        autoclose = true,
      },
    },
    -- builtin configuration override
    ksb_builtin_get_text_all = {
      kitty_get_text = {
        ansi = false,
      },
    },
    -- user defined configuration table
    myconfig = {
      kitty_get_text = {
        ansi = false,
      },
    },
    -- user defined configuration function
    myfnconfig = function(kitty_data)
      return {
        kitty_get_text = {
          extent = (kitty_data.scrolled_by > kitty_data.lines) and 'all' or 'screen',
        },
      }
    end,
})
```

#### Configuration Precedence

The configuration precedence is `default` > `global` > `builtin` > `user` where `default` has the lowest and `user` has the highest precedence.

| Type      | Description                                                                                                                                                                                                                                                                                                                                                                                                         |
| :-------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `default` | Standard options defined by kitty-scrollback.nvim and can be found in the file [lua/kitty-scrollback/configs/defaults.lua](./lua/kitty-scrollback/configs/defaults.lua).                                                                                                                                                                                                                                            |
| `global`  | Global options that apply to all `builtin` and `user` defined configurations. The first element in the options table without a key is considered the `global` options.                                                                                                                                                                                                                                              |
| `builtin` | Options defined by kitty-scrollback.nvim for each `kitty_scrollback_nvim` kitten command generated by `:KittyScrollbackGenerateKittens` (e.g., `ksb_builtin_get_text_all`, `ksb_builtin_last_cmd_output`, and `ksb_builtin_last_visited_cmd_output`). The builtin options can be found in the file [lua/kitty-scrollback/configs/builtin.lua](./lua/kitty-scrollback/configs/builtin.lua).                          |
| `user`    | Options defined by the user in the options table with a `string` name that is referenced in `kitty.conf` using the `--config` flag when defining a mapping for the `kitty_scrollback_nvim` kitten (e.g.,  `map kitty_mod+h kitty_scrollback_nvim --config myconfig`). User defined options can be any `string` and will merge with `builtin` options if they share the same key such as `ksb_builtin_get_text_all`. |

#### Configuration Options

```lua
{
  -- KsbCallbacks? fire and forget callback functions
  callbacks = {
    -- fun(kitty_data: KsbKittyData, opts: KsbOpts)? callback executed after initializing kitty-scrollback.nvim
    after_setup = nil,
    -- fun(kitty_data: KsbKittyData, opts: KsbOpts)? callback executed after launch started to process the scrollback buffer
    after_launch = nil,
    -- fun(kitty_data: KsbKittyData, opts: KsbOpts)?  callback executed after scrollback buffer is loaded and cursor is positioned
    after_ready = nil,
    -- fun(paste_window_data: KsbPasteWindowData, kitty_data: KsbKittyData, opts: KsbOpts)? callback executed after the paste window is opened or resized
    after_paste_window_ready = nil,
  },
  -- boolean? if true, enabled all default keymaps
  keymaps_enabled = true,
  -- boolean? if true, restore options that were modified while processing the scrollback buffer
  restore_options = false,
  -- KsbHighlights? highlight overrides
  highlight_overrides = {
    -- table? status window Normal highlight group
    KittyScrollbackNvimStatusWinNormal = {},
    -- table? status window heart icon highlight group
    KittyScrollbackNvimStatusWinHeartIcon = {},
    -- table? status window spinner icon highlight group 
    KittyScrollbackNvimStatusWinSpinnerIcon = {},
    -- table? status window ready icon highlight group
    KittyScrollbackNvimStatusWinReadyIcon = {},
    -- table? status window kitty icon highlight group
    KittyScrollbackNvimStatusWinKittyIcon = {},
    -- table? status window vim icon highlight group
    KittyScrollbackNvimStatusWinNvimIcon = {},
    -- table? paste window Normal highlight group
    KittyScrollbackNvimPasteWinNormal = {},
    -- table? paste window FloatBorder highlight group
    KittyScrollbackNvimPasteWinFloatBorder = {},
    -- table? paste window FloatTitle highlight group
    KittyScrollbackNvimPasteWinFloatTitle = {},
    -- table? scrollback buffer window Visual selection highlight group
    KittyScrollbackNvimVisual = {},
    -- table? scrollback buffer window Normal highlight group
    KittyScrollbackNvimNormal = {},
  },
  -- KsbStatusWindowOpts? options for status window indicating that kitty-scrollback.nvim is ready
  status_window = {
    -- boolean If true, show status window in upper right corner of the screen
    enabled = true,
    -- boolean If true, use plaintext instead of nerd font icons
    style_simple = false,
    -- boolean If true, close the status window after kitty-scrollback.nvim is ready
    autoclose = false,
    -- boolean If true, show a timer in the status window while kitty-scrollback.nvim is loading
    show_timer = false,
    -- KsbStatusWindowIcons? Icons displayed in the status window
    icons = {
      -- string kitty status window icon
      kitty = '󰄛',
      -- string heart string heart status window icon
      heart = '󰣐', -- variants 󰣐 |  |  | ♥ |  | 󱢠 | 
      -- string nvim status window icon
      nvim = '', -- variants  |  |  | 
    },
  },

  -- KsbPasteWindowOpts? options for paste window that sends commands to Kitty
  paste_window = {
    --- BoolOrFn? If true, use Normal highlight group. If false, use NormalFloat
    highlight_as_normal_win = nil,
    -- string? The filetype of the paste window. If nil, use the shell that is configured for kitty
    filetype = nil,
    -- boolean? If true, hide mappings in the footer when the paste window is initially opened
    hide_footer = false,
    -- integer? The winblend setting of the window, see :help winblend
    winblend = 0,
    -- KsbWinOptsOverride? Paste float window overrides, see nvim_open_win() for configuration
    winopts_overrides = nil,
    -- KsbFooterWinOptsOverride? Paste footer window overrides, see nvim_open_win() for configuration
    footer_winopts_overrides = nil,
    -- string? register used during yanks to paste window, see :h registers
    yank_register = '',
    -- boolean? If true, the yank_register copies content to the paste window. If false, disable yank to paste window
    yank_register_enabled = true,
  },

  -- KsbKittyGetText? options passed to get-text when reading scrollback buffer, see kitty @ get-text --help
  kitty_get_text = {
    -- boolean If true, the text will include the ANSI formatting escape codes for colors, bold, italic, etc.
    ansi = true,
    -- string What text to get. The default of screen means all text currently on the screen. all means all the screen+scrollback and selection means the currently selected text. first_cmd_output_on_screen means the output of the first command that was run in the window on screen. last_cmd_output means the output of the last command that was run in the window. last_visited_cmd_output means the first command output below the last scrolled position via scroll_to_prompt. last_non_empty_output is the output from the last command run in the window that had some non empty output. The last four require shell_integration to be enabled. Choices: screen, all, first_cmd_output_on_screen, last_cmd_output, last_non_empty_output, last_visited_cmd_output, selection
    extent = 'all',
    -- boolean If true, clear the selection in the matched window, if any.
    clear_selection = true,
  },
  -- boolean? if true execute :checkhealth kitty-scrollback and skip setup
  checkhealth = false,
  -- string? Sets the mode for coloring the Visual highlight group in the scrollback buffer window. darken uses a darkened version of the Normal highlight group to improve readability. kitty uses the colors defined for selection_foreground and selection_background in your Kitty configuration. nvim uses the default colors defined in the Visual highlight group. reverse reverses the foreground and background colors of the visual selection.
  visual_selection_highlight_mode = 'darken',
  -- integer? Temporary column width during get-text operation to avoid hard wrapping (larger values may impact performance), see :h columns
  scrollback_columns = 300,
}
```

### Nerd Fonts 

By default, `kitty-scrollback.nvim` uses [Nerd Fonts](https://www.nerdfonts.com) in the status window. If you would like to 
use ASCII instead, set the option `status_window.style_simple` to `true`.

<!-- panvimdoc-ignore-start -->

- Status window with Nerd Fonts <code>v3.1.0+</code> <code>opts.status_window.icons.nvim = ''</code> <code>opts.status_window.style_simple = false</code>
<div align="center">
    <img width="75%" src="https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/44d3abf2-345b-4667-aca9-cf816e37ebfa" alt="status-win-icon-nvim" />
</div>

- Status window with Nerd Fonts <code>< v3.1.0</code> <code>opts.status_window.icons.nvim = ''</code> <code>opts.status_window.style_simple = false</code>
<div align="center">
    <img width="75%" src="https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/00341b56-719c-48a2-b9c0-6604423c14be" alt="status-win-icon-vim" />
</div>

- Status window with ASCII text <code>opts.status_window.style_simple = true</code>
<div align="center">
    <img width="75%" src="https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/4b91428e-7d89-4aa2-b034-a0dfc431ae63" alt="status-win-icon-simple" />
</div>


<!-- panvimdoc-ignore-end -->

### Separate Neovim Configuration 

By default, kitty-scrollback.nvim uses your default Neovim configuration. The benefit of this, is that all of your commands, keymaps, and plugins are available to use.
However, depending on your setup, having all of your configuration load may be overkill and slow the start time of kitty-scrollback.nvim.
There are a couple approaches that can be taken to separate kitty-scrollback.nvim's Neovim configuration from the default Neovim configuration.

#### No Configuration

If you prefer not to load any Neovim configuration, the arguments `--nvim-args --clean --noplugin -n` are recommended to be passed to the `kitty_scrollback_nvim` kitten 

Details on these flags can be found by running the command [:help startup-options](https://neovim.io/doc/user/starting.html#startup-options).

```
--clean     Mimics a fresh install of Nvim.
--noplugin  Skip loading plugins.  
-n          No swap-file will be used.  
```

To provide this configuration to kitty-scrollback.nvim, pass the `--nvim-args` flag to the `kitty_scrollback_nvim` kitten defined in kitty.conf. See [Kitten Arguments](#kitten-arguments)
for more details on configuration the `kitty_scrollback_nvim` kitten. The following is an example of what the configuration should look like in your kitty.conf. 

```kitty
action_alias kitty_scrollback_nvim kitten /path/to/your/install/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py --nvim-args --clean --noplugin -n
```

#### User Configuration

If you prefer to load only a few simple configurations, creating a minimal `vimrc` (.e.g, `init.lua` or `init.vim`) and passing the `-u` argument to 
the `kitty_scrollback_nvim` kitten is recommended.

First, start off by creating your `vimrc` file. In this example, I will create the file `kitty-scrollback-nvim-kitten-config.lua` at `/path/to/your/config/` with
the contents:

```lua
-- kitty-scrollback-nvim-kitten-config.lua

-- put your general Neovim configurations here
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

vim.keymap.set({ 'n' }, '<C-e>', '5<C-e>', {})
vim.keymap.set({ 'n' }, '<C-y>', '5<C-y>', {})

-- add kitty-scrollback.nvim to the runtimepath to allow us to require the kitty-scrollback module
-- pick a runtimepath that corresponds with your package manager, if you are not sure leave them all it will not cause any issues
vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/lazy/kitty-scrollback.nvim') -- lazy.nvim
vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/site/pack/packer/opt/kitty-scrollback.nvim') -- packer
vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/site/pack/mikesmithgh/start/kitty-scrollback.nvim') -- pack
require('kitty-scrollback').setup({
  -- put your kitty-scrollback.nvim configurations here
})
```

In this example, I added a few keymaps before calling `require('kitty-scrollback').setup()`. You can add your desired configuration, the important part of this
configuration are the lines related to `runtimepath`. Pick the line that corresponds to your package manager, if you are not sure it is safe to leave all the lines.
If you have a custom or unique installation of kitty-scrollback.nvim, update the `runtimepath` to append that location so that Neovim can find the module when 
calling `require('kitty-scrollback')`. 

If you would like to confirm that the runtimepath in `kitty-scrollback-nvim-kitten-config.lua` is correct, run the following command.

```sh
nvim -u /path/to/your/config/kitty-scrollback-nvim-kitten-config.lua
```

If Neovim opens without any errors, then the runtimepath is configured correctly. If there are errors, you may need to manually find your kitty-scrollback.nvim and 
append that directory to `runtimepath` in `kitty-scrollback-nvim-kitten-config.lua`

Second, after your `vimrc` file is created (e.g., `kitty-scrollback-nvim-kitten-config.lua`), pass the file to Neovim using the `-u` flag in kitty.conf. The following 
is an example of what the configuration should look like in your kitty.conf. 


```kitty
action_alias kitty_scrollback_nvim kitten /path/to/your/install/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py --nvim-args -u /path/to/your/config/kitty-scrollback-nvim-kitten-config.lua
```

#### Use `KITTY_SCROLLBACK_NVIM` Environment Variable 

If you want to use your default Neovim configuration but only have a few minors differences, then using the environment variable `KITTY_SCROLLBACK_NVIM` is recommended. See
the [Environment Variables](#-environment-variables) section for an example of how this can be used.

#### `NVIM_APPNAME` With Separate Configuration 
If you prefer to have a completely separate Neovim configuration for kitty-scrollback.nvim, then using the environment variable
[NVIM_APPNAME](https://neovim.io/doc/user/starting.html#%24NVIM_APPNAME) is recommended.

First, start off by creating your Neovim configuration directory. In this example, I will create the directory `~/.config/ksb-nvim` and add the file `init.lua` with the contents:

```lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath, })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "mikesmithgh/kitty-scrollback.nvim",
  enabled = true,
  lazy = true,
  cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth', 'KittyScrollbackGenerateCommandLineEditing' },
  event = { "User KittyScrollbackLaunch" },
  config = function()
    require("kitty-scrollback").setup({
      {
        callbacks = {
          after_ready = vim.defer_fn(function()
            vim.fn.confirm(vim.env.NVIM_APPNAME .. " kitty-scrollback.nvim example!")
          end, 1000),
        },
      },
    })
  end,
})
```

In this example, we have a completely separate Neovim configuration with lazy.nvim as the package manager. kitty-scrollback.nvim is a configured package and has a global
configuration to print a message a second after kitty-scrollback.nvim loads.

Second, after your Neovim configuration directory is created (e.g., `~/.config/ksb-nvim`), set the environment variable `NVIM_APPNAME` to your directory in kitty.conf. The following 
is an example of what the configuration should look like in your kitty.conf. 

```kitty
action_alias kitty_scrollback_nvim kitten /path/to/your/install/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py --env NVIM_APPNAME=ksb-nvim
```

## 🧬 Environment Variables
The environment variable `KITTY_SCROLLBACK_NVIM` is set to `'true'` while kitty-scrollback.nvim is active.
> [!NOTE]  
> `'true'` is a string because `KITTY_SCROLLBACK_NVIM` is an environment variable. Make sure to use a string `'true'` in Lua
> instead of accidentally using a boolean `true`. Otherwise, the conditional checks will not operate as expected.

This can be used to in your Neovim configuration to provide kitty-scrollback.nvim specific behavior that may differ from a regular Neovim instance.
```lua
if vim.env.KITTY_SCROLLBACK_NVIM == 'true' then
    -- kitty-scrollback.nvim specific configuration
end
```

## 📄 Filetypes
The scrollback buffer's filetype is set to `kitty-scrollback` after kitty-scrollback.nvim has finished loading.

This can be used in you Neovim configuration to setup an autocommand to trigger when kitty-scrollback.nvim has finished loading the scrollback buffer.

```lua
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = vim.api.nvim_create_augroup('KittyScrollbackNvimFileType', { clear = true }),
  pattern = { 'kitty-scrollback' },
  callback = function()
    -- add your logic here
    vim.print('kitty-scrollback.nvim is open!')
    return true
  end,
})
```

The approach of using the filetype autocommand is similar to using the option `callbacks.after_ready`. One key differences, is that the callback receives
metadata about kitty as an argument. The following example is similar to the autocommand and is a just a matter of user preference.

```lua
require('kitty-scrollback').setup({
  {
    callbacks = {
      after_ready = function(kitty_data)
        vim.print(kitty_data)
      end,
    },
  },
})
```

## 🫡 Commands
The API is available via the `kitty-scrollback.api` module. e.g., `require('kitty-scrollback.api')`

| Command                                             | API                                                           | Description                                                                                       |
| :-------------------------------------------------- | :------------------------------------------------------------ | :------------------------------------------------------------------------------------------------ |
| `:KittyScrollbackGenerateKittens [generate_modes]`  | `generate_kittens(table<string\|'commands'\|'maps'>)?`        | Generate Kitten commands used as reference for configuring `kitty.conf`                           |
| `:KittyScrollbackCheckHealth`                       | `checkhealth()`                                               | Run `:checkhealth kitty-scrollback` in the context of Kitty                                       |
| `:KittyScrollbackGenerateCommandLineEditing`        | `generate_command_line_editing(string\|'bash'\|'fish'\|'zsh)` | Generate command-line editing commands used as reference for configuring `bash`, `fish`, or `zsh` |

## ⌨️ Keymaps
The API is available via the `kitty-scrollback.api` module. e.g., `require('kitty-scrollback.api')`

| `<Plug>` Mapping              | Default Mapping | Mode  | API                        | Description                                                                             |
| ----------------------------- | --------------- | ----- | -------------------------- | --------------------------------------------------------------------------------------- |
| `<Plug>(KsbExecuteCmd)`       | `<C-CR>`        | n,i   | `execute_command()`        | Execute the contents of the paste window in Kitty                                       |
| `<Plug>(KsbPasteCmd)`         | `<S-CR>`        | n,i   | `paste_command()`          | Paste the contents of the paste window to Kitty without executing                       |
| `<Plug>(KsbExecuteVisualCmd)` | `<C-CR>`        | v     | `execute_visual_command()` | Execute the contents of visual selection in Kitty                                       |
| `<Plug>(KsbPasteVisualCmd)`   | `<S-CR>`        | v     | `paste_visual_command()`   | Paste the contents of visual selection to Kitty without executing                       |
| `<Plug>(KsbToggleFooter)`     | `g?`            | n     | `toggle_footer()`          | Toggle the paste window footer that displays mappings                                   |
| `<Plug>(KsbCloseOrQuitAll)`   | `q`             | n     | `close_or_quit_all()`      | If the current buffer is the paste buffer, then close the window. Otherwise quit Neovim |
| `<Plug>(KsbQuitAll)`          | `<C-c>`         | n,i,t | `quit_all()`               | Quit Neovim                                                                             |
| `<Plug>(KsbVisualYankLine)`   | `<Leader>Y`     | v     |                            | Maps to `"+Y`                                                                           |
| `<Plug>(KsbVisualYank)`       | `<Leader>y`     | v     |                            | Maps to `"+y`                                                                           |
| `<Plug>(KsbNormalYankEnd)`    | `<Leader>Y`     | n     |                            | Maps to `"+y$`                                                                          |
| `<Plug>(KsbNormalYank)`       | `<Leader>y`     | n     |                            | Maps to `"+y`                                                                           |
| `<Plug>(KsbNormalYankLine)`   | `<Leader>yy`    | n     |                            | Maps to `"+yy`                                                                          |


## 🪛 Optional Setup

### Command-line editing

> [!NOTE]  
> Command-line editing is only supported for `bash`, `fish`, or `zsh`
>
> Only `zsh` version 5.9 or greater is supported by kitty-scrollback.nvim for command-line editing. If you are using `zsh`,
> please confirm you have a compatible version by running `zsh --version`

Generate the configuration and add it to the appropriate location. The comments in the configuration will provide
additional setup instructions. `KittyScrollbackGenerateCommandLineEditing` requires one parameter, either `bash`, `fish`, or `zsh`.
  ```sh
  nvim --headless +'KittyScrollbackGenerateCommandLineEditing <shell>' # replace <shell> with bash, fish, or zsh
  ```

The generated configuration will mention the environment variable `KITTY_SCROLLBACK_NVIM_EDIT_ARGS`. This can be used to pass arguments to kitty-scrollback.nvim in command-line editing mode.
This allows [Kitten Arguments](#kitten-arguments) setup specific to opening kitty-scrollback.nvim in command-line editing mode
that you may want to configure differently than your standard kitty-scrollback.nvim setup.

### Example setups
<details> 
<summary>bash</summary>
 
- Run `nvim --headless +'KittyScrollbackGenerateCommandLineEditing bash'`. You should see similar output to the following:

```bash

# add the following environment variables to your bash config (e.g., ~/.bashrc)
# the editor defined in KITTY_SCROLLBACK_VISUAL will be used in place of VISUAL
# for other scenarios that are not editing the command-line. For example, C-xC-e
# will edit the current command-line in kitty-scrollback.nvim and pressing v in
# less will open the file in $KITTY_SCROLLBACK_VISUAL (defaults to nvim if not
# defined)
export KITTY_SCROLLBACK_VISUAL='nvim'
export VISUAL='~/.local/share/nvim/lazy/kitty-scrollback.nvim/scripts/edit_command_line.bash'

# [optional] pass arguments to kitty-scrollback.nvim in command-line editing mode
# by using the environment variable KITTY_SCROLLBACK_NVIM_EDIT_ARGS
# export KITTY_SCROLLBACK_NVIM_EDIT_ARGS=''

# [optional] customize your readline config (e.g., ~/.inputrc) 
# default mapping in vi mode
set keymap vi-command
"v": vi-edit-and-execute-command

# default mapping in emacs mode
set keymap emacs
"\C-x\C-e": edit-and-execute-command
```
- In this case, I will use the default mappings and not make any changes to `~/.inputrc`. Open, 
`~/.bashrc` and add the following:
```bash
# ~/.bashrc
export VISUAL='~/.local/share/nvim/lazy/kitty-scrollback.nvim/scripts/edit_command_line.bash'
```
- Close and reopen your `bash` shell
- Enter a command and press `<C-x><C-e>`, you should now be editing your command line with kitty-scrollback.nvim!

Since this configuration is making use of the `VISUAL` environment variable. The environment variable `KITTY_SCROLLBACK_VISUAL` 
can be used for cases where programs open `VISUAL` that do not involve command-line editing. By default, if `KITTY_SCROLLBACK_VISUAL`
is not set, it will default to `nvim`. For example, if you open a file with `less` and press `v` to open the file with the `VISUAL`
editor, it will open in the command defined in `KITTY_SCROLLBACK_VISUAL`. So, in this case open in `nvim` as you typically would expect. 
  
</details>
<details> 
<summary>fish</summary>
 
- Run `nvim --headless +'KittyScrollbackGenerateCommandLineEditing fish'`. You should see similar output to the following:

```fish
# add the following function and bindings to your fish config
# e.g., ~/.config/fish/conf.d/kitty_scrollback_nvim.fish or ~/.config/fish/config.fish

function kitty_scrollback_edit_command_buffer
  set --local --export VISUAL '~/.local/share/nvim/lazy/kitty-scrollback.nvim/scripts/edit_command_line.sh'
  edit_command_buffer
  commandline ''
end

bind --mode default \ee kitty_scrollback_edit_command_buffer
bind --mode default \ev kitty_scrollback_edit_command_buffer

bind --mode visual \ee kitty_scrollback_edit_command_buffer
bind --mode visual \ev kitty_scrollback_edit_command_buffer

bind --mode insert \ee kitty_scrollback_edit_command_buffer
bind --mode insert \ev kitty_scrollback_edit_command_buffer

# [optional] pass arguments to kitty-scrollback.nvim in command-line editing mode
# by using the environment variable KITTY_SCROLLBACK_NVIM_EDIT_ARGS
# set --global --export KITTY_SCROLLBACK_NVIM_EDIT_ARGS ''
```

- In this case, I will map `<M-e>` to use kitty-scrollback.nvim and keep `<M-v>` with the default mappings. Open
`~/.config/fish/conf.d/kitty_scrollback_nvim.fish` and add the following:

```fish
# ~/.config/fish/conf.d/kitty_scrollback_nvim.fish 
function kitty_scrollback_edit_command_buffer
    set --local --export VISUAL '~/.local/share/nvim/lazy/kitty-scrollback.nvim/scripts/edit_command_line.sh'
    edit_command_buffer
    commandline ''
end

bind --mode default \ee kitty_scrollback_edit_command_buffer
bind --mode visual \ee kitty_scrollback_edit_command_buffer
bind --mode insert \ee kitty_scrollback_edit_command_buffer
```
- Close and reopen your `fish` shell
- Enter a command and press `<M-e>` (where `M` is the alt key), you should now be editing your command line with kitty-scrollback.nvim!

Since this example configuration is not rebinding `\ev`. You can still press `<M-v>` (where `M` is the alt key), to open then
command-line buffer in the editor defined in the `VISUAL` environment variable. This gives you some extra flexibility in the fish shell!
  
</details>
<details> 
<summary>zsh</summary>
 
- Run `nvim --headless +'KittyScrollbackGenerateCommandLineEditing zsh'`. You should see similar output to the following:

```zsh
# IMPORTANT: kitty-scrollback.nvim only supports zsh 5.9 or greater for command-line editing,
# please check your version by running: zsh --version

# add the following environment variables to your zsh config (e.g., ~/.zshrc)

autoload -Uz edit-command-line
zle -N edit-command-line

function kitty_scrollback_edit_command_line() { 
  local VISUAL='~/.local/share/nvim/lazy/kitty-scrollback.nvim/scripts/edit_command_line.sh'
  zle edit-command-line
  zle kill-whole-line
}
zle -N kitty_scrollback_edit_command_line

bindkey '^x^e' kitty_scrollback_edit_command_line

# [optional] pass arguments to kitty-scrollback.nvim in command-line editing mode
# by using the environment variable KITTY_SCROLLBACK_NVIM_EDIT_ARGS
# export KITTY_SCROLLBACK_NVIM_EDIT_ARGS=''
```
- Open `~/.zshrc` and add the following:
```zsh
# ~/.zshrc
autoload -Uz edit-command-line
zle -N edit-command-line

function kitty_scrollback_edit_command_line() { 
  local VISUAL='~/.local/share/nvim/lazy/kitty-scrollback.nvim/scripts/edit_command_line.sh'
  zle edit-command-line
  zle kill-whole-line
}
zle -N kitty_scrollback_edit_command_line

bindkey '^x^e' kitty_scrollback_edit_command_line
```
- Close and reopen your `zsh` shell
- Enter a command and press `<C-x><C-e>`, you should now be editing your command line with kitty-scrollback.nvim!

</details>

## 👏 Recommendations

- Check out my ⚡️ Lightning Talk @ Neovim Conf 2023 [Developing kitty-scrollback.nvim](https://youtu.be/9TINe0J9rNg?si=_ISKqAQVS2NCuSRF)!

<!-- panvimdoc-ignore-start -->

[![Developing kitty-scrollback.nvim NeovimConf 2023](https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/d103a326-dfac-4948-8f15-d2885e646a6c)](https://www.youtube.com/watch?v=9TINe0J9rNg)

<!-- panvimdoc-ignore-end -->

- The following plugins are nice additions to your Neovim and Kitty setup.
  - [vim-kitty](https://github.com/fladson/vim-kitty) - Syntax highlighting for Kitty terminal config files
  - [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) - Seamless navigation between Neovim and Kitty split panes 

## 🤝 Acknowledgements
- Kitty [custom kitten](https://sw.kovidgoyal.net/kitty/kittens/custom/) documentation
- [baleia.nvim](https://github.com/m00qek/baleia.nvim) - very nice plugin to colorize Neovim buffer containing ANSI escape sequences. I plan to add integration with this plugin 🤝
- [kovidgoyal/kitty#719 Feature Request: Ability to select text with the keyboard (vim-like)](https://github.com/kovidgoyal/kitty/issues/719) - ideas for passing the scrollback buffer to Neovim
  - [kovidgoyal/kitty#719 Comment 952039731 ](https://github.com/kovidgoyal/kitty/issues/719#issuecomment-952039731) - very detailed solution to opening the Kitty scrollback buffer in Neovim. In particular, I used the `set title` escape code to hide the `[Process exited]` message
- [kovidgoyal/kitty#2426 'Failed to open controlling terminal' error when trying to remote control from vim](https://github.com/kovidgoyal/kitty/issues/2426) - workaround for issuing kitty remote commands without a TTY `listen_on unix:/tmp/mykitty`
- [kovidgoyal/kitty#6485 Vi mode for kitty](https://github.com/kovidgoyal/kitty/discussions/6485) - inspiration to leverage Neovim's terminal for the scrollback buffer
- [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) - referenced for color darkening, thank you folke!
- [lazy.nvim](https://github.com/folke/lazy.nvim) - referenced for window sizing, thank you folke!
- [fzf-lua](https://github.com/ibhagwan/fzf-lua) - quickstart `mini.sh` and inspiration/reference for displaying keymapping footer
- [panvimdoc](https://github.com/kdheepak/panvimdoc) - generating vimdocs from README
- [lemmy-help](https://github.com/numToStr/lemmy-help) - generating vimdocs from Lua annotations
- [bob](https://github.com/MordechaiHadad/bob) - easy Neovim version management to check backward compatibility

## 🐶 Alternatives
- [kitty+page.lua](https://gist.github.com/galaxia4Eva/9e91c4f275554b4bd844b6feece16b3d) - Open Kitty's scrollback buffer in Neovim via `scrollback_pager`
- [Neovim scrollback pager by page-down](https://github.com/kovidgoyal/kitty/issues/719#issuecomment-952039731) - Linux only solution to open Kitty scrollback buffer in Neovim
- [kitty_grab](https://github.com/yurikhan/kitty_grab) - Keyboard-driven screen grabber for Kitty
- [kitty-kitten-search](https://github.com/trygveaa/kitty-kitten-search) - Kitten for the kitty terminal emulator providing live incremental search in the terminal history.
  
<!-- panvimdoc-ignore-start -->

<div align="center">
    <img src="https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/50852780-b3ce-4cb2-8e88-c1ea79e3e140" alt="scared cat" />
</div>

<!-- panvimdoc-ignore-end -->

