local plenary_dir = os.getenv('PLENARY_DIR') or 'tmp/plenary.nvim'
local is_not_a_directory = vim.fn.isdirectory(plenary_dir) == 0
if is_not_a_directory then
  vim.fn.system({ 'git', 'clone', 'https://github.com/nvim-lua/plenary.nvim', plenary_dir })
end

vim.opt.rtp:append('.')
vim.opt.rtp:append(plenary_dir)

vim.cmd('runtime plugin/plenary.vim')
require('plenary.busted')

local Job = require('plenary.job')
local Path = require('plenary.path')
local harness = require('plenary.test_harness')

-- HACK: overwrite plenary _find_files_to_run to pass additional arguments to find
-- originally this uses directory as the parameter
harness._find_files_to_run = function(directory_and_find_args)
  local find_args = {}
  local directory
  directory_and_find_args:gsub('([^%s]+)', function(substring)
    if directory == nil then
      directory = substring
    else
      table.insert(find_args, substring)
    end
  end)

  local finder
  finder = Job:new({
    command = 'find',
    args = vim.list_extend({ directory, '-type', 'f', '-name', '*_spec.lua' }, find_args),
  })

  return vim.tbl_map(Path.new, finder:sync(vim.env.PLENARY_TEST_TIMEOUT))
end
