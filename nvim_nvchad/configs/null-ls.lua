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

  -- bash formatting
  formatting.beautysh,

  formatting.ruff.with {
    args = {
      "check",
      "--extend-select",
      "I",
      "--fix",
      "--line-length=120",
      "--stdin-filename",
      "$FILENAME",
      "-",
    },
  },

  formatting.ruff.with {
    args = {
      "format",
      "--line-length=120",
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
