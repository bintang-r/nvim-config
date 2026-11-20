-- ============================================================================
-- CORE MODULE: VS Code Style Keymaps (lua/core/keymaps.lua)
-- Semua Shortcut Menggunakan Standar VS Code (Ctrl / Alt / F1-F12)
-- TANPA Perlu Kombinasi Tombol <Space>!
-- ============================================================================

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Keluar dari Insert Mode dengan cepat menggunakan 'jk' atau 'Esc'
keymap("i", "jk", "<ESC>", { desc = "Keluar ke Normal Mode" })
keymap("n", "<Esc>", function()
  vim.cmd("nohlsearch")
  pcall(vim.lsp.buf.clear_references)
end, { desc = "Bersihkan Highlight Pencarian & Referensi LSP" })

-- Lompati karakter '>' secara otomatis di Insert Mode jika sudah ada '>' di sebelah kanan kursor (ala VS Code HTML)
keymap("i", ">", function()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  if line:sub(col + 1, col + 1) == ">" then
    return "<Right>"
  end
  return ">"
end, { expr = true, replace_keycodes = true, desc = "Lompati > otomatis jika sudah ada" })

-- Navigasi baris panjang yang terlipat (wrapped lines) tetap mulus per baris visual
keymap("n", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true, silent = true })
keymap("n", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true, silent = true })

-- ============================================================================
-- 0. BUAT BARIS BARU (NEW LINE) PERSIS VS CODE (Enter, Ctrl+Enter, Alt+Enter)
-- ============================================================================
-- Di Normal Mode (saat baru klik baris kode): Tekan ENTER langsung buat baris baru & masuk Mode Ketik (Insert)!
keymap("n", "<CR>", function()
  local bt = vim.bo.buftype
  local ft = vim.bo.filetype
  if bt ~= "" or not vim.bo.modifiable or ft == "neo-tree" or ft == "alpha" or ft == "qf" then
    return "<CR>"
  end
  return "o"
end, { expr = true, noremap = true, silent = true, desc = "↵ Buat Baris Baru & Masuk Mode Ketik (Enter)" })

-- Buat Baris Baru di Bawah dari posisi tengah baris mana pun (Ctrl+Enter atau Shift+Enter) ala VS Code
keymap("n", "<C-CR>", "o", { desc = "↵ Buat Baris Baru di Bawah (Ctrl+Enter)" })
keymap("i", "<C-CR>", "<Esc>o", { desc = "↵ Buat Baris Baru di Bawah (Ctrl+Enter)" })
keymap("n", "<S-CR>", "o", { desc = "↵ Buat Baris Baru di Bawah (Shift+Enter)" })
keymap("i", "<S-CR>", "<Esc>o", { desc = "↵ Buat Baris Baru di Bawah (Shift+Enter)" })

-- Buat Baris Baru di Atas baris aktif (Alt+Enter atau Ctrl+Shift+Enter) ala VS Code
keymap("n", "<A-CR>", "O", { desc = "↵ Buat Baris Baru di Atas (Alt+Enter)" })
keymap("i", "<A-CR>", "<Esc>O", { desc = "↵ Buat Baris Baru di Atas (Alt+Enter)" })
keymap("n", "<C-S-CR>", "O", { desc = "↵ Buat Baris Baru di Atas (Ctrl+Shift+Enter)" })
keymap("i", "<C-S-CR>", "<Esc>O", { desc = "↵ Buat Baris Baru di Atas (Ctrl+Shift+Enter)" })

-- Di Normal Mode: Tekan Backspace pada file kode akan menghapus karakter ke kiri & masuk mode ketik seperti VS Code
keymap("n", "<BS>", function()
  local bt = vim.bo.buftype
  local ft = vim.bo.filetype
  if bt ~= "" or not vim.bo.modifiable or ft == "neo-tree" or ft == "alpha" or ft == "qf" then
    return "<BS>"
  end
  return "i<BS>"
end, { expr = true, noremap = true, silent = true, desc = "⌫ Hapus Karakter & Masuk Mode Ketik (Backspace)" })

