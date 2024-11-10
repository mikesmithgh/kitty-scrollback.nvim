vim.opt.runtimepath:append(
  vim.fn.fnamemodify(vim.env.HOME .. '/gitrepos/kitty-scrollback.nvim', ':p') -- local setup
)

if vim.env.GITHUB_ACTIONS == 'true' then
  vim.opt.runtimepath:append(vim.fn.fnamemodify(vim.env.GITHUB_WORKSPACE, ':p'))
end

vim.opt.runtimepath:append(vim.fn.fnamemodify(
  vim.fn.stdpath('data') .. '/site/pack/mikesmithgh/start/kitty-scrollback.nvim', -- pack setup
  ':p'
))
vim.opt.runtimepath:append(vim.fn.fnamemodify(
  vim.fn.stdpath('data') .. '/lazy/kitty-scrollback.nvim', -- lazy.nvim
  ':p'
))

require('kitty-scrollback').setup({
  --- Example configuration invoking callbacks with delays and prints timestamps
  --- Includes after_setup, after_launch, and after_ready callback functions
  --- and prints kitty_data and options that are passed to after_ready function
  --- This example is not practical and only for demonstration purposes
  ---@return KsbCallbacks
  ksb_example_callbacks = function()
    local msg = {}
    return {
      callbacks = {
        after_setup = function()
          vim.defer_fn(function()
            table.insert(
              msg,
              '# kitty-scrollback after_setup callback triggered @ ' .. vim.fn.strftime('%c')
            )
          end, 1000)
        end,
        after_launch = function()
          vim.defer_fn(function()
            table.insert(
              msg,
              '# kitty-scrollback after_launch callback triggered @ ' .. vim.fn.strftime('%c')
            )
          end, 2000)
        end,
        after_ready = function(kitty_data, opts)
          vim.defer_fn(function()
            vim.cmd.startinsert()
            table.insert(
              msg,
              '# kitty-scrollback after_ready callback triggered @ ' .. vim.fn.strftime('%c')
            )
            table.insert(msg, '# kitty_data:')
            table.insert(msg, '# ' .. vim.fn.json_encode(kitty_data))
            table.insert(msg, '# opts:')
            table.insert(msg, '# ' .. vim.fn.json_encode(vim.inspect(opts)))
            vim.api.nvim_buf_set_lines(0, 0, -1, false, msg)
            vim.cmd.stopinsert()
          end, 3000)
        end,
      },
    }
  end,
  ksb_example_get_text_all_plain = {
    kitty_get_text = {
      extent = 'all',
      ansi = false,
    },
  },
  ksb_example_get_text_first_cmd_output_on_screen = {
    kitty_get_text = {
      extent = 'first_cmd_output_on_screen',
      ansi = true,
    },
  },
  ksb_example_get_text_first_cmd_output_on_screen_plain = {
    kitty_get_text = {
      extent = 'first_cmd_output_on_screen',
      ansi = false,
    },
  },
  ksb_example_get_text_last_cmd_output_plain = {
    kitty_get_text = {
      extent = 'last_cmd_output',
      ansi = false,
    },
  },
  ksb_example_get_text_last_non_empty_output = {
    kitty_get_text = {
      extent = 'last_non_empty_output',
      ansi = true,
    },
  },
  ksb_example_get_text_last_non_empty_output_plain = {
    kitty_get_text = {
      extent = 'last_non_empty_output',
      ansi = false,
    },
  },
  ksb_example_get_text_last_visited_cmd_output_plain = {
    kitty_get_text = {
      extent = 'last_visited_cmd_output',
      ansi = false,
    },
  },
  ksb_example_get_text_screen = {
    kitty_get_text = {
      extent = 'screen',
      ansi = true,
    },
  },
  ksb_example_get_text_screen_plain = {
    kitty_get_text = {
      extent = 'screen',
      ansi = false,
    },
  },
  ksb_example_get_text_selection = {
    kitty_get_text = {
      extent = 'selection',
      ansi = true,
    },
  },
  ksb_example_get_text_selection_keep_selection = {
    kitty_get_text = {
      extent = 'selection',
      ansi = true,
      clear_selection = false,
    },
  },
  ksb_example_get_text_selection_plain = {
    kitty_get_text = {
      extent = 'selection',
      ansi = false,
    },
  },
  ksb_example_highlight_overrides = function()
    for i = 0, 15 do
      vim.g['terminal_color_' .. i] = 'Cyan'
    end
    return {
      highlight_overrides = {
        KittyScrollbackNvimStatusWinNormal = {
          fg = '#ee82ee',
          bg = '#ee82ee',
        },
        KittyScrollbackNvimStatusWinHeartIcon = {
          fg = '#ff0000',
          bg = '#4b0082',
        },
        KittyScrollbackNvimStatusWinSpinnerIcon = {
          fg = '#000099',
          bg = '#4b0082',
        },
        KittyScrollbackNvimStatusWinReadyIcon = {
          fg = '#4b0082',
          bg = '#ffa500',
        },
        KittyScrollbackNvimStatusWinKittyIcon = {
          fg = '#ffa500',
          bg = '#000099',
        },
        KittyScrollbackNvimStatusWinNvimIcon = {
          fg = '#008000',
          bg = '#000099',
        },
        KittyScrollbackNvimPasteWinNormal = {
          link = 'IncSearch',
        },
        KittyScrollbackNvimPasteWinFloatBorder = {
          link = 'IncSearch',
        },
        KittyScrollbackNvimPasteWinFloatTitle = {
          link = 'IncSearch',
        },
        KittyScrollbackNvimVisual = {
          bg = 'Pink',
          fg = 'Black',
        },
      },
    }
  end,
  ksb_example_visual_selection_highlight_mode_reverse = {
    visual_selection_highlight_mode = 'reverse',
  },
  ksb_example_keymaps_custom = function()
    vim.keymap.set({ 'v' }, 'sY', '<Plug>(KsbVisualYankLine)', {})
    vim.keymap.set({ 'v' }, 'sy', '<Plug>(KsbVisualYank)', {})
    vim.keymap.set({ 'n' }, 'sY', '<Plug>(KsbNormalYankEnd)', {})
    vim.keymap.set({ 'n' }, 'sy', '<Plug>(KsbNormalYank)', {})
    vim.keymap.set({ 'n' }, 'syy', '<Plug>(KsbYankLine)', {})
    vim.keymap.set({ 'n' }, '<Esc>', '<Plug>(KsbCloseOrQuitAll)', {})
    vim.keymap.set({ 'n', 't', 'i' }, 'ZZ', '<Plug>(KsbQuitAll)', {})
    vim.keymap.set({ 'n' }, '<tab>', '<Plug>(KsbToggleFooter)', {})
    vim.keymap.set({ 'n', 'i' }, '<cr>', '<Plug>(KsbExecuteCmd)', {})
    vim.keymap.set({ 'n', 'i' }, '<c-v>', '<Plug>(KsbPasteCmd)', {})
    vim.keymap.set({ 'v' }, '<leader><cr>', '<Plug>(KsbExecuteVisualCmd)', {})
    vim.keymap.set({ 'v' }, '<leader><c-v>', '<Plug>(KsbPasteVisualCmd)', {})
  end,
  ksb_example_keymaps_disabled = {
    keymaps_enabled = false,
  },
  ksb_example_paste_win_filetype = {
    paste_window = {
      filetype = 'markdown',
    },
    callbacks = {
      after_ready = vim.schedule_wrap(function()
        local msg = {
          '',
          '\t',
          '',
          '# kitty-scrollback.nvim example',
          '',
          '## Change paste window filetype to `markdown`',
          '',
          '```lua',
          'paste_window = {',
          '  filetype = "markdown", -- change this to your desired filetype',
          '},',
          '```',
        }
        local curbuf = vim.api.nvim_get_current_buf()
        vim.cmd.startinsert()
        vim.fn.timer_start(250, function(t) ---@diagnostic disable-line: redundant-parameter
          if curbuf ~= vim.api.nvim_get_current_buf() then
            vim.fn.timer_stop(t)
            vim.api.nvim_buf_set_lines(0, 0, -1, false, msg)
            vim.cmd.stopinsert()
            vim.fn.setcursorcharpos(2, 4)
          end
        end, {
          ['repeat'] = 12,
        })
      end),
    },
  },
  ksb_example_paste_win_hide_mappings = {
    paste_window = {
      hide_footer = true,
    },
  },
  ksb_example_paste_win_highlight_as_float = {
    paste_window = {
      highlight_as_normal_win = false,
    },
  },
  ksb_example_paste_win_register = {
    paste_window = {
      yank_register = '*',
    },
  },
  ksb_example_paste_win_register_disabled = {
    paste_window = {
      yank_register_enabled = false,
    },
  },
  ksb_example_paste_win_winblend = {
    paste_window = {
      winblend = 50,
    },
  },
  ksb_example_paste_win_winopts = {
    paste_window = {
      winblend = 10,
      winopts_overrides = function()
        local h = vim.o.lines - 5 -- TODO: magic number 3 for footer and 2 for border
        return {
          border = 'solid',
          row = 0,
          col = 0,
          height = h < 1 and 3 or h, -- TODO: magic number 3 for footer
          width = vim.o.columns,
        }
      end,
      footer_winopts_overrides = function()
        return {
          border = 'single',
          title = ' kitty-scrollback.nvim ',
          title_pos = 'center',
        }
      end,
    },
  },
  ksb_example_restore_opts = function()
    vim.o.termguicolors = true
    vim.o.number = true
    return {
      restore_options = true,
    }
  end,
  ksb_example_status_win_autoclose = {
    status_window = {
      autoclose = true,
    },
  },
  ksb_example_status_win_disabled = {
    status_window = {
      enabled = false,
    },
  },
  ksb_example_status_win_show_timer = {
    status_window = {
      show_timer = true,
    },
    callbacks = {
      after_setup = function()
        vim.loop.sleep(8000)
      end,
    },
  },
  ksb_example_status_win_vim = {
    status_window = {
      icons = {
        nvim = '',
      },
    },
  },
  ksb_example_status_win_simple = {
    status_window = {
      style_simple = true,
    },
  },
})
