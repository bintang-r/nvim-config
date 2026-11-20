# ⚡ Neovim VS Code Edition — FiraCode Nerd Font & Modular Lua IDE (`C:\_neovim`)

[🇮🇩 Bahasa Indonesia](#-bahasa-indonesia) | [🇬🇧 English](#-english)

---

<a id="-bahasa-indonesia"></a>
# 🇮🇩 Bahasa Indonesia

Dokumentasi resmi konfigurasi **Neovim v0.11.5 (100% Modular Lua)** yang dirancang khusus untuk menghadirkan pengalaman, tampilan modern, **Multi-Terminal**, dan **shortcut keyboard 100% standar Visual Studio Code** — **tanpa perlu kombinasi tombol `<Space>`**.

---

## 📸 Tangkapan Layar (*Screenshots Gallery*)

Berikut adalah tampilan antarmuka Neovim VS Code Edition dalam aksi:

### 1. Tampilan Utama Editor & Winbar Tab (VS Code Style)
> *Menampilkan sidebar Neo-tree di kiri, editor kode dengan FiraCode Nerd Font, Winbar navigasi atas dengan tombol interaktif, dan status bar bawah.*
```markdown
![Editor & Winbar View](./screenshots/editor-winbar.png)
*(Placeholder: Simpan screenshot tampilan editor ke `./screenshots/editor-winbar.png`)*
```

### 2. Fitur Kotak Input Mengambang (*Floating Input Modal*) untuk Buat File & Folder
> *Kotak input mengambang di tengah layar saat Anda menekan `Ctrl + N` (Buat File) atau `Alt + N` (Buat Folder).*
```markdown
![Floating Input Modal](./screenshots/floating-input.png)
*(Placeholder: Simpan screenshot kotak input mengambang ke `./screenshots/floating-input.png`)*
```

### 3. Multi-Terminal Manager & Split Terminal di Panel Bawah
> *Panel terminal bawah yang mendukung banyak tab PowerShell (`PowerShell #1`, `#2`, `#3`), Split Terminal, dan tombol kontrol interaktif.*
```markdown
![Multi-Terminal Manager](./screenshots/multi-terminal.png)
*(Placeholder: Simpan screenshot multi-terminal ke `./screenshots/multi-terminal.png`)*
```

### 4. Halaman Kontrol Git (`Neogit` & `Diffview`)
> *Manajemen Git visual yang sangat lengkap ala VS Code (`Alt + G` / `F9`).*
```markdown
![Git Control View](./screenshots/git-control.png)
*(Placeholder: Simpan screenshot git control ke `./screenshots/git-control.png`)*
```

---

## 🌟 Fitur Utama

1. **󰛖 Font FiraCode Nerd Font & Ikon Lengkap**:
   - Menggunakan **FiraCode Nerd Font** dengan *ligatures* yang aktif otomatis di Windows Terminal, VS Code Terminal, dan Neovim.
   - Dilengkapi 3 paket ikon (`nvim-web-devicons`, `mini.icons`, `lspkind.nvim`) untuk mewarnai jenis file, folder, dan autocomplete.
2. **📄 Buat File & Folder dengan Floating Modal**:
   - Kotak input elegan di tengah layar (`Ctrl + N` untuk File, `Alt + N` untuk Folder). Mendukung pembuatan direktori otomatis jika diakhiri `/`.
3. ** Multi-Terminal Manager**:
   - Tambah banyak tab terminal (`Alt +=`), Split Terminal berdampingan (`Alt + \`), dan pindah antar terminal (`Alt + ]` / `Alt + [`).
4. **⌨️ 100% Shortcut Standar VS Code**:
   - Seluruh navigasi dan editing menggunakan `Ctrl`, `Alt`, dan `F1–F12` tanpa tombol `<Space>`.

---

## 🚀 Cara Membuka Neovim di Project

Buka terminal di dalam folder project Anda, lalu ketik:
```powershell
nvim .
```
*(atau panggil langsung dari `C:\_neovim`)*:
```powershell
C:\_neovim\nvim.cmd .
```
> **Catatan**: Jika Neovim sudah terbuka, tutup dulu (`Ctrl + Q` atau `:qa!`) lalu buka kembali dengan `nvim .` agar modul terbaru termuat sempurna.

---

## ⌨️ Dokumentasi Shortcut Keyboard (Standar VS Code)

### 1. 📄 Buat File & 📁 Folder Baru
| Shortcut / Tombol | Fungsi |
| :--- | :--- |
| **`Ctrl + N`** *(atau klik `[+󰈔 Buat File]`)* | **Buat File Baru** — Memunculkan kotak input mengambang di tengah layar. Ketik nama file, tekan **`Enter`**. |
| **`Alt + N`** / **`Ctrl + Shift + N`** *(atau klik `[+ Buat Folder]`)* | **Buat Directory / Folder Baru** — Memunculkan kotak input mengambang, ketik nama folder, tekan **`Enter`**. |
| **`F2`** | **Rename File / Folder** yang sedang dibuka atau disorot di Sidebar. |
| **`Alt + Delete`** | **Hapus File Aktif** dengan konfirmasi aman `y`. |

### 2.  Multi-Terminal PowerShell
| Shortcut / Tombol | Fungsi |
| :--- | :--- |
| **`Ctrl + T`** / **`Ctrl + \`** / **`F7`** | **Buka / Sembunyikan Panel Terminal Bawah** |
| **`Alt + =`** / **`Ctrl + Shift + T`** | **➕ Tambah Terminal Baru** (`PowerShell #2`, `#3`, dst.) |
| **`Alt + ]`** / **`Alt + [`** | **Pindah ke Tab Terminal Berikutnya / Sebelumnya** |
| **`Alt + \`** | **Split Terminal Kanan-Kiri** di panel bawah |
| **`Alt + X`** | **Hapus / Matikan Terminal Aktif** |
| **`Alt + T`** | **Buka / Tutup Floating Terminal** |

### 3. ✏️ Editing & Undo/Redo (Standar VS Code)
| Shortcut | Fungsi |
| :--- | :--- |
| **`Ctrl + Z`** / **`Ctrl + Y`** | **Undo** / **Redo** |
| **`Ctrl + D`** / **`Shift + Alt + Down/Up`** | **Duplikat Baris / Teks** ke bawah atau ke atas |
| **`Alt + Down/Up`** | **Geser Baris (Move Line)** ke bawah / ke atas |
| **`Ctrl + C`** / **`Ctrl + X`** / **`Ctrl + V`** | **Copy** / **Cut** / **Paste** |
| **`Ctrl + /`** | **Toggle Comment** (Beri / hapus komentar baris atau blok) |
| **`Ctrl + S`** | **Simpan File (Save)** |
| **`F5`** | **Run Code** (Jalankan file aktif `.html`, `.js`, `.py`, `.lua`, dll.) |
| **`F6`** | **Ganti Tema Warna** (*TokyoNight* ⇄ *VS Code Dark+* ⇄ *Catppuccin*) |

---

<a id="-english"></a>
---

# 🇬🇧 English

Official documentation for the **Neovim v0.11.5 (100% Modular Lua)** configuration, designed to provide a modern interface, **Multi-Terminal management**, and **100% standard Visual Studio Code keyboard shortcuts** — **without requiring any `<Space>` key combinations**.

---

## 📸 Screenshots Gallery

Here is a preview of the Neovim VS Code Edition interface in action:

### 1. Main Editor & Winbar Tab (VS Code Style)
> *Showing the Neo-tree sidebar on the left, code editor with FiraCode Nerd Font, top navigation Winbar with interactive buttons, and bottom statusline.*
```markdown
![Editor & Winbar View](./screenshots/editor-winbar.png)
*(Placeholder: Save editor screenshot to `./screenshots/editor-winbar.png`)*
```

### 2. Floating Input Modal for Creating Files & Folders
> *The floating input box centered on the screen when pressing `Ctrl + N` (New File) or `Alt + N` (New Folder).*
```markdown
![Floating Input Modal](./screenshots/floating-input.png)
*(Placeholder: Save floating modal screenshot to `./screenshots/floating-input.png`)*
```

### 3. Multi-Terminal Manager & Split Terminal
> *The bottom terminal panel supporting multiple PowerShell tabs (`PowerShell #1`, `#2`, `#3`), Split Terminals, and interactive control buttons.*
```markdown
![Multi-Terminal Manager](./screenshots/multi-terminal.png)
*(Placeholder: Save multi-terminal screenshot to `./screenshots/multi-terminal.png`)*
```

### 4. Git Control View (`Neogit` & `Diffview`)
> *Comprehensive visual Git source control management ala VS Code (`Alt + G` / `F9`).*
```markdown
![Git Control View](./screenshots/git-control.png)
*(Placeholder: Save git control screenshot to `./screenshots/git-control.png`)*
```

---

## 🌟 Key Features

1. **󰛖 FiraCode Nerd Font & Rich Icons**:
   - Powered by **FiraCode Nerd Font** with ligatures enabled across Windows Terminal, VS Code Terminal, and Neovim.
   - Includes 3 icon packages (`nvim-web-devicons`, `mini.icons`, `lspkind.nvim`) for file types, folders, and autocomplete.
2. **📄 Create Files & Folders via Floating Modal**:
   - Elegant centered input dialog (`Ctrl + N` for files, `Alt + N` for directories). Automatically creates parent folders when suffixed with `/`.
3. ** Multi-Terminal Manager**:
   - Add multiple terminal tabs (`Alt +=`), split terminals side-by-side (`Alt + \`), and switch tabs (`Alt + ]` / `Alt + [`).
4. **⌨️ 100% VS Code Standard Shortcuts**:
   - All editing and navigation rely on `Ctrl`, `Alt`, and `F1–F12` without needing `<Space>` prefixes.

---

## 🚀 How to Open Neovim in Your Project

Open your terminal inside your project directory and type:
```powershell
nvim .
```
*(or call directly from `C:\_neovim`)*:
```powershell
C:\_neovim\nvim.cmd .
```
> **Note**: If Neovim is already running, exit first (`Ctrl + Q` or `:qa!`) and reopen with `nvim .` to load all updated modules.

---

## ⌨️ Keyboard Shortcuts Reference (VS Code Style)

### 1. 📄 New File & 📁 New Folder
| Shortcut / Button | Description |
| :--- | :--- |
| **`Ctrl + N`** *(or click `[+󰈔 New File]`)* | **Create New File** — Opens a centered floating input box. Type file name, press **`Enter`**. |
| **`Alt + N`** / **`Ctrl + Shift + N`** *(or click `[+ New Folder]`)* | **Create New Directory / Folder** — Opens a centered input box, type folder name, press **`Enter`**. |
| **`F2`** | **Rename** active file or selected item in Sidebar. |
| **`Alt + Delete`** | **Delete Active File** with safe confirmation prompt (`y`). |

### 2.  Multi-Terminal PowerShell
| Shortcut / Button | Description |
| :--- | :--- |
| **`Ctrl + T`** / **`Ctrl + \`** / **`F7`** | **Toggle Bottom Terminal Panel** |
| **`Alt + =`** / **`Ctrl + Shift + T`** | **➕ Add New Terminal** (`PowerShell #2`, `#3`, etc.) |
| **`Alt + ]`** / **`Alt + [`** | **Switch to Next / Previous Terminal Tab** |
| **`Alt + \`** | **Split Terminal Side-by-Side** in the bottom panel |
| **`Alt + X`** | **Kill / Close Active Terminal** |
| **`Alt + T`** | **Toggle Floating Terminal** |

### 3. ✏️ Editing & Undo/Redo (VS Code Standard)
| Shortcut | Description |
| :--- | :--- |
| **`Ctrl + Z`** / **`Ctrl + Y`** | **Undo** / **Redo** |
| **`Ctrl + D`** / **`Shift + Alt + Down/Up`** | **Duplicate Line / Selection** down or up |
| **`Alt + Down/Up`** | **Move Line** down or up |
| **`Ctrl + C`** / **`Ctrl + X`** / **`Ctrl + V`** | **Copy** / **Cut** / **Paste** |
| **`Ctrl + /`** | **Toggle Comment** (Line or visual block) |
| **`Ctrl + S`** | **Save File** |
| **`F5`** | **Run Code** (Executes active file `.html`, `.js`, `.py`, `.lua`, etc.) |
| **`F6`** | **Cycle Color Themes** (*TokyoNight* ⇄ *VS Code Dark+* ⇄ *Catppuccin*) |

---

## 🛡️ License & Exclusive Copyright (`All Rights Reserved`)

**Copyright © 2026 Muhammad Bintang. All Rights Reserved.**

This software, configuration, and documentation are protected by a **Strict Proprietary License** and hardware-bound license verification system (`lua/core/license.lua`). 

1. **Unauthorized Use Prohibited**: Any unauthorized use, copying, modification, or distribution by third parties is strictly prohibited.
2. **Hardware Protection**: The system automatically verifies hardware identity and blocks unauthorized execution on foreign machines.
3. For full legal terms, please refer to the **[`LICENSE`](./LICENSE)** file.
