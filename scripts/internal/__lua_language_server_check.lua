local uv = vim.uv
local ci_build = vim.env.CI == 'true' or vim.env.GITHUB_ACTIONS == 'true'

local function lua_language_server_executable()
  local lua_language_server
  if vim.env.LUA_LS_SERVER then
    lua_language_server = vim.env.LUA_LS_SERVER
    if vim.fn.executable(lua_language_server) == 0 then
      io.write(('LUS_LS_SERVER %s not found or not executable\n'):format(lua_language_server))
      os.exit(1)
    end
  else
    lua_language_server = vim.fn.exepath('lua-language-server')
  end

  if lua_language_server == '' or vim.fn.executable(lua_language_server) == 0 then
    if ci_build then
      lua_language_server = vim.env.GITHUB_WORKSPACE
        .. [[/tmp/lua_language_server/bin/lua-language-server]]
      io.write(
        ('lua-language-server not found or not executable. CI build detected, falling back to %s\n\n'):format(
          lua_language_server
        )
      )
    elseif lua_language_server == '' then
      lua_language_server = vim.fn.stdpath('data')
        .. '/mason/packages/lua-language-server/lua-language-server'
      io.write(
        ('lua-language-server not found or not executable. falling back to %s\n\n'):format(
          lua_language_server
        )
      )
    end
  end

  if vim.fn.executable(lua_language_server) == 0 then
    io.write(('%s not found or not executable\n'):format(lua_language_server))
    os.exit(1)
  end
  return lua_language_server
end

local function tmpfile()
  local tmp_dir = (vim.env.TMPDIR or '/tmp/') .. 'lua_ls_report/'
  vim.fn.mkdir(tmp_dir, '-p')
  local template = tmp_dir .. 'lua_ls_report.XXXXXX'
  local _, path_or_errname, err_msg = uv.fs_mkstemp(template)
  if err_msg ~= nil or path_or_errname == nil then
    io.write(('%s\n'):format(err_msg or 'mkstemp failed'))
    os.exit(1)
  end
  return path_or_errname
end

local function check_command(lua_language_server, tmp_path)
  local command = {
    lua_language_server,
    '--check',
    '.',
    '--check_out_path',
    tmp_path,
  }

  if vim.env.LUA_LS_LOGLEVEL then
    table.insert(command, '--loglevel')
    table.insert(command, vim.env.LUA_LS_LOGLEVEL)
  end

  if vim.env.LUA_LS_LOGPATH then
    table.insert(command, '--logpath')
    table.insert(command, vim.env.LUA_LS_LOGPATH)
  end

  if vim.env.LUA_LS_CONFIGPATH then
    table.insert(command, '--configpath')
    table.insert(command, vim.env.LUA_LS_CONFIGPATH)
  end
  return command
end

local lua_language_server = lua_language_server_executable()
local tmp_path = tmpfile()
local command = check_command(lua_language_server, tmp_path)
local check_command_result = vim.system(command):wait()
io.write(check_command_result.stdout)
os.exit(check_command_result.code)
