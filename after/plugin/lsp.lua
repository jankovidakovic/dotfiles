local lsp = require('lsp-zero')

lsp.preset('recommended')
lsp.ensure_installed({
    "tsserver"
})

-- Fix Undefined global 'vim'
lsp.configure('lua_ls', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    }
})

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
    ["<C-k>"] = cmp.mapping.select_prev_item(cmp_select),
    ["<C-j>"] = cmp.mapping.select_next_item(cmp_select),
    ["<Tab>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
})


lsp.setup_nvim_cmp({
    mapping = cmp_mappings
})

lsp.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "H", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)

    vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]
end)

-- something about disabling completion with tab,
-- it is supposed to help copilot

lsp.set_preferences({
    suggest_lsp_servers = true,
    sign_icons = {
        error = "E",
        warn = "W",
        hint = "H",
        info = "I"
    }
})

lsp.setup()

vim.diagnostic.config({ virtual_test = true, })

-- null-ls to setup black formatter for python
local null_ls = require("null-ls")
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.black,
        null_ls.builtins.code_actions.shellcheck,
        null_ls.builtins.formatting.beautysh
    },
})

-- lets try setting up pyright here
-- require("mason-lspconfig").setup()
--
-- require("lspconfig").pyright.setup({
-- settings = {
-- python = {
-- analysis = {
-- useLibraryCodeForTypes = true,
-- diagnosticMode = "workspace",
-- typeCheckingMode = "basic", -- off, basic, strict
-- },
-- },
-- },
-- root_dir = function(startpath)
-- return startpath
-- end
-- })
