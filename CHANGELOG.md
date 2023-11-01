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
of separate config file. The config name correspondes to the key of
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
