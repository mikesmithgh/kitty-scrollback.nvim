# [6.3.0](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v6.2.2...v6.3.0) (2025-04-01)


### Features

* remove jobstart workaround since Neovim v0.11 is released ([fea315d](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/fea315d016eec41e807d67dd8980fa119850694a)), closes [#306](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/306)

## [6.2.2](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v6.2.1...v6.2.2) (2025-01-20)


### Bug Fixes

* add workaround for jobstart issues on nvim nightly ([#305](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/305)) ([#307](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/307)) ([a74948a](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/a74948a9a28d403531a19039f25ceeeb17aefb15)), closes [#303](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/303)

## [6.2.1](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v6.2.0...v6.2.1) (2025-01-07)


### Bug Fixes

* improve jobstart error handling ([#299](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/299)) ([d72d742](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/d72d7423e2cbc1cc048035bb799c48731c708d0e)), closes [#282](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/282)

# [6.2.0](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v6.1.2...v6.2.0) (2024-12-31)


### Features

* use jobstart for Neovim v0.11+ instead of termopen ([#298](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/298)) ([2d24427](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/2d244272544cceea84f1249fbbb94297d907bbc9)), closes [#295](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/295)

## [6.1.2](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v6.1.1...v6.1.2) (2024-12-31)


### Bug Fixes

* update warning message during kitten generation if path contains whitespace ([#296](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/296)) ([a8d7b84](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/a8d7b849435d10021672064d9bba61ffe8d8bde6))

## [6.1.1](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v6.1.0...v6.1.1) (2024-12-30)


### Bug Fixes

* add warning during kitten generation if path contains whitespace ([#294](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/294)) ([7ee7677](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/7ee767738ec4cbc7de7731dbe7bfe3a0b22b3dc4))

# [6.1.0](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v6.0.0...v6.1.0) (2024-12-18)


### Features

* edit the current command line for bash, fish, or zsh ([#253](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/253)) ([d8f5433](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/d8f5433153c4ff130fbef6095bd287b680ef2b6f)), closes [#245](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/245)

See [Command-line editing setup](https://github.com/mikesmithgh/kitty-scrollback.nvim/tree/main?tab=readme-ov-file#command-line-editing) for setup instructions.

bash ([edit-and-execute-command](https://www.gnu.org/software/bash/manual/html_node/Miscellaneous-Commands.html#index-edit_002dand_002dexecute_002dcommand-_0028C_002dx-C_002de_0029)), fish ([edit_command_buffer](https://fishshell.com/docs/current/cmds/bind.html#additional-functions)), and zsh ([edit-command-line](https://zsh.sourceforge.io/Doc/Release/User-Contributions.html)) all have the ability to edit the current command in an external editor. The typical workflow is that you have a long command already entered in your shell that you need to modify and execute, this makes it easy to refine complex commands.

After [setting up command-line editing in kitty-scrollback.nvim](https://github.com/mikesmithgh/kitty-scrollback.nvim/tree/main?tab=readme-ov-file#command-line-editing), you can open your current command in kitty-scrollback.nvim's paste window. The benefit of this approach compared to using a standard Neovim instance is that you still have access to the scrollback history and kitty-scrollback.nvim's [features](https://github.com/mikesmithgh/kitty-scrollback.nvim/tree/main?tab=readme-ov-file#-features) to help you quickly modify or execute the command.


# [6.0.0](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v5.0.2...v6.0.0) (2024-11-15)


* feat!: exit kitty-scrollback.nvim with q key instead of esc ([#272](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/272)) ([1ae369b](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/1ae369be4186857bddeeb49561d3dccafc13b801))


### BREAKING CHANGES

* Change the default keymap for quitting kitty-scrollback.nvim from `<Esc>` to `q`.

If you prefer the previous behavior of using `<Esc>` to exit kitty-scrollback.nvim, this can be reconfigured by
adding the following to your kitty-scrollback.nvim setup.

```lua
vim.keymap.set({ 'n' }, '<Esc>', '<Plug>(KsbCloseOrQuitAll)', {})
```

For example, if you are using lazy.nvim, it would look something like this

```lua
return {
  {
    'mikesmithgh/kitty-scrollback.nvim',
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    event = { 'User KittyScrollbackLaunch' },
    config = function()
      vim.keymap.set({ 'n' }, '<Esc>', '<Plug>(KsbCloseOrQuitAll)', {}) -- quit kitty-scrollback.nvim with Esc key
      -- vim.keymap.set({ 'n' }, 'q', '<Plug>(KsbCloseOrQuitAll)', {}) -- uncomment if you would like to also quit with the q key
      require('kitty-scrollback').setup()
    end,
  },
}
```

## [5.0.2](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v5.0.1...v5.0.2) (2024-11-14)


### Bug Fixes

* remove kitty debug config from checkhealth ([dd4bd78](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/dd4bd78abbae4256a29c7cdecbe778957bb932b5))

## [5.0.1](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v5.0.0...v5.0.1) (2024-08-20)


### Bug Fixes

* defer setting 'columns' to hardwrap at 300 columns ([#267](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/267)) ([2f267c3](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/2f267c315bea50cd67ea3fd23f78e586fb2915c5))

# [5.0.0](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v4.3.6...v5.0.0) (2024-06-07)


* feat!: use Kitty's builtin bracketed paste ([#257](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/257)) ([89ba2b1](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/89ba2b1cf7a865761b3f01ba2d2f53e5c2e493a6))


### BREAKING CHANGES

* remove support for Kitty versions < 0.32.2

## [4.3.6](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v4.3.5...v4.3.6) (2024-06-01)


### Bug Fixes

* **pastewin:** default the paste window's filetype to kitty's shell ([#256](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/256)) ([9294cc5](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/9294cc5b2f3a957532eb5120161234eaafa4753a)), closes [#254](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/254)

## [4.3.5](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v4.3.4...v4.3.5) (2024-05-23)


### Bug Fixes

* **fish:** use empty bracketed paste instead of NUL char ([#251](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/251)) ([af16e06](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/af16e06b3e26d73aeafe89c684b802671b2dd577)), closes [#250](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/250)

## [4.3.4](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v4.3.3...v4.3.4) (2024-05-16)


### Bug Fixes

* disable existing swap file is found message ([e947826](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/e94782605fdcb054309f5ab187d0c645bb382ef4))
* disable swapfile for kitty-scrollback buffers ([772acac](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/772acac09e84a116dd06ebe9696c1244f3fc1dbc))

## [4.3.3](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v4.3.2...v4.3.3) (2024-04-18)


### Bug Fixes

* try child foreground cwd instead of root ([#234](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/234)) ([70f148a](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/70f148a25cd11d159e0fe168152c20c264f6f30c)), closes [#233](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/233)

## [4.3.2](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v4.3.1...v4.3.2) (2024-04-18)


### Bug Fixes

* adjust pastewin position when winbar is set ([#232](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/232)) ([e291b9e](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/e291b9e611a9c9ce25adad6bb1c4a9b850963de2)), closes [#119](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/119)

## [4.3.1](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v4.3.0...v4.3.1) (2024-04-05)


### Bug Fixes

* use root for cwd instead of current ([#222](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/222)) ([db38665](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/db38665bb573e7f62e0a435612f5f8abd0a9855c))

# [4.3.0](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v4.2.3...v4.3.0) (2024-04-03)


### Features

* update paste_window options to be either a table of function ([#220](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/220)) ([f1df70c](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/f1df70cddea4a7259d56e84de65fe8addccb9ee3))

## [4.2.3](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v4.2.2...v4.2.3) (2024-04-03)


### Bug Fixes

* close command-line window before quitting ([12d82c5](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/12d82c5029eb204c825abd97f966bf00000dbd03)), closes [#213](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/213)

## [4.2.2](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v4.2.1...v4.2.2) (2024-03-10)


### Bug Fixes

* no longer overwriting config name in error ([#206](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/206)) ([6e96a31](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/6e96a310c5b4bbe40e6c530b7623ee24202e1f8c))

## [4.2.1](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v4.2.0...v4.2.1) (2024-02-20)


### Bug Fixes

* adjust tmux position based on status option and add .ksb_errorbuf ([a55226d](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/a55226d5027fd34cdca92bcd3832d50c0929c1bd))

# [4.2.0](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v4.1.0...v4.2.0) (2024-02-20)


### Bug Fixes

* add buffer name suffix .ksb_footerbuf to footer ([4f234de](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/4f234de744cb0e84aa34e1e58654a8348ea96304))
* create separate set_local_defaults function ([2c6812a](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/2c6812abff7bb440ca4ae08310c6907324786ed4))
* include buffer local mappings when resolving footer keymaps ([af2aa25](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/af2aa252866d4c29a60b6a9c76ef010ee81f27f5))


### Features

* add after_paste_window_ready callback ([646a41e](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/646a41ea3d0f4168cdb710833a64237d13fec0ef)), closes [#197](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/197)

# [4.1.0](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v4.0.3...v4.1.0) (2024-02-19)


### Features

* add experimental tmux support ([#191](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/191)) ([8b1f70b](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/8b1f70b951ef439eb8d3810505258814c55d6f57))

## [4.0.3](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v4.0.2...v4.0.3) (2024-02-10)


### Bug Fixes

* print configs for KittyScrollbackGenerateKittens if headless mode ([#190](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/190)) ([fca2b05](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/fca2b05d153bc75f75e46745e6d9fef785a08c30)), closes [#189](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/189)

## [4.0.2](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v4.0.1...v4.0.2) (2024-02-01)


### Bug Fixes

* fallback to kitty colors when Normal hl is undefined ([#185](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/185)) ([0d2e76f](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/0d2e76ff30f0dfd7c5a253d2b9c01d33858bd7b4)), closes [#181](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/181)

## [4.0.1](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v4.0.0...v4.0.1) (2024-01-31)


### Bug Fixes

* wrong config merge operation ([#182](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/182)) ([2a42b18](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/2a42b18178ed3e2c31d275be25feaa934fcc1518))

# [4.0.0](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v3.2.1...v4.0.0) (2024-01-29)


* feat!: redesign kitty-scrollback.nvim configuration (#118) ([97fea1b](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/97fea1b6c9188a1665332fbcf3df2261f5bba8d7)), closes [#118](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/118) [#69](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/69)


### BREAKING CHANGES

* kitty-scrollback.nvim loads your Neovim configuration by default. Previous versions of kitty-scrollback.nvim, did not load any configurations or plugins by default.

  - Previously, kitty-scrollback.nvim did not open Neovim with your Neovim configuration by default. This has changed to loading your Neovim 
  configuration by default, with the ability to opt out. If you prefer to continue not loading your Neovim configuration, then follow the
  steps at [No Configuration](#no-configuration).
  - If you previously used the flag `--no-nvim-args`, then delete it from your configuration because it no longer has any effect. The flag 
  `--nvim-args` remains unchanged and can still be used.
  - `ksb_example` configurations have been removed and can no longer be referenced by name. If you were previously referencing an example configuration
  by name, then you can manually copy it from [./tests/example.lua](./tests/example.lua) into your kitty-scrollback.nvim configuration. See 
  [Plugin Configuration](#plugin-configuration) for detailed instructions on configuration kitty-scrollback.nvim. 
  - The command `KittyScrollbackGenerateKittens` and api `generate_kittens` no longer have an option to generate `ksb_example` configurations.
    - The command `KittyScrollbackGenerateKittens` no longer accepts the bang `!` modifier
    - The api `generate_kittens` signature removed the `all` parameter
  - The reserved `global` configuration name has been removed and global options are now configured by the first element of the options table without a key.
  See [Global Configuration](#global-configuration) for more details.
  - The undocumented reserved `default` configuration name has been removed. kitty-scrollback.nvim defaults to `ksb_builtin_get_text_all` if no configuration is provided.

## [3.2.1](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v3.2.0...v3.2.1) (2024-01-23)


### Bug Fixes

* create empty buffer when first buffer has content ([#169](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/169)) ([ba68807](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/ba688073e3ee4336f9624ad06dfac98d2453f40a))

# [3.2.0](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v3.1.6...v3.2.0) (2024-01-20)


### Features

* add the env variable KITTY_SCROLLBACK_NVIM ([#166](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/166)) ([c598ff9](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/c598ff932fe3c3816de6b9194b1f260ff0fd933e))

## [3.1.6](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v3.1.5...v3.1.6) (2024-01-10)


### Bug Fixes

* use nul instead of enquiry ([#150](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/150)) ([141f678](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/141f67804a4d4fe4796d8b65807e95ccca1ff1a8)), closes [#147](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/147)

## [3.1.5](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v3.1.4...v3.1.5) (2024-01-10)


### Bug Fixes

* prefer xsel over xclip ([#157](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/157)) ([088b3fc](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/088b3fcf04e4882dbd2f08822eb33dae2c33b1a2))

## [3.1.4](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v3.1.3...v3.1.4) (2024-01-09)


### Bug Fixes

* prevent caught deadly signal message on exit ([#155](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/155)) ([00a0b5f](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/00a0b5f97030687a4fb6b454499f5ce55eb52144)), closes [#135](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/135)

## [3.1.3](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v3.1.2...v3.1.3) (2024-01-03)


### Bug Fixes

* default cwd to current directory ([#144](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/144)) ([d33c1fb](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/d33c1fbc75433800de813ceab79ccdc43acf848e))

## [3.1.2](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v3.1.1...v3.1.2) (2024-01-03)


### Bug Fixes

* temporarily block user input on start ([#140](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/140)) ([ad0d6e8](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/ad0d6e85c46dd9c33d232ec0eaf9f06e1abd93b3))

## [3.1.1](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v3.1.0...v3.1.1) (2024-01-02)


### Bug Fixes

* add fallback for kitty during checkhealth ([#139](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/139)) ([a29f917](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/a29f9178fe584f95a8ac03b7b6cda7c44ce60110)), closes [#138](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/138)

# [3.1.0](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v3.0.0...v3.1.0) (2024-01-02)


### Features

* add paste and execute commands in visual mode ([#134](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/134)) ([ad00bcd](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/ad00bcd6b4e9a424a31dff6a69eed871214e06ab))

# [3.0.0](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v2.4.7...v3.0.0) (2023-12-29)


### Bug Fixes

* correct hl_as_normal_win override ([73f4e8b](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/73f4e8b85020eaf96a84dc4b9a943cdb3ae7d361))


* feat!: set default icon to new nvim icon (#80) ([51367da](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/51367da0b6f13594aaf8c9c0b33f66ba018df600)), closes [#80](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/80) [#70](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/70)
* feat!: add support for new neovim default colorscheme (#103) ([e4e4429](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/e4e4429cea29507a9188c86066f6c0de8a2e8578)), closes [#103](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/103)


### BREAKING CHANGES

* The Neovim icon is now the default icon in the status window. Update your Nerd Font to the latest version or at least version [v3.1.0](https://github.com/ryanoasis/nerd-fonts/releases/tag/v3.1.0).
* Existing highlight groups were renamed. If you were overriding any kitty-scrollback.nvim highlight groups, please update the names referencing the table below.

    | Previous highlight name    | New highlight name                      |
    | -------------------------- | --------------------------------------- |
    | KittyScrollbackNvimNormal  | KittyScrollbackNvimStatusWinNormal      |
    | KittyScrollbackNvimHeart   | KittyScrollbackNvimStatusWinHeartIcon   |
    | KittyScrollbackNvimSpinner | KittyScrollbackNvimStatusWinSpinnerIcon |
    | KittyScrollbackNvimReady   | KittyScrollbackNvimStatusWinReadyIcon   |
    | KittyScrollbackNvimKitty   | KittyScrollbackNvimStatusWinKittyIcon   |
    | KittyScrollbackNvimVim     | KittyScrollbackNvimStatusWinNvimIcon    |

## [2.4.7](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v2.4.6...v2.4.7) (2023-12-15)


### Bug Fixes

* adjust pastewin position depending on showtabline values ([#112](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/112)) ([9d66c4c](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/9d66c4cc1c6def697f38be954ec70442a8deaf22))

## [2.4.6](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v2.4.5...v2.4.6) (2023-12-14)


### Bug Fixes

* unset KITTY_KITTEN_RUN_MODULE ([#113](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/113)) ([9984d10](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/9984d10873fa00088259265362e1c937c804e837))

## [2.4.5](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v2.4.4...v2.4.5) (2023-12-13)


### Bug Fixes

* only set vim colorscheme for default colorscheme ([#111](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/111)) ([8529d4d](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/8529d4d5ca6eab1d20b1dfe8e80158c1a86cf863))

## [2.4.4](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v2.4.3...v2.4.4) (2023-12-12)


### Bug Fixes

* explicitly set colorscheme to vim ([#106](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/106)) ([6e2bd60](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/6e2bd60d14fdfb9839a7ac6e352c880f463cc9ba)), closes [#93](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/93)

## [2.4.3](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v2.4.2...v2.4.3) (2023-12-11)


### Bug Fixes

* add kitty fallback for checkhealth ([#98](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/98)) ([6c93db4](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/6c93db4f4a82001cd1c6f3ff014481426dfa8648))

## [2.4.2](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v2.4.1...v2.4.2) (2023-12-07)


### Bug Fixes

* read kitty executable from path ([#94](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/94)) ([acdc317](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/acdc3170f20252ba2a4c4bb114b698d85995ae70)), closes [#95](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/95)

## [2.4.1](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v2.4.0...v2.4.1) (2023-12-01)


### Bug Fixes

* update orig_columns during WinResized event ([#85](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/85)) ([88e2063](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/88e20631e55fc37a7926b597636897e058eaa783)), closes [#75](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/75)

# [2.4.0](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v2.3.1...v2.4.0) (2023-12-01)


### Features

* clear selection in kitty after paste ([#84](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/84)) ([7cc5814](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/7cc581409cbd6bd601e4a66f3b3a21af81c22bf5)), closes [#76](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/76)

## [2.3.1](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v2.3.0...v2.3.1) (2023-11-27)


### Bug Fixes

* remove shell integration validation ([#71](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/71)) ([357c1f5](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/357c1f52f3e779674e29a6dd5236be4fe45c44bf)), closes [#66](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/66)

# [2.3.0](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v2.2.0...v2.3.0) (2023-11-26)


### Features

* add neovim nerd font icon ([#67](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/67)) ([70bb2ae](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/70bb2aea9cb77a46874740583e7881ddc98eb4e5)), closes [#38](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/38)

# [2.2.0](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v2.1.2...v2.2.0) (2023-11-24)


### Features

* add support for neovim v0.9 ([#60](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/60)) ([30fffc0](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/30fffc0060c8d8c0a84b0465b3cc49feace29a65))

## [2.1.2](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v2.1.1...v2.1.2) (2023-11-22)


### Bug Fixes

* set shell to sh before executing termopen ([#59](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/59)) ([cabb1f2](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/cabb1f2c5fe32bd39bc0b2f29d64e14d45da4ad9)), closes [#56](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/56)

## [2.1.1](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v2.1.0...v2.1.1) (2023-11-10)


### Bug Fixes

* set nvim terminal colors to match kitty ([#51](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/51)) ([0971ab0](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/0971ab05879eb6193128b4361d55b2f6591c0651)), closes [#49](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/49)

# [2.1.0](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v2.0.0...v2.1.0) (2023-11-06)


### Features

* add ability to customize Visual highlight ([#45](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/45)) ([b2ca294](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/b2ca294fb3b2655e8f6e55daf128cedc0413680b))

# [2.0.0](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v1.1.10...v2.0.0) (2023-11-01)


* feat!: use kitty_mod for keymaps ([8e652bf](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/8e652bf49f2e048450e5bb9681148f6caf5cf2ae)), closes [#30](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/30)
* feat!: replace config-file with config name ([e16e96a](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/e16e96a7d6fa67057fc5ab1580bad30a2cf01afa)), closes [#16](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/16) [#12](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/12) [#2](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/2)


### BREAKING CHANGES

* The default mapping keys changed from `ctrl+shift` to `kitty_mod`.

- If you are using the default value for `kitty_mod` of `ctrl+shift`, then no change is needed.
- If you are using a different value for `kitty_mod`, then you should correct any potential mapping conflicts that may occur
  now that `kitty-scrollback.nvim` is using `kitty_mod`.
* The `--config-file` option has been removed.
Custom configurations are now supplied in the setup() function instead
of separate config file. The config name corresponds to the key of
the table provided to `setup()`.

## [1.1.10](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v1.1.9...v1.1.10) (2023-10-24)


### Bug Fixes

* fallback to opts if no shell integration env ([#37](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/37)) ([858f1e3](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/858f1e3e416c0ee668fde45d7edd3dab0a5ce995))

## [1.1.9](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v1.1.8...v1.1.9) (2023-10-15)


### Bug Fixes

* set initial cursor position on pastewin close ([#34](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/34)) ([bb98562](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/bb985625db4167f988f1c90d9ddabc326d76bede))

## [1.1.8](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v1.1.7...v1.1.8) (2023-10-15)


### Bug Fixes

* use set title to remove process exited msg ([#33](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/33)) ([684dd83](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/684dd833ef6a0ee0c2992b510cbe7119d44ae419))

## [1.1.7](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v1.1.6...v1.1.7) (2023-10-01)


### Bug Fixes

* error handling improvements ([#29](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/29)) ([21e83f4](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/21e83f4ae15a93cc0b8f5d29fc52ad4b6098ed9b))

## [1.1.6](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v1.1.5...v1.1.6) (2023-10-01)


### Bug Fixes

* reattempt kitty window close and get-colors ([#28](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/28)) ([abc677a](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/abc677aa585a1af86207569a0d5dee03a8f33bd0)), closes [#20](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/20)

## [1.1.5](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v1.1.4...v1.1.5) (2023-09-29)


### Bug Fixes

* disable opening scrollback if already open ([#27](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/27)) ([b78242d](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/b78242d7df0f597cbe64379787bdf16346b80c16))

## [1.1.4](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v1.1.3...v1.1.4) (2023-09-28)


### Bug Fixes

* **healthcheck:** add fallback logic for < 0.10 closes [#23](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/23) ([#26](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/26)) ([f1e8c40](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/f1e8c4048ddd5a3017424b89ace08cf59ac53848))

## [1.1.3](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v1.1.2...v1.1.3) (2023-09-28)


### Bug Fixes

* improve extent validation logic ([#25](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/25)) ([9772715](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/97727150343c41578b829e225fcc831845e8ba44))

## [1.1.2](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v1.1.1...v1.1.2) (2023-09-27)


### Bug Fixes

* **healthcheck:** change sed check and add debug details ([#22](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/22)) ([dfd7f0a](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/dfd7f0a4ca0a9dbbe3cb96526ffc420f13c4dae8))

## [1.1.1](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v1.1.0...v1.1.1) (2023-09-25)


### Bug Fixes

* **checkhealth:** reorganize and fix advice() ([#21](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/21)) ([c4b7ca7](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/c4b7ca7430eefe6cd8643cc7e60fdce246dd4086))

# [1.1.0](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v1.0.3...v1.1.0) (2023-09-23)


### Features

* make paste window yank register configurable closes [#15](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/15) ([#17](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/17)) ([31f75ea](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/31f75eafd772f8213233f5ed8467407b6ce71bff))

## [1.0.3](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v1.0.2...v1.0.3) (2023-09-22)


### Bug Fixes

* allow file writing if not the paste buffer ([#14](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/14)) ([87ff296](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/87ff2967586715436d00026f3b722881b3ee46d9))

## [1.0.2](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v1.0.1...v1.0.2) (2023-09-19)


### Bug Fixes

* explicitly flush stdout for large scrollback closes [#7](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/7) ([#11](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/11)) ([3afc5a3](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/3afc5a34cd420b04fd28f849ad5cddd17027a7a9))

## [1.0.1](https://github.com/mikesmithgh/kitty-scrollback.nvim/compare/v1.0.0...v1.0.1) (2023-09-18)


### Bug Fixes

* use single quotes in sed command closes [#9](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/9) ([#10](https://github.com/mikesmithgh/kitty-scrollback.nvim/issues/10)) ([5d84b91](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/5d84b91361c5328089f48b4cf227dcc55f08dc9c))

# 1.0.0 (2023-09-18)


### Features

* Initial stable release ([c376fbc](https://github.com/mikesmithgh/kitty-scrollback.nvim/commit/c376fbc3a8d39f438be6f7b2670b9334755a1941))
