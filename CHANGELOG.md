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
