---@type lsp_test.Spec
return {
  server = 'bashls',
  filetype = 'sh',
  attach_timeout_ms = 15000,

  diagnostics = {
    file = 'bad.sh',
    expected = {
      { line = 3, pattern = 'Double quote to prevent globbing' },
    },
    clean_file = 'good.sh',
  },

  definition = {
    file = 'good.sh',
    cursor = { 8, 1 },
    target_file = 'good.sh',
    target_line = 3,
  },
}
