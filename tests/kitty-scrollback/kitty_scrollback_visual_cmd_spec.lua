local h = require('tests.kitty-scrollback.helpers')

h.setup_backport()

local ksb_dir = vim.fn.fnamemodify(
  vim.fn.fnamemodify(vim.api.nvim_get_runtime_file('lua/kitty-scrollback', false)[1], ':h:h'),
  ':p'
)
h.debug({
  ksb_dir = ksb_dir,
  kitty_conf = ksb_dir .. 'tests/kitty.conf',
})

local tmpsock
local kitty_instance

local shell = h.debug(h.is_github_action and '/bin/bash' or (vim.o.shell .. ' --noprofile --norc'))

describe('kitty-scrollback.nvim', function()
  before_each(function()
    vim.fn.mkdir(ksb_dir .. 'tests/workdir', 'p')
    tmpsock = h.tempsocket(ksb_dir .. 'tmp/')
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

  it('should execute visual selection in Kitty (visual mode per character mode)', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.open_kitty_scrollback_nvim(),
        h.send_without_newline([[aecho start echo stop]]),
        h.esc(),
        h.send_without_newline([[vBB]]),
        h.send_without_newline(h.control_enter()),
      }),
      {
        stdout = [[
$ echo stop
stop
$ 
]],
        cursor_y = 3,
        cursor_x = 3,
      }
    )
  end)

  it('should execute visual selection in Kitty (visual mode linewise)', function()
    h.assert_screen_equals(
      h.feed_kitty({
        [[echo echo start stop]],
        h.open_kitty_scrollback_nvim(),
        h.send_without_newline([[kV]]),
        h.send_without_newline(h.control_enter()),
      }),
      {
        stdout = [[
$ echo echo start stop
echo start stop
$ echo start stop
start stop
$ 
]],
        cursor_y = 5,
        cursor_x = 3,
      }
    )
  end)

  it('should execute visual selection in Kitty (visual mode blockwise)', function()
    h.assert_screen_equals(
      h.feed_kitty({
        [[echo aaecho start stop]],
        h.open_kitty_scrollback_nvim(),
        h.send_without_newline([[k]]),
        h.send_without_newline(h.control_v()),
        h.send_without_newline([[kww]]),
        h.send_without_newline(h.control_enter()),
      }),
      {
        stdout = [[
$ echo aaecho start stop
aaecho start stop
$ echo aaecho s
echo start st
aaecho s
start st
$ 
]],
        cursor_y = 7,
        cursor_x = 3,
      }
    )
  end)

  it('should paste visual selection to Kitty (visual mode per character mode)', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.open_kitty_scrollback_nvim(),
        h.send_without_newline([[aecho start echo stop]]),
        h.esc(),
        h.send_without_newline([[vBB]]),
        h.send_without_newline(h.shift_enter()),
      }),
      {
        stdout = [[
$ echo stop
]],
        cursor_y = 1,
        cursor_x = 12,
      }
    )
  end)

  it('should paste visual selection to Kitty (visual mode linewise)', function()
    h.assert_screen_equals(
      h.feed_kitty({
        [[echo echo start stop]],
        h.open_kitty_scrollback_nvim(),
        h.send_without_newline([[kV]]),
        h.send_without_newline(h.shift_enter()),
      }),
      {
        stdout = [[
$ echo echo start stop
echo start stop
$ echo start stop
]],
        cursor_y = 3,
        cursor_x = 18,
      }
    )
  end)

  it('should paste visual selection to Kitty (visual mode blockwise)', function()
    h.assert_screen_equals(
      h.feed_kitty({
        [[echo aaecho start stop]],
        h.open_kitty_scrollback_nvim(),
        h.send_without_newline([[k]]),
        h.send_without_newline(h.control_v()),
        h.send_without_newline([[kww]]),
        h.send_without_newline(h.shift_enter()),
      }),
      {
        stdout = [[
$ echo aaecho start stop
aaecho start stop
$ echo aaecho s
echo start st
]],
        cursor_y = 4,
        cursor_x = 14,
      }
    )
  end)
end)
