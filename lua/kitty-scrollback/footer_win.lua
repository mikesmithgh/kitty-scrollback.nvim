---@mod kitty-scrollback.footer_win
local ksb_util = require('kitty-scrollback.util')
local plug = ksb_util.plug_mapping_names

local M = {}

---@type KsbPrivate
local p

---@type KsbOpts
local opts ---@diagnostic disable-line: unused-local

M.setup = function(private, options)
  p = private
  opts = options ---@diagnostic disable-line: unused-local
end

M.footer_winopts = function(paste_winopts)
  local target_border = { '▏', ' ', '▕', '▕', '🭿', '▁', '🭼', '▏' }
  local row_offset = 1
  if vim.o.lines - paste_winopts.height < 5 then
    target_border = { '', '', '', '▕', '🭿', '▁', '🭼', '▏' }
  end
  if vim.o.lines - paste_winopts.height < 4 then
    target_border = { '', '', '', '▕', '', '', '', '▏' }
  end
  local footer_winopts = {
    relative = 'win',
    win = p.paste_winid,
    zindex = paste_winopts.zindex + 1,
    focusable = false,
    border = target_border,
    height = 1,
    width = paste_winopts.width,
    row = paste_winopts.height + row_offset,
    col = -1,
    style = 'minimal',
  }

  local footer_winopts_overrides = opts.paste_window.footer_winopts_overrides
  if footer_winopts_overrides and type(footer_winopts_overrides) == 'function' then
    footer_winopts = vim.tbl_deep_extend(
      'force',
      footer_winopts,
      opts.paste_window.footer_winopts_overrides(footer_winopts, paste_winopts) or {}
    )
  elseif type(footer_winopts_overrides) == 'table' then
    footer_winopts = vim.tbl_deep_extend('force', footer_winopts, footer_winopts_overrides)
  end

  return footer_winopts
end

M.open_footer_window = function(winopts, refresh_only)
  if not p.paste_winid then
    return
  end

  if refresh_only and not p.footer_bufid then
    return
  end

  if not refresh_only or refresh_only == nil then
    -- if buffer already exists, assume window is already created and just read
    p.footer_bufid = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(p.footer_bufid, vim.fn.tempname() .. '.ksb_footerbuf')
    vim.api.nvim_set_option_value('filetype', 'help', { buf = p.footer_bufid })
    vim.api.nvim_set_option_value('swapfile', false, { buf = p.paste_bufid })

    p.footer_winid = vim.api.nvim_open_win(p.footer_bufid, false, M.footer_winopts(winopts))

    vim.api.nvim_set_option_value('conceallevel', 2, {
      win = p.footer_winid,
    })
    vim.api.nvim_set_option_value('winblend', opts.paste_window.winblend or 0, {
      win = p.footer_winid,
    })
  end

  local mapped_to_ksb_keymaps = vim.tbl_filter(
    function(km)
      if not km.rhs then
        return false
      end
      return km.rhs:match('^%<Plug%>%(Ksb.*%)$')
    end,
    -- '' is normal, visual, and operator-pending mode
    -- ! is insert and command-line mode
    vim.list_extend(
      vim.list_extend(vim.api.nvim_get_keymap(''), vim.api.nvim_get_keymap('!')),
      vim.list_extend(
        vim.api.nvim_buf_get_keymap(p.paste_bufid, ''),
        vim.api.nvim_buf_get_keymap(p.paste_bufid, '!')
      )
    )
  )

  local default_footer_keys = {
    ['<Plug>(KsbNormalYank)'] = vim.fn.keytrans((vim.g.mapleader or '\\') .. 'y'):gsub('<lt>', '<'),
    ['<Plug>(KsbExecuteCmd)'] = '<C-CR>',
    ['<Plug>(KsbPasteCmd)'] = '<S-CR>',
    ['<Plug>(KsbToggleFooter)'] = 'g?',
  }

  local footer_keys = {
    [plug.NORMAL_YANK] = false,
    [plug.EXECUTE_CMD] = false,
    [plug.PASTE_CMD] = false,
    [plug.TOGGLE_FOOTER] = false,
  }

  -- buffer local mappings are appended and will take precedence over global mappings
  for _, km in pairs(mapped_to_ksb_keymaps) do
    local rhs = km.rhs
    if footer_keys[rhs] ~= nil then
      local lhs = vim.fn.keytrans(km.lhs):gsub('<lt>', '<')
      if not footer_keys[rhs] or (footer_keys[rhs] and lhs ~= default_footer_keys[rhs]) then
        footer_keys[rhs] = lhs
      end
    end
  end

  local write_msg = '`:w` *Paste* '
  local footer_msg = {}
  if footer_keys[plug.NORMAL_YANK] then
    table.insert(footer_msg, ('`%s` *Yank* '):format(footer_keys[plug.NORMAL_YANK]))
  end
  if footer_keys[plug.EXECUTE_CMD] then
    table.insert(footer_msg, ('`%s` *Execute* '):format(footer_keys[plug.EXECUTE_CMD]))
  end
  if footer_keys[plug.PASTE_CMD] then
    table.insert(footer_msg, ('`%s` *Paste* '):format(footer_keys[plug.PASTE_CMD]))
  end
  table.insert(footer_msg, write_msg)
  if footer_keys[plug.TOGGLE_FOOTER] then
    table.insert(footer_msg, ('`%s` *Toggle* *Mappings*'):format(footer_keys[plug.TOGGLE_FOOTER]))
  end

  local padding = math.floor(winopts.width / #footer_msg) - 2
  local string_with_padding = '%' .. math.floor(padding / 2) .. 's'
  local string_with_half_padding = '%' .. math.floor(padding / 4) .. 's'
  local first = true
  footer_msg = vim.tbl_map(function(msg)
    if first then
      first = false
      return string.format(string_with_half_padding .. string_with_padding, '', msg)
    end
    return string.format(string_with_padding .. string_with_padding, '', msg)
  end, footer_msg)

  local final_footer = string.format(string_with_padding .. string_with_padding, '', write_msg)
  if opts.keymaps_enabled then
    final_footer = table.concat(footer_msg)
  end
  vim.api.nvim_buf_set_lines(p.footer_bufid, 0, -1, false, { final_footer })

  vim.api.nvim_set_option_value(
    'winhighlight',
    'Normal:KittyScrollbackNvimPasteWinNormal,FloatBorder:KittyScrollbackNvimPasteWinFloatBorder,FloatTitle:KittyScrollbackNvimPasteWinFloatTitle',
    { win = p.footer_winid, scope = 'local' }
  )
end

return M
