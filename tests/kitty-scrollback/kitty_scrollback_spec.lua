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

describe('kitty-scrollback.nvim', function()
  h.init_nvim([[
{
  test_pastewin_opts = {
    paste_window = {
      winopts_overrides = function(winopts)
         winopts.border = { '▛', '▀', '▜', '▐', '▟', '▄', '▙', '▌' }
         return winopts
       end,
    },
  },
  test_footer_opts = {
    paste_window = {
      footer_winopts_overrides = function(winopts)
         winopts.border = { '▛', '▀', '▜', '▐', '▟', '▄', '▙', '▌' }
         return winopts
       end,
    },
  },
  test_after_paste_window_ready = {
    callbacks = {
      after_paste_window_ready = function(pastewin_data, kitty_data, opts)
        local stc = '%#ErrorMsg#%{(v:lnum%2)?" "."a":""}' .. '%#WarningMsg#%{!(v:lnum%2)?" "."b":""} '
        vim.api.nvim_set_option_value('statuscolumn', stc, {
          win = pastewin_data.paste_window.winid,
        })

        vim.keymap.set({ '' }, '<Tab>', '<Plug>(KsbToggleFooter)', {
          buffer = pastewin_data.paste_window.bufid,
        })

        if pastewin_data.paste_window_footer.winid then
          vim.api.nvim_set_option_value('statuscolumn', 'help:', {
            win = pastewin_data.paste_window_footer.winid,
          })
        end
      end,
    },
  },
}
]])

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

  it('should successfully open KittyScrollbackCheckHealth', function()
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

  it('should successfully open checkhealth and warn user no kitty data available', function()
    local actual = h.feed_kitty({
      h.send_as_string(
        [[nvim +'lua vim.opt.rtp:append("../..") vim.opt.rtp:append("../../kitty-scrollback.nvim") require("kitty-scrollback").setup() vim.cmd("checkhealth kitty-scrollback")']]
      ),
      h.send_without_newline([[zR]]),
    })
    h.assert_screen_not_match(
      actual,
      { pattern = 'ERROR', cursor_y = 1, cursor_x = 1 },
      'kitty-scrollback.nvim checkhealth had an unexpected health check ERROR'
    )
    h.assert_screen_match(actual, {
      pattern = 'WARNING No Kitty data available unable to perform a complete healthcheck',
      cursor_y = 1,
      cursor_x = 1,
    })
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

  it([[should remove \r wrap markers and display line up to 300 columns]], function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.send_as_string([[printf '

]] .. string.rep('A', 300) .. [[
0123456789
']]),
        h.open_kitty_scrollback_nvim(),
      }),
      {
        stdout = h.with_status_win([[
$ printf '
> 
> AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AA0123456789
> '


AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
0123456789
$ 
]]),
        cursor_y = 12,
        cursor_x = 3,
      },
      'kitty-scrollback.nvim did not have expected removed wrap marker results'
    )
    h.assert_screen_equals(
      h.feed_kitty({
        h.send_without_newline(h.esc()),
      }),
      {
        stdout = [[
$ printf '
> 
> AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0123456789
> '


AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0123456789
$ 
]],
        cursor_y = 12,
        cursor_x = 3,
      },
      'kitty-scrollback.nvim did not have expected wrap marker results'
    )
  end)

  it('should temporarily block user input on start', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim()
    h.assert_screen_not_match(
      h.feed_kitty({
        h.send_without_newline([[aa]]),
        h.send_without_newline(h.control_c()),
      }),
      { pattern = 'Error' }
    )
  end)

  it('should have environment variable set', function()
    h.assert_screen_match(
      h.feed_kitty({
        h.open_kitty_scrollback_nvim(),
        h.with_pause_seconds_before([[:=vim.env.KITTY_SCROLLBACK_NVIM]], 1),
      }),
      {
        pattern = [[
.*
:=vim.env.KITTY_SCROLLBACK_NVIM
true
Press ENTER or type command to continue.*]],
      }
    )
  end)

  it('should set winopts_overrides', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.open_kitty_scrollback_nvim({
          '--config',
          'test_pastewin_opts',
        }),
        h.send_without_newline([[a]]),
      }),
      {
        stdout = [[
$▛▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▜
 ▌                                                                                                        ▐
 ▌                                                                                                        ▐
 ▌                                                                                                        ▐
 ▌                                                                                                        ▐
 ▌                                                                                                        ▐
 ▌                                                                                                        ▐
 ▌                                                                                                        ▐
 ▌                                                                                                        ▐
 ▌                                                                                                        ▐
 ▌                                                                                                        ▐
 ▙▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▟
 ▏                                                                                                        ▕
 ▏    \y Yank          <C-CR> Execute          <S-CR> Paste          :w Paste          g? Toggle Mappings ▕
 🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
        cursor_y = 2,
        cursor_x = 3,
      }
    )
  end)

  it('should set footer_winopts_overrides', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.open_kitty_scrollback_nvim({
          '--config',
          'test_footer_opts',
        }),
        h.send_without_newline([[a]]),
      }),
      {
        stdout = [[
$🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
 ▛▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▜
 ▌    \y Yank          <C-CR> Execute          <S-CR> Paste          :w Paste          g? Toggle Mappings ▐
 ▙▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▟
]],
        cursor_y = 2,
        cursor_x = 3,
      }
    )
  end)

  it('should call after_paste_window_ready', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.open_kitty_scrollback_nvim({
          '--config',
          'test_after_paste_window_ready',
        }),
        [[a]],
      }),
      {
        stdout = [[
$🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
 ▏a                                                                                                       ▕
 ▏b                                                                                                       ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 ▏                                                                                                        ▕
 🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
 ▏                                                                                                        ▕
 ▏help:    \y Yank          <C-CR> Execute          <S-CR> Paste          :w Paste          <Tab> Toggle M▕
 🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
        cursor_y = 3,
        cursor_x = 5,
      }
    )
  end)

  it('should send text to kitty from command-line window', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.open_kitty_scrollback_nvim(),
        h.send_without_newline([[q:i]]),
        h.send_without_newline([[# in command-line window]]),
        h.send_without_newline(h.esc()),
        h.send_without_newline([[V]]),
        h.shift_enter(),
      }),
      {
        stdout = [[
$ # in command-line window
]],
        cursor_y = 1,
        cursor_x = 27,
      },
      'kitty-scrollback.nvim content did not match the terminal screen'
    )
  end)
end)
