-- ============================================================================
-- NEOVIM LUA CONFIGURATION — MUHAMMAD BINTANG (VS CODE EDITION)
-- Copyright (c) 2026 Muhammad Bintang. All Rights Reserved.
-- Licensed under Exclusive Proprietary License (Dilarang Digunakan Tanpa Izin)
-- Location : C:\_neovim\init.lua
-- ============================================================================

-- 0. PROTEKSI LISENSI PERANGKAT (Blokir otomatis jika dijalankan di perangkat orang lain!)
local license_ok, license = pcall(require, "core.license")
if license_ok and not license.enforce() then
  return
end

-- Nonaktifkan netrw bawaan agar Sidebar Neo-tree bekerja optimal
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Tambahkan compiler GCC dari MSYS2 jika tersedia di Windows
if vim.fn.isdirectory("C:\\msys64\\ucrt64\\bin") == 1 then
  vim.env.PATH = "C:\\msys64\\ucrt64\\bin;" .. vim.env.PATH
end

-- ripgrep lokal (dibutuhkan Telescope live_grep & TodoTelescope)
if vim.fn.isdirectory("C:\\_neovim\\bin") == 1 then
  vim.env.PATH = "C:\\_neovim\\bin;" .. vim.env.PATH
end

-- 1. Muat konfigurasi inti (Bahasa, Options, VS Code Keymaps, Autocommands)
require("core.i18n")
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- 2. Muat Plugin Manager (lazy.nvim) beserta daftar plugin di lua/plugins/
require("core.lazy")

-- 3. Muat modul Lua kustom (Duplikat, Buat File/Folder, Multi-Terminal, Runner, Winbar, Project Picker)
require("custom")
require("custom.project")

-- 4. Command :Tohtml (Ekspor kode berwarna di buffer menjadi file HTML)
vim.api.nvim_create_user_command("Tohtml", function(args)
  vim.cmd.packadd("nvim.tohtml")
  vim.cmd.TOhtml({
    range = { args.line1, args.line2 },
    args = args.args ~= "" and { args.args } or {},
  })
end, {
  bar = true,
  nargs = "?",
  range = "%",
  complete = "file",
  desc = "Konversi kode di buffer menjadi file HTML berwarna",
})
