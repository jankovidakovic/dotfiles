---@type lint_test.Spec
return {
  linter = 'hadolint',
  filetype = 'dockerfile',
  timeout_ms = 15000,

  diagnostics = {
    file = 'bad.Dockerfile',
    expected = {
      { line = 1, pattern = 'DL3006' },
      { line = 2, pattern = 'DL3008' },
    },
    clean_file = 'good.Dockerfile',
  },
}
