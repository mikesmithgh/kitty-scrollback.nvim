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
  minimal_kitty_conf = ksb_dir .. 'tests/minimal_kitty.conf',
})

local tmpsock = h.tempsocket(ksb_dir .. 'tmp/')
local kitty_instance

local shell =
  h.debug(h.is_github_action and '/bin/bash' or (vim.o.shell .. ' --login --noprofile --norc'))

local kitty_cmd = h.debug({
  'kitty',
  '--listen-on=unix:' .. tmpsock,
  '--config',
  ksb_dir .. 'tests/minimal_kitty.conf',
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
    end)

    if not ready then
      vim.notify('kitty is not ready for remote connections, exiting', vim.log.levels.ERROR)
      os.exit(1) -- TODO: change to an assert fail?
    end
    h.pause()
  end)

  after_each(function()
    kitty_instance:kill(2)
    kitty_instance = nil
  end)

  it('should show the terminal screen in nvim', function()
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
      'kitty-scrollback.nvim content did not match the terminal screen'
    )
  end)

  -- during brew search a, the PATH env changes. if we are not pointing to the correct kitty executable, it will error out
  it('should use correct kitty path during brew command', function()
    h.assert_screen_equals(
      h.feed_kitty({
        [[brew search a]],
        [[\n]], -- enter
        [[__open_ksb]],
      }),
      [[
$ brew search a                                                             󰄛 󰣐  
]],
      'kitty-scrollback.nvim content did not match the terminal screen'
    )
  end)

  it('should successfully open checkhealth', function()
    local stdtout = h.feed_kitty({
      [[nvim +'KittyScrollbackCheckHealth']],
      [[\n]], -- enter
    })
    h.assert_screen_not_match(
      stdtout,
      'ERROR',
      'kitty-scrollback.nvim checkhealth had an unexpected health check ERROR'
    )
    h.assert_screen_starts_with(
      stdtout,
      [[

──────────────────────────────────────────────────────────────────────────────
kitty-scrollback: require("kitty-scrollback.health").check()

kitty-scrollback: Neovim version
]],
      'kitty-scrollback.nvim checkhealth content did not start with expected content'
    )
  end)
end)
