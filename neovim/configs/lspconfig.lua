local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

-- if you just want default config for the servers then put them in a table
local servers = { "html", "cssls", "tsserver", "clangd", "hls" }

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

lspconfig["pyright"].setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = lspconfig.util.find_git_ancestor,
  settings = {
    analysis = {
      autoImportCompletions = true,
      extraPaths = vim.fs.dirname(vim.fs.find({"requirements.txt"}, {upward=true})[1])
    },
  },
}
