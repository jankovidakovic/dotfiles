---@type lsp_test.Spec
return {
  server = 'lua_ls',
  filetype = 'lua',
  attach_timeout_ms = 15000,

  diagnostics = {
    file = 'bad.lua',
    expected = {
      { line = 2, pattern = 'Undefined global' },
    },
    clean_file = 'good.lua',
  },

  definition = {
    file = 'good.lua',
    cursor = { 8, 1 },
    target_file = 'good.lua',
    target_line = 3,
  },
}
