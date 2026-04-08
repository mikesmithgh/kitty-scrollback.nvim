local assert = require('luassert.assert')

describe('kitty-scrollback.nvim fzf-lua integration', function()
  local grep_calls
  local grep_provider
  local path_call
  local temp_path
  local scrollback_buf
  local scrollback_win
  local other_buf
  local p
  local opts

  local function reset_modules()
    package.loaded['kitty-scrollback.fzf_lua'] = nil
    package.loaded['fzf-lua.providers.grep'] = nil
    package.loaded['fzf-lua.path'] = nil
  end

  local function load_fzf_lua_module()
    grep_calls = {}
    path_call = nil
    grep_provider = {
      grep_curbuf = function(user_opts, ...)
        table.insert(grep_calls, {
          picker = 'grep',
          opts = user_opts,
          extra = { ... },
        })
        return user_opts
      end,
      lgrep_curbuf = function(user_opts, ...)
        table.insert(grep_calls, {
          picker = 'lgrep',
          opts = user_opts,
          extra = { ... },
        })
        return user_opts
      end,
    }
    package.loaded['fzf-lua.providers.grep'] = grep_provider
    package.loaded['fzf-lua.path'] = {
      entry_to_file = function(selected, picker_opts)
        path_call = {
          selected = selected,
          opts = picker_opts,
        }
        return {
          line = 3,
          col = 5,
          path = temp_path,
        }
      end,
    }
    return require('kitty-scrollback.fzf_lua')
  end

  before_each(function()
    reset_modules()
    if vim.fn.winnr('$') > 1 then
      vim.cmd('only!')
    end
    vim.cmd('enew!')

    scrollback_win = vim.api.nvim_get_current_win()
    temp_path = vim.fn.tempname() .. '.ksb_scrollback'
    vim.fn.writefile({
      'alpha',
      'bravo',
      'charlie',
      'delta',
      'echo',
    }, temp_path)

    scrollback_buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(scrollback_buf)
    vim.api.nvim_buf_set_name(scrollback_buf, temp_path)
    vim.api.nvim_buf_set_lines(scrollback_buf, 0, -1, false, {
      'alpha',
      'bravo',
      'charlie',
      'delta',
      'echo',
    })

    p = {
      bufid = scrollback_buf,
      winid = scrollback_win,
      scrollback_tempfile = temp_path,
    }
    opts = {
      scrollback_buffer = {
        tempfile = {
          enabled = true,
        },
      },
    }
    other_buf = nil
  end)

  after_each(function()
    reset_modules()
    if vim.fn.winnr('$') > 1 then
      vim.cmd('only!')
    end
    vim.cmd('enew!')

    for _, buf in ipairs({ other_buf, scrollback_buf }) do
      if buf and vim.api.nvim_buf_is_valid(buf) then
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end
    end

    if temp_path and (vim.uv or vim.loop).fs_stat(temp_path) then
      vim.fn.delete(temp_path)
    end

    other_buf = nil
    scrollback_buf = nil
    scrollback_win = nil
    temp_path = nil
    p = nil
    opts = nil
  end)

  it('wraps grep and lgrep enter actions for the active scrollback tempfile buffer', function()
    local fzf_lua = load_fzf_lua_module()
    fzf_lua.setup(p, opts)

    grep_provider.grep_curbuf({})
    grep_provider.lgrep_curbuf({})

    assert.are.equal(2, #grep_calls)
    assert.are.equal('grep', grep_calls[1].picker)
    assert.are.equal('lgrep', grep_calls[2].picker)
    assert.is_function(grep_calls[1].opts.actions.enter)
    assert.is_function(grep_calls[2].opts.actions.enter)
  end)

  it('jumps selected matches back into the scrollback window', function()
    local fzf_lua = load_fzf_lua_module()
    fzf_lua.setup(p, opts)

    grep_provider.lgrep_curbuf({})
    local enter = grep_calls[1].opts.actions.enter

    vim.cmd('split')
    other_buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(other_buf)
    vim.api.nvim_buf_set_lines(other_buf, 0, -1, false, { 'placeholder' })

    enter({ temp_path .. ':3:5:charlie' }, {})

    assert.is_true(vim.wait(200, function()
      local cursor = vim.api.nvim_win_get_cursor(scrollback_win)
      return vim.api.nvim_get_current_win() == scrollback_win
        and vim.api.nvim_get_current_buf() == scrollback_buf
        and cursor[1] == 3
        and cursor[2] == 4
    end))

    assert.are.equal(scrollback_win, p.winid)
    assert.are.equal(3, p.pos.cursor_line)
    assert.are.equal(4, p.pos.col)
    assert.are.equal(temp_path .. ':3:5:charlie', path_call.selected)
  end)

  it('leaves picker actions untouched outside the active scrollback tempfile buffer', function()
    local fzf_lua = load_fzf_lua_module()
    fzf_lua.setup(p, opts)

    other_buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(other_buf)

    grep_provider.grep_curbuf({})

    assert.are.equal(1, #grep_calls)
    assert.is_nil(grep_calls[1].opts.actions)
  end)

  it('does not patch providers when tempfile support is disabled', function()
    local fzf_lua = load_fzf_lua_module()
    local original_grep = grep_provider.grep_curbuf
    local original_lgrep = grep_provider.lgrep_curbuf

    fzf_lua.setup(p, {
      scrollback_buffer = {
        tempfile = {
          enabled = false,
        },
      },
    })

    assert.are.equal(original_grep, grep_provider.grep_curbuf)
    assert.are.equal(original_lgrep, grep_provider.lgrep_curbuf)
  end)
end)
