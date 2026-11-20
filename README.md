# ⚡ Neovim VS Code Edition — FiraCode Nerd Font & Modular Lua IDE (`C:\_neovim`)

Setup Neovim modern bergaya **Visual Studio Code** berbasis **100% Lua** (menggunakan **Lazy.nvim**) dengan font **FiraCode Nerd Font** (mendukung *ligatures* & ikon lengkap), **Baris Tab Atas**, **Breadcrumbs Berikon + Tombol Klik Mouse**, **Sidebar Multi-Tab (` Files |  Git | 󰓩 Tabs`)**, **Panel Terminal Bawah yang Bisa Dibuka/Ditutup Cepat (`Ctrl + T` / Klik Mouse)**, serta **Halaman Git Lengkap (`Neogit` & `Diffview`)**.

---

## ✨ Fitur Utama yang Telah Terpasang

1. **󰛖 Font FiraCode Nerd Font (Teks + Ikon Lengkap)**:
   - Font **`FiraCode Nerd Font`** telah diunduh ke `C:\_neovim\fonts\`, diinstal ke Windows Fonts, serta otomatis diaktifkan pada **Windows Terminal**, **VS Code Integrated Terminal**, dan **Neovim (`guifont`)**.
   - Dilengkapi **3 paket ikon** sekaligus: **`nvim-web-devicons`** (ikon file HTML ``, CSS ``, JS ``, Lua ``, Markdown ``, gambar `󰸭`), **`mini.icons`**, dan **`lspkind.nvim`** (ikon menu autocomplete ala VS Code).

2. ** Panel Terminal Bawah yang Mudah Dibuka & Ditutup**:
   - **Lewat Keyboard (Berfungsi Saat Mengedit Kode MAUPUN Saat Kursor di Dalam Terminal)**:
     - Tekan **`Ctrl + t`** atau **`Ctrl + \`** atau **`Alt + t`** atau **`F7`** untuk **Membuka** dan **Menutup** panel terminal bawah.
     - Tekan **`<Space> tt`** (di Normal Mode) untuk buka/tutup panel terminal bawah, atau **`<Space> tf`** untuk terminal mengambang (*Floating Terminal*).
     - Saat berada di dalam terminal, Anda juga bisa menekan **`Esc` 2x** (atau **`jk`**) lalu tekan **`q`** untuk menutup terminal.
   - **Lewat Klik Mouse (1x Klik)**:
     - Klik tombol **`[  Buka Terminal (Ctrl+T) ]`** di pojok kanan atas editor atau di statusbar bawah untuk membuka terminal.
     - Klik tombol **`[  Tutup Terminal (Ctrl+T) ]`** di pojok kanan atas panel terminal untuk menutupnya.

3. **📑 Baris Tab Atas (`Bufferline`) & Breadcrumb Bar Berikon (`Winbar`)**:
   - Menampilkan ikon warna asli setiap file (` index.html`, ` style.css`, ` map.js`), indikator modifikasi (`●`), diagnostik error/warning (` / `), serta tombol tutup **`[󰅖]`**.
   - Di kanan atas Breadcrumb Bar tersedia 3 tombol interaktif yang bisa diklik dengan mouse: **`[  Buka/Tutup Terminal ]`**, **`[  Git ]`**, dan **`[  Run (F5) ]`**.

4. ** Sidebar Kiri Multi-Tab (`Neo-tree`) &  3 Halaman Git**:
   - Tekan **`Ctrl + b`** atau **`<Space> e`** untuk membuka/menutup Sidebar Kiri (` Files`, ` Git`, `󰓩 Tabs`).
   - Tekan **`<Space> gg`** untuk membuka **Halaman Git Source Control (`Neogit`)**.
   - Tekan **`<Space> gd`** untuk membuka **Halaman Git Diff Side-by-Side (`Diffview`)**.

---

## ⌨️ Daftar Shortcut Cepat (Leader Key = `Space`)

###  Shortcut Buka & Tutup Terminal
| Cara / Shortcut | Fungsi |
| :--- | :--- |
| **`Ctrl + t`** *(di Editor / di dalam Terminal)* | **Buka / Tutup Panel Terminal Bawah** |
| **`Ctrl + \`** *(di Editor / di dalam Terminal)* | **Buka / Tutup Panel Terminal Bawah** |
| **`Alt + t`** atau **`F7`** | **Buka / Tutup Panel Terminal Bawah** |
| **`<Space> tt`** | Buka / Tutup Panel Terminal Bawah |
| **`<Space> tf`** | Buka / Tutup Terminal Mengambang (*Floating Terminal*) |
| **`Esc` 2x** (atau **`jk`**) lalu **`q`** | Keluar dari mode ketik terminal lalu tutup panel terminal |
| **Klik Mouse `[  Buka/Tutup Terminal ]`** | Klik tombol di pojok kanan atas editor / terminal / statusbar bawah |

### 🔥 Shortcut Utama Bergaya VS Code
| Shortcut | Fungsi |
| :--- | :--- |
| **`Ctrl + b`** atau **`<Space> e`** | **Buka / Tutup Sidebar Kiri** (` Files` / ` Git` / `󰓩 Tabs`) |
| **`Ctrl + p`** atau **`<Space> ff`** | **Quick Open File** — Cari & buka file cepat di proyek |
| **`Ctrl + f`** | **Find in File** — Cari kata di dalam file yang sedang dibuka |
| **`Ctrl + s`** atau **`<Space> w`** | **Save File** — Simpan perubahan file |
| **`Tab`** / **`Shift + Tab`** | Pindah ke Tab Berikutnya / Sebelumnya |
| **`Alt + 1`** s/d **`Alt + 9`** | Lompat langsung ke Tab nomor `1` s/d `9` |
| **`<Space> x`** atau **`<Space> bd`** | **Tutup Tab Aktif** (Sidebar tetap terbuka rapi) |
| **`F5`** atau **`<Space> rr`** | **Run Code** — Jalankan file aktif (`.html` ke browser, `.js`, `.py`, `.lua`, `.c`, `.cpp`) |
| **`<Space> gg`** atau **`:GitPage`** | Buka **Halaman Git Source Control (Neogit)** |
| **`<Space> gd`** atau **`:GitDiff`** | Buka **Halaman Git Diff Side-by-Side (Diffview)** |
| **`<Space> gh`** atau **`:GitHistory`** | Buka **Halaman Riwayat Commit Git (Git Log)** |
| **`<Space> tv`** atau **`:VSCodeTheme`** | Gunakan tema warna asli **VS Code Dark+** |