-- ============================================================================
-- 1. UNDO, REDO, SAVE, SELECT ALL (Ctrl+Z, Ctrl+Y, Ctrl+S, Ctrl+A)
-- ============================================================================
-- Undo (Ctrl + Z) di Normal, Insert, dan Visual Mode
keymap("n", "<C-z>", "u", { desc = "↩️ Undo (Ctrl+Z)" })
keymap("i", "<C-z>", "<C-o>u", { desc = "↩️ Undo (Ctrl+Z)" })
keymap("v", "<C-z>", "<Esc>u", { desc = "↩️ Undo (Ctrl+Z)" })

-- Redo (Ctrl + Y) di Normal, Insert, dan Visual Mode
keymap("n", "<C-y>", "<C-r>", { desc = "↪️ Redo (Ctrl+Y)" })
keymap("i", "<C-y>", "<C-o><C-r>", { desc = "↪️ Redo (Ctrl+Y)" })
keymap("v", "<C-y>", "<Esc><C-r>", { desc = "↪️ Redo (Ctrl+Y)" })

-- Save File (Ctrl + S) di semua mode
keymap("n", "<C-s>", "<cmd>w<CR>", { desc = "💾 Simpan File (Ctrl+S)" })
keymap("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "💾 Simpan File (Ctrl+S)" })
keymap("v", "<C-s>", "<Esc><cmd>w<CR>", { desc = "💾 Simpan File (Ctrl+S)" })

-- Select All / Blok Semua (Ctrl + A) di semua mode
keymap("n", "<C-a>", "ggVG", { desc = "🔲 Select All / Blok Semua (Ctrl+A)" })
keymap("i", "<C-a>", "<Esc>ggVG", { desc = "🔲 Select All / Blok Semua (Ctrl+A)" })
keymap("v", "<C-a>", "<Esc>ggVG", { desc = "🔲 Select All / Blok Semua (Ctrl+A)" })

-- ============================================================================
-- 1b. SELECT BAGIAN CODE TERTENTU ALA VS CODE (Shift+Panah, Ctrl+L, Alt+D, Alt+A/Z)
-- ============================================================================
local function insert_select_right(motion)
  return function()
    if vim.fn.col(".") == 1 then
      return "<Esc>v" .. (motion or "")
    end
    return "<Esc>lv" .. (motion or "")
  end
end

local function insert_select_left(motion)
  return function()
    if vim.fn.col(".") == 1 then
      return "<Esc>v" .. (motion or "<Left>")
    end
    return "<Esc>v" .. (motion or "")
  end
end

-- Select karakter per karakter & baris per baris (Shift + Panah)
keymap("n", "<S-Left>", "v<Left>", { desc = "🔲 Select ke Kiri (Shift+Left)" })
keymap("n", "<S-Right>", "v<Right>", { desc = "🔲 Select ke Kanan (Shift+Right)" })
keymap("n", "<S-Up>", "v<Up>", { desc = "🔲 Select ke Atas (Shift+Up)" })
keymap("n", "<S-Down>", "v<Down>", { desc = "🔲 Select ke Bawah (Shift+Down)" })

keymap("i", "<S-Left>", insert_select_left(""), { expr = true, replace_keycodes = true, desc = "🔲 Select ke Kiri (Shift+Left)" })
keymap("i", "<S-Right>", insert_select_right(""), { expr = true, replace_keycodes = true, desc = "🔲 Select ke Kanan (Shift+Right)" })
keymap("i", "<S-Up>", "<Esc>v<Up>", { desc = "🔲 Select ke Atas (Shift+Up)" })
keymap("i", "<S-Down>", "<Esc>v<Down>", { desc = "🔲 Select ke Bawah (Shift+Down)" })

keymap("v", "<S-Left>", "<Left>", { desc = "🔲 Perluas Select ke Kiri (Shift+Left)" })
keymap("v", "<S-Right>", "<Right>", { desc = "🔲 Perluas Select ke Kanan (Shift+Right)" })
keymap("v", "<S-Up>", "<Up>", { desc = "🔲 Perluas Select ke Atas (Shift+Up)" })
keymap("v", "<S-Down>", "<Down>", { desc = "🔲 Perluas Select ke Bawah (Shift+Down)" })

-- Select per kata (Ctrl + Shift + Left / Right)
keymap("n", "<C-S-Left>", "vb", { desc = "🔲 Select 1 Kata ke Kiri (Ctrl+Shift+Left)" })
keymap("n", "<C-S-Right>", "ve", { desc = "🔲 Select 1 Kata ke Kanan (Ctrl+Shift+Right)" })
keymap("i", "<C-S-Left>", "<Esc>vb", { desc = "🔲 Select 1 Kata ke Kiri (Ctrl+Shift+Left)" })
keymap("i", "<C-S-Right>", insert_select_right("e"), { expr = true, replace_keycodes = true, desc = "🔲 Select 1 Kata ke Kanan (Ctrl+Shift+Right)" })
keymap("v", "<C-S-Left>", "b", { desc = "🔲 Perluas Select 1 Kata ke Kiri (Ctrl+Shift+Left)" })
keymap("v", "<C-S-Right>", "e", { desc = "🔲 Perluas Select 1 Kata ke Kanan (Ctrl+Shift+Right)" })

-- Select sampai awal / akhir baris (Shift + Home / Shift + End)
keymap("n", "<S-Home>", "v^", { desc = "🔲 Select ke Awal Baris (Shift+Home)" })
keymap("n", "<S-End>", "v$", { desc = "🔲 Select ke Akhir Baris (Shift+End)" })
keymap("i", "<S-Home>", "<Esc>v^", { desc = "🔲 Select ke Awal Baris (Shift+Home)" })
keymap("i", "<S-End>", insert_select_right("$"), { expr = true, replace_keycodes = true, desc = "🔲 Select ke Akhir Baris (Shift+End)" })
keymap("v", "<S-Home>", "^", { desc = "🔲 Perluas Select ke Awal Baris (Shift+Home)" })
keymap("v", "<S-End>", "$", { desc = "🔲 Perluas Select ke Akhir Baris (Shift+End)" })

-- Select 1 Baris Penuh & perluas ke baris bawah (Ctrl + L, persis VS Code)
keymap("n", "<C-l>", "V", { desc = "🔲 Select 1 Baris Penuh (Ctrl+L)" })
keymap("i", "<C-l>", "<Esc>V", { desc = "🔲 Select 1 Baris Penuh (Ctrl+L)" })
keymap("v", "<C-l>", function()
  return vim.fn.mode() == "V" and "j" or "V"
end, { expr = true, desc = "🔲 Perluas Select ke Baris Bawah (Ctrl+L)" })

-- Select 1 Kata Aktif di bawah kursor (Alt + D)
keymap("n", "<A-d>", "viw", { desc = "🔲 Select 1 Kata Aktif (Alt+D)" })
keymap("i", "<A-d>", "<Esc>viw", { desc = "🔲 Select 1 Kata Aktif (Alt+D)" })

-- Hapus blok terpilih dengan Backspace / Delete tanpa menimpa clipboard
keymap("v", "<BS>", '"_d', { desc = "⌫ Hapus Blok Terpilih (Backspace)" })
keymap("v", "<Del>", '"_d', { desc = "🗑️ Hapus Blok Terpilih (Delete)" })

-- ============================================================================
-- 2. COPY, CUT, PASTE ALA VS CODE (Ctrl+C, Ctrl+X, Ctrl+V)
-- ============================================================================
-- Copy (Ctrl + C): Jika diblok menyalin blok, jika tidak diblok menyalin 1 baris aktif
keymap("v", "<C-c>", '"+y', { desc = "📋 Copy Teks yang Diblok (Ctrl+C)" })
keymap("n", "<C-c>", '"+yy', { desc = "📋 Copy Baris Aktif (Ctrl+C)" })

-- Cut (Ctrl + X): Jika diblok memotong blok, jika tidak diblok memotong 1 baris aktif
keymap("v", "<C-x>", '"+d', { desc = "✂️ Cut Teks yang Diblok (Ctrl+X)" })
keymap("n", "<C-x>", '"+dd', { desc = "✂️ Cut Baris Aktif (Ctrl+X)" })
keymap("i", "<C-x>", '<C-o>"+dd', { desc = "✂️ Cut Baris Aktif (Ctrl+X)" })

-- Paste (Ctrl + V): Tempel dari Clipboard Windows di Normal, Insert, dan Visual Mode
keymap("n", "<C-v>", function()
  if not vim.bo.modifiable then
    return ""
  end
  return '"+p'
end, { expr = true, noremap = true, silent = true, desc = "📥 Paste dari Clipboard (Ctrl+V)" })
keymap("i", "<C-v>", "<C-r>+", { desc = "📥 Paste dari Clipboard (Ctrl+V)" })
keymap("v", "<C-v>", '"+p', { desc = "📥 Paste dari Clipboard (Ctrl+V)" })
-- Visual Block Mode tetap bisa diakses lewat Alt + V
keymap("n", "<A-v>", "<C-v>", { desc = "Visual Block Mode (Alt+V)" })

-- Pengaman Terminal Bracketed Paste (Windows Terminal Ctrl+V) di buffer read-only / Sidebar Neo-tree
-- Mencegah error E21 ('modifiable' is off) sekaligus meneruskan Ctrl+V di Neo-tree ke Paste File!
if not vim.g._safe_paste_installed then
  vim.g._safe_paste_installed = true
  local orig_paste = vim.paste
  vim.paste = function(lines, phase)
    local mode = vim.api.nvim_get_mode().mode
    -- Biarkan paste normal di Command-line (:) dan Terminal (PowerShell)
    if mode:sub(1, 1) == "c" or mode:sub(1, 1) == "t" then
      return orig_paste(lines, phase)
    end

    if vim.bo.filetype == "neo-tree" then
      if phase == -1 or phase == 1 then
        vim.schedule(function()
          local ok_mgr, manager = pcall(require, "neo-tree.sources.manager")
          if ok_mgr then
            local state = manager.get_state("filesystem")
            if state and state.clipboard and next(state.clipboard) ~= nil then
              if state.resolved_mappings and state.resolved_mappings["p"] and state.resolved_mappings["p"].handler then
                state.resolved_mappings["p"].handler()
              else
                local ok_cmd, fs_cmds = pcall(require, "neo-tree.sources.filesystem.commands")
                if ok_cmd then
                  state.config = state.config or {}
                  fs_cmds.paste_from_clipboard(state)
                end
              end
            else
              vim.notify(
                "💡 Di Sidebar: tekan 'y' / 'Alt+C' (Copy) atau 'x' / 'Alt+X' (Cut) pada file/folder dulu, lalu 'p' / 'Alt+V' / 'Ctrl+V' untuk Paste.",
                vim.log.levels.INFO
              )
            end
          end
        end)
      end
      return false
    end

    if not vim.bo.modifiable then
      return false
    end

    return orig_paste(lines, phase)
  end
end

-- ============================================================================
-- 3. MOVE LINE UP / DOWN & DELETE LINE ALA VS CODE (Alt+Up/Down, Alt+K)
-- ============================================================================
-- Geser Baris ke Bawah (Alt + Down atau Alt + J)
keymap("n", "<A-Down>", "<cmd>m .+1<CR>==", { desc = "⬇️ Geser Baris ke Bawah (Alt+Down)" })
keymap("i", "<A-Down>", "<Esc><cmd>m .+1<CR>==gi", { desc = "⬇️ Geser Baris ke Bawah (Alt+Down)" })
keymap("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "⬇️ Geser Blok ke Bawah (Alt+Down)" })
keymap("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "⬇️ Geser Baris ke Bawah (Alt+J)" })
keymap("i", "<A-j>", "<Esc><cmd>m .+1<CR>==gi", { desc = "⬇️ Geser Baris ke Bawah (Alt+J)" })
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "⬇️ Geser Blok ke Bawah (Alt+J)" })

-- Geser Baris ke Atas (Alt + Up atau Alt + K)
keymap("n", "<A-Up>", "<cmd>m .-2<CR>==", { desc = "⬆️ Geser Baris ke Atas (Alt+Up)" })
keymap("i", "<A-Up>", "<Esc><cmd>m .-2<CR>==gi", { desc = "⬆️ Geser Baris ke Atas (Alt+Up)" })
keymap("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "⬆️ Geser Blok ke Atas (Alt+Up)" })
keymap("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "⬆️ Geser Baris ke Atas (Alt+K)" })
keymap("i", "<A-k>", "<Esc><cmd>m .-2<CR>==gi", { desc = "⬆️ Geser Baris ke Atas (Alt+K)" })
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "⬆️ Geser Blok ke Atas (Alt+K)" })

-- Hapus Baris Instan (Alt + Backspace atau Ctrl + Shift + K)
keymap("n", "<A-BS>", '"_dd', { desc = "🗑️ Hapus Baris Aktif (Alt+Backspace)" })
keymap("i", "<A-BS>", '<C-o>"_dd', { desc = "🗑️ Hapus Baris Aktif (Alt+Backspace)" })

-- Indentasi dengan Tab / Shift+Tab saat memblok teks (Visual Mode) seperti VS Code
keymap("v", "<Tab>", ">gv", { desc = "Indent Kanan (Tab)" })
keymap("v", "<S-Tab>", "<gv", { desc = "Indent Kiri (Shift+Tab)" })
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- ============================================================================
-- 4. NAVIGASI WINDOW, SPLIT EDITOR & KELUAR (Ctrl+Panah, Alt+\, Alt+-, Ctrl+Q)
-- ============================================================================
-- Pindah Fokus Kursor Antar Window (Sidebar / Editor / Terminal) dengan Ctrl + Panah
keymap("n", "<C-Left>", "<C-w>h", { desc = "⬅️ Fokus ke Window/Sidebar Kiri" })
keymap("n", "<C-Down>", "<C-w>j", { desc = "⬇️ Fokus ke Window/Terminal Bawah" })
keymap("n", "<C-Up>", "<C-w>k", { desc = "⬆️ Fokus ke Window Atas" })
keymap("n", "<C-Right>", "<C-w>l", { desc = "➡️ Fokus ke Window Editor Kanan" })

-- Ubah Ukuran Window dengan Alt + Shift + Panah
keymap("n", "<A-S-Up>", "<cmd>resize +2<CR>", opts)
keymap("n", "<A-S-Down>", "<cmd>resize -2<CR>", opts)
keymap("n", "<A-S-Left>", "<cmd>vertical resize -2<CR>", opts)
keymap("n", "<A-S-Right>", "<cmd>vertical resize +2<CR>", opts)

-- Split Layar Editor ala VS Code (Alt + \ untuk Kanan-Kiri, Alt + - untuk Atas-Bawah)
keymap("n", "<A-\\>", "<C-w>v", { desc = "🪟 Split Editor Kanan-Kiri (Alt+\\)" })
keymap("n", "<A-->", "<C-w>s", { desc = "🪟 Split Editor Atas-Bawah (Alt+-)" })
keymap("n", "<A-=>", "<C-w>=", { desc = "🪟 Ratakan Ukuran Split (Alt+=)" })
keymap("n", "<A-q>", "<cmd>close<CR>", { desc = "🪟 Tutup Split Window Aktif (Alt+Q)" })

-- Keluar dari Neovim (Ctrl + Q)
keymap({ "n", "i", "v" }, "<C-q>", "<cmd>confirm qa<CR>", { desc = "🚪 Keluar dari Neovim (Ctrl+Q)" })
