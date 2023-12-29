local h = require('tests.kitty-scrollback.helpers')
local screencapture = require('tests.kitty-scrollback.screencapture')

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
  '--override',
  'enabled_layouts=fat:bias=90',
  '--override',
  'initial_window_width=161c',
  '--override',
  'initial_window_height=30c',
  '--override',
  'font_size=18.0',
  '--override',
  'background_opacity=1.0',
  '--session',
  '-', -- read session from stdin
})

local it = screencapture.wrap_it(it, tmpsock)

describe('kitty-scrollback.nvim', function()
  before_each(function()
    vim.fn.mkdir(ksb_dir .. 'tests/workdir', 'p')
    kitty_instance = vim.system(kitty_cmd, {
      stdin = 'cd ' .. ksb_dir,
    })
    h.wait_for_kitty_remote_connection()
    local ksb_work_dir = os.getenv('KITTY_SCROLLBACK_NVIM_DIR') or 'tmp/00_kitty-scrollback.nvim'
    local is_directory = vim.fn.isdirectory(ksb_work_dir) > 0
    if is_directory then
      vim.system({ 'rm', '-rf', ksb_work_dir }):wait()
    end
    vim
      .system({
        'git',
        'clone',
        'https://github.com/mikesmithgh/kitty-scrollback.nvim',
        ksb_work_dir,
      })
      :wait()

    h.feed_kitty({
      h.send_as_string([[source ]] .. ksb_dir .. [[tests/bashrc]]),
      h.send_as_string([[cd ]] .. ksb_work_dir),
      h.send_as_string([[
echo '-- demo' >> README.md 
echo '-- demo' >> lua/kitty-scrollback/init.lua
echo '-- demo' >> lua/kitty-scrollback/api.lua
echo '-- demo' >> lua/kitty-scrollback/health.lua]]),
      h.with_pause_seconds_before(h.send_without_newline(h.clear())),
    })
  end)

  after_each(function()
    kitty_instance:kill(2)
    kitty_instance = nil
  end)

  it('kitty_scrollback_nvim', function()
    h.assert_screen_equals(
      h.feed_kitty({
        [[git status]],
        h.open_kitty_scrollback_nvim(),
        [[?README.md]],
        h.send_without_newline(h.control_v()),
        h.send_without_newline([[jjj$]]),
        h.with_pause_seconds_before(h.send_without_newline([[yddggI]]), 1),
        h.send_without_newline([[git checkout ]]),
        h.send_without_newline(h.esc()),
        h.send_without_newline([[j0]]),
        h.send_without_newline(h.control_v()),
        h.send_without_newline([[G]]),
        h.with_pause_seconds_before(h.send_without_newline([[Igit add ]]), 1),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.control_enter()),
        h.with_pause_seconds_before([[git status]], 1),
        h.open_kitty_scrollback_nvim(),
        h.send_without_newline([[4k3V]]),
        h.with_pause_seconds_before(h.send_without_newline([[yggO]]), 1),
        [[printf "\\033[0m\\033[38;2;167;192;128m"]],
        h.send_without_newline([[cat <<EOF]]),
        h.send_without_newline(h.esc()),
        h.shift_enter(),
        [[EOF]],
        h.with_pause_seconds_before(h.open_kitty_scrollback_nvim()),
        h.send_without_newline([[a]]),
        h.send_without_newline(h.esc()),
        h.with_pause_seconds_before(h.send_without_newline([[g?aloldino]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.control_enter()),
      }),
      {
        stdout = [[
$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   README.md
	modified:   lua/kitty-scrollback/api.lua
	modified:   lua/kitty-scrollback/health.lua
	modified:   lua/kitty-scrollback/init.lua

no changes added to commit (use "git add" and/or "git commit -a")
$ git checkout README.md
git add lua/kitty-scrollback/api.lua
git add lua/kitty-scrollback/health.lua
git add lua/kitty-scrollback/init.lua
Updated 1 path from the index
$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	modified:   lua/kitty-scrollback/api.lua
	modified:   lua/kitty-scrollback/health.lua
	modified:   lua/kitty-scrollback/init.lua

$ printf "\033[0m\033[38;2;167;192;128m"
cat <<EOF
        modified:   lua/kitty-scrollback/api.lua
        modified:   lua/kitty-scrollback/health.lua
        modified:   lua/kitty-scrollback/init.lua
> EOF
        modified:   lua/kitty-scrollback/api.lua
        modified:   lua/kitty-scrollback/health.lua
        modified:   lua/kitty-scrollback/init.lua
$  loldino
 ______ 
( nice )
 ------ 
o                             .       .
 o                           / `.   .' " 
  o                  .---.  <    > <    >  .---.
   o                 |    \  \ - ~ ~ - /  /    |
         _____          ..-~             ~-..-~
        |     |   \~~~\.'                    `./~~~/
       ---------   \__/                        \__/
      .'  O    \     /               /       \  " 
     (_____,    `._.'               |         }  \/~~~/
      `----.          /       }     |        /    \__/
            `-.      |       /      |       /      `. ,~~|
                ~-.__|      /_ - ~ ^|      /- _      `..-'   
                     |     /        |     /     ~-.     `-. _  _  _
                     |_____|        |_____|         ~ - . _ _ _ _ _>
$ 
]],
        cursor_y = 30,
        cursor_x = 3,
      },
      'kitty-scrollback.nvim did not have expected output'
    )
  end)
end)
