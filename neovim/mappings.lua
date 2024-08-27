---@type MappingsTable
local M = {}

M.disabled = {

  i = {
    -- go to  beginning and end
    ["<C-b>"] = "",
    ["<C-e>"] = "",

    -- navigate within insert mode
    ["<C-h>"] = "",
    ["<C-l>"] = "",
    ["<C-j>"] = "",
    ["<C-k>"] = "",
  },

  n = {
    ["<C-b>"] = "",
    ["<C-e>"] = "",

    -- save
    ["<C-s>"] = "",

    ["<A-v>"] = "",
    ["<A-h>"] = "",
    ["<leader>h"] = "",
    ["<leader>cc"] = "",
    -- comments
    ["<leader>/"] = "",

    ["<leader>v"] = "", -- the fuck?? why does this suddenly not work??
  },
  v = {
    [">"] = { ">gv", "indent" },

    ["<A-v>"] = "",
    ["<A-h>"] = "",

    ["<leader>/"] = "",
  },
  t = {
    ["<A-v>"] = "",
    ["<A-h>"] = "",
  },
}

-- more keybinds!
--
M.general = {
  n = {
    ["<leader>h"] = { "<C-w>h", "Window left" },
    ["<leader>l"] = { "<C-w>l", "Window right" },
    ["<leader>j"] = { "<C-w>j", "Window down" },
    ["<leader>k"] = { "<C-w>k", "Window up" },
    ["<leader>ds"] = {
      function()
        require("neogen").generate()
      end,
    },
  },
}

M.tabufline = {
  n = {

    ["<A-l>"] = {
      function()
        require("nvchad.tabufline").tabuflineNext()
      end,
      "Goto next buffer",
    },

    ["<A-h>"] = {
      function()
        require("nvchad.tabufline").tabuflinePrev()
      end,
      "Goto prev buffer",
    },

    -- close buffer + hide terminal buffer
    ["<A-w>"] = {
      function()
        require("nvchad.tabufline").close_buffer()
      end,
      "Close buffer",
    },
  },
}

M.comment = {
  -- toggle comment in both modes
  n = {
    ["<leader>cc"] = {
      function()
        require("Comment.api").toggle.linewise.current()
      end,
      "Toggle comment",
    },
  },

  v = {
    ["<leader>cc"] = {
      "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
      "Toggle comment",
    },
  },
}

M.lspconfig = {
  n = {

    ["<leader>vsh"] = {
      function()
        vim.lsp.buf.signature_help()
      end,
      "LSP signature help",
    },

    ["<leader>vd"] = {
      function()
        vim.diagnostic.open_float { border = "rounded" }
      end,
      "Floating diagnostic",
    },

    ["<leader>ca"] = {
      function()
        vim.lsp.buf.code_action()
      end,
      "LSP code action",
    },

    ["<leader>fe"] = {
      function()
        vim.diagnostic.goto_next { wrap = false }
      end,
      "LSP GoTo next error"
    }
  },
}

return M
