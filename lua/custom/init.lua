-- ============================================================================
-- CUSTOM LUA MODULE: VS Code Shortcuts, Duplicate, Create File/Dir, Terminal & Runner
-- Location: C:\_neovim\lua\custom\init.lua
-- TANPA Kombinasi <Space> — 100% Standar VS Code (Ctrl / Alt / F1-F12)
-- ============================================================================

local M = {}

-- ============================================================================
-- 1. FUNGSI DUPLIKAT BARIS / BLOK TEKS ALA VS CODE (Ctrl+D & Shift+Alt+Down/Up)
-- ============================================================================
function M.duplicate_line_down()
  local pos = vim.api.nvim_win_get_cursor(0)
  vim.cmd("t.")
  vim.api.nvim_win_set_cursor(0, { pos[1] + 1, pos[2] })
end

function M.duplicate_line_up()
  local pos = vim.api.nvim_win_get_cursor(0)
  vim.cmd("t-1")
  vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] })
end

-- ============================================================================
-- 2. FUNGSI KOMENTAR CEPAT ALA VS CODE (Ctrl + /)
-- ============================================================================
function M.toggle_comment_line()
  local ok, comment_api = pcall(require, "Comment.api")
  if ok then
    comment_api.toggle.linewise.current()
  else
    vim.cmd("normal gcc")
  end
end

function M.toggle_comment_visual()
  local ok, comment_api = pcall(require, "Comment.api")
  if ok then
    local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
    vim.api.nvim_feedkeys(esc, "nx", false)
    comment_api.toggle.linewise(vim.fn.visualmode())
  else
    vim.cmd("normal gc")
  end
end

-- ============================================================================
-- 3. FUNGSI STANDAR BUAT FILE BARU (Ctrl+N) & DIRECTORY/FOLDER BARU (Alt+N)
-- ============================================================================

-- Helper untuk menyegarkan tampilan Neo-tree Sidebar setelah buat/ubah/hapus file & folder
local function refresh_neotree()
  pcall(function()
    local manager = require("neo-tree.sources.manager")
    manager.refresh("filesystem")
    manager.refresh("git_status")
    manager.refresh("buffers")
  end)
end

-- Dapatkan direktori awal yang relevan (folder file aktif atau root project)
local function get_base_dir()
  local ft = vim.bo.filetype
  if ft == "neo-tree" or ft == "alpha" or ft == "toggleterm" or vim.bo.buftype ~= "" then
    return ""
  end
  local dir = vim.fn.expand("%:~:.:h")
  if dir == "." or dir == "" then
    return ""
  end
  return dir:gsub("\\", "/") .. "/"
end

-- BUAT FILE BARU (Ctrl + N)
function M.create_new_file()
  if vim.fn.mode() == "i" or vim.fn.mode() == "t" then
    vim.cmd("stopinsert")
  end

  local default_prefix = get_base_dir()
  vim.ui.input({
    prompt = "📄 Buat File Baru (contoh: baru.html atau assets/js/script.js): ",
    default = default_prefix,
  }, function(input)
    if not input or vim.trim(input) == "" then
      return
    end
    local target = vim.fn.fnamemodify(vim.trim(input), ":p")
    local parent_dir = vim.fn.fnamemodify(target, ":h")

    -- Buat folder induknya secara otomatis jika belum ada
    if vim.fn.isdirectory(parent_dir) == 0 then
      vim.fn.mkdir(parent_dir, "p")
    end

    -- Buat file kosong jika belum ada, lalu buka di Tab Editor
    if vim.fn.filereadable(target) == 0 then
      local f = io.open(target, "w")
      if f then
        f:close()
      end
    end

    vim.cmd("edit " .. vim.fn.fnameescape(target))
    refresh_neotree()
    vim.notify("📄 File berhasil dibuat & dibuka: " .. vim.fn.fnamemodify(target, ":~:."), vim.log.levels.INFO)
  end)
end

