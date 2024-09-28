local h = require('tests.kitty-scrollback.helpers')

h.setup_backport()

local ksb_dir = h.ksb_dir()
h.debug({
  ksb_dir = ksb_dir,
  kitty_conf = ksb_dir .. 'tests/kitty.conf',
})

local tmpsock
local kitty_instance

local shell = h.debug(h.is_github_action and '/bin/bash' or (vim.o.shell .. ' --noprofile --norc'))

describe('kitty-scrollback.nvim', function()
  h.init_nvim()

  before_each(function()
    vim.fn.mkdir(ksb_dir .. 'tests/workdir', 'p')
    tmpsock = h.tempsocket(ksb_dir .. 'tmp/')
    local kitty_cmd = h.debug({
      h.kitty,
      '--listen-on=unix:' .. tmpsock,
      '--config',
      ksb_dir .. 'tests/kitty.conf',
      '--override',
      'shell=' .. shell,
      '--session',
      '-', -- read session from stdin
    })
    kitty_instance = h.wait_for_kitty_remote_connection(kitty_cmd, tmpsock, {
      stdin = 'cd ' .. ksb_dir .. 'tests/workdir',
    })
    h.feed_kitty({
      h.with_pause_seconds_before(h.send_without_newline(h.clear())),
    })
  end)

  after_each(function()
    kitty_instance:kill(2)
    kitty_instance = nil
    vim.fn.delete(vim.fn.fnamemodify(tmpsock, ':p:h'), 'rf')
  end)

  it('should position paste window at prompt when showtabline=0', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.enter(),
        h.open_kitty_scrollback_nvim(),
        h.with_pause_seconds_before([[:set tabline=tabline\ header]]),
        [[:set showtabline=0]],
        h.send_without_newline([[a]]),
      }),
      {
        stdout = h.with_status_win([[$
$🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
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
]]),
        cursor_y = 3,
        cursor_x = 3,
      }
    )
  end)

  it('should position paste window at prompt when showtabline=1 and one tab', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.enter(),
        h.open_kitty_scrollback_nvim(),
        h.with_pause_seconds_before([[:set tabline=tabline\ header]]),
        [[:set showtabline=1]],
        h.send_without_newline([[a]]),
      }),
      {
        stdout = h.with_status_win([[$
$🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
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

]]),
        cursor_y = 3,
        cursor_x = 3,
      }
    )
  end)

  it('should position paste window at prompt when showtabline=1 and two tabs', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.send_without_newline(h.enter()),
        h.open_kitty_scrollback_nvim(),
        h.with_pause_seconds_before([[:set tabline=tabline\ header]]),
        [[:set showtabline=1]],
        [[:tab new]],
        h.send_without_newline([[gta]]),
      }),
      {
        stdout = h.with_status_win([[
tabline header
$🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
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
]]),
        cursor_y = 3,
        cursor_x = 3,
      }
    )
  end)

  it('should position paste window at prompt when showtabline=2', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.send_without_newline(h.enter()),
        h.open_kitty_scrollback_nvim(),
        h.with_pause_seconds_before([[:set tabline=tabline\ header]]),
        [[:set showtabline=2]],
        h.send_without_newline([[a]]),
      }),
      {
        stdout = h.with_status_win([[
tabline header
$🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
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
]]),
        cursor_y = 3,
        cursor_x = 3,
      }
    )
  end)

  it('should position paste window at prompt when winbar is set', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.send_without_newline(h.enter()),
        h.open_kitty_scrollback_nvim(),
        h.with_pause_seconds_before([[:set winbar=winbar\ header]]),
        h.send_without_newline([[a]]),
      }),
      {
        stdout = h.with_status_win([[
winbar header
$🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
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
]]),
        cursor_y = 3,
        cursor_x = 3,
      }
    )
  end)

  it('should position paste window at prompt when showtabline=2 and winbar is set', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.send_without_newline(h.enter()),
        h.open_kitty_scrollback_nvim(),
        h.with_pause_seconds_before([[:set tabline=tabline\ header]]),
        [[:set showtabline=2]],
        [[:set winbar=winbar\ header]],
        h.send_without_newline([[a]]),
      }),
      {
        stdout = h.with_status_win([[
tabline header
winbar header
$🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
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
]]),
        cursor_y = 4,
        cursor_x = 3,
      }
    )
  end)
end)
