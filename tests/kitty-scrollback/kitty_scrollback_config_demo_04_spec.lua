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
  ksb_work_dir = os.getenv('KITTY_SCROLLBACK_NVIM_DIR') or 'tmp/04_kitty-scrollback.nvim'
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

local it = screencapture.wrap_it(it, tmpsock, 27)

describe('kitty-scrollback.nvim', function()
  before_all()

  before_each(h.pause_seconds)
  after_each(h.kitty_remote_close_window)

  it('ksb_example_paste_win_register_disabled', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_paste_win_register_disabled',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), 2),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_paste_win_register_disabled 
paste_window yank_register_enabled is set to false

yanks to " perform normal Neovim behavior and no longer open the paste window
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
N▏# example > --config ksb_example_paste_win_register_disabled                                                                                                  ▕
\▏# paste_window yank_register_enabled is set to false                                                                                                          ▕
\▏#                                                                                                                                                             ▕
\▏# yanks to " perform normal Neovim behavior and no longer open the paste window                                                                               ▕
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
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[:q]]), 2),
        h.with_pause_seconds_before(h.send_without_newline([[

2{v5k
]])),
        h.with_pause_seconds_before(
          h.send_without_newline([[
:yank
]]),
          2
        ),
        h.with_pause_seconds_before(
          h.send_without_newline([[
:='yank to " did not open the paste window'
]]),
          1
        ),

        h.with_pause_seconds_before(
          h.send_without_newline([[
:=vim.fn.getreg('"')
]]),
          2
        ),
        h.with_pause_seconds_before(h.send_without_newline(), 4),
      }),
      {
        stdout = h.with_status_win(
          [[
$ banner
        _     _ _____ _______ _______ __   __     _______ _______  ______  _____                ______  _______ _______ _     _   __   _ _    _ _____ _______
        |____/    |      |       |      \_/   ___ |______ |       |_____/ |     | |      |      |_____] |_____| |       |____/    | \  |  \  /    |   |  |  |
        |    \_ __|__    |       |       |        ______| |_____  |    \_ |_____| |_____ |_____ |_____] |     | |_____  |    \_ . |  \_|   \/   __|__ |  |  |
                                                       
$ ksb_tree                                            
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
                                                                                                                                                                 
:='yank to " did not open the paste window'
yank to " did not open the paste window
:=vim.fn.getreg('"')
        _     _ _____ _______ _______ __   __     _______ _______  ______  _____                ______  _______ _______ _     _   __   _ _    _ _____ _______
        |____/    |      |       |      \_/   ___ |______ |       |_____/ |     | |      |      |_____] |_____| |       |____/    | \  |  \  /    |   |  |  |
        |    \_ __|__    |       |       |        ______| |_____  |    \_ |_____| |_____ |_____ |_____] |     | |_____  |    \_ . |  \_|   \/   __|__ |  |  |


Press ENTER or type command to continue
]],
          168
        ),
        cursor_y = 30,
        cursor_x = 40,
      }
    )
  end)

  it('ksb_example_paste_win_register', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_paste_win_register',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), 2),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_paste_win_register 
paste_window yank_register is set to *
change the default register from " to *

yanks to * register open the paste window
yanks to " perform normal Neovim behavior
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
N▏# example > --config ksb_example_paste_win_register                                                                                                           ▕
\▏# paste_window yank_register is set to *                                                                                                                      ▕
\▏# change the default register from " to *                                                                                                                     ▕
\▏#                                                                                                                                                             ▕
\▏# yanks to * register open the paste window                                                                                                                   ▕
\▏# yanks to " perform normal Neovim behavior                                                                                                                   ▕
\▏#                                                                                                                                                             ▕
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
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[:q]]), 2),
        h.with_pause_seconds_before(h.send_without_newline([[

2{v5k
]])),
        h.with_pause_seconds_before([[:yank *]], 2),
        h.with_pause_seconds_before([[Gzz]], 1),

        h.with_pause_seconds_before(
          h.send_without_newline([[
:=vim.fn.getreg('*')
]]),
          2
        ),
        h.with_pause_seconds_before(h.send_without_newline(), 4),
      }),
      {
        stdout = h.with_status_win(
          [[
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
                                                                                                                                                                 
$ colortest                                                                                                                                                      
NORMAL bold  dim   itali under rever strik  BRIGHT bold  dim   itali under rever strik                                                                           
\🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
\▏                                                                                                                                                              ▕
\▏        _     _ _____ _______ _______ __   __     _______ _______  ______  _____                ______  _______ _______ _     _   __   _ _    _ _____ _______ ▕
\▏        |____/    |      |       |      \_/   ___ |______ |       |_____/ |     | |      |      |_____] |_____| |       |____/    | \  |  \  /    |   |  |  | ▕
\▏        |    \_ __|__    |       |       |        ______| |_____  |    \_ |_____| |_____ |_____ |_____] |     | |_____  |    \_ . |  \_|   \/   __|__ |  |  | ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
                                                                                                                                                                 
:=vim.fn.getreg('*')
        _     _ _____ _______ _______ __   __     _______ _______  ______  _____                ______  _______ _______ _     _   __   _ _    _ _____ _______
        |____/    |      |       |      \_/   ___ |______ |       |_____/ |     | |      |      |_____] |_____| |       |____/    | \  |  \  /    |   |  |  |
        |    \_ __|__    |       |       |        ______| |_____  |    \_ |_____| |_____ |_____ |_____] |     | |_____  |    \_ . |  \_|   \/   __|__ |  |  |


