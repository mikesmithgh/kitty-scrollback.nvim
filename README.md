<img src="https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/a7357844-e0e4-4053-8c77-6d129528504f" alt="kitty-scrollback" style="width: 20%" align="right" />

# 😽 kitty-scrollback.nvim

Navigate your Kitty scrollback buffer to quickly search, copy, and execute commands in Neovim.

<!-- panvimdoc-ignore-start -->

[![neovim: v0.10+](https://img.shields.io/static/v1?style=flat-square&label=neovim&message=v0.10%2b&logo=neovim&labelColor=282828&logoColor=8faa80&color=414b32)](https://neovim.io/)
[![kitty v0.29+](https://img.shields.io/badge/v0.29%2B-352217?style=flat-square&logo=data%3Aimage%2Fjpeg%3Bbase64%2C%2F9j%2F4AAQSkZJRgABAQAAAQABAAD%2F4gHYSUNDX1BST0ZJTEUAAQEAAAHIAAAAAAQwAABtbnRyUkdCIFhZWiAH4AABAAEAAAAAAABhY3NwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAA9tYAAQAAAADTLQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlkZXNjAAAA8AAAACRyWFlaAAABFAAAABRnWFlaAAABKAAAABRiWFlaAAABPAAAABR3dHB0AAABUAAAABRyVFJDAAABZAAAAChnVFJDAAABZAAAAChiVFJDAAABZAAAAChjcHJ0AAABjAAAADxtbHVjAAAAAAAAAAEAAAAMZW5VUwAAAAgAAAAcAHMAUgBHAEJYWVogAAAAAAAAb6IAADj1AAADkFhZWiAAAAAAAABimQAAt4UAABjaWFlaIAAAAAAAACSgAAAPhAAAts9YWVogAAAAAAAA9tYAAQAAAADTLXBhcmEAAAAAAAQAAAACZmYAAPKnAAANWQAAE9AAAApbAAAAAAAAAABtbHVjAAAAAAAAAAEAAAAMZW5VUwAAACAAAAAcAEcAbwBvAGcAbABlACAASQBuAGMALgAgADIAMAAxADb%2F2wBDACodICUgGiolIiUvLSoyP2lEPzo6P4FcYUxpmYagnpaGk5GovfLNqLPltZGT0v%2FV5fr%2F%2F%2F%2F%2Fo8v%2F%2F%2F%2F%2F%2F%2FL%2F%2F%2F%2F%2F2wBDAS0vLz83P3xERHz%2FrpOu%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwAARCAEAAQADASIAAhEBAxEB%2F8QAGgABAAMBAQEAAAAAAAAAAAAAAAECAwQFBv%2FEAC8QAQACAQIEAgkFAQEAAAAAAAABAgMEERIhMVFBYQUTFCIyUnGRoUJTgZLB4SP%2FxAAXAQEBAQEAAAAAAAAAAAAAAAAAAQID%2F8QAGxEBAQEBAQEBAQAAAAAAAAAAAAERAhIhMUH%2F2gAMAwEAAhEDEQA%2FAPHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHXix1ikTtG8rzWs9ax9mfTXlwjrtgpPht9GVtPaPhnddieaxCYmJ2mNhUAiJmdojdpXBefCI%2BppjMbxpu9vwt7NXvKbF81zDp9mr3lWdN2t%2BDYeawGlsF48In6M5iYnnEwupgBETM7RG4A2rp7T8U7NK4KR4b%2FVNi%2Ba5R2xSsdKx9lcuOs0mdoiYhPS%2BXIA0yAAAAAAAAAA7MU746z5LsNNb3Zr2bud%2FXSfgAiotWLRtaN2UaesTvO8x2bC6YiIiI2iNkggAAAAImImNpjdIDGdPWZ3jeI7Na1isbVjZIumACAplnbHafJdhqbbVivdZ%2BpfxzgOjmAAAAAABtunhnsCBPDPZALY7cF4n7u1wOnT5N68M9Y6M9RrmtgGGwAATFLW%2BGsz9IJiYnaYmPqCAAAAAiJmdoiZnyWml6xvNbR9YBUAAABx5b8eSZ8PBvnvw02jrLlb5jHV%2FgCeGezTKBPDPZG2wAAAJisgg3nutwx3TwwmrisWlaJiUcMI4T4fUzWCsTF4267o3mq1bc%2FMHYKY78Uea7DoPQ02krWItkje3afBzaOkX1Fd%2Bkc3qNcxnqit6VvG16xMeaMlprtELVneIknUtxh5uq03qZ4q86T%2BHO9jNSMmK1Z8YeOlmOnN0b6XTzmtvblSOvmwevgpFMNKx25kmnVxalK442pWIjyWRadqzKuO02336r6kuObDU6St4m2ONrdo6S87o9t5mtpFNRO36o3Oo3zXOCmTJFeUdWWnNliZy23RFY8VrW57zzlTebNua0zEKzaThTwwfD6rvPcX4YRwx3NMVEzWUKgAALRXunesdk1cU3nunilbihpSsTG8gzj3vCUxXhtE7dJbgqs0%2FXjlpS3FXdTaazvX7d167Tzjlv1ZrUdWhtFdRG%2FjGz03iRMxMTHKYepp9RXNXaZ2v4wvNZ6i2X4o%2Bi%2BP4ILVi3VPKI7RDM5s6tZRktFMdrT4Ru8Z16zUxf8A86TvXxnu5F6rfMHsYrRfFW0eMPHdWj1MY%2FcvPuz0nsc06mu7J8CuLrLTlaO8SitYrHJLzb3Kws83X2i2o2j9MbOzUaiuGve3hDy7TNrTaZ3mectdVrmKZL8Fd%2FsypT9eWf4a2iN4tPPbpCm02ne327JGqyvXjvNoidlZ93wl0DWMuXilG89296REbwz4oEUF96yiax4GmKgKgAAtjpxz5Kt8HwT9QXisVjlCQRQAAAF6zunp0YZbzSu8TtLL12T5vwnlr09GuqzVjaMk%2FwA81b5smT47zMdnB67J834PXZPm%2FBlNjsb10ma0b8G31l5sZ8kTvFua%2Ftup%2Fev9zyXp3zpM0fo3%2BksJiYnaY2mHP7bqf3r%2FAHUnPlmZmbzMz4nlJ07qZsmP4LzEdl51Wa0bTkn%2BOTzfXZPm%2FB67J834Mq%2Bo7JmZneecomdnJ67J834a4rzeJ4p3lPJ6XmdwGkABBW1K26wsA5r0mk%2BSrfP8H8sFQAAAAXx34J59JUAdUTExyndLkImYneBddYyrm5e9H2JzRtyj7g0m0R1mIVnLWPHdzzMzO89QNTe03neUAIAAAAAAAAJpaazvCAHRXLWevJaLRPSYlykTMTvAuusZVzRt70fYtm5e7H3BqiZiOs7OWZmZ3nqBq%2BS%2FHPLpCgCAAAAAAAAAAAALY8d8s7Y6WtPlCLVtS01tExMdYl6vobJj4L4%2BUZN9%2FrDp12jrqqbxtGSOk%2F5IPAFslLY7zS8TFo6xKoAAAAAAAAAAAAAAAAAAAAAAAAAAAAJpa1LRaszFo6TD3dBra6mvDfaMsdY7vBTW1qWi1ZmLR0mAe9rtHXVU3jaMkdJ%2FyXhZKWx3ml4mLR1h7eg1tdTXhvtGWOsd1tdo66qm8bRkjpP%2BSDwBOSlsd5peJi0dYQAAAAAAAAAAAAAAAAAAAAAAAAAAAACa2tS0WrMxaOkw93QayNVThtyyVjn5%2BbxcGG%2BoyxTHG8z%2BHv6XTU02Phrzmetu4M9fo66jHNo5ZKxynv5PAex6S10Y4nDine88rT2eOAAAAAAAAAAAAAAAAAAAAAAAAAAA0wYb6jLFMcbzP4MGG%2BoyxTHG8z%2BHv6XTU02Lhpzmetu4Gl01NNj4a85nrbu5fSOv9VE4sM%2B%2F4z8v%2FT0jr%2FVb4sM%2B%2FwCNvl%2F68br1A6zzAAF64ct43pjvaO8VmU%2BzZ%2F2cn9ZBmNfZs%2F7OT%2Bsns2f9nJ%2FWQZDT2bP%2Bzk%2FrKLYctI3vjvWO81mAUAAAAAAAAAAAAAAAAAAAB6vobJirjvWZiMkzvz8YX9IekIxxOLBaJvPW0eDxwDr1AAI68%2BgA%2BmwXx2xVnFMTXblsu%2BWAfVIfLAPqVM18dMVpyzEV257vmQCevIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH%2F9k%3D&label=kitty&labelColor=282828)](https://sw.kovidgoyal.net/kitty/)
[![semantic-release: angular](https://img.shields.io/static/v1?style=flat-square&label=semantic-release&message=angular&logo=semantic-release&labelColor=282828&logoColor=d8869b&color=8f3f71)](https://github.com/semantic-release/semantic-release)

<a href="https://github.com/mikesmithgh/kitty-scrollback.nvim/wiki/kitty_scrollback_nvim">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/6dd229dd-0206-4d50-b627-f5f0f5fe8cd1">
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/6dd229dd-0206-4d50-b627-f5f0f5fe8cd1">
    <img alt="kitty-scrollback.nvim demo" src="https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/6dd229dd-0206-4d50-b627-f5f0f5fe8cd1">
  </picture>
  <div align="center"><sup>(click for video)<sup></div>
</a>

> [!NOTE]\
> 👀 Check out [Advanced Configuration](https://github.com/mikesmithgh/kitty-scrollback.nvim/wiki/Advanced-Configuration) for more demos! 🎥

<!-- panvimdoc-ignore-end -->

## 🚀 Migrating to v2.0.0
> [!IMPORTANT]\
> v2.0.0 has breaking changes and requires steps to properly migrate from v1.X.X.
> 
> You can ignore this section if you have not previously installed any verions of kitty-scrollback.nvim

<details>

  <summary>Migration Steps</summary>

  <img src="media/sad_kitty_thumbs_up.png" alt="sad-kitty-thumps-up" style="width: 20%" align="right" />

  - If you are using the <a href="https://github.com/folke/lazy.nvim">lazy.nvim</a> or <a href="https://github.com/wbthomason/packer.nvim">packer.nvim</a> package manager, then
    add the custom `User` event `KittyScrollbackLaunch` as a trigger for lazy loading. See [Installation](#-installation) for additional details.
    
    ```lua
    event = { 'User KittyScrollbackLaunch' }
    ```

  - Regenerate default Kitten mappings and add to `kitty.conf`

    ```sh
    nvim --headless +'KittyScrollbackGenerateKittens' +'set nonumber' +'set norelativenumber' +'%print' +'quit!' 2>&1
    ```
  - Remove previous kitty-scrollback.nvim Kitten mappings in `kitty.conf`

  - The default mapping keys changed from `ctrl+shift` to `kitty_mod`. The default values for `kitty_mod` in Kitty is `ctrl+shift`.
    - If you are using the default value for `kitty_mod` of `ctrl+shift`, then no change is needed.
    - If you are using a different value for `kitty_mod`, then you should correct any potential mapping conflicts that may occur
      now that `kitty-scrollback.nvim` is using `kitty_mod`.

  - Migrate any customized configurations to the new format
    - When you define your kitty-scrollback.nvim Kitten configuration, do not use `--config-file` `yourconfigfile.lua`. Instead,
      move the contents of `yourconfigfile.lua` to an entry in the configuration passed to the kitty-scrollback.nvim setup function.
      ```lua
      require('kitty-scrollback').setup({ 
        yourconfig = function() 
          ...
        end, 
      })
      ```
      Update your Kitten to use the name of the configuration defined in the setup function. In this example,
      `--config-file yourconfigfile.lua` changes to `--config yourconfig`
      <details>
        <summary>Real example</summary>
  
        The configuration to view the last command output now references a builtin configuration instead of a file. The 
        new configuation can be viewed by running `:KittyScrollbackGenerateKittens`.
        
        - Old configuration
          The Kitten defined in `kitty.conf` references the configuration file `get_text_last_cmd_output.lua`
        
        ```kitty
            # Browse output of the last shell command in nvim
            map kitty_mod+g kitty_scrollback_nvim --config-file get_text_last_cmd_output.lua
        ```
        
        ```lua
            -- get_text_last_cmd_output.lua
            local M = {}
            M.config = function()
              return {
                kitty_get_text = {
                  extent = 'last_visited_cmd_output',
                  ansi = true,
                },
              }
            end
            
            return M
        ```
        
        - New configuration
          The Kitten defined in `kitty.conf` references the builtin configuration name `ksb_builtin_last_cmd_output`
        
        ```kitty
            # Browse output of the last shell command in nvim
            map kitty_mod+g kitty_scrollback_nvim --config ksb_builtin_last_cmd_output
        ```
        
        ```lua
            require('kitty-scrollback').setup({ 
              ksb_builtin_last_cmd_output = function()
                return {
                  kitty_get_text = {
                    extent = 'last_visited_cmd_output',
                    ansi = true,
                  },
                }
              end
            })
        ```
      </details>



</details>



## ✨ Features
- 😻 Navigate Kitty's scrollback buffer with Neovim
- 🐱 Copy contents from Neovim to system clipboard
- 😺 Send contents from Neovim to Kitty shell
- 🙀 Execute shell command from Neovim to Kitty shell

## 🤯 Example use cases

<details> 

<summary>Copy scrollback text to the clipboard</summary>

  - Open Kitty's scrollback history (default mapping `<C-S-h>`)
  - Search backward for a pattern in Neovim `?{pattern}<CR>`
  - Enter Visual mode `v` and select desired text
  - Copy selection to clipboard (default mapping `<leader>y`)
  - `kitty-scrollback.nvim` automatically closes and returns to Kitty

</details>
<details> 

<summary>Modify and execute command</summary>

  - Open Kitty's scrollback history (default mapping `<C-S-h>`)
  - Copy desired selection to clipboard (e.g., `yy`)
    - Alternatively, you could just enter Insert mode (`i` or `a`) to open an empty floating window (similar to `<C-x><C-e>` in Bash)
  - `kitty-scrollback.nvim` opens a floating window in Neovim with the contents of the selection
  - Modify the content 
  - Execute the command (default mapping `<C-CR>`)
  - `kitty-scrollback.nvim` automatically closes and executes the command in Kitty

</details>
<details> 

<summary>Modify and paste content</summary>

  - Open Kitty's scrollback history (default mapping `<C-S-h>`)
  - Copy desired selection to clipboard (e.g., `yy`)
  - `kitty-scrollback.nvim` opens a floating window in Neovim with the contents of the selection
  - Modify the content
    - Note: you can close (default mapping `<ESC>`) and reopen (yank or enter Insert mode) the floating window multiple times
  - Paste the content (default mapping `<S-CR>` or `:w`)
  - `kitty-scrollback.nvim` automatically closes and paste the contents in Kitty for further editing

</details>

## 📚 Prerequisites

- Neovim [v0.10+](https://github.com/neovim/neovim/releases)
- Kitty [v0.29+](https://github.com/kovidgoyal/kitty/releases)

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
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    event = { 'User KittyScrollbackLaunch' },
    -- version = '*', -- latest stable version, may have breaking changes if major version changed
    -- version = '^2.0.0', -- pin major version, include fixes and features that do not have breaking changes
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
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    event = { 'User KittyScrollbackLaunch' },
    -- tag = '*', -- latest stable version, may have breaking changes if major version changed
    -- tag = 'v2.0.0', -- pin specific tag
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

## ✍️ Configuration

> [!NOTE]\
> The [Advanced Configuration](https://github.com/mikesmithgh/kitty-scrollback.nvim/wiki/Advanced-Configuration) section of the Wiki provides
> detailed demos of each configuration option.

### Kitty 
The following steps outline how to properly configure [kitty.conf](https://sw.kovidgoyal.net/kitty/conf/)

<details>
<summary>Enable <a href="https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.allow_remote_control">allow_remote_control</a></summary>

  - Valid values are `yes`, `socket`, `socket-only`
  - If `kitty-scrollback.nvim` is the only application controlling Kitty then `socket-only` is preferred to continue denying TTY requests.

</details>
<details>
<summary>Set <a href="https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.listen_on">listen_on</a> to a Unix socket</summary>

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
nvim +'KittyScrollbackCheckHealth'
```

  - Follow the instructions of any `ERROR` or `WARNINGS` reported during the healthcheck

</details>
<details>
<summary>Test <code>kitty-scrollback.nvim</code> is working as expected by pressing <code>kitty_mod+h</code> to open the scrollback buffer in Neovim</summary>

`kitty_mod` is a special modifier key alias for default shortcuts. You can change the value of this option to 
alter all default shortcuts that use `kitty_mod`. See Kitty documentation [#opt-kitty.kitty_mod](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.kitty_mod).

The default value of `kitty_mod` is `ctrl+shift`. In this example, `kitty_mod+h` represents `ctrl+shift+h`.

</details>

<details>
<summary>See example <code>kitty.conf</code> for reference</summary>

```sh
allow_remote_control yes
listen_on unix:/tmp/kitty
shell_integration enabled

# kitty-scrollback.nvim Kitten alias
action_alias kitty_scrollback_nvim kitten /Users/mike/gitrepos/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py

# Browse scrollback buffer in nvim
map kitty_mod+h kitty_scrollback_nvim
# Browse output of the last shell command in nvim
map kitty_mod+g kitty_scrollback_nvim --config ksb_builtin_last_cmd_output
# Show clicked command output in nvim
mouse_map kitty_mod+right press ungrabbed combine : mouse_select_command_output : kitty_scrollback_nvim --config ksb_builtin_last_visited_cmd_output
```
  
</details>

### Kitten arguments
Arguments that can be passed to the `kitty_scrollback_nvim` Kitten defined in [kitty.conf](https://sw.kovidgoyal.net/kitty/conf/).

| Argument         | Description                                                                                                                                                                                                                                                                                                                                                                 |
| :--------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `--config`       | The name of the `kitty-scrollback.nvim` plugin configuration. The configuration can be defined during plugin setup (i.e., `require('kitty-scrollback').setup({ ... })`).                                                                                                                                                                                                    |
| `--no-nvim-args` | Do not provide any arguments to the Neovim instance that displays the scrollback buffer. The default arguments passed to Neovim are `--clean --noplugin -n`. This flag removes those options.                                                                                                                                                                               |
| `--nvim-args`    | All arguments after this flag are passed to the Neovim instance that displays the scrollback buffer. This must be the last of the `kitty-scrollback.nvim` Kitten arguments that are configured. Otherwise, you may unintentionally send the wrong arguments to Neovim. The default arguments passed to Neovim are `--clean --noplugin -n`. This flag removes those options. |
| `--env`          | Environment variable that is passed to the Neovim instance that displays the scrollback buffer. Format is `--env var_name=var_value`. You may specify multiple config files that will merge all configuration options. Useful for setting `NVIM_APPNAME`                                                                                                                    |
| `--cwd`          | The current working directory of the Neovim instance that displays the scrollback buffer.                                                                                                                                                                                                                                                                                   |

### `kitty-scrollback.nvim` configuration file

| Options                                                          | Type                                                                             | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| :--------------------------------------------------------------- | :------------------------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| callbacks                                                        | `KsbCallbacks?`                                                                  | fire and forget callback functions                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| callbacks.after_setup                                            | `fun(kitty_data: KsbKittyData, opts: KsbOpts)?`                                  | callback executed after initializing kitty-scrollback.nvim                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| callbacks.after_launch                                           | `fun(kitty_data: KsbKittyData, opts: KsbOpts)?`                                  | callback executed after launch started to process the scrollback buffer                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| callbacks.after_ready                                            | `fun(kitty_data: KsbKittyData, opts: KsbOpts)?`                                  | callback executed after scrollback buffer is loaded and cursor is positioned                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| keymaps_enabled                                                  | `boolean?`                                                                       | if true, enabled all default keymaps                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| restore_options                                                  | `boolean?`                                                                       | if true, restore options that were modified while processing the scrollback buffer                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| highlight_overrides                                              | `KsbHighlights?`                                                                 | kitty-scrollback.nvim highlight overrides                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| highlight_overrides<br />.KittyScrollbackNvimNormal              | `table?`                                                                         | status window Normal highlight group                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| highlight_overrides<br />.KittyScrollbackNvimHeart               | `table?`                                                                         | status window heart icon highlight group                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| highlight_overrides<br />.KittyScrollbackNvimSpinner             | `table?`                                                                         | status window spinner icon highlight group                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| highlight_overrides<br />.KittyScrollbackNvimReady               | `table?`                                                                         | status window ready icon highlight group                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| highlight_overrides<br />.KittyScrollbackNvimKitty               | `table?`                                                                         | status window kitty icon highlight group                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| highlight_overrides<br />.KittyScrollbackNvimVim                 | `table?`                                                                         | status window vim icon highlight group                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| highlight_overrides<br />.KittyScrollbackNvimPasteWinNormal      | `table?`                                                                         | paste window Normal highlight group                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| highlight_overrides<br />.KittyScrollbackNvimPasteWinFloatBorder | `table?`                                                                         | paste window FloatBorder highlight group                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| highlight_overrides<br />.KittyScrollbackNvimPasteWinFloatTitle  | `table?`                                                                         | paste window FloatTitle highlight group                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| status_window                                                    | `KsbStatusWindowOpts?`                                                           | options for status window indicating that kitty-scrollback.nvim is ready                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| status_window.enabled                                            | `boolean`                                                                        | If true, show status window in upper right corner of the screen                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| status_window.style_simple                                       | `boolean`                                                                        | If true, use plaintext instead of nerd font icons                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| status_window.autoclose                                          | `boolean`                                                                        | If true, close the status window after kitty-scrollback.nvim is ready                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| status_window.show_timer                                         | `boolean`                                                                        | If true, show a timer in the status window while kitty-scrollback.nvim is loading                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| paste_window                                                     | `KsbPasteWindowOpts?`                                                            | options for paste window that sends commands to Kitty                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| paste_window.highlight_as_normal_win                             | `fun(): boolean?`                                                                | If function returns true, use Normal highlight group. If false, use NormalFloat                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| paste_window.filetype                                            | `string?`                                                                        | The filetype of the paste window                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| paste_window.hide_footer                                         | `boolean?`                                                                       | If true, hide mappings in the footer when the paste window is initially opened                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| paste_window.winblend                                            | `integer?`                                                                       | The winblend setting of the window, see :help winblend                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| paste_window.winopts_overrides                                   | `fun(paste_winopts: KsbWinOpts): table<string,any>?`                             | Paste float window overrides, see nvim_open_win() for configuration                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| paste_window.footer_winopts_overrides                            | `fun(footer_winopts: KsbWinOpts, paste_winopts: KsbWinOpts): table<string,any>?` | Paste footer window overrides, see nvim_open_win() for configuration                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| paste_window.yank_register                                       | `string?`                                                                        | register used during yanks to paste window, see `:h registers`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| paste_window.yank_register_enabled                               | `boolean?`                                                                       | If true, the `yank_register` copies content to the paste window. If false, disable yank to paste window                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| kitty_get_text                                                   | `KsbKittyGetText?`                                                               | options passed to get-text when reading scrollback buffer, see `kitty @ get-text --help`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| kitty_get_text.ansi                                              | `boolean`                                                                        | If true, the text will include the ANSI formatting escape codes for colors, bold, italic, etc.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| kitty_get_text.clear_selection                                   | `boolean`                                                                        | If true, clear the selection in the matched window, if any.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| kitty_get_text.extent                                            | `string`                                                                         | What text to get. The default of screen means all text currently on the screen. all means all the `screen+scrollback` and selection means the currently selected text. `first_cmd_output_on_screen` means the output of the first command that was run in the window on screen. `last_cmd_output` means the output of the last command that was run in the window. `last_visited_cmd_output` means the first command output below the last scrolled position via scroll_to_prompt. `last_non_empty_output` is the output from the last command run in the window that had some non empty output. The last four require `shell_integration` to be enabled. Choices: `screen`, `all`, `first_cmd_output_on_screen`, `last_cmd_output`, `last_non_empty_output`, `last_visited_cmd_output`, `selection` |
| checkhealth                                                      | `boolean?`                                                                       | if true execute :checkhealth kitty-scrollback and skip setup                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |

### Nerd Fonts 

By default, `kitty-scrollback.nvim` uses [Nerd Fonts](https://www.nerdfonts.com) in the status window. If you would like to 
use ASCII instead, set the option `status_window.style_simple` to `true`. 

- Status window with Nerd Fonts <code>opts.status_window.style_simple = false</code>
![style_simple_false](https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/662bf132-0b39-4028-b69f-eb85fbb69b60)

- Status window with ASCII text <code>opts.status_window.style_simple = true</code>
![style_simple_true](https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/c19a1869-e4e4-40fd-b619-fed771d0153f)


## 🫡 Commands and Lua API
The API is available via the `kitty-scrollback.api` module. e.g., `require('kitty-scrollback.api')`

| Command                                               | API                                                              | Description                                                             |
| :---------------------------------------------------- | :--------------------------------------------------------------- | :---------------------------------------------------------------------- |
| `:KittyScrollbackGenerateKittens[!] [generate_modes]` | `generate_kittens(boolean?, table<string\|'commands'\|'maps'>)?` | Generate Kitten commands used as reference for configuring `kitty.conf` |                 
| `:KittyScrollbackCheckHealth`                         | `checkhealth()`                                                  | Run `:checkhealth kitty-scrollback` in the context of Kitty             |

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

## 👏 Recommendations

The following plugins are nice additions to your Neovim and Kitty setup.

- [vim-kitty](https://github.com/fladson/vim-kitty) - Syntax highlighting for Kitty terminal config files
- [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) - Seamless navigation between Neovim and Kitty split panes 

## 🤝 Acknowledgements
- Kitty [custom kitten](https://sw.kovidgoyal.net/kitty/kittens/custom/) documentation
- [baleia.nvim](https://github.com/m00qek/baleia.nvim) - very nice plugin to colorize Neovim buffer containing ANSI escape sequences. I plan to add integration with this plugin 🤝
- [kovidgoyal/kitty#719 Feature Request: Ability to select text with the keyboard (vim-like)](https://github.com/kovidgoyal/kitty/issues/719) - ideas for passing the scrollback buffer to Neovim
  - [kovidgoyal/kitty#719 Comment 952039731 ](https://github.com/kovidgoyal/kitty/issues/719#issuecomment-952039731) - very detailed solution to opening the Kitty scrollback buffer in Neovim. In particular, I used the `set title` escape code to hide the `[Process exited]` message
- [kovidgoyal/kitty#2426 'Failed to open controlling terminal' error when trying to remote control from vim](https://github.com/kovidgoyal/kitty/issues/2426) - workaround for issuing kitty remote commands without a tty `listen_on unix:/tmp/mykitty`
- [kovidgoyal/kitty#6485 Vi mode for kitty](https://github.com/kovidgoyal/kitty/discussions/6485) - inspiration to leverage Neovim's terminal for the scrollback buffer
- [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) - referenced for color darkening, thank you folke!
- [lazy.nvim](https://github.com/folke/lazy.nvim) - referenced for window sizing, thank you folke!
- [fzf-lua](https://github.com/ibhagwan/fzf-lua) - quickstart `mini.sh` and inspiration/reference for displaying keymapping footer
- [cellular-automaton.nvim](https://github.com/Eandrju/cellular-automaton.nvim) - included in a fun example config
- StackExchange [CamelCase2snake_case()](https://codegolf.stackexchange.com/a/177958/119424) - for converting Neovim highlight names to `SCREAMING_SNAKE_CASE`
- [panvimdoc](https://github.com/kdheepak/panvimdoc) - generating vimdocs from README
- [lemmy-help](https://github.com/numToStr/lemmy-help) - generating vimdocs from Lua annotations
- [bob](https://github.com/MordechaiHadad/bob) - easy Neovim version management to check backward compatibility

## 🐶 Alternatives
- [kitty+page.lua](https://gist.github.com/galaxia4Eva/9e91c4f275554b4bd844b6feece16b3d) - Open Kitty's scrollback buffer in Neovim via `scrollback_pager`
- [Neovim scrollback pager by page-down](https://github.com/kovidgoyal/kitty/issues/719#issuecomment-952039731) - Linux only solution to open Kitty scrollback buffer in Neovim
- [kitty_grab](https://github.com/yurikhan/kitty_grab) - Keyboard-driven screen grabber for Kitty
- [kitty-kitten-search](https://github.com/trygveaa/kitty-kitten-search) - Kitten for the kitty terminal emulator providing live incremental search in the terminal history.
  
<!-- panvimdoc-ignore-start -->

#
<div align="center">
    <img src="https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/50852780-b3ce-4cb2-8e88-c1ea79e3e140" alt="scared cat" />
</div>

<!-- panvimdoc-ignore-end -->

