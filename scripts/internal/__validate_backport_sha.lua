#!/usr/bin/env -S nvim -l
vim.print('starting backport validation...')
---@type table<string, string>
local backport_shas =
  vim.json.decode(table.concat(vim.fn.readfile('lua/kitty-scrollback/backport/backport-sha.json')))

for file, expected_sha in pairs(backport_shas) do
  local url = 'https://raw.githubusercontent.com/neovim/neovim/master/' .. file

  local file_content = vim
    .system({
      'curl',
      '-L',
      's',
      url,
    })
    :wait().stdout or ''

  local actual_sha = vim.fn.sha256(file_content)

  vim.print(
    string.format('\nvalidating %s\n   actual: %s\n expected: %s\n', file, actual_sha, expected_sha)
  )
  assert(actual_sha == expected_sha)
end

vim.print('finished backport validation')
