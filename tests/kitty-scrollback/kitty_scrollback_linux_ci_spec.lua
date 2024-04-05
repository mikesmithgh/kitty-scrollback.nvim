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

local it = it
if not (h.is_github_action and vim.fn.has('linux') ~= 0) then
  it = function(desc, ...)
    h.ignore(h.color_string('red', 'Test only runs on linux CI! ') .. desc, ...)
  end
end

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

  it('should open scrollback buffer over ssh', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before([[ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_ci_test -N '']]),
        [[cat ~/.ssh/id_ed25519_ci_test.pub >> ~/.ssh/authorized_keys]],
        [[ssh -o "StrictHostKeyChecking no" -i ~/.ssh/id_ed25519_ci_test localhost]],
        h.with_pause_seconds_before([[clear; \]]),
        [==[[ -n "$SSH_CONNECTION" ] && echo "You are connected via SSH." || echo "You are not connected via SSH."; \]==],
        [[read -r]],
        h.open_kitty_scrollback_nvim(),
      }),
      {
        stdout = h.with_status_win([[
You are connected via SSH.
]]),
        cursor_y = 2,
        cursor_x = 1,
      }
    )
  end)
end)
