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

  it('should position the cursor on first line when scrollback buffer has one line', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.open_kitty_scrollback_nvim(),
      }),
      {
        stdout = h.with_status_win([[
$
]]),
        cursor_y = 1,
        cursor_x = 3,
      },
      'kitty-scrollback.nvim did not position cursor on first line'
    )
  end)

  it('should position the cursor on second line when scrollback buffer has two lines', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.send_without_newline(h.enter()),
        h.open_kitty_scrollback_nvim(),
      }),
      {
        stdout = h.with_status_win([[
$
$
]]),
        cursor_y = 2,
        cursor_x = 3,
      },
      'kitty-scrollback.nvim did not position cursor on second line'
    )
  end)

  it('should show position the cursor on second to last line', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.send_without_newline(h.send_as_string([[
# 1
# 2
# 3
# 4
# 5
# 6
# 7
# 8
# 9
# 10
# 11
# 12
# 13
# 14
# 15
# 16
# 17
# 18
# 19
# 20
# 21
# 22
# 23
# 24
# 25
# 26
# 27
# 28
# 29]])),
        h.open_kitty_scrollback_nvim(),
      }),
      {
        stdout = h.with_status_win([[
$ # 1
$ # 2
$ # 3
$ # 4
$ # 5
$ # 6
$ # 7
$ # 8
$ # 9
$ # 10
$ # 11
$ # 12
$ # 13
$ # 14
$ # 15
$ # 16
$ # 17
$ # 18
$ # 19
$ # 20
$ # 21
$ # 22
$ # 23
$ # 24
$ # 25
$ # 26
$ # 27
$ # 28
$ # 29
]]),
        cursor_y = 29,
        cursor_x = 7,
      },
      'kitty-scrollback.nvim did not position cursor on second to last line'
    )
  end)

  it('should position the cursor on the last line', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.send_without_newline(h.send_as_string([[
# 1
# 2
# 3
# 4
# 5
# 6
# 7
# 8
# 9
# 10
# 11
# 12
# 13
# 14
# 15
# 16
# 17
# 18
# 19
# 20
# 21
# 22
# 23
# 24
# 25
# 26
# 27
# 28
# 29
# 30]])),
        h.open_kitty_scrollback_nvim(),
      }),
      {
        stdout = h.with_status_win([[
$ # 1
$ # 2
$ # 3
$ # 4
$ # 5
$ # 6
$ # 7
$ # 8
$ # 9
$ # 10
$ # 11
$ # 12
$ # 13
$ # 14
$ # 15
$ # 16
$ # 17
$ # 18
$ # 19
$ # 20
$ # 21
$ # 22
$ # 23
$ # 24
$ # 25
$ # 26
$ # 27
$ # 28
$ # 29
$ # 30
]]),
        cursor_y = 30,
        cursor_x = 7,
      },
      'kitty-scrollback.nvim did not position cursor on last line'
    )
  end)

  it('should show position the cursor on the last line when screen is full', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.send_without_newline(h.send_as_string([[
# 1 
# 2 
# 3 
# 4 
# 5 
# 6 
# 7 
# 8 
# 9 
# 10
# 11
# 12
# 13
# 14
# 15
# 16
# 17
# 18
# 19
# 20
# 21
# 22
# 23
# 24
# 25
# 26
# 27
# 28
# 29
# 30
# 31]])),
        h.open_kitty_scrollback_nvim(),
      }),
      {
        stdout = h.with_status_win([[
$ # 2
$ # 3
$ # 4
$ # 5
$ # 6
$ # 7
$ # 8
$ # 9
$ # 10
$ # 11
$ # 12
$ # 13
$ # 14
$ # 15
$ # 16
$ # 17
$ # 18
$ # 19
$ # 20
$ # 21
$ # 22
$ # 23
$ # 24
$ # 25
$ # 26
$ # 27
$ # 28
$ # 29
$ # 30
$ # 31
]]),
        cursor_y = 30,
        cursor_x = 7,
      },
      'kitty-scrollback.nvim did not position cursor on last line'
    )
  end)
end)
