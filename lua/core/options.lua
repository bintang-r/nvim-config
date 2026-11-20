-- ============================================================================
-- CORE MODULE: Editor Options (lua/core/options.lua)
-- Font Default: FiraCode Nerd Font (Mendukung Ligatures & Ikon Lengkap)
-- ============================================================================

local opt = vim.opt

-- Aktifkan Dukungan Penuh Nerd Font Icons & Fira Code Font
vim.g.have_nerd_font = true
opt.guifont = "FiraCode Nerd Font:h12,FiraCode Nerd Font Mono:h12,Fira Code:h12"

-- Nomor Baris & Tampilan Visual
opt.number = true             -- Tampilkan nomor baris
opt.relativenumber = true     -- Nomor baris relatif untuk navigasi cepat
opt.cursorline = true         -- Highlight baris kursor aktif
opt.signcolumn = "yes"        -- Selalu tampilkan sign column (untuk ikon Git & LSP)
opt.termguicolors = true      -- Aktifkan warna 24-bit True Color
opt.showmode = false          -- Mode sudah ditampilkan oleh Lualine beserta ikonnya
opt.wrap = false              -- Jangan melipat baris panjang secara default
opt.scrolloff = 8             -- Jaga jarak minimal 8 baris saat scroll vertikal
opt.sidescrolloff = 8         -- Jaga jarak minimal 8 kolom saat scroll horizontal
opt.cmdheight = 1             -- Tinggi baris perintah
opt.laststatus = 3            -- Global statusline tunggal ala VS Code
opt.showtabline = 2           -- Selalu tampilkan baris Tab di bagian atas

-- Indentasi & Tab (2 Spasi Modern untuk Web/Lua/JS/TS)
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true          -- Gunakan spasi alih-alih karakter Tab
opt.smartindent = true
opt.autoindent = true

-- Pencarian
opt.ignorecase = true         -- Abaikan huruf besar/kecil saat mencari
opt.smartcase = true          -- Peka huruf besar jika kata kunci mengandung huruf kapital
opt.hlsearch = true           -- Highlight hasil pencarian
opt.incsearch = true          -- Tampilkan hasil pencarian secara inkremental

-- Clipboard, Mouse & File
opt.clipboard = "unnamedplus" -- Sinkronkan clipboard dengan Windows (Ctrl+C / Ctrl+V)
opt.mouse = "a"               -- Aktifkan dukungan mouse penuh (klik tab, sidebar, tombol terminal)
opt.mousemoveevent = true     -- Aktifkan efek hover mouse pada tab Bufferline
opt.undofile = true           -- Simpan riwayat undo meski file ditutup
opt.swapfile = false          -- Nonaktifkan swapfile yang mengganggu
opt.backup = false
opt.updatetime = 200          -- Respons cepat untuk CursorHold & GitSigns
opt.timeoutlen = 300          -- Waktu tunggu kombinasi tombol (Which-Key)

-- Perilaku Split Window
opt.splitright = true         -- Vertical split baru muncul di sebelah kanan
opt.splitbelow = true         -- Horizontal split baru (termasuk Terminal) muncul di bawah

-- Karakter Visual & Ikon Indikator
opt.list = true
opt.listchars = { tab = "▸ ", trail = "·", nbsp = "␣" }
opt.fillchars = {
  eob = " ",
  fold = " ",
  foldopen = "",
  foldsep = " ",
  foldclose = "",
  diff = "╱",
}

-- Gunakan PowerShell di Windows bila tersedia
if vim.fn.has("win32") == 1 then
  opt.shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
  opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
  opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  opt.shellquote = ""
  opt.shellxquote = ""
end
