local assert = require('luassert.assert')
local h = require('tests.helpers')
local describe = describe ---@diagnostic disable-line: undefined-global
local it = it ---@diagnostic disable-line: undefined-global
local after_each = after_each ---@diagnostic disable-line: undefined-global
local before_each = before_each ---@diagnostic disable-line: undefined-global

h.setup_backport()

local ksb_dir = vim.fn.fnamemodify(
  vim.fn.fnamemodify(vim.api.nvim_get_runtime_file('lua/kitty-scrollback', false)[1], ':h:h'),
  ':p'
)
h.debug({
  ksb_dir = ksb_dir,
  kitty_conf = ksb_dir .. 'tests/kitty.conf',
})

local tmpsock = h.tempsocket(ksb_dir .. 'tmp/')
local kitty_instance

local shell = h.debug(h.is_github_action and '/bin/bash' or (vim.o.shell .. ' --noprofile --norc'))

local kitty_cmd = h.debug({
  'kitty',
  '--listen-on=unix:' .. tmpsock,
  '--config',
  ksb_dir .. 'tests/kitty.conf',
  '--override',
  'shell=' .. shell,
  '--session',
  '-', -- read session from stdin
})

describe('kitty-scrollback.nvim', function()
  before_each(function()
    vim.fn.mkdir(ksb_dir .. 'tests/workdir', 'p')
    kitty_instance = vim.system(kitty_cmd, {
      stdin = 'cd ' .. ksb_dir .. 'tests/workdir',
    })
    local ready = false
    vim.fn.wait(5000, function()
      ready = (h.debug(h.kitty_remote_ls():wait()).code == 0)
      return ready
    end, 500)

    assert.is_true(ready, 'kitty is not ready for remote connections, exiting')

    h.feed_kitty({
      h.with_pause_before(h.send_without_newline(h.clear())),
    })
  end)

  after_each(function()
    kitty_instance:kill(2)
    kitty_instance = nil
  end)

  it('should position paste window at prompt when showtabline=0', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.open_kitty_scrollback_nvim(),
        [[:set showtabline=0]],
        h.send_without_newline([[a]]),
      }),
      {
        stdout = [[
$🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
 ▏                                                                                                        ▕
 ▏    \y Yank          <C-CR> Execute          <S-CR> Paste          :w Paste          g? Toggle Mappings ▕
 🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
        cursor_y = 2,
        cursor_x = 3,
      },
      'kitty-scrollback.nvim content did not match the terminal screen'
    )
  end)

  it('should position paste window at prompt when showtabline=1 and one tab', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.open_kitty_scrollback_nvim(),
        [[:set showtabline=1]],
        h.send_without_newline([[a]]),
      }),
      {
        stdout = [[
$🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
 ▏                                                                                                        ▕
 ▏    \y Yank          <C-CR> Execute          <S-CR> Paste          :w Paste          g? Toggle Mappings ▕
 🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
        cursor_y = 2,
        cursor_x = 3,
      },
      'kitty-scrollback.nvim content did not match the terminal screen'
    )
  end)

  it('should position paste window at prompt when showtabline=1 and two tabs', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.open_kitty_scrollback_nvim(),
        [[:set showtabline=1]],
        [[:tab new]],
        h.send_without_newline([[gta]]),
      }),
      {
        stdout = [[
 🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
$▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
 ▏                                                                                                        ▕
 ▏    \y Yank          <C-CR> Execute          <S-CR> Paste          :w Paste          g? Toggle Mappings ▕
 🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
        cursor_y = 2,
        cursor_x = 3,
      },
      'kitty-scrollback.nvim content did not match the terminal screen'
    )
  end)

  it('should position paste window at prompt when showtabline=2', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.open_kitty_scrollback_nvim(),
        [[:set showtabline=2]],
        h.send_without_newline([[a]]),
      }),
      {
        stdout = [[
 🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
$▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
 ▏                                                                                                        ▕
 ▏    \y Yank          <C-CR> Execute          <S-CR> Paste          :w Paste          g? Toggle Mappings ▕
 🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
        cursor_y = 2,
        cursor_x = 3,
      },
      'kitty-scrollback.nvim content did not match the terminal screen'
    )
  end)
end)
