---@mod kitty-scrollback.api
local ksb_footer_win = require('kitty-scrollback.footer_win')
local ksb_kitty_cmds = require('kitty-scrollback.kitty_commands')
local ksb_util = require('kitty-scrollback.util')

---@type KsbPrivate
local p

---@type KsbOpts
local opts ---@diagnostic disable-line: unused-local

local M = {}

M.setup = function(private, options)
  p = private
  opts = options ---@diagnostic disable-line: unused-local
end

---Attempt to force quit Neovim. How do you exit vim? Why would you exit vim?
M.quit_all = function()
  ksb_util.quitall()
end

---If the current buffer is the paste buffer, then close the window
---If the current buffer is the scrollback buffer, then quitall
---Otherwise, no operation
M.close_or_quit_all = function()
  if vim.api.nvim_get_current_buf() == p.bufid then
    M.quit_all()
    return
  end
  if vim.api.nvim_get_current_buf() == p.paste_bufid then
    vim.cmd.close({ bang = true })
    return
  end
end

---If the current buffer is the paste buffer, then quit and execute the paste
---window contents in Kitty. Otherwise, no operation
M.execute_command = function()
  if vim.api.nvim_get_current_buf() == p.paste_bufid then
    ksb_kitty_cmds.send_paste_buffer_text_to_kitty_and_quit(true)
  end
end

---If the current buffer is the paste buffer, then quit and paste the paste
---window contents to Kitty. Otherwise, no operation
M.paste_command = function()
  if vim.api.nvim_get_current_buf() == p.paste_bufid then
    ksb_kitty_cmds.send_paste_buffer_text_to_kitty_and_quit(false)
  end
end

M.paste_visual_command = function()
  local visual_selection_lines = ksb_util.clear_yank_autocommand_and_get_visual_selection()
  ksb_kitty_cmds.send_lines_to_kitty_and_quit(visual_selection_lines, false)
end

M.execute_visual_command = function()
  local visual_selection_lines = ksb_util.clear_yank_autocommand_and_get_visual_selection()
  ksb_kitty_cmds.send_lines_to_kitty_and_quit(visual_selection_lines, true)
end

---If the current buffer is the paste buffer, toggle the footer window
---open or closed. Otherwise, no operation
M.toggle_footer = function()
  if vim.api.nvim_get_current_buf() == p.paste_bufid then
    if p.footer_winid then
      pcall(vim.api.nvim_win_close, p.footer_winid, true)
      p.footer_winid = nil
    else
      local winopts = vim.api.nvim_win_get_config(p.paste_winid)
      vim.schedule_wrap(ksb_footer_win.open_footer_window)(winopts)
    end
    vim.schedule_wrap(vim.cmd.doautocmd)('WinResized')
    return
  end
end

---@alias KsbGenKittenModes string | 'maps' | 'commands'