-- BUAT DIRECTORY / FOLDER BARU (Alt + N)
function M.create_new_directory()
  if vim.fn.mode() == "i" or vim.fn.mode() == "t" then
    vim.cmd("stopinsert")
  end

  local default_prefix = get_base_dir()
  vim.ui.input({
    prompt = "📁 Buat Directory/Folder Baru (contoh: components atau assets/icons): ",
    default = default_prefix,
  }, function(input)
    if not input or vim.trim(input) == "" then
      return
    end
    local target_dir = vim.fn.fnamemodify(vim.trim(input), ":p")

    if vim.fn.isdirectory(target_dir) == 1 then
      vim.notify("⚠️ Directory sudah ada: " .. vim.fn.fnamemodify(target_dir, ":~:."), vim.log.levels.WARN)
      return
    end

    local ok = vim.fn.mkdir(target_dir, "p")
    if ok == 1 then
      vim.cmd("Neotree show filesystem left")
      refresh_neotree()
      vim.notify("📁 Directory berhasil dibuat: " .. vim.fn.fnamemodify(target_dir, ":~:."), vim.log.levels.INFO)
    else
      vim.notify("❌ Gagal membuat directory: " .. target_dir, vim.log.levels.ERROR)
    end
  end)
end

-- RENAME FILE AKTIF (F2)
function M.rename_current_file()
  local current = vim.fn.expand("%:p")
  if current == "" or vim.bo.buftype ~= "" then
    vim.notify("⚠️ Buka file terlebih dahulu untuk di-rename (atau tekan F2 di Sidebar).", vim.log.levels.WARN)
    return
  end

  local rel_current = vim.fn.expand("%:~:."):gsub("\\", "/")
  vim.ui.input({
    prompt = "✏️ Rename File ke: ",
    default = rel_current,
  }, function(input)
    if not input or vim.trim(input) == "" or vim.trim(input) == rel_current then
      return
    end
    local new_path = vim.fn.fnamemodify(vim.trim(input), ":p")
    local parent_dir = vim.fn.fnamemodify(new_path, ":h")
    if vim.fn.isdirectory(parent_dir) == 0 then
      vim.fn.mkdir(parent_dir, "p")
    end

    vim.cmd("silent! write")
    local old_buf = vim.api.nvim_get_current_buf()
    local ok, err = os.rename(current, new_path)
    if not ok then
      vim.notify("❌ Gagal rename file: " .. tostring(err), vim.log.levels.ERROR)
      return
    end

    vim.cmd("edit " .. vim.fn.fnameescape(new_path))
    pcall(vim.cmd, "bdelete! " .. old_buf)
    refresh_neotree()
    vim.notify("✅ File berhasil diubah menjadi: " .. vim.fn.fnamemodify(new_path, ":~:."), vim.log.levels.INFO)
  end)
end

-- HAPUS FILE AKTIF (Alt + Delete)
function M.delete_current_file()
  local current = vim.fn.expand("%:p")
  if current == "" or vim.bo.buftype ~= "" then
    return
  end
  local name = vim.fn.expand("%:t")
  vim.ui.input({
    prompt = "🗑️ Yakin ingin menghapus file '" .. name .. "'? (ketik y untuk hapus): ",
  }, function(ans)
    if ans and ans:lower() == "y" then
      local bufnr = vim.api.nvim_get_current_buf()
      M.smart_close_buffer(bufnr)
      os.remove(current)
      refresh_neotree()
      vim.notify("🗑️ File dihapus: " .. name, vim.log.levels.INFO)
    end
  end)
end

