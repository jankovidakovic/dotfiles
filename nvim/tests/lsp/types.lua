---@class lsp_test.DiagnosticExpectation
---@field line integer 1-indexed line where the diagnostic should appear
---@field pattern string Lua pattern matched against the diagnostic message

---@class lsp_test.DiagnosticsSpec
---@field file string Fixture file containing known errors
---@field expected lsp_test.DiagnosticExpectation[] Diagnostics that MUST appear
---@field clean_file? string File that must produce 0 diagnostics

---@class lsp_test.DefinitionSpec
---@field file string Fixture file to open
---@field cursor integer[] {line, col} 1-indexed position to place cursor
---@field target_file? string Expected target file (nil = any file)
---@field target_line? integer Expected target line (nil = don't check)

---@class lsp_test.Spec
---@field server string LSP server name (must match the name used in vim.lsp / lspconfig)
---@field filetype string Filetype to set on fixture buffers
---@field attach_timeout_ms? integer Max wait for server to attach (default 15000)
---@field diagnostics? lsp_test.DiagnosticsSpec
---@field definition? lsp_test.DefinitionSpec
