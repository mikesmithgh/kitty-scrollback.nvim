local h = require('tests.kitty-scrollback.helpers')

h.setup_backport()

local ksb_dir = h.ksb_dir()
h.debug({
  ksb_dir = ksb_dir,
  kitty_conf = ksb_dir .. 'tests/kitty.conf',
})

local tmpsock
local tmux_tmpsock
local kitty_instance

local shell = h.debug(h.is_github_action and '/bin/bash' or 'bash --noprofile --norc')

describe('kitty-scrollback.nvim', function()
  h.init_nvim()

  vim.fn.writefile({
    [[bind [ run-shell 'kitty @ kitten ]]
      .. ksb_dir
      .. [[python/kitty_scrollback_nvim.py --env "TMUX=$TMUX" --env "TMUX_PANE=#{pane_id}"']],
  }, './tmp/tmux.conf')

  before_each(function()
    vim.fn.mkdir(ksb_dir .. 'tests/workdir', 'p')
    tmpsock = h.tempsocket(ksb_dir .. 'tmp/')
    tmux_tmpsock = h.temp_tmux_socket(ksb_dir .. 'tmp/')
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
      h.send_as_string(
        ([[tmux -S %s -f %stmp/tmux.conf new-session -c %s %s]]):format(
          tmux_tmpsock,
          ksb_dir,
          ksb_dir .. 'tests/workdir',
          shell
        )
      ),
    })
  end)

  after_each(function()
    kitty_instance:kill(2)
    kitty_instance = nil
    vim.fn.delete(vim.fn.fnamemodify(tmpsock, ':p:h'), 'rf')
    vim.system({ 'tmux', '-S', tmux_tmpsock, 'kill-server' }):wait()
    vim.fn.delete(vim.fn.fnamemodify(tmux_tmpsock, ':p:h'), 'rf')
  end)

  it('should open kitty-scrollback.nvim with tmux', function()
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
        h.open_tmux_kitty_scrollback_nvim(),
      }),
      {
        stdout = h.with_status_win([[
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
        cursor_y = 29,
        cursor_x = 7,
      }
    )
    h.assert_screen_equals(
      h.feed_kitty({
        h.send_without_newline(h.send_as_string([[gg0]])),
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
        cursor_y = 1,
        cursor_x = 1,
      }
    )
  end)

  it('should have tmux environment variables set', function()
    h.assert_screen_match(
      h.feed_kitty({
        h.open_tmux_kitty_scrollback_nvim(),
        h.with_pause_seconds_before([[:lua vim.print(vim.env.TMUX)]], 1),
      }),
      {
        pattern = [[
.*vim.env.TMUX.*
.*tmux.sock.*,.*,.*
Press ENTER or type command to continue.*]],
      }
    )
    h.assert_screen_match(
      h.feed_kitty({
        h.send_without_newline(h.enter()),
        h.with_pause_seconds_before([[:lua vim.print(vim.env.TMUX_PANE)]], 1),
      }),
      {
        pattern = [[
.*TMUX_PANE.*
%%0
Press ENTER or type command to continue.*]],
      }
    )
  end)
end)
