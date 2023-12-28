local h = require('tests.kitty-scrollback.helpers')

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

local function before_all()
  vim.fn.mkdir(ksb_dir .. 'tests/workdir', 'p')
  kitty_instance = vim.system(kitty_cmd, {
    stdin = 'cd ' .. ksb_dir,
  })
  local ready = false
  vim.fn.wait(5000, function()
    ready = (h.debug(h.kitty_remote_ls():wait()).code == 0)
    return ready
  end, 500)

  assert.is_true(ready, 'kitty is not ready for remote connections, exiting')
  h.pause_seconds()

  local ksb_work_dir = os.getenv('KITTY_SCROLLBACK_NVIM_DIR') or 'tmp/kitty-scrollback.nvim'
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
end

describe('kitty-scrollback.nvim', function()
  before_all()

  before_each(h.pause_seconds)

  it('ksb_example_highlight_overrides', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_highlight_overrides',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]])),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_highlight_overrides 
Custom KittyScrollbackNvim highlight overrides
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
N▏# example > --config ksb_example_highlight_overrides                                                                                                          ▕
\▏# Custom KittyScrollbackNvim highlight overrides                                                                                                              ▕
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
        h.send_without_newline([[VG]]),
        h.with_pause_seconds_before(h.send_without_newline(h.esc())),
        h.with_pause_seconds_before(h.send_without_newline(h.esc())),
        h.send_without_newline([[V15k]]),
        h.send_without_newline(h.with_pause_seconds_before(nil, 2)),
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
$                                                                                                                                                                
$                                                                                                                                                                
$                                                                                                                                                      
]],
          168
        ),
        cursor_y = 15,
        cursor_x = 3,
      }
    )
    h.kitty_remote_close_window()
  end)

  it('ksb_example_visual_selection_highlight_mode_reverse', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_visual_selection_highlight_mode_reverse',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]])),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_visual_selection_highlight_mode_reverse 
ksb_example_visual_selection_highlight_mode is set to 'reverse'
visual selection in scrollback buffer window is reversed
visual selection in other windows is the same as hl-Visual
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
N▏# example > --config ksb_example_visual_selection_highlight_mode_reverse                                                                                      ▕
\▏# ksb_example_visual_selection_highlight_mode is set to 'reverse'                                                                                             ▕
\▏# visual selection in scrollback buffer window is reversed                                                                                                    ▕
\▏# visual selection in other windows is the same as hl-Visual                                                                                                  ▕
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
        h.send_without_newline([[VG]]),
        h.with_pause_seconds_before(h.send_without_newline(h.esc())),
        h.with_pause_seconds_before(h.send_without_newline(h.esc())),
        h.send_without_newline([[V15k]]),
        h.send_without_newline(h.with_pause_seconds_before(nil, 2)),
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
$                                                                                                                                                                
$                                                                                                                                                                
$                                                                                                                                                      
]],
          168
        ),
        cursor_y = 15,
        cursor_x = 3,
      }
    )
    h.kitty_remote_close_window()
  end)

  it('ksb_example_keymaps_custom', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_keymaps_custom',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]])),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_keymaps_custom 
Custom keymap overrides
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
N▏# example > --config ksb_example_keymaps_custom                                                                                                               ▕
\▏# Custom keymap overrides                                                                                                                                     ▕
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
$▏         sy Yank               <CR> Execute               <C-V> Paste                :w Paste               <Tab> Toggle Mappings                             ▕
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

  it('ksb_example_keymaps_disabled', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_keymaps_disabled',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]])),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_keymaps_disabled 
Custom keymap overrides
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
N▏# example > --config ksb_example_keymaps_disabled                                                                                                             ▕
\▏# Custom keymap overrides                                                                                                                                     ▕
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
$▏               :w Paste                                                                                                                                       ▕
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

  it('ksb_example_paste_win_filetype', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_paste_win_filetype',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), 4),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_paste_win_filetype 
# Set a custom filetype for the paste window
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
N▏                                                                                                                                                              ▕
\▏    # example > --config ksb_example_paste_win_filetype                                                                                                       ▕
\▏    # Set a custom filetype for the paste window                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏# kitty-scrollback.nvim example                                                                                                                               ▕
\▏                                                                                                                                                              ▕
\▏## Change paste window filetype to `markdown`                                                                                                                 ▕
\▏                                                                                                                                                              ▕
T▏```lua                                                                                                                                                        ▕
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

  it('ksb_example_paste_win_hide_mappings', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_paste_win_hide_mappings',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]])),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_paste_win_hide_mappings 
paste_window hide_footer is set to true, hide paste window footer
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
N▏# example > --config ksb_example_paste_win_hide_mappings                                                                                                      ▕
\▏# paste_window hide_footer is set to true, hide paste window footer                                                                                           ▕
\▏#                                                                                                                                                             ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
\▏                                                                                                                                                              ▕
T▏                                                                                                                                                              ▕
$▏                                                                                                                                                              ▕
$▏                                                                                                                                                              ▕
$▏                                                                                                                                                              ▕
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

  it('ksb_example_paste_win_highlight_as_float', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_paste_win_highlight_as_float',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]])),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_paste_win_highlight_as_float 
paste_window highlight_as_normal_win is set to false, disable paste window highlight as normal
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
N▏# example > --config ksb_example_paste_win_highlight_as_float                                                                                                 ▕
\▏# paste_window highlight_as_normal_win is set to false, disable paste window highlight as normal                                                              ▕
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

  after_all()
end)
