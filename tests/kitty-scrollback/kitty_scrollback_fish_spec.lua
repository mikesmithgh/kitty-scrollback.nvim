local h = require('tests.kitty-scrollback.helpers')

local ksb_dir = h.ksb_dir()
h.debug({
  ksb_dir = ksb_dir,
  kitty_conf = ksb_dir .. 'tests/kitty.conf',
})

local tmpsock
local kitty_instance

local shell = h.debug(h.is_github_action and '/bin/fish' or 'fish')

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
function fish_prompt  
  echo "fish \$ " 
end                   
function kitty_scrollback_edit_command_buffer
    set -lx VISUAL ']] .. ksb_dir .. [[scripts/edit_command_line.sh'
    edit_command_buffer
    commandline ''
end
bind --mode default \\ee kitty_scrollback_edit_command_buffer
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

  it('should not have autocomplete in executed command', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before([[echo autocomplete test]]),
        h.open_kitty_scrollback_nvim(),
        h.with_pause_seconds_before(h.send_without_newline([[a]]), 2),
        h.send_without_newline([[echo]]),
        h.send_without_newline(h.control_enter()),
      }),
      {
        stdout = [[
fish $ echo autocomplete test
autocomplete test
fish $ echo

fish $
]],
        cursor_y = 5,
        cursor_x = 8,
      }
    )
  end)

  it('should have autocomplete available after cursor in current command', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before([[echo autocomplete test]]),
        h.open_kitty_scrollback_nvim(),
        h.with_pause_seconds_before(h.send_without_newline([[a]]), 2),
        h.send_without_newline([[echo]]),
        h.send_without_newline(h.shift_enter()),
      }),
      {
        stdout = [[
fish $ echo autocomplete test
autocomplete test
fish $ echo autocomplete test
]],
        cursor_y = 3,
        cursor_x = 12,
      }
    )
  end)

  it('should have fish filetype for paste window', function()
    h.assert_screen_match(
      h.feed_kitty({
        h.open_kitty_scrollback_nvim(),
        h.with_pause_seconds_before(h.send_without_newline([[a]]), 2),
        h.send_without_newline(h.esc()),
        [[:set filetype?]],
      }),
      {
        pattern = [[
.*
:set filetype%?
  filetype=fish
Press ENTER or type command to continue.*]],
      }
    )
  end)

  it('should open command in command-line editing mode for fish', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[nacho cheese]])),
        h.alt_e(),
        h.with_pause_seconds_before(h.send_without_newline([[ciwecho]]), 2),
        h.send_without_newline(h.control_enter()),
      }),
      {
        stdout = [[
fish $ echo cheese
cheese
fish $
]],
        cursor_y = 3,
        cursor_x = 8,
      }
    )
  end)

  it('should clear command if no-op in command-line editing mode for fish', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[nacho cheese]])),
        h.alt_e(),
        h.with_pause_seconds_before([[:qa!]]),
      }),
      {
        stdout = [[
fish $
]],
        cursor_y = 1,
        cursor_x = 8,
      }
    )
  end)
end)
