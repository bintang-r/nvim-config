-- ============================================================================
-- PLUGIN MODULE: Padanan Ekstensi VS Code (lua/plugins/vscode-extensions.lua)
-- Fitur editor yang dulu dipakai di VS Code kini tersedia di Neovim:
-- auto rename tag, warna hex, komentar TODO, Error Lens, WakaTime, Discord.
-- ============================================================================

return {
  -- 1. AUTO RENAME TAG + AUTO CLOSE TAG (formulahendry.auto-rename-tag / auto-close-tag)
  --    Mengganti tag pembuka & penutup bersamaan, dan menutup tag otomatis.
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = false,
      },
      per_filetype = {
        html = { enable_close = true },
        javascriptreact = { enable_close = true },
        typescriptreact = { enable_close = true },
        vue = { enable_close = true },
        svelte = { enable_close = true },
        php = { enable_close = true },
        blade = { enable_close = true },
      },
    },
  },

  -- 2. COLOR HIGHLIGHT (naumovs.color-highlight / anseki.vscode-color / css-peek)
  --    Menampilkan warna asli untuk kode hex, rgb, hsl, nama warna & kelas Tailwind.
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      filetypes = { "*" },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = true,
        RRGGBBAA = true,
        AARRGGBB = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        tailwind = true,
        mode = "virtualtext",
      },
    },
  },

  -- 3. BETTER COMMENTS (aaron-bond.better-comments)
  --    Menyoroti TODO / FIXME / HACK / WARN / NOTE di dalam komentar.
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = true,
      keywords = {
        TODO = { color = "info", icon = "" },
        FIX = { color = "error", icon = "", alt = { "FIXME", "BUG" } },
        WARN = { color = "warning", icon = "", alt = { "WARNING", "XXX" } },
        HACK = { color = "warning", icon = "" },
        PERF = { color = "#F59E0B", icon = "", alt = { "OPTIMIZE" } },
        NOTE = { color = "hint", icon = "", alt = { "INFO" } },
      },
      highlight = { before = "", keyword = "bg" },
    },
    keys = {
      {
        "<A-c>",
        function()
          require("telescope").load_extension("todo-comments")
          vim.cmd("TodoTelescope")
        end,
        desc = "󰓩 Daftar TODO/FIXME di Project (Alt+C)",
      },
    },
  },

  -- 4. ERROR LENS (usernamehw.errorlens) -> Trouble + error inline
  --    Panel daftar error LSP (Alt+M) + pesan error di baris kursor via virtual text.
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<A-m>", "<cmd>Trouble diagnostics toggle<CR>", desc = " Panel Error/Problem (Alt+M)" },
      { "<A-M>", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = " Error di File Ini (Alt+Shift+M)" },
    },
    opts = {
      focus = false,
      auto_close = false,
      warn_no_results = false,
      symbols = {
        error = "",
        warning = "",
        hint = "󰌵",
        information = "",
        other = "",
      },
    },
  },

  -- 5. WAKATIME (wakatime.vscode-wakatime) - memakai ~/.wakatime.cfg yang sudah ada.
  {
    "wakatime/vim-wakatime",
    lazy = false,
  },

  -- 6. DISCORD RICH PRESENCE (icrawl.discord-vscode)
  {
    "andweeb/presence.nvim",
    event = "VeryLazy",
    opts = {
      auto_update = true,
      neovim_image_text = "Neovim - VS Code Edition",
      main_image = "file",
      client_id = "793271441293967371", -- client ID resmi presence.nvim (terdaftar di Discord)
      debounce_timeout = 10,
      enable_line_number = false,
      blacklist = {},
      editing_text = "Menyunting %s",
      file_explorer_text = "Menjelajah %s",
      git_commit_text = "Commit di Git",
      plugin_manager_text = "Mengelola plugin",
      reading_text = "Membaca %s",
      workspace_text = "Working on %s",
      line_number_text = "Baris %s dari %s",
    },
  },
}
