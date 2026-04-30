---@type lsp_test.Spec
return {
  server = 'basedpyright',
  filetype = 'python',
  attach_timeout_ms = 15000,

  diagnostics = {
    file = 'bad.py',
    expected = {
      { line = 4, pattern = 'is not defined' },
    },
    clean_file = 'good.py',
  },

  definition = {
    file = 'good.py',
    cursor = { 8, 10 },
    target_file = 'good.py',
    target_line = 4,
  },
}
