local h = require('tests.kitty-scrollback.helpers')

local ksb_dir = h.ksb_dir()
h.debug({
  ksb_dir = ksb_dir,
  kitty_conf = ksb_dir .. 'tests/kitty.conf',
})

local tmpsock
local kitty_instance

local shell = h.debug(h.is_github_action and '/bin/bash' or 'bash --noprofile --norc')

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

  it('should create tempfile for the scrollback buffer when enabled', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_scrollback_tempfile',
    })
    h.assert_screen_match(
      h.feed_kitty({
        h.with_pause_seconds_before(
          h.send_without_newline(
            [[:=vim.api.nvim_buf_get_name(0):match('^term://.*:kitty%-scrollback%.nvim$') == nil]]
          )
        ),
        [[ and vim.fn.filereadable(vim.api.nvim_buf_get_name(0)) == 1]],
      }),
      {
        pattern = [[
.*
true
Press ENTER or type command to continue.*]],
      }
    )
  end)

  it('should not create tempfile for the scrollback buffer when disabled', function()
    h.assert_screen_match(
      h.feed_kitty({
        h.open_kitty_scrollback_nvim(),
        h.with_pause_seconds_before(
          h.send_without_newline(
            [[:=vim.api.nvim_buf_get_name(0):match('^term://.*:kitty%-scrollback%.nvim$') ~= nil]]
          )
        ),
        [[ and vim.fn.filereadable(vim.api.nvim_buf_get_name(0)) == 0]],
      }),
      {
        pattern = [[
.*
true
Press ENTER or type command to continue.*]],
      }
    )
  end)
end)
