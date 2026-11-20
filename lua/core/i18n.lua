-- ============================================================================
-- CORE MODULE: Bahasa / Language (lua/core/i18n.lua)
-- Pilihan bahasa untuk menu Dashboard & status bar (Indonesia / English).
-- Pilihan disimpan di stdpath("data")/nvim-language agar awet tiap restart.
-- ============================================================================

local M = {}

local DATA_FILE = vim.fn.stdpath("data") .. "/nvim-language"
local VALID = { id = true, en = true }

local STRINGS = {
  id = {
    tagline = "󰛖 FIRA CODE NERD FONT  •  SHORTCUT VS CODE  •  TANPA <SPACE>",
    section_file = "FILE & EXPLORER",
    section_search = "CARI & TERMINAL",
    section_git = "GIT & RIWAYAT",
    section_prefs = "PREFERENSI & BANTUAN",

    open_project = "󰉋  Buka Project / Directory",
    new_file = "󰈔  Buat File Baru",
    new_folder = "  Buat Folder / Directory Baru",
    explorer = "󰙅  Buka / Tutup Sidebar Explorer",
    find_file = "  Cari & Buka File Cepat",
    terminal = "  Buka / Tutup Panel Terminal Bawah",
    neogit = "  Halaman Source Control (Neogit)",
    diffview = "  Git Diff Side-by-Side",
    git_log = "  Riwayat Commit Git",
    live_grep = "󰊄  Cari Teks di Seluruh Project",
    theme = "  Ganti Tema Warna",
    language = "󰖟  Pilih Bahasa (saat ini: Indonesia)",
    license = "🛡️  Sertifikat Lisensi Eksklusif",
    keymaps = "  Daftar Semua Shortcut Keyboard",
    quit = "󰈆  Keluar dari Neovim",

    footer = "🔒 Lisensi Eksklusif: MUHAMMAD BINTANG (Hak Cipta Dilindungi)  •  Neovim v%s",

    project_prompt = "Cari Project / Directory...",
    project_none = "Tidak ada directory yang ditemukan.",
    project_opened = "Project dibuka",

    language_title = "Pilih Bahasa / Language",
    language_hint = "↑↓ pilih  •  Enter konfirmasi  •  Esc batal  •  1/2 cepat",
    language_changed = "Bahasa diubah ke",
    opt_id = "Bahasa Indonesia",
    opt_en = "English",
    lang_badge = "󰖟 ID",

    terminal_open = " Buka Terminal [Ctrl+T]",
    terminal_close = " Tutup Terminal [Ctrl+T]",
  },

  en = {
    tagline = "󰛖 FIRA CODE NERD FONT  •  VS CODE SHORTCUTS  •  NO <SPACE>",
    section_file = "FILE & EXPLORER",
    section_search = "SEARCH & TERMINAL",
    section_git = "GIT & HISTORY",
    section_prefs = "PREFERENCES & HELP",

    open_project = "󰉋  Open Project / Directory",
    new_file = "󰈔  New File",
    new_folder = "  New Folder / Directory",
    explorer = "󰙅  Toggle Explorer Sidebar",
    find_file = "  Quick Open File",
    terminal = "  Toggle Bottom Terminal Panel",
    neogit = "  Source Control (Neogit)",
    diffview = "  Git Diff Side-by-Side",
    git_log = "  Git Commit History",
    live_grep = "󰊄  Live Grep in Project",
    theme = "  Cycle Color Theme",
    language = "󰖟  Change Language (current: English)",
    license = "🛡️  Exclusive License Certificate",
    keymaps = "  Show All Keyboard Shortcuts",
    quit = "󰈆  Quit Neovim",

    footer = "🔒 Exclusively Licensed to: MUHAMMAD BINTANG (All Rights Reserved)  •  Neovim v%s",

    project_prompt = "Find Project / Directory...",
    project_none = "No directories found.",
    project_opened = "Project opened",

    language_title = "Choose Language / Pilih Bahasa",
    language_hint = "↑↓ select  •  Enter confirm  •  Esc cancel  •  1/2 quick",
    language_changed = "Language changed to",
    opt_id = "Bahasa Indonesia",
    opt_en = "English",
    lang_badge = "󰖟 EN",

    terminal_open = " Open Terminal [Ctrl+T]",
    terminal_close = " Close Terminal [Ctrl+T]",
  },
}

