local h = require('tests.kitty-scrollback.helpers')
local screencapture = require('tests.kitty-scrollback.screencapture')

h.setup_backport()

local ksb_dir = h.ksb_dir()

h.debug({
  ksb_dir = ksb_dir,
  kitty_conf = ksb_dir .. 'tests/kitty.conf',
})

local tmpsock = h.tempsocket(ksb_dir .. 'tmp/')
local kitty_instance
local ksb_work_dir

local shell = h.debug(h.is_github_action and '/bin/bash' or (vim.o.shell .. ' --noprofile --norc'))

local kitty_cmd = h.debug({
  h.kitty,
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

local function before_all()
  h.init_nvim()
  vim.fn.mkdir(ksb_dir .. 'tests/workdir', 'p')
  kitty_instance = h.wait_for_kitty_remote_connection(kitty_cmd, tmpsock, {
    stdin = 'cd ' .. ksb_dir,
  })
  ksb_work_dir = os.getenv('KITTY_SCROLLBACK_NVIM_DIR') or 'tmp/01_kitty-scrollback.nvim'
  local is_directory = vim.fn.isdirectory(ksb_work_dir) > 0
  if is_directory then
    vim.fn.delete(ksb_work_dir, 'rf')
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
    h.with_pause_seconds_before(h.send_without_newline(h.clear())),
    h.with_pause_seconds_before(h.send_as_string([[banner]])),
    h.with_pause_seconds_before(h.send_as_string([[ksb_tree]])),
    h.with_pause_seconds_before(h.send_as_string([[loldino]])),
    h.with_pause_seconds_before(h.send_as_string([[lolbanner]])),
    h.with_pause_seconds_before(h.send_as_string([[
colortest


    ]])),
  })
  h.pause_seconds()
end

local function after_all()
  kitty_instance:kill(2)
  kitty_instance = nil
  vim.fn.delete(vim.fn.fnamemodify(tmpsock, ':p:h'), 'rf')
  vim.fn.delete(ksb_work_dir, 'rf')
end

local it = screencapture.wrap_it(it, tmpsock, 0)

