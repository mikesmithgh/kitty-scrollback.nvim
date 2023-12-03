local h = require('tests.helpers')
local describe = describe ---@diagnostic disable-line: undefined-global
local it = it ---@diagnostic disable-line: undefined-global

h.setup_backport()

local tmpsock = h.tempsocket()

local kitty_cmd = {
  'kitty',
  '--listen-on=unix:' .. tmpsock,
  '--override',
  'enabled_layouts=fat:bias=90',
  '--override',
  'initial_window_width=1000',
  '--override',
  'initial_window_height=800',
  '--override',
  'env=PROMPT_COMMAND=',
  '--override',
  [==[env=PS1=\[\e[34m\]$ \[\e[m\]]==],
  '--override',
  'shell=/opt/homebrew/bin/bash --login --noprofile',
  '--session',
  '-', -- read session from stdin
}

describe('kitty-scrollback.nvim', function()
  it('should show the terminal screen in nvim', function()
    local kitty_instance = vim.system(kitty_cmd, {
      stdin = 'cd /Users/mike/gitrepos/kitty-scrollback.nvim/tests/workdir',
    })
    print(('starting kitty with pid %s on socket %s...'):format(kitty_instance.pid, tmpsock))

    local ready = false
    vim.fn.wait(5000, function()
      ready = (h.kitty_remote_ls():wait().code == 0)
      return ready
    end)

    if not ready then
      vim.notify('kitty is not ready for remote connections, exiting', vim.log.levels.ERROR)
      os.exit(1)
    end
    vim.notify('kitty is ready for remote connections', vim.log.levels.INFO)

    h.assert_screen_equals(
      h.feed_kitty({
        [[echo meow]],
        [[\n]], -- enter
        [[__open_ksb]],
      }),
      [[
$ echo meow                                                                 󰄛 󰣐  
meow
$
]],
      'should pass'
    )

    kitty_instance:kill(2)
  end)
end)
