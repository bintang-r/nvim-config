-- ============================================================================
-- NEOVIM LUA CONFIGURATION — MUHAMMAD BINTANG (VS CODE EDITION)
-- Location : C:\_neovim\init.lua
-- Font     : FiraCode Nerd Font
-- Shortcuts: 100% Standar VS Code (Ctrl / Alt / F1-F12 — Tanpa Kombinasi Space)
-- ============================================================================

-- Nonaktifkan netrw bawaan agar Sidebar Neo-tree bekerja optimal
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Tambahkan compiler GCC dari MSYS2 jika tersedia di Windows
if vim.fn.isdirectory("C:\\msys64\\ucrt64\\bin") == 1 then
  vim.env.PATH = "C:\\msys64\\ucrt64\\bin;" .. vim.env.PATH
end

-- 1. Muat konfigurasi inti (Options, VS Code Keymaps, Autocommands)
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- 2. Muat Plugin Manager (lazy.nvim) beserta daftar plugin di lua/plugins/
require("core.lazy")

-- 3. Muat modul Lua kustom (Duplikat, Buat File/Folder, Terminal, Runner, Winbar)
require("custom")
