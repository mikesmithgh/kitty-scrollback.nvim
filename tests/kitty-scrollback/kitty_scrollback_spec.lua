---@diagnostic disable: undefined-global
if vim.fn.has('nvim-0.10') <= 0 then
  vim.opt.runtimepath:append('/Users/mike/gitrepos/kitty-scrollback.nvim')
  require('kitty-scrollback.backport').setup()
end

local tmpdir = vim.system({ 'mktemp', '-d' }):wait().stdout:gsub('\n', '')
local tmpsock = tmpdir .. '/kitty-scrollback-nvim.sock'
local now = vim.fn.strftime('%m-%d-%Y %H:%M:%S', vim.fn.localtime())

local kitty_cmd = {
  'kitty',
  '--listen-on=unix:' .. tmpsock,
  '--override',
  'enabled_layouts=fat:bias=90',
  '--override',
  'initial_window_width=2000',
  '--override',
  'initial_window_height=800',
  '--override',
  'env=PROMPT_COMMAND=',
  '--override',
  [==[env=PS1=\[\e[34m\]\s-\v \[\e[36m\]\$ \[\e[m\]]==],
  '--override',
  'shell=/opt/homebrew/bin/bash --login --noprofile',
}

local function kitty_remote_cmd()
  return { 'kitty', '@', '--to', 'unix:' .. tmpsock }
end

local function kitty_remote_get_text_cmd(args)
  return vim.list_extend(kitty_remote_cmd(), vim.list_extend({ 'get-text' }, args or {}))
end

local function kitty_remote_get_text(args, ...)
  return vim.system(kitty_remote_get_text_cmd(args or {}), ...):wait()
end

local function kitty_remote_send_text_cmd(txt)
  return vim.list_extend(kitty_remote_cmd(), { 'send-text', txt })
end

local function kitty_remote_send_text(txt, ...)
  return vim.system(kitty_remote_send_text_cmd(txt), ...):wait()
end

local function kitty_remote_set_title_cmd(title)
  return vim.list_extend(kitty_remote_cmd(), { 'set-window-title', title })
end

local function kitty_remote_set_title(title, ...)
  return vim.system(kitty_remote_set_title_cmd(title), ...)
end

local function kitty_remote_close_window_cmd()
  return vim.list_extend(kitty_remote_cmd(), { 'close-window' })
end

local function kitty_remote_close_window()
  return vim.system(kitty_remote_close_window_cmd()):wait()
end

local function kitty_remote_ls_cmd()
  return vim.list_extend(kitty_remote_cmd(), { 'ls' })
end

local function kitty_remote_ls()
  return vim.system(kitty_remote_ls_cmd())
end

local function kitty_remote_kitten_cmd()
  return vim.list_extend(kitty_remote_cmd(), { 'kitten' })
end

local function kitty_remote_kitten_kitty_scrollback_nvim_cmd(ksb_args)
  local kitten_args = vim.list_extend(
    { '/Users/mike/gitrepos/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py' },
    ksb_args or {}
  )
  return vim.list_extend(kitty_remote_kitten_cmd(), kitten_args)
end

local function kitty_remote_kitten_kitty_scrollback_nvim(ksb_args, ...)
  return vim.system(kitty_remote_kitten_kitty_scrollback_nvim_cmd(ksb_args), ...)
end

local function kitty_remote_kitten_kitty_scroll_prompt_cmd(direction, select_cmd_output)
  local kitten_args = {
    '/Users/mike/gitrepos/kitty-scrollback.nvim/python/kitty_scroll_prompt.py',
    direction or 0,
  }
  if select_cmd_output then
    table.insert(kitten_args, 'true')
  end
  return vim.list_extend(kitty_remote_kitten_cmd(), kitten_args)
end

local function kitty_remote_kitten_kitty_scroll_prompt(direction, select_cmd_output, ...)
  return vim.system(kitty_remote_kitten_kitty_scroll_prompt_cmd(direction, select_cmd_output), ...)
end

local function pause(delay)
  vim.uv.sleep((delay or 0.5) * 1000)
end

local function kitty_remote_kitten_kitty_scroll_prompt_and_pause(direction, select_cmd_output, ...)
  local result = vim
    .system(kitty_remote_kitten_kitty_scroll_prompt_cmd(direction, select_cmd_output), ...)
    :wait()
  pause(1)
  return result
end

local function move_forward_one_prompt()
  kitty_remote_kitten_kitty_scroll_prompt_and_pause(1)
end

local function move_backward_one_prompt()
  kitty_remote_kitten_kitty_scroll_prompt_and_pause(-1)
end

local function move_to_first_prompt()
  kitty_remote_kitten_kitty_scroll_prompt_and_pause(0)
  kitty_remote_kitten_kitty_scroll_prompt_and_pause(-3)
end

local function move_to_last_prompt()
  kitty_remote_kitten_kitty_scroll_prompt_and_pause(0)
  kitty_remote_kitten_kitty_scroll_prompt_and_pause(3)
end

local function ksb(config_type, ksb_args, opts)
  local o = opts or {}
  kitty_remote_kitten_kitty_scrollback_nvim(ksb_args)
  pause(o.before)
  if o.show_text == nil or o.show_text then
    kitty_remote_send_text([[a]])
    pause()
    kitty_remote_send_text(
      [[# ]] .. config_type .. [[ > kitty_scrollback_nvim ]] .. vim.fn.join(ksb_args or {}, ' ')
    )
    kitty_remote_send_text([[\e0]])
  end
  pause()
  if o.msg then
    pause()
    kitty_remote_send_text([[o]])
    pause()
    kitty_remote_send_text(o.msg)
    kitty_remote_send_text([[\egg0]])
  end
  pause(o.after or 4)
  if not o.keep_open then
    kitty_remote_close_window()
  end
  pause()
end

local function ksb_b(...)
  ksb('builtin', ...)
end

local function ksb_e(...)
  ksb('example', ...)
end

local function ksb_builtin_last_visited_cmd_output_and_move_forward()
  ksb_b({ '--config', 'ksb_builtin_last_visited_cmd_output' }, {
    msg = [[
default configuration for the mousemap `ctrl+shift+right`

Show clicked command output in kitty-scrollback.nvim
]],
  })
  move_forward_one_prompt()
end

local function ksb_example_last_visited_cmd_output_plain_and_move_forward()
  ksb_b(
    { '--config', 'ksb_example_get_text_last_visited_cmd_output_plain' },
    { msg = [[
Show clicked command plaintext output in kitty-scrollback.nvim
]] }
  )
  move_forward_one_prompt()
end

-- local ksb = require('kitty-scrollback')

describe('setup', function()
  -- it('test 1', function()
  --   assert(false, 'expected to fail')
  -- end)
  -- it('test 2', function()
  --   assert(nil, 'expected to fail')
  -- end)
  it('test 3', function()
    assert(true, 'expected to pass')
  end)
  it('test 4', function()
    assert(true, 'expected to pass')
  end)
  it('does something', function()
    local kitty_instance = vim.system(kitty_cmd)
    print(('starting kitty with pid %s on socket %s...'):format(kitty_instance.pid, tmpsock))

    local ready = false
    vim.fn.wait(5000, function()
      ready = (kitty_remote_ls():wait().code == 0)
      return ready
    end)

    if not ready then
      vim.notify('kitty is not ready for remote connections, exiting', vim.log.levels.ERROR)
      os.exit(1)
    end
    vim.notify('kitty is ready for remote connections', vim.log.levels.INFO)

    pause(3) -- wait for PS1 prompt

    kitty_remote_send_text([[
cd /Users/mike/gitrepos/kitty-scrollback.nvim
]])

    kitty_remote_send_text('clear\n')
    pause(2)

    -- start_screencapture('kitty_scrollback_nvim')

    local demo_text = {
      [[git status]],
      [[\n]], -- enter
      [[__open_ksb]],
      [[?README.md]],
      [[\n]], -- enter
    }
    for _, line in pairs(demo_text) do
      if line == 'pause' then
        pause()
      elseif line == '__open_ksb' then
        pause()
        kitty_remote_kitten_kitty_scrollback_nvim()
        pause()
      elseif line:match('^\\') then
        pause(0.2)
        kitty_remote_send_text(line)
        pause(0.2)
      else
        line:gsub('.', function(c)
          kitty_remote_send_text(c)
          pause(0.03)
        end)
      end
    end

    pause(3)
    local buffer = kitty_remote_get_text()
    local out = {}
    for s in buffer.stdout:gmatch('[^\r\n]+') do
      table.insert(out, s)
      vim.print(#out .. ' | ' .. s)
    end
    local expected = [[
-bash-5.2 $ git status                                                                                                                                         󰄛 󰣐 
On branch tabline_offset
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   lua/kitty-scrollback/api.lua
        modified:   lua/kitty-scrollback/health.lua
        modified:   lua/kitty-scrollback/init.lua
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   README.md
        modified:   lua/kitty-scrollback/api.lua
        modified:   lua/kitty-scrollback/health.lua
        modified:   lua/kitty-scrollback/init.lua
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        Makefile
        tests/

    ]]

    assert(buffer.stdout == expected, 'should pass')

    -- kitty_instance:kill(2)

    -- assert(true, 'expected to pass')
  end)
end)