-- ============================================================================
-- 4. FIND & REPLACE INTERAKTIF ALA VS CODE (Ctrl + R)
-- ============================================================================
function M.find_and_replace()
  local default_word = vim.fn.expand("<cword>")
  vim.ui.input({
    prompt = "🔎 Cari Teks yang Ingin Diganti: ",
    default = default_word,
  }, function(find_str)
    if not find_str or find_str == "" then
      return
    end
    vim.ui.input({
      prompt = "✏️ Ganti '" .. find_str .. "' Dengan: ",
      default = find_str,
    }, function(replace_str)
      if replace_str == nil then
        return
      end
      local escaped_find = vim.fn.escape(find_str, "/\\.*$^~[]")
      local escaped_rep = vim.fn.escape(replace_str, "/\\&~")
      local ok = pcall(vim.cmd, string.format("%%s/%s/%s/g", escaped_find, escaped_rep))
      if ok then
        vim.cmd("nohlsearch")
        vim.notify(string.format("✅ Berhasil mengganti '%s' -> '%s'", find_str, replace_str), vim.log.levels.INFO)
      else
        vim.notify("⚠️ Teks '" .. find_str .. "' tidak ditemukan di file ini.", vim.log.levels.WARN)
      end
    end)
  end)
end

-- ============================================================================
-- 5. GANTI TEMA WARNA CEPAT (F6)
-- ============================================================================
local themes = { "tokyonight-night", "vscode", "catppuccin-mocha" }
local current_theme_idx = 1

