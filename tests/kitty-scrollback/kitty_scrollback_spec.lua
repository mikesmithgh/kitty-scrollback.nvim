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
      h.with_pause_seconds_before(h.send_without_newline(h.clear())),
    })
  end)

  after_each(function()
    kitty_instance:kill(2)
    kitty_instance = nil
  end)

  -- during brew search a, the PATH env changes. if we are not pointing to the correct kitty executable, it will error out
  it('should use correct kitty path during brew command', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before([[brew search a]]),
        h.open_kitty_scrollback_nvim(),
      }),
      {
        stdout = h.with_status_win([[
$ brew search a
]]),
        cursor_y = 2,
        cursor_x = 1,
      },
      'kitty-scrollback.nvim content did not match the terminal screen'
    )
  end)

  it('should successfully open checkhealth', function()
    local actual = h.feed_kitty({
      h.send_as_string(
        [[nvim +'lua vim.opt.rtp:append("../..") vim.opt.rtp:append("../../kitty-scrollback.nvim") require("kitty-scrollback").setup() vim.cmd("KittyScrollbackCheckHealth")']]
      ),
    })
    h.assert_screen_not_match(
      actual,
      { pattern = 'ERROR', cursor_y = 1, cursor_x = 1 },
      'kitty-scrollback.nvim checkhealth had an unexpected health check ERROR'
    )
    h.assert_screen_starts_with(actual, {
      stdout = [[

──────────────────────────────────────────────────────────────────────────────
kitty-scrollback: require("kitty-scrollback.health").check()

kitty-scrollback: Neovim version
]],
      cursor_y = 1,
      cursor_x = 1,
    }, 'kitty-scrollback.nvim checkhealth content did not start with expected content')
  end)

  it('should paste command to kitty in bracketed paste mode', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.send_as_string([[\n\n]]),
        h.open_kitty_scrollback_nvim(),
        [[acat <<EOF]],
        h.send_as_string([[
line1
line2
line3]]),
        h.shift_enter(),
        [[EOF]],
      }),
      {
        stdout = [[
$
$
$
$ cat <<EOF
line1
line2
line3
> EOF
line1
line2
line3
$
]],
        cursor_y = 12,
        cursor_x = 3,
      },
      'kitty-scrollback.nvim did not have expected bracketed paste results'
    )
  end)

  it('should execute command in kitty with bracketed paste mode', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.send_as_string([[\n\n]]),
        h.open_kitty_scrollback_nvim(),
        [[acat <<EOF]],
        h.send_as_string([[
line1
line2
line3
EOF]]),
        h.send_without_newline(h.control_enter()),
      }),
      {
        stdout = [[
$
$
$
$ cat <<EOF
line1
line2
line3
EOF
line1
line2
line3
$
]],
        cursor_y = 12,
        cursor_x = 3,
      },
      'kitty-scrollback.nvim did not have expected bracketed paste results'
    )
  end)
end)
