local severity_map = {
  '\27[31merror:\27[0m',
  '\27[33mwarning:\27[0m',
  '\27[90minfo:\27[0m',
  '\27[36mhint:\27[0m',
}

local lua_language_server = vim.fn.stdpath('data')
  .. '/mason/packages/lua-language-server/lua-language-server'

if vim.env.LUA_LS_SERVER then
  lua_language_server = vim.env.LUA_LS_SERVER
elseif vim.env.GITHUB_ACTIONS == 'true' then
  lua_language_server = vim.env.GITHUB_WORKSPACE
    .. [[/tmp/lua_language_server/bin/lua-language-server]]
end

local tmp_dir = (vim.env.TMPDIR or '/tmp/') .. 'lua_ls_report/'
vim.fn.mkdir(tmp_dir, '-p')
local template = tmp_dir .. 'lua_ls_report.XXXXXX'
local _, path_or_errname, err_msg = vim.uv.fs_mkstemp(template)
if err_msg ~= nil or path_or_errname == nil then
  vim.print(err_msg or 'mkstemp failed')
  os.exit(1)
end
local tmp_path = path_or_errname

local check_command = {
  lua_language_server,
  '--check',
  '.',
  '--check_out_path',
  tmp_path,
}

if vim.env.LUA_LS_LOGLEVEL then
  table.insert(check_command, '--loglevel')
  table.insert(check_command, vim.env.LUA_LS_LOGLEVEL)
end

if vim.env.LUA_LS_LOGPATH then
  table.insert(check_command, '--logpath')
  table.insert(check_command, vim.env.LUA_LS_LOGPATH)
end

if vim.env.LUA_LS_CONFIGPATH then
  table.insert(check_command, '--configpath')
  table.insert(check_command, vim.env.LUA_LS_CONFIGPATH)
end

local check_command_result = vim.system(check_command):wait()
local ok = check_command_result.code == 0
if not ok then
  vim.print(check_command_result)
  os.exit(check_command_result.code)
end

local input = vim.fn.readfile(tmp_path)
local diagnostics = vim.json.decode(table.concat(input))
local formatted_diagnostics = {}
for filepath, file_diagnostics in pairs(diagnostics) do
  vim.validate('diagnostics', file_diagnostics, vim.islist, 'a list of diagnostics')
  local path = filepath:gsub('^file://', ''):gsub('/%./', '/')
  for _, v in ipairs(file_diagnostics) do
    local item = {
      file = path,
      message = v.message,
      severity = severity_map[v.severity or 1],
      line = v.range.start.line + 1,
      col = v.range.start.character + 1,
    }
    table.insert(formatted_diagnostics, item)
  end
end

if vim.tbl_isempty(formatted_diagnostics) then
  io.write('\27[32m')
  io.write(check_command_result.stdout)
  io.write('\27[0m')
  os.exit(0)
else
  io.write('\27[31m')
  io.write(check_command_result.stdout)
  io.write('\27[0m\n')
  for _, v in ipairs(formatted_diagnostics) do
    io.write(
      ('\x1b]8;;file://%s\x1b\\%s\x1b]8;;\x1b\\:%s:%s: %s %s\n'):format(
        v.file,
        vim.fn.fnamemodify(v.file, ':.'),
        v.line,
        v.col,
        v.severity,
        v.message
      )
    )
  end
  os.exit(1)
end