function M.cycle_theme()
  current_theme_idx = (current_theme_idx % #themes) + 1
  local next_theme = themes[current_theme_idx]
  pcall(vim.cmd.colorscheme, next_theme)
  vim.notify("🎨 Tema aktif: " .. next_theme .. " (Tekan F6 lagi untuk ganti)", vim.log.levels.INFO)
end

-- ============================================================================
-- 6. FUNGSI BUKA / TUTUP TERMINAL (Ctrl+T / Ctrl+\ / F7 / Klik Mouse)
-- ============================================================================
local function find_open_terminal_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "toggleterm" or vim.bo[buf].buftype == "terminal" then
      return win, buf
    end
  end
  return nil, nil
end

function M.toggle_bottom_terminal()
  if vim.fn.mode() == "t" or vim.fn.mode() == "i" then
    vim.cmd("stopinsert")
  end

  local term_win = find_open_terminal_win()
  if term_win then
    vim.api.nvim_win_close(term_win, false)
  else
    vim.cmd("1ToggleTerm direction=horizontal size=13")
  end
end

function M.toggle_float_terminal()
  if vim.fn.mode() == "t" or vim.fn.mode() == "i" then
    vim.cmd("stopinsert")
  end

  local term_win = find_open_terminal_win()
  if term_win then
    vim.api.nvim_win_close(term_win, false)
  else
    vim.cmd("2ToggleTerm direction=float")
  end
end

function M.close_terminal()
  if vim.fn.mode() == "t" or vim.fn.mode() == "i" then
    vim.cmd("stopinsert")
  end
  local term_win = find_open_terminal_win()
  if term_win then
    vim.api.nvim_win_close(term_win, false)
  end
end

-- Handler Global untuk Klik Mouse di Bar Atas (Winbar)
_G.BintangClickNewFile = function()
  M.create_new_file()
end
_G.BintangClickNewDir = function()
  M.create_new_directory()
end
_G.BintangClickTerminal = function()
  M.toggle_bottom_terminal()
end
_G.BintangClickCloseTerminal = function()
  M.close_terminal()
end
_G.BintangClickGitPage = function()
  if vim.fn.mode() == "t" then
    vim.cmd("stopinsert")
  end
  vim.cmd("Neogit")
end
_G.BintangClickRunCode = function()
  if vim.fn.mode() == "t" then
    vim.cmd("stopinsert")
  end
  M.run_current_file()
end

-- ============================================================================
-- 7. SMART CLOSE TAB (Alt+W atau F4 — Tutup Tab Tanpa Menutup Sidebar)
-- ============================================================================
function M.smart_close_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  if ft == "neo-tree" or ft == "alpha" then
    return
  end

  if ft == "toggleterm" or vim.bo[bufnr].buftype == "terminal" then
    M.close_terminal()
    return
  end

  local listed = vim.fn.getbufinfo({ buflisted = 1 })
  local target_buf = nil
  for _, b in ipairs(listed) do
    if b.bufnr ~= bufnr and vim.bo[b.bufnr].filetype ~= "neo-tree" then
      target_buf = b.bufnr
      break
    end
  end

  if target_buf then
    vim.api.nvim_set_current_buf(target_buf)
    pcall(vim.cmd, "bdelete! " .. bufnr)
  else
    vim.cmd("enew")
    pcall(vim.cmd, "bdelete! " .. bufnr)
  end
end

-- ============================================================================
-- 8. VS CODE BREADCRUMB WINBAR + TOMBOL KLIK [+File] [+Folder] [Terminal] [Git] [Run]
-- ============================================================================
function M.get_winbar()
  local ft = vim.bo.filetype
  local bt = vim.bo.buftype

  if ft == "toggleterm" or bt == "terminal" then
    local left = "  %#Title# TERMINAL POWERSHELL (FiraCode)%*  %#Comment#│  Tekan Ctrl+T / Ctrl+\\ / F7 untuk menutup%*"
    local right = "%@v:lua.BintangClickCloseTerminal@%#DiagnosticError# [  Tutup Terminal (Ctrl+T) ] %*%X "
    return left .. "%=" .. right
  end

  local excluded = {
    ["alpha"] = true,
    ["neo-tree"] = true,
    ["neo-tree-popup"] = true,
    ["NeogitStatus"] = true,
    ["NeogitPopup"] = true,
    ["DiffviewFiles"] = true,
    ["DiffviewFileHistory"] = true,
    ["lazy"] = true,
    ["mason"] = true,
    ["qf"] = true,
    ["help"] = true,
  }

  if bt ~= "" or excluded[ft] then
    return ""
  end

  -- Tombol Interaktif di Kanan Atas Editor (Bisa Diklik Mouse!)
  local new_file_btn = "%@v:lua.BintangClickNewFile@%#Directory# [+󰈔 File (Ctrl+N)] %*%X"
  local new_dir_btn = "%@v:lua.BintangClickNewDir@%#Directory# [+ Folder (Alt+N)] %*%X"
  local term_open = find_open_terminal_win() ~= nil
  local term_btn = term_open
    and "%@v:lua.BintangClickTerminal@%#DiagnosticWarn# [ Tutup Term (Ctrl+T)] %*%X"
    or "%@v:lua.BintangClickTerminal@%#DiagnosticInfo# [ Terminal (Ctrl+T)] %*%X"
  local git_btn = "%@v:lua.BintangClickGitPage@%#String# [ Git (Alt+G)] %*%X"
  local run_btn = "%@v:lua.BintangClickRunCode@%#Title# [ Run (F5)] %*%X "
  local right_actions = "%=" .. new_file_btn .. " " .. new_dir_btn .. " " .. term_btn .. " " .. git_btn .. " " .. run_btn

  local filepath = vim.fn.expand("%:~:.")
  if filepath == "" then
    return "  󰈔 [File Baru]" .. right_actions
  end

  local filename = vim.fn.expand("%:t")
  local ext = vim.fn.expand("%:e")
  local file_icon = "󰈙"
  local icon_hl = "Title"
  local ok_devicons, devicons = pcall(require, "nvim-web-devicons")
  if ok_devicons then
    local ic, hl = devicons.get_icon(filename, ext, { default = true })
    if ic then
      file_icon = ic
    end
    if hl then
      icon_hl = hl
    end
  end

  local parts = vim.split(filepath:gsub("\\", "/"), "/")
  local crumbs = {}
  for i, part in ipairs(parts) do
    if i < #parts then
      table.insert(crumbs, " " .. part)
    else
      table.insert(crumbs, "%#" .. icon_hl .. "#" .. file_icon .. " %#Title#" .. part .. "%*")
    end
  end

  local mod = vim.bo.modified and " %#WarningMsg#●%*" or ""
  return "  " .. table.concat(crumbs, "    ") .. mod .. right_actions
end

function M.setup_vscode_winbar()
  vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "BufWritePost", "TextChanged", "TextChangedI", "TermOpen" }, {
    group = vim.api.nvim_create_augroup("VSCodeBreadcrumbs", { clear = true }),
    callback = function()
      if vim.bo.filetype == "neo-tree" or vim.bo.filetype == "neo-tree-popup" then
        return
      end
      local ok, bar = pcall(M.get_winbar)
      if ok and bar ~= "" then
        vim.wo.winbar = bar
      else
        vim.wo.winbar = nil
      end
    end,
  })
