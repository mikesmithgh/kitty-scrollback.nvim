local h = require('tests.kitty-scrollback.helpers')

h.setup_backport()

local ksb_dir = h.ksb_dir()
h.debug({
  ksb_dir = ksb_dir,
  kitty_conf = ksb_dir .. 'tests/kitty.conf',
})

local tmpsock
local kitty_instance

local shell = h.debug(h.is_github_action and '/bin/zsh -f' or 'zsh -f')

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
      h.send_as_string([[
PROMPT="zsh \$ "
autoload -Uz edit-command-line
zle -N edit-command-line

function kitty_scrollback_edit_command_line() { 
  local VISUAL=']] .. ksb_dir .. [[scripts/edit_command_line.sh'
  zle edit-command-line
  zle kill-whole-line
}
zle -N kitty_scrollback_edit_command_line

bindkey '^x^e' kitty_scrollback_edit_command_line
]]),
      h.with_pause_seconds_before(h.send_without_newline(h.clear())),
    })
    h.pause_seconds()
  end)

  after_each(function()
    kitty_instance:kill(2)
    kitty_instance = nil
    vim.fn.delete(vim.fn.fnamemodify(tmpsock, ':p:h'), 'rf')
  end)

  it('should open command in command-line editing mode for zsh', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[gouda cheese]])),
        h.send_without_newline(h.ctrl_x()),
        h.ctrl_e(),
        h.with_pause_seconds_before(h.send_without_newline([[ciwecho]]), 2),
        h.send_without_newline(h.control_enter()),
      }),
      {
        stdout = [[
zsh $ echo cheese
cheese
zsh $
]],
        cursor_y = 3,
        cursor_x = 7,
      }
    )
  end)

  it('should clear command if no-op in command-line editing mode for zsh', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[gouda cheese]])),
        h.send_without_newline(h.ctrl_x()),
        h.ctrl_e(),
        h.with_pause_seconds_before([[:qa!]]),
      }),
      {
        stdout = [[
zsh $
]],
        cursor_y = 1,
        cursor_x = 7,
      }
    )
  end)
end)
