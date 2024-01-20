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
---@param all boolean|nil
---@param generate_modes table<KsbGenKittenModes>|nil
M.generate_kittens = function(all, generate_modes)
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

  local kitten_map_configs = builtin_map_configs

  local builtin_command_configs = vim.tbl_map(function(config)
    return config:gsub(
      '^.*map%s%S+.*kitty_scrollback_nvim',
      'kitty @ kitten ' .. kitty_scrollback_kitten
    )
  end, builtin_map_configs)

  local kitten_command_configs = vim.tbl_map(function(config)
    return config:gsub(
      '^.*map%s%S+.*kitty_scrollback_nvim',
      'kitty @ kitten ' .. kitty_scrollback_kitten
    )
  end, kitten_map_configs)

  local configs = {}

  -- TODO: clean this up after removing examples

  if all then
    if target_gen_modes['maps'] then
      vim.list_extend(configs, alias_config)
      vim.list_extend(configs, kitten_map_configs)
      table.insert(configs, '')
    end
    if target_gen_modes['commands'] then
      vim.list_extend(configs, kitten_command_configs)
    end
  else
    if target_gen_modes['maps'] then
      vim.list_extend(configs, alias_config)
      vim.list_extend(configs, builtin_map_configs)
      table.insert(configs, '')
    end
    if target_gen_modes['commands'] then
      vim.list_extend(configs, builtin_command_configs)
    end
  end

  local bufid = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_set_option_value('filetype', 'kitty', {
    buf = bufid,
  })
  vim.api.nvim_set_current_buf(bufid)
  vim.api.nvim_buf_set_lines(bufid, 0, -1, false, configs)
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
