# Lint Integration Tests

Headless integration tests that verify linters (via nvim-lint) produce expected diagnostics using the real Neovim config.

## Running Tests

```bash
bash tests/lint/run.sh            # Run all linter tests
bash tests/lint/run.sh hadolint   # Run a single linter
```

Results printed to stdout and written to `results.json`.

## Adding a New Linter Test

1. Create fixture directory: `tests/lint/fixtures/<linter_name>/`
2. Create fixture files:
   - `bad.<ext>` — File with deliberate lint errors
   - `good.<ext>` — Clean file with zero diagnostics
3. Write `spec.lua` with test configuration
4. Verify: `bash tests/lint/run.sh linter_name`

## Spec Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `linter` | string | yes | Linter name (must match nvim-lint name) |
| `filetype` | string | yes | Filetype to set on fixture buffers |
| `timeout_ms` | integer | no | Max wait for diagnostics (default 15000) |
| `diagnostics.file` | string | yes | File with known lint errors |
| `diagnostics.expected` | table | yes | Array of `{line, pattern}` expectations |
| `diagnostics.clean_file` | string | no | File that must produce 0 diagnostics |

## Example spec.lua

```lua
---@type lint_test.Spec
return {
  linter = 'hadolint',
  filetype = 'dockerfile',

  diagnostics = {
    file = 'bad.Dockerfile',
    expected = {
      { line = 2, pattern = 'DL3006' },
    },
    clean_file = 'good.Dockerfile',
  },
}
```

## Tips

- Diagnostic patterns use Lua `string.find` semantics (case-sensitive)
- For slow linters, increase `timeout_ms`
- Diagnostics are filtered by `source` matching the linter name
- Annotation `---@type lint_test.Spec` provides autocomplete in lua_ls