---Generate Kitten commands used as reference for configuring `kitty.conf`
---@param generate_modes table<KsbGenKittenModes>|nil
M.generate_kittens = function(generate_modes)
  generate_modes = (generate_modes and next(generate_modes)) and generate_modes or { 'maps' }
  local target_gen_modes = {}
  for _, gen_mode in pairs(generate_modes) do
    target_gen_modes[gen_mode] = true
  end

  local kitty_scrollback_kitten = vim.fn.fnamemodify(
    vim.api.nvim_get_runtime_file('python/kitty_scrollback_nvim.py', false)[1],
    ':p'
  )

  local action_alias = 'kitty_scrollback_nvim'
  local alias_config = {
    '# kitty-scrollback.nvim Kitten alias',
    'action_alias ' .. action_alias .. ' kitten ' .. kitty_scrollback_kitten,
    '',
  }
  local alias_config_quoted = ([[action_alias %s kitten '%s']]):format(
    action_alias,
    kitty_scrollback_kitten
  )

  local alias_warn = {}
  if kitty_scrollback_kitten:find('%s') then
    alias_warn = {
      [[# WARNING]],
      [[#  ']] .. kitty_scrollback_kitten .. [[' contains whitespace.]],
      [[#]],
      [[#  If you are using Kitty version 0.39.0 or greater, then whitespace is allowed in the]],
      [[#  path and you can ignore this warning. Just make sure that the kitten path is]],
      [[#  wrapped in quotes. For example,]],
      [[#]],
      [[#    ]] .. alias_config_quoted,
      [[#]],
      [[#  If you are using Kitty version 0.38.1 or less, then you may receive an error opening]],
      [[#  kitty-scrollback.nvim. If an error occurs, you can workaround this issue by symlinking]],
      [[#  the kitty-scrollback.nvim plugin directory to Kitty's configuration directory with]],
      [[#  the command:]],
      [[#]],
      [[#    ln -s ']]
        .. vim.fn.fnamemodify(kitty_scrollback_kitten, ':h:h')
        .. [[' ~/.config/kitty/kitty-scrollback.nvim]],
      [[#]],
      [[#  Then use the symlinked directory as the action_alias in kitty.conf instead of the real path]],
      [[#]],
      [[#    action_alias kitty_scrollback_nvim kitten kitty-scrollback.nvim/python/kitty_scrollback_nvim.py]],
      [[#]],
      [[#  Also, if you are using any kitty @ kitten commands update them to use the symlink path:]],
      [[#]],
      [[#    kitty kitten kitty-scrollback.nvim/python/kitty_scrollback_nvim.py]],
      [[#]],
      [[]],
    }
  end

  local builtin_map_configs = {
    '# Browse scrollback buffer in nvim',
    'map kitty_mod+h ' .. action_alias,
    '# Browse output of the last shell command in nvim',
    'map kitty_mod+g ' .. action_alias .. ' --config ksb_builtin_last_cmd_output',
    '# Show clicked command output in nvim',
    'mouse_map ctrl+shift+right press ungrabbed combine : mouse_select_command_output : '
      .. action_alias
      .. ' --config ksb_builtin_last_visited_cmd_output',
  }

  local builtin_command_configs = vim.tbl_map(function(config)
    return config:gsub(
      '^.*map%s%S+.*kitty_scrollback_nvim',
      'kitty @ kitten ' .. kitty_scrollback_kitten
    )
  end, builtin_map_configs)
  table.insert(builtin_command_configs, '')

  local builtin_tmux_configs = {
    '# Browse tmux pane in nvim',
    [[bind [ run-shell 'kitty @ kitten ]]
      .. kitty_scrollback_kitten
      .. [[ --env "TMUX=$TMUX" --env "TMUX_PANE=#{pane_id}"']],
    '',
  }

  local configs = {}
  vim.list_extend(configs, alias_warn)

  local filetype
  if target_gen_modes['maps'] then
    vim.list_extend(configs, alias_config)
    vim.list_extend(configs, builtin_map_configs)
    table.insert(configs, '')
    filetype = 'kitty'
  end
  if target_gen_modes['commands'] then
    vim.list_extend(configs, builtin_command_configs)
    filetype = 'sh'
  end
  if target_gen_modes['tmux'] then
    vim.list_extend(configs, builtin_tmux_configs)
    filetype = 'tmux'
  end
  if #vim.tbl_values(target_gen_modes) > 1 then
    filetype = nil
  end

  local bufid = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_set_option_value('filetype', filetype or '', {
    buf = bufid,
  })
  vim.api.nvim_set_current_buf(bufid)
  vim.api.nvim_buf_set_lines(bufid, 0, -1, false, configs)

  if #vim.api.nvim_list_uis() == 0 then -- if nvim is running in headless mode
    for _, line in pairs(configs) do
      vim.print(line)
    end
    M.quit_all()
  end
end

M.generate_command_line_editing = function(shell)
  shell = (shell and next(shell)) and shell[1] or 'undefined'
  local kitty_scrollback_edit_command_line = vim.fn.fnamemodify(
    vim.api.nvim_get_runtime_file('scripts/edit_command_line.sh', false)[1],
    ':p'
  )
  local kitty_scrollback_edit_command_line_bash = vim.fn.fnamemodify(
    vim.api.nvim_get_runtime_file('scripts/edit_command_line.bash', false)[1],
    ':p'
  )

  local configs = {
    bash = {
      [[# add the following environment variables to your bash config (e.g., ~/.bashrc)]],
      [[# the editor defined in KITTY_SCROLLBACK_VISUAL will be used in place of VISUAL]],
      [[# for other scenarios that are not editing the command-line. For example, C-xC-e]],
      [[# will edit the current command-line in kitty-scrollback.nvim and pressing v in]],
      [[# less will open the file in $KITTY_SCROLLBACK_VISUAL (defaults to nvim if not]],
      [[# defined)]],
      [[export KITTY_SCROLLBACK_VISUAL='nvim']],
      [[export VISUAL=']] .. kitty_scrollback_edit_command_line_bash .. [[']],
      [[# [optional] pass arguments to kitty-scrollback.nvim in command-line editing mode]],
      [[# by using the environment variable KITTY_SCROLLBACK_NVIM_EDIT_ARGS]],
      [[# export KITTY_SCROLLBACK_NVIM_EDIT_ARGS='']],
      [[]],
      [[# [optional] customize your readline config (e.g., ~/.inputrc) ]],
      [[# default mapping in vi mode]],
      [[set keymap vi-command]],
      [["v": vi-edit-and-execute-command]],
      [[]],
      [[# default mapping in emacs mode]],
      [[set keymap emacs]],
      [["\C-x\C-e": edit-and-execute-command]],
      [[]],
    },
    fish = {
      [[# add the following function and bindings to your fish config]],
      [[# e.g., ~/.config/fish/conf.d/kitty_scrollback_nvim.fish or ~/.config/fish/config.fish]],
      [[]],
      [[function kitty_scrollback_edit_command_buffer]],
      [[  set --local --export VISUAL ']] .. kitty_scrollback_edit_command_line .. [[']],
      [[  edit_command_buffer]],
      [[  commandline '']],
      [[end]],
      [[]],
      [[bind --mode default \ee kitty_scrollback_edit_command_buffer]],
      [[bind --mode default \ev kitty_scrollback_edit_command_buffer]],
      [[]],
      [[bind --mode visual \ee kitty_scrollback_edit_command_buffer]],
      [[bind --mode visual \ev kitty_scrollback_edit_command_buffer]],
      [[]],
      [[bind --mode insert \ee kitty_scrollback_edit_command_buffer]],
      [[bind --mode insert \ev kitty_scrollback_edit_command_buffer]],
      [[]],
      [[# [optional] pass arguments to kitty-scrollback.nvim in command-line editing mode]],
      [[# by using the environment variable KITTY_SCROLLBACK_NVIM_EDIT_ARGS]],
      [[# set --global --export KITTY_SCROLLBACK_NVIM_EDIT_ARGS '']],
      [[]],
    },
    zsh = {
      [[# IMPORTANT: kitty-scrollback.nvim only supports zsh 5.9 or greater for command-line editing,]],
      [[# please check your version by running: zsh --version]],
      [[]],
      [[# add the following environment variables to your zsh config (e.g., ~/.zshrc)]],
      [[]],
      [[autoload -Uz edit-command-line]],
      [[zle -N edit-command-line]],
      [[]],
      [[function kitty_scrollback_edit_command_line() { ]],
      [[  local VISUAL=']] .. kitty_scrollback_edit_command_line .. [[']],
      [[  zle edit-command-line]],
      [[  zle kill-whole-line]],
      [[}]],
      [[zle -N kitty_scrollback_edit_command_line]],
      [[]],
      [[bindkey '^x^e' kitty_scrollback_edit_command_line]],
      [[]],
      [[# [optional] pass arguments to kitty-scrollback.nvim in command-line editing mode]],
      [[# by using the environment variable KITTY_SCROLLBACK_NVIM_EDIT_ARGS]],
      [[# export KITTY_SCROLLBACK_NVIM_EDIT_ARGS='']],
      [[]],
    },
  }

  ---@type table|string
  local config = configs[shell]
  if not config then
    vim.notify('no config found for: ' .. shell, vim.log.levels.ERROR, {})
    return
  end

  local bufid = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_set_option_value('filetype', shell or '', {
    buf = bufid,
  })
  vim.api.nvim_set_current_buf(bufid)
  vim.api.nvim_buf_set_lines(bufid, 0, -1, false, config)

  if #vim.api.nvim_list_uis() == 0 then -- if nvim is running in headless mode
    for _, line in pairs(config) do
      vim.print(line)
    end
    M.quit_all()
  end
end

M.checkhealth = function()
  local kitty_scrollback_kitten = vim.fn.fnamemodify(
    vim.api.nvim_get_runtime_file('python/kitty_scrollback_nvim.py', false)[1],
    ':p'
  )
  -- NOTE(#58): nvim v0.9 support
  -- setup backports for v0.9 because checkhealth can be called outside of standard setup flow
  if vim.fn.has('nvim-0.10') <= 0 then
    require('kitty-scrollback.backport').setup()
  end
  if vim.fn.has('nvim-0.9') > 0 then
    vim
      .system({
        -- fallback to 'kitty' because checkhealth can be called outside of standard setup flow
        (p and p.kitty_data and p.kitty_data.kitty_path) and p.kitty_data.kitty_path or 'kitty',
        '@',
        'kitten',
        '--match=recent:0',
        kitty_scrollback_kitten,
        '--config',
        'ksb_builtin_checkhealth',
      })
      :wait()
  else
    -- fallback on checkhealth for earlier versions of nvim
    vim.cmd.checkhealth('kitty-scrollback')
  end
end

--- Try to close Kitty loading window
--- If the first attempt to close fails, then list all Kitty windows to see if window exists
--- If the window does exist, then reattempt to close the window and report error on failure
M.close_kitty_loading_window = function()
  local winid = p.kitty_loading_winid
  local close_ok, close_result = ksb_kitty_cmds.close_kitty_loading_window(true)
  if not close_ok then
    if
      close_result
      and close_result.stderr
      and close_result.stderr:match('.*No matching windows.*')
    then
      local ok, kitty_windows_result = ksb_kitty_cmds.list_kitty_windows()
      if not ok then
        return
      end
      local kitty_windows = vim.json.decode(kitty_windows_result.stdout)
      for _, kitty_window in pairs(kitty_windows) do
        for _, tab in pairs(kitty_window.tabs) do
          for _, window in pairs(tab.windows) do
            for env_name, env_value in pairs(window.env) do
              if env_name == 'KITTY_WINDOW_ID' and tonumber(env_value) == winid then
                -- the close error is valid, attempt one more time to properly display error to user
                vim.defer_fn(ksb_kitty_cmds.close_kitty_loading_window, 500)
              end
            end
          end
        end
      end
    end
  end
end

--- Try to get Kitty terminal colors
--- If the first attempt fails for the given window id, then reattempt without a window id
---@param kitty_data KsbKittyData
---@return boolean, vim.SystemCompleted
M.get_kitty_colors = function(kitty_data)
  local colors_ok, colors_result = ksb_kitty_cmds.get_kitty_colors(kitty_data, true)
  if not colors_ok then
    if
      colors_result
      and colors_result.stderr
      and colors_result.stderr:match('.*No matching windows.*')
    then
      -- do not specify a window id
      return ksb_kitty_cmds.get_kitty_colors(kitty_data, false, true)
    end
  end
  return colors_ok, colors_result
end

return M