end

-- ============================================================================
-- 9. SHORTCUT KHUSUS DI DALAM TERMINAL & AUTO-SIDEBAR
-- ============================================================================
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("VSCodeTerminalKeymaps", { clear = true }),
  callback = function(event)
    local b = event.buf
    local topts = { buffer = b, silent = true }

    vim.keymap.set({ "t", "n" }, "<C-t>", M.toggle_bottom_terminal, topts)
    vim.keymap.set({ "t", "n" }, "<C-\\>", M.toggle_bottom_terminal, topts)
    vim.keymap.set({ "t", "n" }, "<A-t>", M.toggle_float_terminal, topts)
    vim.keymap.set({ "t", "n" }, "<F7>", M.toggle_bottom_terminal, topts)

    vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], topts)
    vim.keymap.set("t", "jk", [[<C-\><C-n>]], topts)
    vim.keymap.set("n", "q", M.close_terminal, topts)

    vim.keymap.set("t", "<C-Up>", [[<C-\><C-n><C-w>k]], topts)
    vim.keymap.set("t", "<C-Left>", [[<C-\><C-n><C-w>h]], topts)
    vim.keymap.set("t", "<C-Right>", [[<C-\><C-n><C-w>l]], topts)
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("VSCodeAutoSidebar", { clear = true }),
  callback = function(data)
    local is_dir = vim.fn.isdirectory(data.file) == 1
    if is_dir then
      vim.cmd.cd(data.file)
      vim.schedule(function()
        vim.cmd("Neotree show filesystem left")
      end)
    end
  end,
})

-- ============================================================================
-- 10. CODE RUNNER (<F5>)
-- ============================================================================
function M.run_current_file()
  vim.cmd("silent! write")
  local file = vim.fn.expand("%:p")
  local ext = vim.fn.expand("%:e"):lower()
  local filename_no_ext = vim.fn.expand("%:p:r")

  local cmd_map = {
    lua = string.format('nvim -l "%s"', file),
    js = string.format('node "%s"', file),
    mjs = string.format('node "%s"', file),
    py = string.format('python "%s"', file),
    c = string.format('gcc "%s" -o "%s.exe" && "%s.exe"', file, filename_no_ext, filename_no_ext),
    cpp = string.format('g++ "%s" -o "%s.exe" && "%s.exe"', file, filename_no_ext, filename_no_ext),
    html = string.format('cmd /c start "" "%s"', file),
  }

  local run_cmd = cmd_map[ext]
  if not run_cmd then
    vim.notify("Belum ada runner otomatis untuk ekstensi ." .. ext, vim.log.levels.WARN)
    return
  end

  if ext == "html" then
    vim.fn.jobstart(run_cmd, { detach = true })
    vim.notify("🌐 Membuka " .. vim.fn.expand("%:t") .. " di Browser...", vim.log.levels.INFO)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.82)
  local height = math.floor(vim.o.lines * 0.75)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = "  Code Runner: " .. vim.fn.expand("%:t") .. " (Tekan 'q' untuk menutup) ",
    title_pos = "center",
  })

  vim.fn.termopen(run_cmd)
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
  vim.cmd("startinsert")
end

