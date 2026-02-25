local h = require('tests.kitty-scrollback.helpers')

local ksb_dir = h.ksb_dir()
h.debug({
  ksb_dir = ksb_dir,
  kitty_conf = ksb_dir .. 'tests/kitty.conf',
})

local tmpsock = h.tempsocket(ksb_dir .. 'tmp/')
local kitty_instance
local ksb_work_dir

local shell = h.debug(h.is_github_action and '/bin/bash' or 'bash --noprofile --norc')

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
  ksb_work_dir = os.getenv('KITTY_SCROLLBACK_NVIM_DIR') or 'tmp/02_kitty-scrollback.nvim'
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

-- TODO: seeing some flakiness in github runners, adding a delay to see if this helps
-- we may want to add conditional delays depending on if the test is running locally vs a github runner
local append_delay = 3

describe('kitty-scrollback.nvim', function()
  before_all()

  before_each(h.pause_seconds)
  after_each(h.kitty_remote_close_window)

  it('ksb_example_get_text_first_cmd_output_on_screen', function()
    h.move_to_first_prompt()

    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_get_text_first_cmd_output_on_screen',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), append_delay),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_get_text_first_cmd_output_on_screen 
first_cmd_output_on_screen means the output of the first command that was run in the window on screen
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
▏# example > --config ksb_example_get_text_first_cmd_output_on_screen                                                                                           ▕
▏# first_cmd_output_on_screen means the output of the first command that was run in the window on screen                                                        ▕
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
  end)

  it('ksb_example_get_text_first_cmd_output_on_screen_plain', function()
    h.move_to_first_prompt()

    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_get_text_first_cmd_output_on_screen_plain',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), append_delay),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_get_text_first_cmd_output_on_screen_plain 
first_cmd_output_on_screen means the output of the first command that was run in the window on screen
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
▏# example > --config ksb_example_get_text_first_cmd_output_on_screen_plain                                                                                     ▕
▏# first_cmd_output_on_screen means the output of the first command that was run in the window on screen                                                        ▕
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
  end)

  it('ksb_example_get_text_last_non_empty_output', function()
    h.move_to_last_prompt()

    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_get_text_last_non_empty_output',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), append_delay),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_get_text_last_non_empty_output 
The output from the last command run in the window that had some non empty output
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
▏# example > --config ksb_example_get_text_last_non_empty_output                                                                                                ▕
▏# The output from the last command run in the window that had some non empty output                                                                            ▕
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
  end)

  it('ksb_example_get_text_last_non_empty_output_plain', function()
    h.move_to_last_prompt()

    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_get_text_last_non_empty_output_plain',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), append_delay),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_get_text_last_non_empty_output_plain 
The output from the last command run in the window that had some non empty output
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
▏# example > --config ksb_example_get_text_last_non_empty_output_plain                                                                                          ▕
▏# The output from the last command run in the window that had some non empty output                                                                            ▕
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
  end)

  it('ksb_example_get_text_screen', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_get_text_screen',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), append_delay),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_get_text_screen 
All text currently on the screen, excluding the scrollback history
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
N▏# example > --config ksb_example_get_text_screen                                                                                                              ▕
\▏# All text currently on the screen, excluding the scrollback history                                                                                          ▕
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
  end)

  it('ksb_example_get_text_screen_plain', function()
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_get_text_screen_plain',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), append_delay),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_get_text_screen_plain 
All text currently on the screen as plaintext, excluding the scrollback history
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
N▏# example > --config ksb_example_get_text_screen_plain                                                                                                        ▕
\▏# All text currently on the screen as plaintext, excluding the scrollback history                                                                             ▕
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
  end)

  it('ksb_example_get_text_selection', function()
    h.move_to_last_prompt()
    h.move_backward_one_prompt()
    h.kitty_remote_kitten_kitty_scroll_prompt_and_pause(0, true)
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_get_text_selection',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), append_delay),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_get_text_selection 
Currently selected text
]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
      }),
      {
        stdout = h.with_status_win(
          [[
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
🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
▏# example > --config ksb_example_get_text_selection                                                                                                            ▕
▏# Currently selected text                                                                                                                                      ▕
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
        cursor_y = 17,
        cursor_x = 2,
      }
    )
  end)

  it('ksb_example_get_text_selection_plain', function()
    h.move_to_last_prompt()
    h.move_backward_one_prompt()
    h.kitty_remote_kitten_kitty_scroll_prompt_and_pause(0, true)
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_get_text_selection_plain',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), append_delay),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_get_text_selection_plain 
Currently selected text as plaintext
]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
      }),
      {
        stdout = h.with_status_win(
          [[
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
🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
▏# example > --config ksb_example_get_text_selection_plain                                                                                                      ▕
▏# Currently selected text as plaintext                                                                                                                         ▕
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
        cursor_y = 17,
        cursor_x = 2,
      }
    )
  end)

  it('ksb_example_get_text_selection_keep_selection', function()
    h.move_to_last_prompt()
    h.move_backward_one_prompt()
    h.kitty_remote_kitten_kitty_scroll_prompt_and_pause(0, true)
    h.kitty_remote_kitten_kitty_scrollback_nvim({
      '--config',
      'ksb_example_get_text_selection_keep_selection',
    })
    h.assert_screen_equals(
      h.feed_kitty({
        h.with_pause_seconds_before(h.send_without_newline([[a]]), append_delay),
        h.send_without_newline(h.send_as_string([[
# example > --config ksb_example_get_text_selection_keep_selection 
Currently selected text, keep text selected after closing kitty-scrollback.nvim
]])),
        h.send_without_newline(h.esc()),
        h.send_without_newline(h.send_as_string([[gg0]])),
      }),
      {
        stdout = h.with_status_win(
          [[
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
🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾
▏# example > --config ksb_example_get_text_selection_keep_selection                                                                                             ▕
▏# Currently selected text, keep text selected after closing kitty-scrollback.nvim                                                                              ▕
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
        cursor_y = 17,
        cursor_x = 2,
      }
    )
  end)

  after_all()
end)
