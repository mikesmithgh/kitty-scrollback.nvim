local M = {}

M.config = function()
  return {
    status_window = {
      show_timer = true,
    },
    callbacks = {
      after_setup = function()
        vim.loop.sleep(4000)
      end,
    }
  }
end

return M
