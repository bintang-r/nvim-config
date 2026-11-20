-- ============================================================================
-- PLUGIN MODULE: Telescope Fuzzy Finder (lua/plugins/telescope.lua)
-- Shortcut Standar VS Code: Ctrl+P, Ctrl+F, Alt+F / F3, F1 (Tanpa <Space>)
-- ============================================================================

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<C-p>", "<cmd>Telescope find_files<CR>", mode = { "n", "i" }, desc = " Quick Open / Cari File (Ctrl+P)" },
      { "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find<CR>", mode = { "n", "i" }, desc = " Cari Teks di File Ini (Ctrl+F)" },
      { "<A-f>", "<cmd>Telescope live_grep<CR>", mode = { "n", "i" }, desc = "󰊄 Cari Teks di Seluruh Project (Alt+F)" },
      { "<F3>", "<cmd>Telescope live_grep<CR>", mode = { "n", "i" }, desc = "󰊄 Cari Teks di Seluruh Project (F3)" },
      { "<A-b>", "<cmd>Telescope buffers<CR>", mode = { "n", "i" }, desc = "󰓩 Cari Tab / Buffer yang Terbuka (Alt+B)" },
      { "<A-o>", "<cmd>Telescope oldfiles<CR>", mode = { "n", "i" }, desc = " Riwayat File Terakhir Dibuka (Alt+O)" },
      { "<F1>", "<cmd>Telescope keymaps<CR>", mode = { "n", "i" }, desc = " Command Palette & Daftar Shortcut (F1)" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = "   ",
          selection_caret = "  ",
          path_display = { "smart" },
          file_ignore_patterns = {
            "node_modules",
            "%.git/",
            "dist/",
            "build/",
          },
          mappings = {
            i = {
              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<Esc>"] = actions.close,
            },
          },
        },
      })
    end,
  },
}
