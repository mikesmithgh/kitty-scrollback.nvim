local M = {}

local msg = {}

M.config = function(kitty_data)
  return {
    callbacks = {
      after_setup = function(kitty_data, opts)
        vim.defer_fn(function()
          table.insert(msg, '# kitty-scrollback after_setup callback triggered @ ' .. vim.fn.strftime('%c'))
        end, 1000)
      end,
      after_launch = function(kitty_data, opts)
        vim.defer_fn(function()
          table.insert(msg, '# kitty-scrollback after_launch callback triggered @ ' .. vim.fn.strftime('%c'))
        end, 2000)
      end,
      after_ready = function(kitty_data, opts)
        vim.defer_fn(function()
          table.insert(msg, '# kitty-scrollback after_ready callback triggered @ ' .. vim.fn.strftime('%c'))
          table.insert(msg, '# kitty_data:')
          table.insert(msg, '# ' .. vim.fn.json_encode(kitty_data))
          table.insert(msg, '# opts:')
          table.insert(msg, '# ' .. vim.fn.json_encode(vim.inspect(opts)))
          local curbuf = vim.api.nvim_get_current_buf()
          vim.cmd.startinsert()
          vim.fn.timer_start(250, function(t) ---@diagnostic disable-line: redundant-parameter
            if curbuf ~= vim.api.nvim_get_current_buf() then
              vim.fn.timer_stop(t)
              vim.api.nvim_buf_set_lines(0, 0, -1, false, msg)
              vim.cmd.stopinsert()
            end
          end, {
            ['repeat'] = 12,
          })
        end, 3000)
      end,
    },
  }
end

return M