describe('kitty-scrollback.nvim', function()
  before_all()

  before_each(h.pause_seconds)

  it('ksb_builtin_get_text_all', function()
    h.assert_screen_equals(
      h.feed_kitty({
        h.open_kitty_scrollback_nvim(),
        h.send_without_newline([[a]]),
        h.send_without_newline(h.send_as_string([[
# builtin > kitty_scrollback_nvim
default configuration for the keymap `kitty_mod+h`

Browse scrollback buffer in kitty-scrollback.nvim 
]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
      }),
      {
        stdout = h.with_status_win(
          [[
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
$ lolbanner
        _     _ _____ _______ _______ __   __     _______ _______  ______  _____                ______  _______ _______ _     _   __   _ _    _ _____ _______    
        |____/    |      |       |      \_/   ___ |______ |       |_____/ |     | |      |      |_____] |_____| |       |____/    | \  |  \  /    |   |  |  |    
        |    \_ __|__    |       |       |        ______| |_____  |    \_ |_____| |_____ |_____ |_____] |     | |_____  |    \_ . |  \_|   \/   __|__ |  |  |    
                                                                                                                                                                 
$🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
N▏# builtin > kitty_scrollback_nvim                                                                                                                             ▕
\▏# default configuration for the keymap `kitty_mod+h`                                                                                                          ▕
\▏#                                                                                                                                                             ▕
\▏# Browse scrollback buffer in kitty-scrollback.nvim                                                                                                           ▕
\▏#                                                                                                                                                             ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
T▏                                                                                                                                                              ▕
$🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
$▏                                                                                                                                                              ▕
$▏         \y Yank               <C-CR> Execute               <S-CR> Paste                :w Paste               g? Toggle Mappings                             ▕
$🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
          168
        ),
        cursor_y = 17,
        cursor_x = 3,
      }
    )
    h.kitty_remote_close_window()
  end)

  it('ksb_example_get_text_all_plain', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_get_text_all_plain',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before((h.send_without_newline([[a]]))),
        h.send_without_newline(h.send_as_string([[
# builtin > --config ksb_builtin_last_cmd_output 
Browse plaintext scrollback buffer in kitty-scrollback.nvim
]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
      }),
      {
        stdout = h.with_status_win(
          [[
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
$ lolbanner    
        _     _ _____ _______ _______ __   __     _______ _______  ______  _____                ______  _______ _______ _     _   __   _ _    _ _____ _______
        |____/    |      |       |      \_/   ___ |______ |       |_____/ |     | |      |      |_____] |_____| |       |____/    | \  |  \  /    |   |  |  |
        |    \_ __|__    |       |       |        ______| |_____  |    \_ |_____| |_____ |_____ |_____] |     | |_____  |    \_ . |  \_|   \/   __|__ |  |  |
                   
$🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
N▏# builtin > --config ksb_builtin_last_cmd_output                                                                                                              ▕
\▏# Browse plaintext scrollback buffer in kitty-scrollback.nvim                                                                                                 ▕
\▏#                                                                                                                                                             ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
T▏                                                                                                                                                              ▕
$🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
$▏                                                                                                                                                              ▕
$▏         \y Yank               <C-CR> Execute               <S-CR> Paste                :w Paste               g? Toggle Mappings                             ▕
$🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
          168
        ),
        cursor_y = 17,
        cursor_x = 3,
      }
    )
    h.kitty_remote_close_window()
  end)

  it('ksb_builtin_last_cmd_output', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_builtin_last_cmd_output',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before((h.send_without_newline([[a]]))),
        h.send_without_newline(h.send_as_string([[
# builtin > --config ksb_builtin_last_cmd_output 
default configuration for the keymap `kitty_mod+g`

Browse output of the last shell command in kitty-scrollback.nvim
]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
      }),
      {
        stdout = h.with_status_win(
          [[
NORMAL bold  dim   itali under rever strik  BRIGHT bold  dim   itali under rever strik
\e[30m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[90m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m
\e[31m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[91m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m
\e[32m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[92m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m
\e[33m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[93m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m
\e[34m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[94m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m
\e[35m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[95m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m
\e[36m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[96m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m
\e[37m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[97m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m
TRUECOLOR                                                                              

🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
▏# builtin > --config ksb_builtin_last_cmd_output                                                                                                               ▕
▏# default configuration for the keymap `kitty_mod+g`                                                                                                           ▕
▏#                                                                                                                                                              ▕
▏# Browse output of the last shell command in kitty-scrollback.nvim                                                                                             ▕
▏#                                                                                                                                                              ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
▏                                                                                                                                                               ▕
▏          \y Yank                <C-CR> Execute                <S-CR> Paste                  :w Paste                g? Toggle Mappings                        ▕
🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
          168
        ),
        cursor_y = 13,
        cursor_x = 2,
      }
    )
    h.kitty_remote_close_window()
  end)

  it('ksb_example_get_text_last_cmd_output_plain', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_get_text_last_cmd_output_plain',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before((h.send_without_newline([[a]]))),
        h.send_without_newline(h.send_as_string([[
# builtin > --config ksb_builtin_last_cmd_output 
Browse the plaintext output of the last shell command in kitty-scrollback.nvim
]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
      }),
      {
        stdout = h.with_status_win(
          [[
NORMAL bold  dim   itali under rever strik  BRIGHT bold  dim   itali under rever strik
\e[30m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[90m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m
\e[31m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[91m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m
\e[32m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[92m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m
\e[33m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[93m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m
\e[34m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[94m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m
\e[35m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[95m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m
\e[36m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[96m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m
\e[37m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[97m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m
TRUECOLOR

🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
▏# builtin > --config ksb_builtin_last_cmd_output                                                                                                               ▕
▏# Browse the plaintext output of the last shell command in kitty-scrollback.nvim                                                                               ▕
▏#                                                                                                                                                              ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
▏                                                                                                                                                               ▕
▏          \y Yank                <C-CR> Execute                <S-CR> Paste                  :w Paste                g? Toggle Mappings                        ▕
🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
          168
        ),
        cursor_y = 13,
        cursor_x = 2,
      }
    )
    h.kitty_remote_close_window()
  end)

  it('ksb_builtin_last_visited_cmd_output', function()
    h.move_to_first_prompt()

    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_builtin_last_visited_cmd_output',
    })

    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before((h.send_without_newline([[a]]))),
        h.send_without_newline(h.send_as_string([[
# builtin > --config ksb_builtin_last_visited_cmd_output 
default configuration for the mousemap `ctrl+shift+right`

Show clicked command output in kitty-scrollback.nvim
]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
      }),
      {
        stdout = h.with_status_win(
          [[
        _     _ _____ _______ _______ __   __     _______ _______  ______  _____                ______  _______ _______ _     _   __   _ _    _ _____ ____ 
        |____/    |      |       |      \_/   ___ |______ |       |_____/ |     | |      |      |_____] |_____| |       |____/    | \  |  \  /    |   |  |  |
        |    \_ __|__    |       |       |        ______| |_____  |    \_ |_____| |_____ |_____ |_____] |     | |_____  |    \_ . |  \_|   \/   __|__ |  |  |

🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
▏# builtin > --config ksb_builtin_last_visited_cmd_output                                                                                                       ▕
▏# default configuration for the mousemap `ctrl+shift+right`                                                                                                    ▕
▏#                                                                                                                                                              ▕
▏# Show clicked command output in kitty-scrollback.nvim                                                                                                         ▕
▏#                                                                                                                                                              ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
▏                                                                                                                                                               ▕
▏          \y Yank                <C-CR> Execute                <S-CR> Paste                  :w Paste                g? Toggle Mappings                        ▕
🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
          168
        ),
        cursor_y = 6,
        cursor_x = 2,
      }
    )
    h.kitty_remote_close_window()
    h.move_forward_one_prompt()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_builtin_last_visited_cmd_output',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before((h.send_without_newline([[a]]))),
        h.send_without_newline(h.send_as_string([[
# builtin > --config ksb_builtin_last_visited_cmd_output 
default configuration for the mousemap `ctrl+shift+right`

Show clicked command output in kitty-scrollback.nvim
]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
      }),
      {
        stdout = h.with_status_win(
          [[
../kitty-scrollback.nvim/lua
└── kitty-scrollback
   ├── api.lua
   ├── autocommands.lua
   ├── backport
   │  ├── _system.lua
   │  ├── backport-sha.json
   │  ├── init.lua
   │  └── README.md
   ├── configs
   │  ├── builtin.lua
   │  └── example.lua
   ├── footer_win.lua
   ├── health.lua
   ├── highlights.lua
🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
▏# builtin > --config ksb_builtin_last_visited_cmd_output                                                                                                       ▕
▏# default configuration for the mousemap `ctrl+shift+right`                                                                                                    ▕
▏#                                                                                                                                                              ▕
▏# Show clicked command output in kitty-scrollback.nvim                                                                                                         ▕
▏#                                                                                                                                                              ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
▏                                                                                                                                                               ▕
▏          \y Yank                <C-CR> Execute                <S-CR> Paste                  :w Paste                g? Toggle Mappings                        ▕
🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
          168
        ),
        cursor_y = 17,
        cursor_x = 2,
      }
    )
    h.kitty_remote_close_window()
    h.move_forward_one_prompt()
    h.move_forward_one_prompt()
  end)

  it('ksb_example_get_text_last_visited_cmd_output_plain', function()
    h.move_to_first_prompt()

    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_get_text_last_visited_cmd_output_plain',
    })

    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before((h.send_without_newline([[a]]))),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_get_text_last_visited_cmd_output_plain
Show clicked command plaintext output in kitty-scrollback.nvim
]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
      }),
      {
        stdout = h.with_status_win(
          [[
        _     _ _____ _______ _______ __   __     _______ _______  ______  _____                ______  _______ _______ _     _   __   _ _    _ _____ ____
        |____/    |      |       |      \_/   ___ |______ |       |_____/ |     | |      |      |_____] |_____| |       |____/    | \  |  \  /    |   |  |  |
        |    \_ __|__    |       |       |        ______| |_____  |    \_ |_____| |_____ |_____ |_____] |     | |_____  |    \_ . |  \_|   \/   __|__ |  |  |

🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
▏# example > --config ksb_example_get_text_last_visited_cmd_output_plain                                                                                        ▕
▏# Show clicked command plaintext output in kitty-scrollback.nvim                                                                                               ▕
▏#                                                                                                                                                              ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
▏                                                                                                                                                               ▕
▏          \y Yank                <C-CR> Execute                <S-CR> Paste                  :w Paste                g? Toggle Mappings                        ▕
🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
          168
        ),
        cursor_y = 6,
        cursor_x = 2,
      }
    )
    h.kitty_remote_close_window()
    h.move_forward_one_prompt()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_get_text_last_visited_cmd_output_plain',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before((h.send_without_newline([[a]]))),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_get_text_last_visited_cmd_output_plain
default configuration for the mousemap `ctrl+shift+right`

Show clicked command output in kitty-scrollback.nvim
]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
      }),
      {
        stdout = h.with_status_win(
          [[
../kitty-scrollback.nvim/lua
└── kitty-scrollback
   ├── api.lua
   ├── autocommands.lua
   ├── backport
   │  ├── _system.lua
   │  ├── backport-sha.json
   │  ├── init.lua
   │  └── README.md
   ├── configs
   │  ├── builtin.lua
   │  └── example.lua
   ├── footer_win.lua
   ├── health.lua
   ├── highlights.lua
🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
▏# example > --config ksb_example_get_text_last_visited_cmd_output_plain                                                                                        ▕
▏# default configuration for the mousemap `ctrl+shift+right`                                                                                                    ▕
▏#                                                                                                                                                              ▕
▏# Show clicked command output in kitty-scrollback.nvim                                                                                                         ▕
▏#                                                                                                                                                              ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
▏                                                                                                                                                               ▕
🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
▏                                                                                                                                                               ▕
▏          \y Yank                <C-CR> Execute                <S-CR> Paste                  :w Paste                g? Toggle Mappings                        ▕
🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
          168
        ),
        cursor_y = 17,
        cursor_x = 2,
      }
    )
    h.kitty_remote_close_window()
    h.move_forward_one_prompt()
    h.move_forward_one_prompt()
  end)

  it('ksb_example_callbacks', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_callbacks',
    })
    h.assert_screen_starts_with(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]])),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_callbacks
Capture the timestamps of when the callbacks after_setup, after_launch, and after_ready are executed
]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
      }),
      {
        stdout = h.with_status_win(
          [[
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
$ lolbanner    
        _     _ _____ _______ _______ __   __     _______ _______  ______  _____                ______  _______ _______ _     _   __   _ _    _ _____ _______
        |____/    |      |       |      \_/   ___ |______ |       |_____/ |     | |      |      |_____] |_____| |       |____/    | \  |  \  /    |   |  |  |
        |    \_ __|__    |       |       |        ______| |_____  |    \_ |_____| |_____ |_____ |_____] |     | |_____  |    \_ . |  \_|   \/   __|__ |  |  |
                   
$🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
N▏# kitty-scrollback after_setup callback triggered @]],
          168
        ),
        cursor_y = 17,
        cursor_x = 3,
      }
    )
    h.kitty_remote_close_window()
  end)

  it('ksb_example_status_win_autoclose', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_status_win_autoclose',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]])),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_status_win_autoclose 
status_window auto_close is true, notice status window closes in the top right of the screen
]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
      }),
      {
        stdout = [[
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
$ lolbanner    
        _     _ _____ _______ _______ __   __     _______ _______  ______  _____                ______  _______ _______ _     _   __   _ _    _ _____ _______
        |____/    |      |       |      \_/   ___ |______ |       |_____/ |     | |      |      |_____] |_____| |       |____/    | \  |  \  /    |   |  |  |
        |    \_ __|__    |       |       |        ______| |_____  |    \_ |_____| |_____ |_____ |_____] |     | |_____  |    \_ . |  \_|   \/   __|__ |  |  |
                   
$🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
N▏# example > --config ksb_example_status_win_autoclose                                                                                                         ▕
\▏# status_window auto_close is true, notice status window closes in the top right of the screen                                                                ▕
\▏#                                                                                                                                                             ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
T▏                                                                                                                                                              ▕
$🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
$▏                                                                                                                                                              ▕
$▏         \y Yank               <C-CR> Execute               <S-CR> Paste                :w Paste               g? Toggle Mappings                             ▕
$🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
        cursor_y = 17,
        cursor_x = 3,
      }
    )
    h.kitty_remote_close_window()
  end)

  it('ksb_example_status_win_show_timer', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_status_win_show_timer',
    })
    h.pause_seconds(3)
    h.assert_screen_match(
      h.feed_kitty(),
      { pattern = '%(ctrl%+c to quit%)', cursor_y = 3, cursor_x = 1 }
    )
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), 5),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_status_win_show_timer
status_window show_timer is true, show timer while loading screen is waiting for kitty-scrollback.nvim to finish processing the scrollback buffer
]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
      }),
      {
        stdout = h.with_status_win(
          [[
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
$ lolbanner    
        _     _ _____ _______ _______ __   __     _______ _______  ______  _____                ______  _______ _______ _     _   __   _ _    _ _____ _______
        |____/    |      |       |      \_/   ___ |______ |       |_____/ |     | |      |      |_____] |_____| |       |____/    | \  |  \  /    |   |  |  |
        |    \_ __|__    |       |       |        ______| |_____  |    \_ |_____| |_____ |_____ |_____] |     | |_____  |    \_ . |  \_|   \/   __|__ |  |  |
                   
$🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
N▏# example > --config ksb_example_status_win_show_timer                                                                                                        ▕
\▏# status_window show_timer is true, show timer while loading screen is waiting for kitty-scrollback.nvim to finish processing the scrollback buffer           ▕
\▏#                                                                                                                                                             ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
T▏                                                                                                                                                              ▕
$🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
$▏                                                                                                                                                              ▕
$▏         \y Yank               <C-CR> Execute               <S-CR> Paste                :w Paste               g? Toggle Mappings                             ▕
$🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
          168
        ),
        cursor_y = 17,
        cursor_x = 3,
      }
    )
    h.kitty_remote_close_window()
  end)

  it('ksb_example_status_win_vim', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_status_win_vim',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]])),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_status_win_vim 
status_window icons nvim is '', use nerd font icon '' instead of nerd font icon ''
]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
      }),
      {
        stdout = h.with_status_win(
          [[
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
$ lolbanner    
        _     _ _____ _______ _______ __   __     _______ _______  ______  _____                ______  _______ _______ _     _   __   _ _    _ _____ _______
        |____/    |      |       |      \_/   ___ |______ |       |_____/ |     | |      |      |_____] |_____| |       |____/    | \  |  \  /    |   |  |  |
        |    \_ __|__    |       |       |        ______| |_____  |    \_ |_____| |_____ |_____ |_____] |     | |_____  |    \_ . |  \_|   \/   __|__ |  |  |
                   
$🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
N▏# example > --config ksb_example_status_win_vim                                                                                                               ▕
\▏# status_window icons nvim is '', use nerd font icon '' instead of nerd font icon ''                                                                       ▕
\▏#                                                                                                                                                             ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
T▏                                                                                                                                                              ▕
$🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
$▏                                                                                                                                                              ▕
$▏         \y Yank               <C-CR> Execute               <S-CR> Paste                :w Paste               g? Toggle Mappings                             ▕
$🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
          168,
          '󰄛 󰣐 '
        ),
        cursor_y = 17,
        cursor_x = 3,
      }
    )
    h.kitty_remote_close_window()
  end)

  it('ksb_example_status_win_simple', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_status_win_simple',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]])),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_status_win_simple
status_window style_simple is true, use plaintext instead of nerd font icons
]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
      }),
      {
        stdout = h.with_status_win(
          [[
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
$ lolbanner    
        _     _ _____ _______ _______ __   __     _______ _______  ______  _____                ______  _______ _______ _     _   __   _ _    _ _____ _______
        |____/    |      |       |      \_/   ___ |______ |       |_____/ |     | |      |      |_____] |_____| |       |____/    | \  |  \  /    |   |  |  |
        |    \_ __|__    |       |       |        ______| |_____  |    \_ |_____| |_____ |_____ |_____] |     | |_____  |    \_ . |  \_|   \/   __|__ |  |  |
                   
$🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
N▏# example > --config ksb_example_status_win_simple                                                                                                            ▕
\▏# status_window style_simple is true, use plaintext instead of nerd font icons                                                                                ▕
\▏#                                                                                                                                                             ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
T▏                                                                                                                                                              ▕
$🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
$▏                                                                                                                                                              ▕
$▏         \y Yank               <C-CR> Execute               <S-CR> Paste                :w Paste               g? Toggle Mappings                             ▕
$🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
]],
          160,
          'kitty-scrollback.nvim'
        ),
        cursor_y = 17,
        cursor_x = 3,
      }
    )
    h.kitty_remote_close_window()
  end)

  after_all()
end)
