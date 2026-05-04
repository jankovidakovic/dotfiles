---@class lint_test.DiagnosticExpectation
---@field line integer 1-indexed line where the diagnostic should appear
---@field pattern string Lua pattern matched against the diagnostic message

---@class lint_test.DiagnosticsSpec
---@field file string Fixture file containing known lint errors
---@field expected lint_test.DiagnosticExpectation[] Diagnostics that MUST appear
---@field clean_file? string File that must produce 0 diagnostics

---@class lint_test.Spec
---@field linter string Linter name (must match nvim-lint linter name)
---@field filetype string Filetype to set on fixture buffers
---@field timeout_ms? integer Max wait for diagnostics to settle (default 15000)
---@field diagnostics lint_test.DiagnosticsSpec
