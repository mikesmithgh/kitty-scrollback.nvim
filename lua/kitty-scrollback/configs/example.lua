local prefix = 'ksb_example_'

return {
  configs = {
    --- Example configuration invoking callbacks with delays and prints timestamps
    --- Includes after_setup, after_launch, and after_ready callback functions
    --- and prints kitty_data and options that are passed to after_ready function
    --- This example is not practical and only for demonstration purposes
    ---@return KsbCallbacks
    [prefix .. 'callbacks'] = function()
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
    [prefix .. 'get_text_all_plain'] = function()
      return {
        kitty_get_text = {
          extent = 'all',
          ansi = false,
        },
      }
    end,
    [prefix .. 'get_text_first_cmd_output_on_screen'] = function()
      return {
        kitty_get_text = {
          extent = 'first_cmd_output_on_screen',
          ansi = true,
        },
      }
    end,
    [prefix .. 'get_text_first_cmd_output_on_screen_plain'] = function()
      return {
        kitty_get_text = {
          extent = 'first_cmd_output_on_screen',
          ansi = false,
        },
      }
    end,
    [prefix .. 'get_text_last_cmd_output_plain'] = function()
      return {
        kitty_get_text = {
          extent = 'last_cmd_output',
          ansi = false,
        },
      }
    end,
    [prefix .. 'get_text_last_non_empty_output'] = function()
      return {
        kitty_get_text = {
          extent = 'last_non_empty_output',
          ansi = true,
        },
      }
    end,
    [prefix .. 'get_text_last_non_empty_output_plain'] = function()
      return {
        kitty_get_text = {
          extent = 'last_non_empty_output',
          ansi = false,
        },
      }
    end,
    [prefix .. 'get_text_last_visited_cmd_output_plain'] = function()
      return {
        kitty_get_text = {
          extent = 'last_visited_cmd_output',
          ansi = false,
        },
      }
    end,
    [prefix .. 'get_text_screen'] = function()
      return {
        kitty_get_text = {
          extent = 'screen',
          ansi = true,
        },
      }
    end,
    [prefix .. 'get_text_screen_plain'] = function()
      return {
        kitty_get_text = {
          extent = 'screen',
          ansi = false,
        },
      }
    end,
    [prefix .. 'get_text_selection'] = function()
      return {
        kitty_get_text = {
          extent = 'selection',
          ansi = true,
        },
      }
    end,
    [prefix .. 'get_text_selection_keep_selection'] = function()
      return {
        kitty_get_text = {
          extent = 'selection',
          ansi = true,
          clear_selection = false,
        },
      }
    end,
    [prefix .. 'get_text_selection_plain'] = function()
      return {
        kitty_get_text = {
          extent = 'selection',
          ansi = false,
        },
      }
    end,
    [prefix .. 'highlight_overrides'] = function()
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
    [prefix .. 'visual_selection_highlight_mode_reverse'] = function()
      return {
        visual_selection_highlight_mode = 'reverse',
      }
    end,
    [prefix .. 'keymaps_custom'] = function()
      vim.keymap.set({ 'v' }, 'sY', '<Plug>(KsbVisualYankLine)', {})
      vim.keymap.set({ 'v' }, 'sy', '<Plug>(KsbVisualYank)', {})
      vim.keymap.set({ 'n' }, 'sY', '<Plug>(KsbNormalYankEnd)', {})
      vim.keymap.set({ 'n' }, 'sy', '<Plug>(KsbNormalYank)', {})
      vim.keymap.set({ 'n' }, 'syy', '<Plug>(KsbYankLine)', {})

      vim.keymap.set({ 'n' }, 'q', '<Plug>(KsbCloseOrQuitAll)', {})
      vim.keymap.set({ 'n', 't', 'i' }, 'ZZ', '<Plug>(KsbQuitAll)', {})

      vim.keymap.set({ 'n' }, '<tab>', '<Plug>(KsbToggleFooter)', {})
      vim.keymap.set({ 'n', 'i' }, '<cr>', '<Plug>(KsbExecuteCmd)', {})
      vim.keymap.set({ 'n', 'i' }, '<c-v>', '<Plug>(KsbPasteCmd)', {})
    end,
    [prefix .. 'keymaps_disabled'] = function()
      return {
        keymaps_enabled = false,
      }
    end,
    [prefix .. 'paste_win_filetype'] = function()
      return {
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
      }
    end,
    [prefix .. 'paste_win_hide_mappings'] = function()
      return {
        paste_window = {
          hide_footer = true,
        },
      }
    end,
    [prefix .. 'paste_win_highlight_as_float'] = function()
      return {
        paste_window = {
          highlight_as_normal_win = function()
            return false
          end,
        },
      }
    end,
    [prefix .. 'paste_win_register'] = function()
      return {
        paste_window = {
          yank_register = '*',
        },
      }
    end,
    [prefix .. 'paste_win_register_disabled'] = function()
      return {
        paste_window = {
          yank_register_enabled = false,
        },
      }
    end,
    [prefix .. 'paste_win_winblend'] = function()
      return {
        paste_window = {
          winblend = 50,
        },
      }
    end,
    [prefix .. 'paste_win_winopts'] = function()
      return {
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
      }
    end,
    [prefix .. 'restore_opts'] = function()
      vim.o.termguicolors = true
      vim.o.number = true
      return {
        restore_options = true,
      }
    end,
    [prefix .. 'status_win_autoclose'] = function()
      return {
        status_window = {
          autoclose = true,
        },
      }
    end,
    [prefix .. 'status_win_disabled'] = function()
      return {
        status_window = {
          enabled = false,
        },
      }
    end,
    [prefix .. 'status_win_show_timer'] = function()
      return {
        status_window = {
          show_timer = true,
        },
        callbacks = {
          after_setup = function()
            vim.loop.sleep(8000)
          end,
        },
      }
    end,
    [prefix .. 'status_win_nvim'] = function()
      return {
        status_window = {
          icons = {
            nvim = '',
          },
        },
      }
    end,
    [prefix .. 'status_win_simple'] = function()
      return {
        status_window = {
          style_simple = true,
        },
      }
    end,
  },
}