-- ============================================================================
-- 11. REGISTRASI SEMUA SHORTCUT STANDAR VS CODE (TANPA <SPACE>)
-- ============================================================================
M.setup_vscode_winbar()

-- A. Duplikat Baris / Blok Teks (Ctrl+D & Shift+Alt+Down/Up)
vim.keymap.set("n", "<C-d>", M.duplicate_line_down, { desc = "📑 Duplikat Baris ke Bawah (Ctrl+D)" })
vim.keymap.set("i", "<C-d>", function()
  M.duplicate_line_down()
end, { desc = "📑 Duplikat Baris ke Bawah (Ctrl+D)" })
vim.keymap.set("v", "<C-d>", ":t'><CR>gv", { desc = "📑 Duplikat Blok Teks ke Bawah (Ctrl+D)" })

vim.keymap.set("n", "<S-A-Down>", M.duplicate_line_down, { desc = "📑 Duplikat Baris ke Bawah (Shift+Alt+Down)" })
vim.keymap.set("i", "<S-A-Down>", function()
  M.duplicate_line_down()
end, { desc = "📑 Duplikat Baris ke Bawah (Shift+Alt+Down)" })
vim.keymap.set("v", "<S-A-Down>", ":t'><CR>gv", { desc = "📑 Duplikat Blok Teks ke Bawah (Shift+Alt+Down)" })

vim.keymap.set("n", "<S-A-Up>", M.duplicate_line_up, { desc = "📑 Duplikat Baris ke Atas (Shift+Alt+Up)" })
vim.keymap.set("i", "<S-A-Up>", function()
  M.duplicate_line_up()
end, { desc = "📑 Duplikat Baris ke Atas (Shift+Alt+Up)" })
vim.keymap.set("v", "<S-A-Up>", ":t'<-1<CR>gv", { desc = "📑 Duplikat Blok Teks ke Atas (Shift+Alt+Up)" })

-- B. Komentar Cepat (Ctrl + /)
vim.keymap.set("n", "<C-_>", M.toggle_comment_line, { desc = "💬 Toggle Komentar Baris (Ctrl+/)" })
vim.keymap.set("n", "<C-/>", M.toggle_comment_line, { desc = "💬 Toggle Komentar Baris (Ctrl+/)" })
vim.keymap.set("i", "<C-_>", function()
  M.toggle_comment_line()
end, { desc = "💬 Toggle Komentar Baris (Ctrl+/)" })
vim.keymap.set("i", "<C-/>", function()
  M.toggle_comment_line()
end, { desc = "💬 Toggle Komentar Baris (Ctrl+/)" })
vim.keymap.set("v", "<C-_>", M.toggle_comment_visual, { desc = "💬 Toggle Komentar Blok (Ctrl+/)" })
vim.keymap.set("v", "<C-/>", M.toggle_comment_visual, { desc = "💬 Toggle Komentar Blok (Ctrl+/)" })

-- C. Buat File Baru (Ctrl+N), Buat Folder Baru (Alt+N), Rename (F2), Hapus File (Alt+Delete)
vim.keymap.set({ "n", "i" }, "<C-n>", M.create_new_file, { desc = "📄 Buat File Baru (Ctrl+N)" })
vim.keymap.set({ "n", "i" }, "<A-n>", M.create_new_directory, { desc = "📁 Buat Directory/Folder Baru (Alt+N)" })
vim.keymap.set("n", "<F2>", M.rename_current_file, { desc = "✏️ Rename File Aktif (F2)" })
vim.keymap.set("n", "<A-Del>", M.delete_current_file, { desc = "🗑️ Hapus File Aktif (Alt+Delete)" })

-- D. Find & Replace di File Aktif (Ctrl+R)
vim.keymap.set("n", "<C-r>", M.find_and_replace, { desc = "🔎 Find & Replace Teks di File Ini (Ctrl+R)" })

