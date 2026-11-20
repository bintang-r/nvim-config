-- ============================================================================
-- PLUGIN MODULE: Mason, LSP & Code Formatting (lua/plugins/lsp.lua)
-- Shortcut Standar VS Code: F8 / Alt+Shift+F (Format), F12 (Go to Definition)
-- ============================================================================

return {
  -- 1. Mason (Installer LSP Server, Linter & Formatter: ketik :Mason)
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- 1b. MASON-LSPCONFIG: otomatis pasang & aktifkan server LSP yang terpasang di VS Code
  --     (Intelephense, Tailwind, TS, Vue, Svelte, Prisma, Go, Python, C/C++, Java, Kotlin, dll.)
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        "lua_ls",
        "intelephense",   -- VS Code: bmewburn.vscode-intelephense-client
        "tailwindcss",    -- VS Code: bradlc.vscode-tailwindcss
        "ts_ls",          -- VS Code: ms-vscode.vscode-typescript-next
        "html",
        "cssls",
        "jsonls",
        "eslint",         -- VS Code: dbaeumer.vscode-eslint
        -- volar sudah diwakili vue_ls di Mason (volar tidak punya mapping paket)
        "vue_ls",         -- VS Code: vue.volar
        "svelte",         -- VS Code: svelte.svelte-vscode
        "prismals",       -- VS Code: prisma.prisma
        "gopls",          -- VS Code: golang.go
        "pyright",        -- VS Code: ms-python.python / pylance
        "clangd",         -- VS Code: ms-vscode.cpptools
        "bashls",
        "yamlls",
        "dockerls",       -- VS Code: ms-azuretools.vscode-docker
        "cmake",          -- VS Code: ms-vscode.cmake-tools
        "jdtls",          -- VS Code: redhat.java
        -- csharp_ls & dartls tidak tersedia di Mason; pasang via dotnet/Dart SDK bila perlu.
        "kotlin_language_server", -- VS Code: fwcd.kotlin / mathiasfrohlich.kotlin
        -- gdscript tidak tersedia di Mason; gunakan Godot + gdtoolkit bila perlu.
      },
      -- Nvim 0.11: aktifkan otomatis server yang sudah terpasang via vim.lsp.enable()
      automatic_enable = true,
    },
  },

  -- 2. Konfigurasi Diagnostic & Keymap LSP Bergaya VS Code
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "󰌵",
            [vim.diagnostic.severity.INFO] = "",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded" },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
        callback = function(ev)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = "LSP: " .. desc })
          end
          map("<F12>", vim.lsp.buf.definition, "Go to Definition (F12)")
          map("gd", vim.lsp.buf.definition, "Go to Definition")
          map("<S-F12>", vim.lsp.buf.references, "Show References (Shift+F12)")
          map("gr", vim.lsp.buf.references, "Show References")
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("<A-.>", vim.lsp.buf.code_action, "Quick Fix / Code Action (Alt+.)")
          map("[d", vim.diagnostic.goto_prev, "Diagnostic Sebelumnya")
          map("]d", vim.diagnostic.goto_next, "Diagnostic Berikutnya")
        end,
      })
    end,
  },

  -- 3. Conform.nvim (Format Kode dengan F8 atau Alt+Shift+F seperti VS Code)
  {
    "stevearc/conform.nvim",
    keys = {
      {
        "<F8>",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = { "n", "i", "v" },
        desc = "✨ Format Kode Otomatis (F8)",
      },
      {
        "<A-S-f>",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = { "n", "i", "v" },
        desc = "✨ Format Kode Otomatis (Alt+Shift+F)",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
        python = { "black" },
      },
    },
  },
}
