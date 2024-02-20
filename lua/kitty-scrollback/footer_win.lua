---@mod kitty-scrollback.footer_win
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

  if opts.paste_window.footer_winopts_overrides then
    footer_winopts = vim.tbl_deep_extend(
      'force',
      footer_winopts,
      opts.paste_window.footer_winopts_overrides(footer_winopts, paste_winopts) or {}
    )
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
    vim.api.nvim_set_option_value('filetype', 'help', {
      buf = p.footer_bufid,
    })

    p.footer_winid = vim.api.nvim_open_win(p.footer_bufid, false, M.footer_winopts(winopts))

    vim.api.nvim_set_option_value('conceallevel', 2, {
      win = p.footer_winid,
    })
    vim.api.nvim_set_option_value('winblend', opts.paste_window.winblend or 0, {
      win = p.footer_winid,
    })
  end

  local mapped_to_ksb_keymaps = vim.tbl_filter(function(km)
    if not km.rhs then
      return false
    end
    return km.rhs:match('^%<Plug%>%(Ksb.*%)$')
  end, vim.api.nvim_get_keymap('a'))

  local footer_keys = {
    ['<Plug>(KsbNormalYank)'] = vim.fn.keytrans((vim.g.mapleader or '\\') .. 'y'):gsub('<lt>', '<'),
    ['<Plug>(KsbExecuteCmd)'] = '<C-CR>',
    ['<Plug>(KsbPasteCmd)'] = '<S-CR>',
    ['<Plug>(KsbToggleFooter)'] = 'g?',
  }

  for _, km in pairs(mapped_to_ksb_keymaps) do
    local rhs = km.rhs
    if footer_keys[rhs] then
      local lhs = vim.fn.keytrans(km.lhs):gsub('<lt>', '<')
      footer_keys[rhs] = lhs
    end
  end

  local write_msg = '`:w` *Paste* '
  local footer_msg = {
    '`' .. footer_keys['<Plug>(KsbNormalYank)'] .. '` *Yank* ',
    '`' .. footer_keys['<Plug>(KsbExecuteCmd)'] .. '` *Execute* ',
    '`' .. footer_keys['<Plug>(KsbPasteCmd)'] .. '` *Paste* ',
    write_msg,
    '`' .. footer_keys['<Plug>(KsbToggleFooter)'] .. '` *Toggle* *Mappings*',
  }
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
