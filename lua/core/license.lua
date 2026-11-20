-- ============================================================================
-- CORE MODULE: Exclusive License Protection & Device Lock (lua/core/license.lua)
-- Copyright (c) 2026 Muhammad Bintang. All Rights Reserved.
-- Mencegah konfigurasi ini digunakan di perangkat orang lain tanpa izin!
-- ============================================================================

local M = {}

M.info = {
  owner = "Muhammad Bintang",
  copyright = "Copyright (c) 2026 Muhammad Bintang. All Rights Reserved.",
  license_type = "Exclusive Proprietary License (All Rights Reserved)",
  legal_basis = "UU Hak Cipta RI No. 28 Tahun 2014 & Berne Convention",
  license_id = "MB-NVIM-2026-EXCLUSIVE",
  -- Daftar akun perangkat resmi milik Muhammad Bintang
  authorized_users = {
    ["MUH BINTANG"] = true,
    ["MUHAMMAD BINTANG"] = true,
    ["BINTANG"] = true,
  },
}

-- Ambil informasi user & perangkat saat ini
function M.get_device_identity()
  local user = (vim.env.USERNAME or vim.env.USER or "UNKNOWN"):upper()
  local host = (vim.env.COMPUTERNAME or vim.fn.hostname() or "UNKNOWN"):upper()
  return user, host
end

-- Periksa apakah perangkat yang menjalankan Neovim ini adalah milik Muhammad Bintang
function M.is_authorized()
  local user = M.get_device_identity()
  if M.info.authorized_users[user] then
    return true
  end
  -- Fallback jika pemilik menggunakan kunci environment khusus di perangkat baru
  if vim.env.BINTANG_LICENSE_KEY == "MB-NVIM-2026-EXCLUSIVE" then
    return true
  end
  return false
end

-- Tampilkan layar kunci (Lock Screen) dan blokir akses jika digunakan oleh orang lain!
function M.lock_unauthorized_device()
  local user, host = M.get_device_identity()

  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      vim.cmd("silent! only")
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)

      local lines = {
        "",
        "  ╔══════════════════════════════════════════════════════════════════════════╗",
        "  ║       ⛔ AKSES DITOLAK — LISENSI EKSKLUSIF MILIK MUHAMMAD BINTANG        ║",
        "  ║          UNAUTHORIZED USE PROHIBITED — ALL RIGHTS RESERVED               ║",
        "  ╠══════════════════════════════════════════════════════════════════════════╣",
        "  ║                                                                          ║",
        "  ║  Konfigurasi Neovim (VS Code Edition) ini dilindungi oleh Hak Cipta      ║",
        "  ║  dan Lisensi Tertutup (Proprietary License — All Rights Reserved).       ║",
        "  ║                                                                          ║",
        "  ║  • Pemegang Hak Cipta : MUHAMMAD BINTANG                                 ║",
        "  ║  • ID Lisensi         : " .. M.info.license_id .. "                          ║",
        "  ║  • Status Perangkat   : TIDAK TERDAFTAR / TIDAK SAH                      ║",
        string.format("  ║  • Perangkat Terdeteksi: %-47s ║", user .. " @ " .. host),
        "  ║                                                                          ║",
        "  ║  Pihak mana pun selain Muhammad Bintang DILARANG KERAS menggunakan,      ║",
        "  ║  menyalin, memodifikasi, atau mendistribusikan konfigurasi ini.          ║",
        "  ║                                                                          ║",
        "  ║  Tekan [Enter], [q], atau [Esc] untuk keluar dari Neovim.                ║",
        "  ╚══════════════════════════════════════════════════════════════════════════╝",
        "",
      }

      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.bo[buf].modifiable = false
      vim.bo[buf].readonly = true
      vim.bo[buf].buftype = "nofile"
      vim.wo.number = false
      vim.wo.relativenumber = false

      local quit_keys = { "<CR>", "q", "<Esc>", "<C-c>", "<C-q>", "i", "a", ":" }
      for _, k in ipairs(quit_keys) do
        vim.keymap.set({ "n", "v" }, k, "<cmd>qa!<CR>", { buffer = buf, silent = true, noremap = true })
      end
    end,
  })
end

-- Tampilkan Popup Sertifikat Lisensi Resmi (:LicenseInfo)
function M.show_license_certificate()
  local user, host = M.get_device_identity()
  local status = M.is_authorized() and "✓ TERVERIFIKASI & AKTIF (Pemilik Sah)" or "✗ TIDAK SAH"

  local lines = {
    " ╔════════════════════════════════════════════════════════════════════╗ ",
    " ║        🔒 SERTIFIKAT LISENSI & HAK CIPTA EKSKLUSIF NEOVIM          ║ ",
    " ╠════════════════════════════════════════════════════════════════════╣ ",
    " ║                                                                    ║ ",
    string.format(" ║  Pemegang Hak Cipta : %-44s ║ ", M.info.owner),
    string.format(" ║  Jenis Lisensi      : %-44s ║ ", M.info.license_type),
    string.format(" ║  ID Lisensi         : %-44s ║ ", M.info.license_id),
    string.format(" ║  Perangkat Aktif    : %-44s ║ ", user .. " @ " .. host),
    string.format(" ║  Status Verifikasi  : %-44s ║ ", status),
    " ║  Perlindungan Hukum : UU Hak Cipta No. 28/2014 & Berne Convention  ║ ",
    " ║                                                                    ║ ",
    " ║  PERINGATAN:                                                       ║ ",
    " ║  Konfigurasi ini terkunci khusus untuk perangkat Muhammad Bintang. ║ ",
    " ║  Dilarang keras menggunakan, menyalin, atau membagikan kode ini    ║ ",
    " ║  tanpa izin tertulis dari pemilik hak cipta.                       ║ ",
    " ║                                                                    ║ ",
    " ║             Tekan [Enter], [q], atau [Esc] untuk menutup           ║ ",
    " ╚════════════════════════════════════════════════════════════════════╝ ",
  }

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local width = 72
  local height = #lines
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(1, row),
    col = math.max(1, col),
    style = "minimal",
    border = "rounded",
    title = " 🛡️ Exclusive License — Muhammad Bintang ",
    title_pos = "center",
    zindex = 260,
  })

  vim.wo[win].winhl = "Normal:NormalFloat,FloatBorder:DiagnosticOk"

  local function close_cert()
    if vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end

  vim.keymap.set("n", "q", close_cert, { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", close_cert, { buffer = buf, silent = true })
  vim.keymap.set("n", "<CR>", close_cert, { buffer = buf, silent = true })
end

-- Fungsi utama yang dipanggil di baris pertama init.lua
function M.enforce()
  if not M.is_authorized() then
    M.lock_unauthorized_device()
    return false
  end

  vim.api.nvim_create_user_command("LicenseInfo", M.show_license_certificate, {
    desc = "Tampilkan Sertifikat Lisensi Eksklusif Muhammad Bintang",
  })
  return true
end

return M
