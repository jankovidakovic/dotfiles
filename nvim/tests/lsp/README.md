# LSP Test Framework

Headless integration tests that verify LSP servers attach, produce diagnostics, and resolve definitions using your real Neovim config.

## Running

```bash
# Run all server tests
bash tests/lsp/run.sh

# Run a single server
bash tests/lsp/run.sh basedpyright
```

Results are printed to stdout and written to `results.json`.

## Adding a new server test

### 1. Create the fixture directory

```
tests/lsp/fixtures/<server_name>/
```

The directory name must match the LSP server name as it appears in your config (the name passed to `lspconfig` or `vim.lsp.config`).

### 2. Add root markers

If the server requires project files to initialize (e.g. `tsconfig.json`, `pyproject.toml`, `go.mod`), add minimal stubs to the fixture directory. Without these, the server may refuse to attach.

### 3. Create fixture files

You need at least one file for the server to open. Typically:

- **`bad.<ext>`** — A file with deliberate errors the server should diagnose.
- **`good.<ext>`** — A clean file with zero diagnostics, also used for definition jumps.

### 4. Write `spec.lua`

Create `tests/lsp/fixtures/<server_name>/spec.lua`:

```lua
---@type lsp_test.Spec
return {
  server = 'server_name',
  filetype = 'filetype',
  attach_timeout_ms = 15000,  -- optional, default 15000

  diagnostics = {
    file = 'bad.ext',
    expected = {
      { line = 3, pattern = 'some error message' },
    },
    clean_file = 'good.ext',  -- optional: asserts 0 diagnostics on this file
  },

  definition = {
    file = 'good.ext',
    cursor = { 8, 5 },           -- 1-indexed {line, col} on a symbol
    target_file = 'good.ext',    -- optional: nil = any file
    target_line = 2,             -- optional: nil = don't check line
  },
}
```

All fields except `server` and `filetype` are optional. A minimal spec that only tests attachment:

```lua
---@type lsp_test.Spec
return {
  server = 'bashls',
  filetype = 'sh',
}
```

### 5. Verify

```bash
bash tests/lsp/run.sh server_name
```

## Spec reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `server` | `string` | yes | LSP server name |
| `filetype` | `string` | yes | Filetype set on buffers |
| `attach_timeout_ms` | `integer` | no | Max wait for attachment (default 15000) |
| `diagnostics.file` | `string` | if diagnostics | File containing known errors |
| `diagnostics.expected` | `{line, pattern}[]` | if diagnostics | Each must match a diagnostic |
| `diagnostics.clean_file` | `string` | no | File that must have 0 diagnostics |
| `definition.file` | `string` | if definition | File to open |
| `definition.cursor` | `{line, col}` | if definition | 1-indexed cursor position on a symbol |
| `definition.target_file` | `string` | no | Expected jump target file |
| `definition.target_line` | `integer` | no | Expected jump target line |

## Tips

- **Diagnostic patterns** are Lua patterns matched against the diagnostic message. Use `string.find` semantics (e.g. `'is not defined'` matches anywhere in the message). Case-sensitive.
- **Definition cursor** should be placed on a symbol whose definition is in the same fixture file for reliable testing. Jumping to stdlib/external files works but `target_file` must be omitted or set to the absolute installed path.
- **Slow servers** — if a server takes a long time to initialize, increase `attach_timeout_ms`. The attach time is always reported in results regardless.
- The `---@type lsp_test.Spec` annotation gives you autocomplete and validation in any editor with lua_ls.
