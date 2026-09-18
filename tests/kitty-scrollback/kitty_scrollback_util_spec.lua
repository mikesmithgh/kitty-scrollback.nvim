local assert = require('luassert.assert')
local util = require('kitty-scrollback.util')

describe('system_handle_error_async', function()
  local reported

  -- the real display_cmd_error ends in a confirm prompt and a possible quit, so stand
  -- in a recorder that still does one of the API calls the real one makes
  ---@diagnostic disable-next-line: duplicate-set-field
  util.display_cmd_error = function(cmd, detail)
    local api_ok, buf = pcall(vim.api.nvim_create_buf, false, true)
    reported = { cmd = cmd, detail = detail, api_ok = api_ok, buf = buf }
  end

  before_each(function()
    reported = nil
  end)

  it('reports a failing command from a non fast event, then calls on_exit', function()
    local done = false
    local in_fast_event
    local exit_code

    util.system_handle_error_async({ 'sh', '-c', 'exit 3' }, { 'HEADER' }, function(result)
      in_fast_event = vim.in_fast_event()
      exit_code = result.code
      done = true
    end)

    assert.is_true(vim.wait(5000, function()
      return done
    end, 20))
    assert.is_false(in_fast_event)
    assert.equals(3, exit_code)
    assert.is_not_nil(reported)
    assert.is_true(reported.api_ok)
    assert.equals(3, reported.detail.code)
    assert.is_number(reported.detail.pid)
  end)

  it('does not report anything when the command succeeds', function()
    local done = false
    local exit_code

    util.system_handle_error_async({ 'sh', '-c', 'exit 0' }, { 'HEADER' }, function(result)
      exit_code = result.code
      done = true
    end)

    assert.is_true(vim.wait(5000, function()
      return done
    end, 20))
    assert.is_nil(reported)
    assert.equals(0, exit_code)
  end)
end)