Press ENTER or type command to continue
]],
          168
        ),
        cursor_y = 30,
        cursor_x = 40,
      }
    )
  end)

  it('ksb_example_paste_win_winblend', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_paste_win_winblend',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), 2),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_paste_win_winblend 
paste_window winblend set to 50
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
N▏#Mexample >d--configlksb_example_paste_win_winblendld  dim   itali under rever strik                                                                          ▕
\▏#3paste_window2winblend\setmtoe50m \e[9m  \e[90m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m                                                                          ▕
\▏#31m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[91m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m                                                                          ▕
\▏[32m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[92m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m                                                                          ▕
\▏[33m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[93m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m                                                                          ▕
\▏[34m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[94m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m                                                                          ▕
\▏[35m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[95m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m                                                                          ▕
\▏[36m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[96m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m                                                                          ▕
\▏[37m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m  \e[97m \e[1m \e[2m \e[3m \e[4m \e[7m \e[9m                                                                          ▕
T▏UECOLOR                                                                                                                                                       ▕
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
  end)

  it('ksb_example_paste_win_winopts', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_paste_win_winopts',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), 2),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_paste_win_winopts 
Customized paste winopts with maximized window and winblend
]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
      }),
      {
        stdout = [[
         _____          ..-~             ~-..-~
 # example > --config~ksb_example_paste_win_winopts/                                                                                                             
 # Customized-paste\winopts with maximized window_and winblend                                                                                                   
 #    .'  O    \     /               /       \  "                                                                                                                
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
                                                                                                                                                                 
$ colortest                                                                                                                                                      
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
$                                                                                                                                                                
┌──────────────────────────────────────────────────────────────────── kitty-scrollback.nvim ────────────────────────────────────────────────────────────────────┐
│          \y Yank                <C-CR> Execute                <S-CR> Paste                  :w Paste                g? Toggle Mappings                        │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
]],
        cursor_y = 2,
        cursor_x = 2,
      }
    )
  end)

  it('ksb_example_restore_opts', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_restore_opts',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), 2),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_restore_opts 
restore_options is true, original values of overridden options have been restored. For example, line numbers
]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
      }),
      {
        stdout = h.with_status_win(
          [[
 38        ---------   \__/                        \__/
 39       .'  O    \     /               /       \  "                                                                                                            
 40      (_____,    `._.'               |         }  \/~~~/                                                                                                      
 41       `----.          /       }     |        /    \__/                                                                                                       
 42             `-.      |       /      |       /      `. ,~~|                                                                                                   
 43                 ~-.__|      /_ - ~ ^|      /- _      `..-'                                                                                                   
 44                      |     /        |     /     ~-.     `-. _  _  _                                                                                          
 45                      |_____|        |_____|         ~ - . _ _ _ _ _>                                                                                         
 46 $ lolbanner                                                                                                                                                  
 47         _     _ _____ _______ _______ __   __     _______ _______  ______  _____                ______  _______ _______ _     _   __   _ _    _ _____ _______
 48         |____/    |      |       |      \_/   ___ |______ |       |_____/ |     | |      |      |_____] |_____| |       |____/    | \  |  \  /    |   |  |  |
 49         |    \_ __|__    |       |       |        ______| |_____  |    \_ |_____| |_____ |_____ |_____] |     | |_____  |    \_ . |  \_|   \/   __|__ |  |  |
 50                                                                                                                                                              
 51 $ colortest                                                                                                                                                  
 52 NORMAL bold  dim   itali under rever strik  BRIGHT bold  dim   itali under rever strik                                                                       
 🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
 ▏  1 # example > --config ksb_example_restore_opts                                                                                                             ▕
 ▏  2 # restore_options is true, original values of overridden options have been restored. For example, line numbers                                            ▕
 ▏  3 #                                                                                                                                                         ▕
 ▏~                                                                                                                                                             ▕
 ▏~                                                                                                                                                             ▕
 ▏~                                                                                                                                                             ▕
 ▏~                                                                                                                                                             ▕
 ▏~                                                                                                                                                             ▕
 ▏~                                                                                                                                                             ▕
 ▏~                                                                                                                                                             ▕
 ▏                                                                                                                                                              ▕
 ▏         \y Yank               <C-CR> Execute               <S-CR> Paste                :w Paste               g? Toggle Mappings                             ▕
t🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿
                                                                                                                                               1,1           All
]],
          168
        ),
        cursor_y = 17,
        cursor_x = 7,
      }
    )
  end)

  it('ksb_example_status_win_disabled', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_status_win_disabled',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), 2),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_status_win_disabled 
status_window is disabled, notice no status window is displayed in the top right of the screen
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
N▏# example > --config ksb_example_status_win_disabled                                                                                                          ▕
\▏# status_window is disabled, notice no status window is displayed in the top right of the screen                                                              ▕
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
  end)

  it('ksb_example_env_nvim_appname', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--no-nvim-args',
      '--env',
      'NVIM_APPNAME=ksb-nvim',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), 2),
        h.send_without_newline(h.send_as_string([[
# example > --no-nvim-args --env NVIM_APPNAME=ksb-nvim
NVIM_APPNAME is set to ksb-nvim
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
N▏# example > --no-nvim-args --env NVIM_APPNAME=ksb-nvim                                                                                                        ▕
\▏# NVIM_APPNAME is set to ksb-nvim                                                                                                                             ▕
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
    h.assert_screen_equals(
      h.feed_kitty({
        h.send_as_string([[:=vim.fn.stdpath('config')]]),
        h.with_pause_seconds_before(h.send_without_newline(h.enter()), 2),
        h.with_pause_seconds_before(
          h.send_without_newline((h.send_as_string([[:=vim.env.NVIM_APPNAME]]))),
          2
        ),
        h.send_without_newline(h.enter()),
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
N▏# example > --no-nvim-args --env NVIM_APPNAME=ksb-nvim                                                                                                        ▕
\▏# NVIM_APPNAME is set to ksb-nvim                                                                                                                             ▕
\▏#                                                                                                                                                             ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
T▏                                                                                                                                                              ▕
                                                                                                                                                                 
:=vim.env.NVIM_APPNAME
ksb-nvim
Press ENTER or type command to continue
]],
          168
        ),
        cursor_y = 30,
        cursor_x = 40,
      }
    )
  end)

  it('ksb_example_nvim_args_darkblue', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--nvim-args',
      '-c',
      'colorscheme darkblue',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), 2),
        h.with_pause_seconds_before(h.send_without_newline(h.send_as_string([[
# example > --no-nvim-args -c 'colorscheme darkblue'
Yo, listen up here's a story
About a little guy
That lives in a blue world
And all day and all night
And everything he sees is just blue
Like him inside and outside
]]))),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
        h.send_as_string([[:colorscheme]]),
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
N▏# example > --no-nvim-args -c 'colorscheme darkblue'                                                                                                          ▕
\▏# Yo, listen up here's a story                                                                                                                                ▕
\▏# About a little guy                                                                                                                                          ▕
\▏# That lives in a blue world                                                                                                                                  ▕
\▏# And all day and all night                                                                                                                                   ▕
\▏# And everything he sees is just blue                                                                                                                         ▕
\▏# Like him inside and outside                                                                                                                                 ▕
\▏#                                                                                                                                                             ▕
\▏                                                                                                                                                              ▕
T▏                                                                                                                                                              ▕
                                                                                                                                                                 
:colorscheme                                                                                                                                                     
darkblue                                                                                                                                                         
Press ENTER or type command to continue                                                                                                                          
]],
          168
        ),
        cursor_y = 30,
        cursor_x = 40,
      }
    )
  end)

  it('ksb_builtin_checkhealth', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_builtin_checkhealth',
    })
    h.assert_screen_match(h.feed_kitty(), {
      pattern = [[
kitty%-scrollback:.*require%("kitty%-scrollback.health"%).check%(%)
.*kitty%-scrollback: Neovim version.*
.*%- OK NVIM.*
]],

      cursor_y = 1,
      cursor_x = 1,
    })
  end)

  after_all()
end)