-- Baca pilihan terakhir (default: Bahasa Indonesia).
local function read_language()
  local ok, lines = pcall(vim.fn.readfile, DATA_FILE)
  if ok and lines[1] and VALID[lines[1]] then
    return lines[1]
  end
  return "id"
end

M.lang = read_language()
vim.g.nvim_language = M.lang

function M.t(key)
  local dict = STRINGS[M.lang] or STRINGS.id
  return dict[key] or STRINGS.id[key] or key
end

local function persist(lang)
  pcall(vim.fn.writefile, { lang }, DATA_FILE)
end

-- Ganti bahasa, simpan, lalu beri tahu dashboard / status bar untuk refresh.
function M.set(lang)
  if not VALID[lang] or lang == M.lang then
    return
  end

  M.lang = lang
  vim.g.nvim_language = lang
  persist(lang)

  vim.api.nvim_exec_autocmds("User", { pattern = "NvimLanguageChanged" })

  vim.notify(M.t("language_changed") .. ": " .. M.t(lang == "id" and "opt_id" or "opt_en"), vim.log.levels.INFO, {
    title = M.t("language_title"),
  })

  vim.schedule(function()
    if vim.bo.filetype == "alpha" and vim.fn.exists(":AlphaRedraw") == 2 then
      pcall(vim.cmd.AlphaRedraw)
    end
    pcall(vim.cmd.redrawstatus)
  end)
end

function M.toggle()
  M.set(M.lang == "id" and "en" or "id")
end

-- Menu pilih bahasa berbentuk floating window (rapi, tidak tergantung vim.ui.select).
function M.select()
  local choices = {
    { lang = "id", label = M.t("opt_id") },
    { lang = "en", label = M.t("opt_en") },
  }
  local selected = M.lang == "en" and 2 or 1
  local width = math.min(48, vim.o.columns - 4)
  local height = 7
  local prev_win = vim.api.nvim_get_current_win()

  if vim.fn.mode() == "i" or vim.fn.mode() == "t" then
    vim.cmd("stopinsert")
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " " .. M.t("language_title") .. " ",
    title_pos = "center",
    zindex = 250,
  })

  vim.wo[win].winhl = "Normal:NormalFloat,FloatBorder:Title"

  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false
  vim.wo[win].cursorline = true

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_win_is_valid(prev_win) then
      pcall(vim.api.nvim_set_current_win, prev_win)
    end
  end

  local function choose(lang)
    close()
    M.set(lang)
  end

  local function render()
    local lines = { "", "", "", "", M.t("language_hint") }
    for i, choice in ipairs(choices) do
      local marker = i == selected and "❯" or " "
      local active = choice.lang == M.lang and "   ●" or ""
      lines[i + 1] = "   " .. marker .. "   " .. choice.label .. active
    end
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.api.nvim_win_set_cursor(win, { selected + 1, 0 })
    vim.api.nvim_buf_add_highlight(buf, -1, "Directory", 1, 3, -1)
    vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 4, 0, -1)
  end

  local function move(step)
    selected = ((selected - 1 + step) % #choices) + 1
    render()
  end

  local map = function(lhs, rhs)
    vim.keymap.set("n", lhs, rhs, { buffer = buf, nowait = true, silent = true })
  end
  map("j", function() move(1) end)
  map("k", function() move(-1) end)
  map("<Down>", function() move(1) end)
  map("<Up>", function() move(-1) end)
  map("<CR>", function() choose(choices[selected].lang) end)
  map("1", function() choose("id") end)
  map("2", function() choose("en") end)
  map("<Esc>", close)
  map("q", close)

  render()
end

-- Perintah & shortcut: :Lang, :LangID, :LangEN, :LangToggle, Alt+L
vim.api.nvim_create_user_command("Lang", M.select, { desc = "Pilih Bahasa / Choose Language (Alt+L)" })
vim.api.nvim_create_user_command("LangID", function() M.set("id") end, { desc = "Gunakan Bahasa Indonesia" })
vim.api.nvim_create_user_command("LangEN", function() M.set("en") end, { desc = "Use English" })
vim.api.nvim_create_user_command("LangToggle", M.toggle, { desc = "Toggle Indonesia / English" })

vim.keymap.set({ "n", "i" }, "<A-l>", M.select, {
  desc = "󰖟 Pilih Bahasa / Choose Language (Alt+L)",
})

return M
