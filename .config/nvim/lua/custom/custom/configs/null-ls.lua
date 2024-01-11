local null_ls = require "null-ls"

local formatting = null_ls.builtins.formatting
local lint = null_ls.builtins.diagnostics

local sources = {

  -- python
  lint.ruff,

  -- Lua
  formatting.stylua,

  -- bash
  lint.shellcheck,

  -- haskell formatting
  formatting.fourmolu,

  -- static type checking for python
  -- null_ls.builtins.diagnostics.mypy,

  formatting.ruff.with {
    args = {
      "check",
      "--extend-select",
      "I",
      "--fix",
      "--stdin-filename",
      "$FILENAME",
      "-",
    },
  },

  formatting.ruff.with {
    args = {
      "format",
      "--stdin-filename",
      "$FILENAME",
      "-",
    },
  },
}

null_ls.setup {
  debug = true,
  sources = sources,
}