-- E. Tutup Tab Aktif Tanpa Menutup Sidebar (Alt+W atau F4)
vim.keymap.set("n", "<A-w>", function()
  M.smart_close_buffer()
end, { desc = "❌ Tutup Tab Aktif (Alt+W)" })
vim.keymap.set("n", "<F4>", function()
  M.smart_close_buffer()
end, { desc = "❌ Tutup Tab Aktif (F4)" })

-- F. Buka / Tutup Terminal (Ctrl+T, Ctrl+\, Alt+T, F7)
vim.keymap.set({ "n", "i", "t" }, "<C-t>", M.toggle_bottom_terminal, { desc = " Buka/Tutup Terminal Bawah (Ctrl+T)" })
vim.keymap.set({ "n", "i", "t" }, "<C-\\>", M.toggle_bottom_terminal, { desc = " Buka/Tutup Terminal Bawah (Ctrl+\\)" })
vim.keymap.set({ "n", "i", "t" }, "<A-t>", M.toggle_float_terminal, { desc = " Buka/Tutup Floating Terminal (Alt+T)" })
vim.keymap.set({ "n", "i", "t" }, "<F7>", M.toggle_bottom_terminal, { desc = " Buka/Tutup Terminal Bawah (F7)" })

-- G. Jalankan Kode (F5) & Ganti Tema Warna (F6)
vim.keymap.set({ "n", "i" }, "<F5>", M.run_current_file, { desc = " Jalankan File Saat Ini (F5)" })
vim.keymap.set("n", "<F6>", M.cycle_theme, { desc = "🎨 Ganti Tema Warna (TokyoNight / VS Code / Catppuccin)" })

-- User Commands Standar
vim.api.nvim_create_user_command("NewFile", M.create_new_file, { desc = "Buat File Baru (Ctrl+N)" })
vim.api.nvim_create_user_command("NewDir", M.create_new_directory, { desc = "Buat Directory/Folder Baru (Alt+N)" })
vim.api.nvim_create_user_command("NewFolder", M.create_new_directory, { desc = "Buat Directory/Folder Baru (Alt+N)" })
vim.api.nvim_create_user_command("RenameFile", M.rename_current_file, { desc = "Rename File Aktif (F2)" })
vim.api.nvim_create_user_command("DeleteFile", M.delete_current_file, { desc = "Hapus File Aktif (Alt+Delete)" })
vim.api.nvim_create_user_command("FindReplace", M.find_and_replace, { desc = "Find & Replace di File Ini (Ctrl+R)" })
vim.api.nvim_create_user_command("TerminalToggle", M.toggle_bottom_terminal, { desc = "Buka/Tutup Terminal Bawah (Ctrl+T)" })
vim.api.nvim_create_user_command("TerminalFloat", M.toggle_float_terminal, { desc = "Buka/Tutup Terminal Mengambang (Alt+T)" })
vim.api.nvim_create_user_command("TerminalClose", M.close_terminal, { desc = "Tutup Terminal" })
vim.api.nvim_create_user_command("VSCodeTheme", "colorscheme vscode", { desc = "Gunakan Tema VS Code Dark+" })
vim.api.nvim_create_user_command("TokyoTheme", "colorscheme tokyonight-night", { desc = "Gunakan Tema TokyoNight" })
vim.api.nvim_create_user_command("GitPage", "Neogit", { desc = "Buka Halaman Git Source Control (Alt+G / F9)" })
vim.api.nvim_create_user_command("GitDiff", "DiffviewOpen", { desc = "Buka Halaman Git Diff Side-by-Side (F10)" })
vim.api.nvim_create_user_command("GitHistory", "DiffviewFileHistory", { desc = "Buka Halaman Riwayat Commit Git (F11)" })
vim.api.nvim_create_user_command("RunCode", M.run_current_file, { desc = "Jalankan file aktif (F5)" })
vim.api.nvim_create_user_command("EditConfig", "edit C:/_neovim/init.lua", { desc = "Buka init.lua di C:\\_neovim" })

return M
