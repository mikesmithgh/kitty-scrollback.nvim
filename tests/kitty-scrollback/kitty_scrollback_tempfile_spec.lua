local assert = require('luassert.assert')
local h = require('tests.kitty-scrollback.helpers')

local ksb_dir = h.ksb_dir()
h.debug({
  ksb_dir = ksb_dir,
  kitty_conf = ksb_dir .. 'tests/kitty.conf',
})

local tmpsock
local kitty_instance

local shell = h.debug(h.is_github_action and '/bin/bash' or 'bash --noprofile --norc')
local scrollback_tempfile_dir = ksb_dir .. 'tmp'
local scrollback_tempfile_capture_path = scrollback_tempfile_dir .. '/scrollback-tempfile-path.txt'

describe('kitty-scrollback.nvim tempfile', function()
  h.init_nvim(string.format(
    [[
{
  test_scrollback_buffer_tempfile = {
    status_window = {
      enabled = false,
    },
    scrollback_buffer = {
      tempfile = {
        enabled = true,
        dir = %q,
      },
    },
  },
}
]],
    scrollback_tempfile_dir
  ))

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
    vim.fn.delete(scrollback_tempfile_capture_path)
    vim.fn.delete(vim.fn.fnamemodify(tmpsock, ':p:h'), 'rf')
  end)

  it('should create a temp file for the scrollback buffer when enabled', function()
    h.assert_screen_match(
      h.feed_kitty({
        h.send_as_string([[printf 'alpha\nbeta\n']]),
        h.open_kitty_scrollback_nvim({
          '--config',
          'test_scrollback_buffer_tempfile',
        }),
        [[:lua =vim.fn.filereadable(vim.api.nvim_buf_get_name(0))]],
      }),
      {
        pattern = [[
.*
:lua =vim%.fn%.filereadable%(vim%.api%.nvim_buf_get_name%(0%)%)
1
Press ENTER or type command to continue.*]],
      }
    )
  end)

  it('should clean up the scrollback temp file on quit', function()
    h.feed_kitty({
      h.send_as_string([[printf 'alpha\nbeta\n']]),
      h.open_kitty_scrollback_nvim({
        '--config',
        'test_scrollback_buffer_tempfile',
      }),
      h.send_as_string(
        string.format(
            [[:lua vim.fn.writefile({ vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':p') }, %q)]],
          scrollback_tempfile_capture_path
        )
      ),
      h.with_pause_seconds_before(h.send_without_newline([[q]])),
    })

    local captured_path = vim.fn.readfile(scrollback_tempfile_capture_path)[1]
    assert.is_not_nil(captured_path)
    assert.are_not.equal('', captured_path)
    assert.is_nil((vim.uv or vim.loop).fs_stat(captured_path))
  end)
end)
