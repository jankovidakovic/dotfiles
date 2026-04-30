# Adding a Native LSP Server

## 1. Create the config file

Create `lsp/<server_name>.lua` in this directory. The file must return a table:

```lua
return {
  cmd = { 'server-binary', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', '.git' },
  settings = {
    -- server-specific settings go here
  },
}
```

### Required fields

| Field | Type | Description |
|-------|------|-------------|
| `cmd` | `string[]` | Command to start the language server |
| `filetypes` | `string[]` | Filetypes that trigger auto-attach |
| `root_markers` | `string[]` | Files/dirs used to detect the workspace root |

### Optional fields

| Field | Type | Description |
|-------|------|-------------|
| `settings` | `table` | Server-specific settings (schema defined by each server) |
| `capabilities` | `table` | Override default client capabilities |
| `on_attach` | `function` | Called when client attaches to a buffer |

### Root markers

Markers are checked in order. The first one found (searching upward from the file) determines the workspace root. Use nested tables for equal-priority markers:

```lua
-- Sequential: check pyproject.toml first, then fall back to .git
root_markers = { 'pyproject.toml', '.git' }

-- Equal priority: either Cargo.toml or rust-toolchain.toml, then .git
root_markers = { { 'Cargo.toml', 'rust-toolchain.toml' }, '.git' }
```

## 2. Enable the server

In `lua/plugins/lsp/init.lua`, add a `vim.lsp.enable()` call:

```lua
vim.lsp.enable('server_name')
```

Multiple servers can be enabled in one call:

```lua
vim.lsp.enable({ 'basedpyright', 'gopls', 'rust_analyzer' })
```

## 3. Prevent duplicate setup

If the server was previously configured via `servers.lua` and mason-lspconfig:

1. Remove the entry from `lua/plugins/lsp/servers.lua`
2. Add the server name to `blacklist_lsp_servers` in `lua/plugins/lsp/init.lua` while both paths coexist (the handler guard skips blacklisted servers)
3. Once the server is fully removed from `servers.lua`, remove it from the blacklist too

## 4. Install the binary

Mason still handles binary installation. Ensure the server is installed:

```vim
:MasonInstall server-name
```

Or add it to the `ensure_installed` list in `mason-tool-installer` setup if you want it auto-installed.

## 5. Verify

```bash
bash tests/lsp/run.sh server_name
```

See `tests/lsp/README.md` for how to add a test fixture for the new server.

## Example: basedpyright

```lua
-- lsp/basedpyright.lua
return {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
  settings = {
    basedpyright = {
      disableOrganizedImports = true,
      analysis = {
        diagnosticMode = "openFilesOnly",
      },
    },
  },
}
```

## How it works

Neovim 0.11 automatically discovers `lsp/*.lua` files on the `runtimepath`. When `vim.lsp.enable('name')` is called, Neovim loads `lsp/name.lua`, watches for buffers matching `filetypes`, and starts/attaches the client when a matching buffer is opened in a workspace that has the expected `root_markers`.

The existing `LspAttach` autocmd in `lua/plugins/lsp/augroups.lua` fires for all LSP clients regardless of how they were started, so keymaps and document highlighting work automatically.
