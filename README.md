# ⚡ Neovim VS Code Edition — FiraCode Nerd Font & Modular Lua IDE (`C:\_neovim`)

Dokumentasi resmi konfigurasi **Neovim v0.11.5 (100% Modular Lua)** yang dirancang dengan pengalaman, tampilan, **Multi-Terminal**, dan **shortcut keyboard standar Visual Studio Code** — **tanpa perlu kombinasi tombol `<Space>`**.

---

## 🌟 Fitur Utama

1. **󰛖 Font FiraCode Nerd Font (Teks + Ligatures + Ikon Lengkap)**:
   - Teks kode menggunakan **FiraCode Nerd Font** (tersimpan di `C:\_neovim\fonts\` & terinstal di Windows Fonts) yang sudah aktif otomatis di **Windows Terminal**, **VS Code Integrated Terminal**, dan **Neovim**.
   - Dilengkapi **3 paket ikon** (`nvim-web-devicons`, `mini.icons`, dan `lspkind.nvim`) untuk menampilkan ikon warna file (`` HTML, `` CSS, `` JS, `` Lua, `` Markdown, `󰸭` Gambar), folder (` / `), status Git (``), hingga ikon *autocomplete*.
2. **📄 Buat File Baru (`Ctrl + N`) & 📁 Buat Directory Baru (`Alt + N`) dengan Popup Mengambang**:
   - Menampilkan **Kotak Input Mengambang (*Floating Input Modal*)** tepat di tengah layar ala VS Code.
   - Bekerja dari mana saja: saat kursor di Editor, saat kursor di Sidebar Kiri (`a`/`n` untuk File, `A`/`N` untuk Folder), maupun lewat **klik mouse** pada tombol **`[ +󰈔 Buat File (Ctrl+N) ]`** dan **`[ + Buat Folder (Alt+N) ]`** di kanan atas editor.
3. ** Multi-Terminal Manager (Bisa Tambah Banyak Terminal & Split Terminal!)**:
   - Buka/sembunyikan panel terminal bawah dengan **`Ctrl + T`** (atau **`Ctrl + \`** / **`F7`**).
   - **Tambah Terminal Baru (`PowerShell #1`, `#2`, `#3`, dst.)** menggunakan **`Alt + =`** atau **`Ctrl + Shift + T`** atau klik tombol **`[ + Tambah Terminal (Alt+=) ]`**.
   - **Pindah antar Tab Terminal** cukup dengan klik mouse pada tab **`[ 1: PowerShell #1 ]` `[ 2: PowerShell #2 ]`** di header terminal, atau tekan **`Alt + [`** dan **`Alt + ]`**.
   - **Split 2 Terminal Berdampingan** (kiri & kanan di panel bawah) dengan **`Alt + \`** (di dalam terminal) atau klik **`[ ◫ Split (Alt+\) ]`**.
4. **⌨️ 100% Shortcut Standar VS Code (Tanpa Kombinasi `<Space>`)**:
   - Semua perintah menggunakan kombinasi **`Ctrl`**, **`Alt`**, atau **`F1`–`F12`** yang langsung bekerja di **Normal Mode**, **Insert Mode**, maupun **Visual Mode** (`Ctrl+Z` Undo, `Ctrl+Y` Redo, `Ctrl+D` Duplikat, `Ctrl+C` Copy, `Ctrl+V` Paste, `Ctrl+S` Save).

---

## 🚀 Cara Membuka Neovim di Project

Buka terminal (PowerShell / Windows Terminal) di dalam folder project Anda, lalu ketik:

```powershell
nvim .
```
*(atau panggil langsung dari `C:\_neovim`:)*
```powershell
C:\_neovim\nvim.cmd .
```
> **Penting**: Jika Neovim sudah terbuka sebelumnya, tutup dulu (`Ctrl + Q` atau `:qa!`) lalu buka kembali dengan `nvim .` agar konfigurasi terbaru dimuat.

---

## ⌨️ Dokumentasi Lengkap Shortcut Keyboard (Standar VS Code — Tanpa `<Space>`)

### 1. 📄 Buat File Baru & 📁 Buat Directory / Folder Baru

| Shortcut / Tombol | Fungsi & Cara Pakai |
| :--- | :--- |
| **`Ctrl + N`** *(atau klik `[+󰈔 Buat File]`)* | **Buat File Baru (Create New File)** — Memunculkan kotak input mengambang di tengah layar. Ketik nama file (misal `baru.html` atau `assets/js/fitur.js`) lalu tekan **`Enter`**. Otomatis membuat folder induknya jika belum ada, membuka file di Tab editor kanan, dan menyegarkan Sidebar. *(Tips: Jika nama diakhiri `/`, misal `folderbaru/`, otomatis dibuat sebagai folder!)* |
| **`Alt + N`** atau **`Ctrl + Shift + N`** *(atau klik `[+ Buat Folder]`)* | **Buat Directory / Folder Baru (Create New Folder)** — Memunculkan kotak input mengambang di tengah layar. Ketik nama folder (misal `components` atau `assets/icons`) lalu tekan **`Enter`**. Otomatis membuat folder dan menampilkannya di Sidebar Kiri. |
| **`F2`** | **Rename File / Folder** — Mengubah nama file yang sedang dibuka (atau file/folder yang sedang disorot di dalam Sidebar). |
| **`Alt + Delete`** | **Hapus File Aktif** — Menghapus file yang sedang dibuka (dengan popup konfirmasi aman `y`) dan menutup tab-nya. |
| **Di dalam Sidebar (`Ctrl + B`)**: | • Tekan **`a`** atau **`n`** atau **`Ctrl + N`** untuk **Buat File Baru** di dalam folder yang disorot<br>• Tekan **`A`** atau **`N`** atau **`Alt + N`** untuk **Buat Directory / Folder Baru**<br>• Tekan **`F2`** atau **`r`** untuk **Rename** file/folder<br>• Tekan **`Delete`** atau **`d`** untuk **Hapus** file/folder |

---

### 2.  Multi-Terminal PowerShell (Buka, Tutup, Tambah Banyak Terminal & Split)

| Cara / Shortcut | Fungsi |
| :--- | :--- |
| **`Ctrl + T`** *(di Editor / di dalam Terminal)* | **Buka / Sembunyikan Panel Terminal Bawah** (semua terminal yang berjalan tetap hidup di latar belakang) |
| **`Ctrl + \`** atau **`F7`** | **Buka / Sembunyikan Panel Terminal Bawah** |
| **`Alt + =`** atau **`Ctrl + Shift + T`** | **➕ Tambah Terminal Baru** (`PowerShell #2`, `PowerShell #3`, dst.) — bisa juga klik **`[ + Tambah Terminal (Alt+=) ]`** di bar atas terminal atau **`[ + Term Baru ]`** di bar atas editor |
| **`Alt + ]`** / **`Alt + [`** *(atau klik Tab Terminal)* | **Pindah ke Tab Terminal Berikutnya / Sebelumnya** (`[ 1: PowerShell #1 ]` ↔ `[ 2: PowerShell #2 ]`) |
| **`Alt + \`** *(di dalam Terminal)* atau klik **`[ ◫ Split ]`** | **Split Terminal Kanan-Kiri** — Membuka 2 terminal berdampingan di panel bawah ala VS Code |
| **`Alt + X`** *(di dalam Terminal)* atau klik **`[ 🗑 Hapus ]`** | **Hapus / Matikan Terminal Aktif** — Menutup 1 tab terminal yang sedang dipilih dan beralih ke tab terminal lainnya |
| **`Alt + T`** | **Buka / Tutup Floating Terminal** (Terminal mengambang di tengah layar) |
| **`Ctrl + ↑`** *(di dalam Terminal)* | Pindah kursor dari Terminal bawah ke Editor kode di atas tanpa menutup terminal |

---

### 3. ✏️ Editing Dasar, Undo/Redo & Duplikat (Persis VS Code)
*Semua shortcut di bawah ini berfungsi langsung baik di **Normal Mode**, **Insert Mode (saat sedang mengetik)**, maupun **Visual Mode (saat memblok teks)**:*

| Shortcut | Fungsi (Standar VS Code) |
| :--- | :--- |
| **`Ctrl + Z`** | **Undo** — Batalkan perubahan terakhir |
| **`Ctrl + Y`** | **Redo** — Ulangi perubahan yang dibatalkan |
| **`Ctrl + D`** | **Duplicate Line / Selection** — Duplikat baris aktif atau blok teks ke bawah |
| **`Shift + Alt + ↓`** | **Duplicate Down** — Duplikat baris atau blok teks ke bawah |
| **`Shift + Alt + ↑`** | **Duplicate Up** — Duplikat baris atau blok teks ke atas |
| **`Alt + ↓`** *(atau `Alt + J`)* | **Move Line Down** — Geser baris atau blok teks ke bawah |
| **`Alt + ↑`** *(atau `Alt + K`)* | **Move Line Up** — Geser baris atau blok teks ke atas |
| **`Ctrl + C`** | **Copy** — Salin teks yang diblok (atau salin 1 baris penuh jika tidak ada yang diblok) |
| **`Ctrl + X`** | **Cut** — Potong teks yang diblok (atau potong 1 baris penuh) |
| **`Ctrl + V`** | **Paste** — Tempel teks dari Clipboard Windows |
| **`Ctrl + A`** | **Select All** — Blok seluruh isi file |
| **`Ctrl + /`** | **Toggle Comment** — Beri atau hapus komentar (`//`, `<!-- -->`, `--`) pada baris/blok kode |
| **`Alt + Backspace`** | **Delete Line** — Hapus 1 baris aktif secara instan |
| **`Tab`** / **`Shift + Tab`** *(saat blok teks)* | **Indent / Outdent** — Geser blok teks ke kanan / ke kiri |
| **`F8`** atau **`Alt + Shift + F`** | **Format Document** — Rapikan kode otomatis (Prettier / Conform / LSP) |
| **`Ctrl + S`** | **Save File** — Simpan perubahan file |

---

### 4. 🔍 Pencarian, Find & Replace, dan Navigasi Cepat

| Shortcut | Fungsi |
| :--- | :--- |
| **`Ctrl + P`** | **Quick Open File** — Cari & buka file apa saja di project dengan cepat |
| **`Ctrl + F`** | **Find in File** — Cari kata/teks di dalam file yang sedang dibuka |
| **`Ctrl + R`** | **Find & Replace in File** — Cari kata dan ganti dengan teks baru secara interaktif di file aktif |
| **`Alt + F`** atau **`F3`** | **Find in Project (Live Grep)** — Cari kata/teks di seluruh file dalam folder project |
| **`Alt + O`** | **Recent Files** — Buka daftar riwayat file yang terakhir kali diedit |
| **`F1`** | **Command Palette & Shortcut List** — Cari semua daftar perintah dan shortcut keyboard |

---

### 5. 📁 Sidebar, 📑 Tab Atas & 🪟 Split Window

| Shortcut | Fungsi |
| :--- | :--- |
| **`Ctrl + B`** | **Buka / Tutup Sidebar Kiri** (` Files` / ` Git` / `󰓩 Tabs`) |
| **`Alt + E`** | **Fokus Kursor ke Sidebar Kiri** |
| **`<`** dan **`>`** *(di dalam Sidebar)* | Pindah antar tab **`[  Files |  Git | 󰓩 Tabs ]`** di bagian atas Sidebar |
| **`Tab`** / **`Shift + Tab`** *(Mode Normal)* | Pindah ke Tab Berikutnya / Sebelumnya di baris tab atas |
| **`Alt + 1`** s/d **`Alt + 9`** | Lompat langsung ke Tab nomor `1` sampai `9` |
| **`Alt + W`** atau **`F4`** | **Tutup Tab Aktif** (Sidebar kiri tetap terbuka rapi) |
| **`Alt + P`** | **Pin / Unpin Tab Aktif** di sebelah kiri |
| **`Alt + \`** *(di Editor)* | **Split Editor Kanan-Kiri** (*Vertical Split*) |
| **`Alt + -`** | **Split Editor Atas-Bawah** (*Horizontal Split*) |
| **`Alt + Q`** | Tutup Split Window yang sedang aktif |
| **`Ctrl + ← / ↓ / ↑ / →`** | Pindah fokus kursor antar-window (Sidebar Kiri / Editor Kanan / Terminal Bawah) |
| **`Ctrl + Q`** | **Keluar dari Neovim** |

---

### 6. 🌿 Halaman Git, 🚀 Code Runner & 🎨 Tema Warna

| Shortcut / Command | Fungsi |
| :--- | :--- |
| **`Alt + G`** atau **`F9`** | Buka **Halaman Git Source Control (`Neogit`)** (`s` = Stage, `u` = Unstage, `cc` = Commit, `P` = Push, `p` = Pull, `q` = Tutup) |
| **`F10`** atau **`:GitDiff`** | Buka **Halaman Git Diff Side-by-Side (`Diffview`)** — Perbandingan kode kiri vs kanan ala VS Code |
| **`Alt + H`** atau **`F11`** | Buka **Halaman Riwayat Commit Git (`Git Log History`)** |
| **`Alt + S`** | Buka tab **Git Status** di Sidebar Kiri |
| **`F5`** *(atau klik `[ Run (F5)]`)* | **Run Code** — Jalankan file aktif (`.html` langsung buka di Browser, `.js` dengan Node.js, `.py` dengan Python, `.lua`, `.c`/`.cpp` dengan GCC) |
| **`F6`** | **Ganti Tema Warna** secara bergantian (*TokyoNight Night* → *VS Code Dark+* → *Catppuccin Mocha*) |
| **`F12`** / **`Shift + F12`** | **Go to Definition** / **Show References** (LSP) |
| **`:LicenseInfo`** *(atau tekan `l` di Dashboard)* | **Tampilkan Sertifikat Lisensi Eksklusif Muhammad Bintang** |
| **`:Tohtml`** | **Ekspor Kode Berwarna di Editor menjadi File HTML** |

---

## 🛡️ Lisensi & Hak Cipta Eksklusif (`All Rights Reserved`)

**Copyright © 2026 Muhammad Bintang. All Rights Reserved.**

Berbeda dengan lisensi *open-source* (seperti MIT atau GPL), seluruh kode sumber dan konfigurasi di dalam `C:\_neovim` dilindungi oleh **Lisensi Hak Cipta Eksklusif / Tertutup (*Proprietary License — All Rights Reserved*)** berdasarkan **UU Hak Cipta RI No. 28 Tahun 2014** serta dilengkapi **Sistem Pengunci Perangkat (`lua/core/license.lua`)**:

1. **Dilarang Menggunakan Tanpa Izin**: Pihak mana pun selain **Muhammad Bintang** dilarang keras menggunakan, menyalin, memodifikasi, atau mendistribusikan konfigurasi ini.
2. **Proteksi Kunci Perangkat Otomatis (`lua/core/license.lua`)**:
   - Konfigurasi ini terkunci secara otomatis pada identitas akun/perangkat milik **Muhammad Bintang (`MUH BINTANG @ LENOVO`)**.
   - Apabila folder konfigurasi ini disalin ke perangkat orang lain, Neovim akan **otomatis memblokir akses editor** dan menampilkan layar peringatan pelanggaran lisensi (`⛔ AKSES DITOLAK — LISENSI EKSKLUSIF MILIK MUHAMMAD BINTANG`).
   - Ketik **`:LicenseInfo`** di dalam Neovim (atau tekan **`l`** di halaman Dashboard) untuk menampilkan **Sertifikat Digital Lisensi Eksklusif**.
3. Lihat dokumen hukum selengkapnya di file **[`LICENSE`](./LICENSE)**.
