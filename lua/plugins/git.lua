-- ============================================================================
-- PLUGIN MODULE: Full Git Pages (Neogit, Diffview & Gitsigns)
-- Shortcut Standar Tanpa <Space>: Alt+G / F9 (Git Page), F10 (Git Diff), Alt+H / F11 (Git Log)
-- ============================================================================

return {
  -- 1. NEOGIT: Halaman Git Source Control Interaktif (Stage, Commit, Push, Pull, Branch)
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<A-g>", "<cmd>Neogit<CR>", mode = { "n", "i" }, desc = " Buka Halaman Git Source Control (Alt+G)" },
      { "<F9>", "<cmd>Neogit<CR>", mode = { "n", "i" }, desc = " Buka Halaman Git Source Control (F9)" },
    },
    opts = {
      kind = "tab",
      graph_style = "unicode",
      integrations = {
        telescope = true,
        diffview = true,
      },
      signs = {
        hunk = { "", "" },
        item = { "", "" },
        section = { "", "" },
      },
    },
  },

  -- 2. DIFFVIEW.NVIM: Halaman Git Diff Side-by-Side (F10) & Riwayat Commit (Alt+H / F11)
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
    keys = {
      { "<F10>", "<cmd>DiffviewOpen<CR>", mode = { "n", "i" }, desc = " Halaman Git Diff Side-by-Side (F10)" },
      { "<A-h>", "<cmd>DiffviewFileHistory<CR>", mode = { "n", "i" }, desc = " Halaman Riwayat Commit Git (Alt+H)" },
      { "<F11>", "<cmd>DiffviewFileHistory<CR>", mode = { "n", "i" }, desc = " Halaman Riwayat Commit Git (F11)" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        file_history = {
          layout = "diff2_horizontal",
        },
      },
      file_panel = {
        listing_style = "tree",
        win_config = {
          position = "left",
          width = 34,
        },
      },
    },
  },

  -- 3. GITSIGNS: Indikator Perubahan Baris & Inline Git Blame di Editor
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 400,
        virt_text_pos = "eol",
      },
    },
    keys = {
      { "]c", "<cmd>Gitsigns next_hunk<CR>", desc = "Loncat ke Perubahan Git Berikutnya" },
      { "[c", "<cmd>Gitsigns prev_hunk<CR>", desc = "Loncat ke Perubahan Git Sebelumnya" },
    },
  },
}
