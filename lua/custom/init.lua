-- ============================================================================
-- CUSTOM LUA MODULE: Floating File/Dir Creator, Multi-Terminal Manager & VS Code Keys
-- Location: C:\_neovim\lua\custom\init.lua
-- ============================================================================

local M = {}

-- ============================================================================
-- 1. FLOATING INPUT MODAL (Kotak Input Mengambang di Tengah Layar Ala VS Code)
-- ============================================================================
-- Menggunakan window mengambang khusus agar 100% berfungsi saat dipanggil
-- dari shortcut keyboard (Ctrl+N / Alt+N), dari dalam Sidebar, maupun klik Mouse!
function M.open_input_modal(opts)
  opts = opts or {}
  local title = opts.title or " Input "
  local default_val = opts.default or ""
  local on_submit = opts.on_submit

  -- Simpan window sebelumnya
  local prev_win = vim.api.nvim_get_current_win()
  if vim.fn.mode() == "i" or vim.fn.mode() == "t" then
    vim.cmd("stopinsert")
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "vscode_input"

  local width = math.min(68, math.floor(vim.o.columns * 0.85))
  local height = 1
  local row = math.floor((vim.o.lines - height) / 2) - 2
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(1, row),
    col = math.max(1, col),
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "center",
    zindex = 250,
  })

  vim.wo[win].winhl = "Normal:NormalFloat,FloatBorder:Title"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { default_val })

  local closed = false
  local function close_modal()
    if closed then
      return
    end
    closed = true
    vim.cmd("stopinsert")
    if vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_close, win, true)
    end
    if vim.api.nvim_win_is_valid(prev_win) then
      pcall(vim.api.nvim_set_current_win, prev_win)
    end
  end

  local function submit_modal()
    if closed then
      return
    end
    local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, false)
    local val = vim.trim((lines and lines[1]) or "")
    close_modal()
    if val ~= "" and on_submit then
      vim.schedule(function()
        on_submit(val)
      end)
    end
  end

  -- Tekan Enter untuk Simpan/Buat, Tekan Esc untuk Batal
  vim.keymap.set({ "i", "n" }, "<CR>", submit_modal, { buffer = buf, noremap = true, silent = true })
  vim.keymap.set({ "i", "n" }, "<Esc>", close_modal, { buffer = buf, noremap = true, silent = true })
  vim.keymap.set("n", "q", close_modal, { buffer = buf, noremap = true, silent = true })

  -- Posisikan kursor di ujung teks default dan langsung masuk Insert Mode
  vim.cmd("startinsert!")
  vim.schedule(function()
    if vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_set_cursor, win, { 1, #default_val })
    end
  end)
end

-- ============================================================================
-- 2. BUAT FILE BARU (Ctrl+N) & BUAT DIRECTORY / FOLDER BARU (Alt+N)
-- ============================================================================

-- Segarkan Sidebar Neo-tree setiap kali ada file/folder baru
local function refresh_neotree()
  pcall(function()
    local manager = require("neo-tree.sources.manager")
    manager.refresh("filesystem")
    manager.refresh("git_status")
    manager.refresh("buffers")
  end)
end

-- Cari atau buat window Editor utama (bukan Sidebar Neo-tree & bukan Terminal)
local function focus_main_editor_win()
  local cur_win = vim.api.nvim_get_current_win()
  local cur_buf = vim.api.nvim_win_get_buf(cur_win)
  local cur_ft = vim.bo[cur_buf].filetype
  if cur_ft ~= "neo-tree" and cur_ft ~= "toggleterm" and vim.bo[cur_buf].buftype ~= "terminal" then
    return cur_win
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local b = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[b].filetype
    local bt = vim.bo[b].buftype
    if ft ~= "neo-tree" and ft ~= "toggleterm" and bt ~= "terminal" then
      vim.api.nvim_set_current_win(win)
      return win
    end
  end

  -- Jika hanya ada Neo-tree di layar, buat split vertikal di sebelah kanan untuk editor
  vim.cmd("rightbelow vnew")
  return vim.api.nvim_get_current_win()
end

-- Dipakai oleh project picker & terminal manager supaya fokus tidak nyangkut
-- di panel terminal / sidebar saat sedang mengetik.
M.focus_editor = focus_main_editor_win

local function ensure_normal_mode()
  local m = vim.fn.mode()
  if m == "i" or m == "t" or m:match("^R") then
    vim.cmd("stopinsert")
  end
end
M.ensure_normal_mode = ensure_normal_mode

-- Klik file di Neo-tree saat sedang insert-mode harus langsung aktif (mapping
-- sidebar hanya berjalan di normal mode). Paksa keluar dari insert saat masuk.
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("VSCodeSidebarNormalMode", { clear = true }),
  callback = function()
    if vim.bo.filetype == "neo-tree" or vim.bo.filetype == "alpha" then
      ensure_normal_mode()
    end
  end,
})

-- Jangan pernah membawa mode terminal/insert pulang saat meninggalkan terminal.
vim.api.nvim_create_autocmd("TermLeave", {
  group = vim.api.nvim_create_augroup("VSCodeTerminalModeReset", { clear = true }),
  callback = function()
    ensure_normal_mode()
  end,
})

-- Saat klik / pindah fokus kembali ke jendela terminal, langsung masuk mode ketik
-- (tanpa harus tekan 'i' dulu). Tekan <Esc><Esc> atau jk di dalam terminal jika
-- ingin keluar ke Normal mode untuk scroll/copy.
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("VSCodeTerminalAutoInsert", { clear = true }),
  callback = function()
    if vim.bo.buftype ~= "terminal" then
      return
    end
    vim.schedule(function()
      if vim.bo.buftype == "terminal" then
        local chan = vim.bo.channel
        if chan and chan > 0 and vim.fn.jobwait({ chan }, 0)[1] == -1 then
          vim.cmd("startinsert")
        end
      end
    end)
  end,
})

-- Deteksi folder aktif (mendukung posisi kursor di Sidebar Neo-tree maupun di Editor)
local function get_base_dir()
  local ft = vim.bo.filetype

  -- Jika kursor sedang berada di dalam Sidebar Neo-tree, ambil folder yang sedang dipilih!
  if ft == "neo-tree" then
    local ok, manager = pcall(require, "neo-tree.sources.manager")
    if ok then
      local state = manager.get_state("filesystem")
      if state and state.tree then
        local node = state.tree:get_node()
        if node then
          local path = node:get_id()
          if path then
            local dir = (node.type == "directory") and path or vim.fn.fnamemodify(path, ":h")
            local rel = vim.fn.fnamemodify(dir, ":~:.")
            if rel ~= "." and rel ~= "" then
              rel = rel:gsub("\\", "/"):gsub("/+$", "")
              return rel .. "/"
            end
          end
        end
      end
    end
    return ""
  end

  if ft == "alpha" or ft == "toggleterm" or vim.bo.buftype ~= "" then
    return ""
  end

  local cur_file = vim.api.nvim_buf_get_name(0)
  if cur_file == "" or vim.fn.isdirectory(cur_file) == 1 then
    return ""
  end

  local dir = vim.fn.fnamemodify(cur_file, ":~:.:h")
  if dir == "." or dir == "" then
    return ""
  end
  return dir:gsub("\\", "/"):gsub("/+$", "") .. "/"
end

-- FUNGSI UTAMA: BUAT FILE BARU (Ctrl + N atau Tombol [+File])
function M.create_new_file()
  local default_prefix = get_base_dir()
  M.open_input_modal({
    title = " 󰈔 Buat File Baru (Ketik nama file lalu Enter | Esc = Batal) ",
    default = default_prefix,
    on_submit = function(input)
      local cleaned = input:gsub("\\", "/")
      -- Jika pengguna mengakhiri nama dengan tanda '/', buat sebagai Folder/Directory!
      if cleaned:sub(-1) == "/" then
        local dir_target = vim.fn.fnamemodify(cleaned:sub(1, -2), ":p"):gsub("[/\\]+$", "")
        vim.fn.mkdir(dir_target, "p")
        vim.cmd("Neotree show filesystem left")
        refresh_neotree()
        vim.notify("📁 Directory berhasil dibuat: " .. vim.fn.fnamemodify(dir_target, ":~:."), vim.log.levels.INFO)
        return
      end

      local target = vim.fn.fnamemodify(cleaned, ":p")
      local parent_dir = vim.fn.fnamemodify(target, ":h")

      if vim.fn.isdirectory(parent_dir) == 0 then
        vim.fn.mkdir(parent_dir, "p")
      end

      if vim.fn.filereadable(target) == 0 then
        local f, err = io.open(target, "w")
        if not f then
          vim.notify("❌ Gagal membuat file: " .. tostring(err), vim.log.levels.ERROR)
          return
        end
        f:close()
      end

      focus_main_editor_win()
      vim.cmd("edit " .. vim.fn.fnameescape(target))
      refresh_neotree()
      vim.notify("📄 File baru berhasil dibuat & dibuka: " .. vim.fn.fnamemodify(target, ":~:."), vim.log.levels.INFO)
    end,
  })
end

-- FUNGSI UTAMA: BUAT DIRECTORY / FOLDER BARU (Alt + N atau Ctrl+Shift+N atau Tombol [+Folder])
function M.create_new_directory()
  local default_prefix = get_base_dir()
  M.open_input_modal({
    title = "  Buat Directory / Folder Baru (Ketik nama folder lalu Enter | Esc = Batal) ",
    default = default_prefix,
    on_submit = function(input)
      local cleaned = input:gsub("\\", "/"):gsub("/+$", "")
      if cleaned == "" then
        return
      end
      local target_dir = vim.fn.fnamemodify(cleaned, ":p"):gsub("[/\\]+$", "")

      if vim.fn.isdirectory(target_dir) == 1 then
        vim.notify("⚠️ Directory sudah ada: " .. vim.fn.fnamemodify(target_dir, ":~:."), vim.log.levels.WARN)
        return
      end

      local ok = vim.fn.mkdir(target_dir, "p")
      if ok == 1 then
        vim.cmd("Neotree show filesystem left")
        refresh_neotree()
        vim.notify("📁 Directory baru berhasil dibuat: " .. vim.fn.fnamemodify(target_dir, ":~:."), vim.log.levels.INFO)
      else
        vim.notify("❌ Gagal membuat directory: " .. target_dir, vim.log.levels.ERROR)
      end
    end,
  })
end

-- RENAME FILE AKTIF (F2)
function M.rename_current_file()
  local current = vim.fn.expand("%:p")
  if current == "" or vim.bo.buftype ~= "" or vim.fn.isdirectory(current) == 1 then
    vim.notify("⚠️ Buka file terlebih dahulu untuk di-rename (atau tekan F2 di Sidebar).", vim.log.levels.WARN)
    return
  end

  local rel_current = vim.fn.expand("%:~:."):gsub("\\", "/")
  M.open_input_modal({
    title = " ✏️ Rename File (Ketik nama baru lalu Enter | Esc = Batal) ",
    default = rel_current,
    on_submit = function(input)
      if input == rel_current then
        return
      end
      local new_path = vim.fn.fnamemodify(input, ":p")
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

      focus_main_editor_win()
      vim.cmd("edit " .. vim.fn.fnameescape(new_path))
      pcall(vim.cmd, "bdelete! " .. old_buf)
      refresh_neotree()
      vim.notify("✅ File berhasil diubah menjadi: " .. vim.fn.fnamemodify(new_path, ":~:."), vim.log.levels.INFO)
    end,
  })
end

-- HAPUS FILE AKTIF (Alt + Delete)
function M.delete_current_file()
  local current = vim.fn.expand("%:p")
  if current == "" or vim.bo.buftype ~= "" or vim.fn.isdirectory(current) == 1 then
    return
  end
  local name = vim.fn.expand("%:t")
  M.open_input_modal({
    title = " 🗑️ Hapus File '" .. name .. "'? (Ketik y lalu Enter untuk hapus) ",
    default = "",
    on_submit = function(ans)
      if ans:lower() == "y" then
        local bufnr = vim.api.nvim_get_current_buf()
        M.smart_close_buffer(bufnr)
        os.remove(current)
        refresh_neotree()
        vim.notify("🗑️ File dihapus: " .. name, vim.log.levels.INFO)
      end
    end,
  })
end

-- ============================================================================
-- 3. MULTI-TERMINAL MANAGER BERGAYA VS CODE (Bisa Tambah Banyak Terminal!)
-- ============================================================================
-- Menyimpan daftar buffer terminal yang aktif: { { id = 1, buf = bufnr }, ... }
M.term_list = {}
M.active_term_idx = 1
M.term_counter = 0

-- Bersihkan daftar terminal yang sudah ditutup/invalid
local function clean_term_list()
  local valid = {}
  for _, item in ipairs(M.term_list) do
    if vim.api.nvim_buf_is_valid(item.buf) then
      table.insert(valid, item)
    end
  end
  M.term_list = valid
  if M.active_term_idx > #M.term_list then
    M.active_term_idx = math.max(1, #M.term_list)
  end
end

-- Cari semua window panel terminal yang sedang tampil di layar
local function find_open_terminal_wins()
  local wins = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" or vim.bo[buf].filetype == "toggleterm" then
      table.insert(wins, win)
    end
  end
  return wins
end

-- Buat buffer terminal PowerShell baru
local function create_terminal_buf()
  M.term_counter = M.term_counter + 1
  local term_id = M.term_counter
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "hide"

  table.insert(M.term_list, {
    id = term_id,
    buf = buf,
    title = "PowerShell #" .. term_id,
  })
  M.active_term_idx = #M.term_list
  return buf, term_id
end

-- Pastikan buffer terminal sudah menjalankan shell PowerShell interaktif
local function ensure_term_running(buf)
  if vim.bo[buf].buftype ~= "terminal" then
    vim.fn.termopen({ vim.o.shell, "-NoLogo" })
    vim.bo[buf].buflisted = false
  end
end

-- Cek apakah sebuah window adalah floating window atau terlalu pendek untuk winbar
local function is_floating_or_small_win(win)
  win = win or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then
    return true
  end
  local ok_cfg, cfg = pcall(vim.api.nvim_win_get_config, win)
  if ok_cfg and cfg and cfg.relative and cfg.relative ~= "" then
    return true
  end
  if vim.api.nvim_win_get_height(win) <= 3 then
    return true
  end
  return false
end

-- Segarkan header Winbar pada semua window normal
local function refresh_all_winbars()
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if not is_floating_or_small_win(w) then
      local b = vim.api.nvim_win_get_buf(w)
      local ft = vim.bo[b].filetype
      if ft ~= "neo-tree" and ft ~= "neo-tree-popup" and ft ~= "vscode_input" then
        vim.api.nvim_win_call(w, function()
          local ok, bar = pcall(M.get_winbar)
          if ok and bar ~= "" then
            pcall(function()
              vim.wo[w].winbar = bar
            end)
          end
        end)
      end
    end
  end
end

-- BUKA PANEL TERMINAL BAWAH (atau Fokus ke Terminal dengan Index Tertentu)
function M.show_terminal_at(idx)
  if vim.fn.mode() == "i" or vim.fn.mode() == "t" then
    vim.cmd("stopinsert")
  end
  clean_term_list()

  local need_new = false
  if #M.term_list == 0 then
    need_new = true
  else
    M.active_term_idx = math.max(1, math.min(idx or M.active_term_idx, #M.term_list))
  end

  local open_wins = find_open_terminal_wins()
  local target_win = open_wins[1]

  if not target_win or not vim.api.nvim_win_is_valid(target_win) then
    focus_main_editor_win()
    vim.cmd("botright 13split")
    target_win = vim.api.nvim_get_current_win()
  else
    vim.api.nvim_set_current_win(target_win)
  end

  if need_new then
    local buf = create_terminal_buf()
    vim.api.nvim_win_set_buf(target_win, buf)
    ensure_term_running(buf)
  else
    local item = M.term_list[M.active_term_idx]
    vim.api.nvim_win_set_buf(target_win, item.buf)
    ensure_term_running(item.buf)
  end

  vim.wo[target_win].number = false
  vim.wo[target_win].relativenumber = false
  vim.wo[target_win].signcolumn = "no"
  vim.wo[target_win].winfixheight = true
  refresh_all_winbars()
  vim.cmd("startinsert")
end

-- TOGGLE (BUKA / SEMBUNYIKAN) PANEL TERMINAL BAWAH (Ctrl + T / Ctrl + \ / F7)
function M.toggle_bottom_terminal()
  if vim.fn.mode() == "i" or vim.fn.mode() == "t" then
    vim.cmd("stopinsert")
  end
  local open_wins = find_open_terminal_wins()
  if #open_wins > 0 then
    for _, w in ipairs(open_wins) do
      if vim.api.nvim_win_is_valid(w) then
        pcall(vim.api.nvim_win_close, w, false)
      end
    end
    -- Pastikan fokus dan mode kembali ke editor, bukan ke jendela terminal yang hilang.
    ensure_normal_mode()
    M.focus_editor()
    refresh_all_winbars()
  else
    M.show_terminal_at(M.active_term_idx)
  end
end

-- TAMBAH TERMINAL BARU (Terminal #2, #3, dst. — Alt + = atau Ctrl + Shift + T atau Klik [+ Tambah Terminal])
function M.new_terminal()
  if vim.fn.mode() == "i" or vim.fn.mode() == "t" then
    vim.cmd("stopinsert")
  end
  clean_term_list()
  local buf, term_id = create_terminal_buf()

  local open_wins = find_open_terminal_wins()
  local target_win = open_wins[1]
  if not target_win or not vim.api.nvim_win_is_valid(target_win) then
    focus_main_editor_win()
    vim.cmd("botright 13split")
    target_win = vim.api.nvim_get_current_win()
  else
    vim.api.nvim_set_current_win(target_win)
  end

  vim.api.nvim_win_set_buf(target_win, buf)
  ensure_term_running(buf)
  vim.wo[target_win].number = false
  vim.wo[target_win].relativenumber = false
  vim.wo[target_win].signcolumn = "no"
  vim.wo[target_win].winfixheight = true
  refresh_all_winbars()
  vim.notify(" Terminal baru ditambahkan: PowerShell #" .. term_id .. " (Total: " .. #M.term_list .. " terminal)", vim.log.levels.INFO)
  vim.cmd("startinsert")
end

-- SPLIT TERMINAL BERDAMPINGAN KANAN-KIRI DI PANEL BAWAH ALA VS CODE (Alt + \ di dalam Terminal atau Klik [Split Term])
function M.split_terminal()
  if vim.fn.mode() == "i" or vim.fn.mode() == "t" then
    vim.cmd("stopinsert")
  end
  clean_term_list()

  local open_wins = find_open_terminal_wins()
  if #open_wins == 0 then
    M.show_terminal_at(M.active_term_idx)
    open_wins = find_open_terminal_wins()
  end

  vim.api.nvim_set_current_win(open_wins[#open_wins])
  vim.cmd("rightbelow vsplit")
  local new_win = vim.api.nvim_get_current_win()

  local buf, term_id = create_terminal_buf()
  vim.api.nvim_win_set_buf(new_win, buf)
  ensure_term_running(buf)
  vim.wo[new_win].number = false
  vim.wo[new_win].relativenumber = false
  vim.wo[new_win].signcolumn = "no"
  vim.wo[new_win].winfixheight = true
  refresh_all_winbars()
  vim.notify(" Split Terminal dibuat: PowerShell #" .. term_id, vim.log.levels.INFO)
  vim.cmd("startinsert")
end

-- PINDAH KE TERMINAL BERIKUTNYA (Alt + ] atau Alt + Right)
function M.next_terminal()
  clean_term_list()
  if #M.term_list <= 1 then
    return
  end
  local next_idx = (M.active_term_idx % #M.term_list) + 1
  M.show_terminal_at(next_idx)
end

-- PINDAH KE TERMINAL SEBELUMNYA (Alt + [ atau Alt + Left)
function M.prev_terminal()
  clean_term_list()
  if #M.term_list <= 1 then
    return
  end
  local prev_idx = ((M.active_term_idx - 2) % #M.term_list) + 1
  M.show_terminal_at(prev_idx)
end

-- HAPUS / MATIKAN TERMINAL AKTIF (Alt + X di dalam Terminal atau Klik [🗑 Hapus])
function M.kill_active_terminal()
  if vim.fn.mode() == "i" or vim.fn.mode() == "t" then
    vim.cmd("stopinsert")
  end
  clean_term_list()
  if #M.term_list == 0 then
    return
  end

  local cur_buf = vim.api.nvim_get_current_buf()
  local kill_idx = M.active_term_idx
  for i, item in ipairs(M.term_list) do
    if item.buf == cur_buf then
      kill_idx = i
      break
    end
  end

  local killed = M.term_list[kill_idx]
  table.remove(M.term_list, kill_idx)

  if #M.term_list > 0 then
    M.active_term_idx = math.min(kill_idx, #M.term_list)
    local open_wins = find_open_terminal_wins()
    if #open_wins > 0 then
      vim.api.nvim_win_set_buf(open_wins[1], M.term_list[M.active_term_idx].buf)
    end
    if killed and vim.api.nvim_buf_is_valid(killed.buf) then
      pcall(vim.api.nvim_buf_delete, killed.buf, { force = true })
    end
    refresh_all_winbars()
    vim.cmd("startinsert")
  else
    M.close_terminal()
    if killed and vim.api.nvim_buf_is_valid(killed.buf) then
      pcall(vim.api.nvim_buf_delete, killed.buf, { force = true })
    end
    refresh_all_winbars()
  end
end

-- SEMBUNYIKAN PANEL TERMINAL
function M.close_terminal()
  if vim.fn.mode() == "i" or vim.fn.mode() == "t" then
    vim.cmd("stopinsert")
  end
  local open_wins = find_open_terminal_wins()
  for _, w in ipairs(open_wins) do
    if vim.api.nvim_win_is_valid(w) then
      pcall(vim.api.nvim_win_close, w, false)
    end
  end
  ensure_normal_mode()
  M.focus_editor()
  refresh_all_winbars()
end

-- FLOATING TERMINAL (Alt + T)
function M.toggle_float_terminal()
  if vim.fn.mode() == "t" or vim.fn.mode() == "i" then
    vim.cmd("stopinsert")
  end
  vim.cmd("99ToggleTerm direction=float")
end

-- Buat fungsi klik mouse untuk memilih tab Terminal #1 s/d #9
for i = 1, 9 do
  _G["BintangSelectTerm" .. i] = function()
    M.show_terminal_at(i)
  end
end

_G.BintangClickNewTerm = function()
  M.new_terminal()
end
_G.BintangClickSplitTerm = function()
  M.split_terminal()
end
_G.BintangClickKillTerm = function()
  M.kill_active_terminal()
end
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
-- 4. FUNGSI DUPLIKAT BARIS / BLOK TEKS ALA VS CODE (Ctrl+D & Shift+Alt+Down/Up)
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
-- 5. FUNGSI KOMENTAR CEPAT ALA VS CODE (Ctrl + /)
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
-- 6. FIND & REPLACE INTERAKTIF ALA VS CODE (Ctrl + R) & GANTI TEMA (F6)
-- ============================================================================
function M.find_and_replace()
  local default_word = vim.fn.expand("<cword>")
  M.open_input_modal({
    title = " 🔎 Langkah 1/2: Cari Teks yang Ingin Diganti (Enter = Lanjut) ",
    default = default_word,
    on_submit = function(find_str)
      M.open_input_modal({
        title = " ✏️ Langkah 2/2: Ganti '" .. find_str .. "' Dengan (Enter = Ganti Semua) ",
        default = find_str,
        on_submit = function(replace_str)
          local escaped_find = vim.fn.escape(find_str, "/\\.*$^~[]")
          local escaped_rep = vim.fn.escape(replace_str, "/\\&~")
          local ok = pcall(vim.cmd, string.format("%%s/%s/%s/g", escaped_find, escaped_rep))
          if ok then
            vim.cmd("nohlsearch")
            vim.notify(string.format("✅ Berhasil mengganti '%s' -> '%s'", find_str, replace_str), vim.log.levels.INFO)
          else
            vim.notify("⚠️ Teks '" .. find_str .. "' tidak ditemukan di file ini.", vim.log.levels.WARN)
          end
        end,
      })
    end,
  })
end

local themes = { "tokyonight-night", "vscode", "catppuccin-mocha" }
local current_theme_idx = 1

function M.cycle_theme()
  current_theme_idx = (current_theme_idx % #themes) + 1
  local next_theme = themes[current_theme_idx]
  pcall(vim.cmd.colorscheme, next_theme)
  vim.notify("🎨 Tema aktif: " .. next_theme .. " (Tekan F6 lagi untuk ganti)", vim.log.levels.INFO)
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
    if b.bufnr ~= bufnr and vim.bo[b.bufnr].filetype ~= "neo-tree" and vim.bo[b.bufnr].buftype ~= "terminal" then
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
-- 8. VS CODE WINBAR: TAB MULTI-TERMINAL + TOMBOL [+FILE] [+FOLDER] [TERMINAL]
-- ============================================================================
function M.get_winbar()
  local ft = vim.bo.filetype
  local bt = vim.bo.buftype

  -- JIKA INI WINDOW TERMINAL: Tampilkan Baris Tab Multi-Terminal (Terminal 1, 2, 3...) + Tombol [+ Tambah Terminal]!
  if ft == "toggleterm" or bt == "terminal" then
    clean_term_list()
    local cur_buf = vim.api.nvim_get_current_buf()
    local tabs = { " %#Title# TERMINALS:%* " }

    for i, item in ipairs(M.term_list) do
      if i <= 9 then
        local is_active = (item.buf == cur_buf)
        local hl = is_active and "%#TabLineSel#" or "%#Comment#"
        local icon = is_active and "● " or ""
        table.insert(
          tabs,
          string.format("%%@v:lua.BintangSelectTerm%d@%s [ %d: %sPowerShell #%d ] %%*%%X", i, hl, i, icon, item.id)
        )
      end
    end

    local add_btn = "%@v:lua.BintangClickNewTerm@%#DiagnosticOk# [ + Tambah Terminal (Alt+=) ] %*%X"
    local split_btn = "%@v:lua.BintangClickSplitTerm@%#DiagnosticInfo# [ ◫ Split (Alt+\\) ] %*%X"
    local kill_btn = "%@v:lua.BintangClickKillTerm@%#DiagnosticWarn# [ 🗑 Hapus (Alt+X) ] %*%X"
    local close_btn = "%@v:lua.BintangClickCloseTerminal@%#DiagnosticError# [  Sembunyikan (Ctrl+T) ] %*%X "

    return table.concat(tabs, " ") .. " " .. add_btn .. "%=" .. split_btn .. " " .. kill_btn .. " " .. close_btn
  end

  local excluded = {
    ["alpha"] = true,
    ["neo-tree"] = true,
    ["neo-tree-popup"] = true,
    ["vscode_input"] = true,
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

  clean_term_list()
  local term_count = #M.term_list
  local term_label = term_count > 0 and string.format(" Terminal (%d) [Ctrl+T]", term_count) or " Terminal [Ctrl+T]"

  -- Tombol Interaktif di Kanan Atas Editor (Bisa Diklik Mouse!)
  local new_file_btn = "%@v:lua.BintangClickNewFile@%#DiagnosticOk# [ +󰈔 Buat File (Ctrl+N) ] %*%X"
  local new_dir_btn = "%@v:lua.BintangClickNewDir@%#Directory# [ + Buat Folder (Alt+N) ] %*%X"
  local term_open = #find_open_terminal_wins() > 0
  local term_btn = term_open
    and "%@v:lua.BintangClickTerminal@%#DiagnosticWarn# [  Tutup Term (Ctrl+T) ] %*%X"
    or ("%@v:lua.BintangClickTerminal@%#DiagnosticInfo# [ " .. term_label .. " ] %*%X")
  local add_term_btn = "%@v:lua.BintangClickNewTerm@%#String# [ + Term Baru (Alt+=) ] %*%X"
  local run_btn = "%@v:lua.BintangClickRunCode@%#Title# [  Run (F5) ] %*%X "
  local right_actions = "%=" .. new_file_btn .. " " .. new_dir_btn .. " " .. term_btn .. " " .. add_term_btn .. " " .. run_btn

  local filepath = vim.fn.expand("%:~:.")
  if filepath == "" or vim.fn.isdirectory(vim.fn.expand("%:p")) == 1 then
    return "  󰈔 [Project Workspace]" .. right_actions
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
      local win = vim.api.nvim_get_current_win()
      -- Jangan pernah pasang winbar pada floating window / popup input (mencegah E36: Not enough room)
      if is_floating_or_small_win(win) then
        return
      end
      local ft = vim.bo.filetype
      if ft == "neo-tree" or ft == "neo-tree-popup" or ft == "vscode_input" then
        return
      end
      local ok, bar = pcall(M.get_winbar)
      if ok and bar ~= "" then
        pcall(function()
          vim.wo[win].winbar = bar
        end)
      else
        pcall(function()
          vim.wo[win].winbar = nil
        end)
      end
    end,
  })
end

-- ============================================================================
-- 9. SHORTCUT KHUSUS DI DALAM TERMINAL & AUTO-SIDEBAR SAAT BUKA PROJECT (nvim .)
-- ============================================================================
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("VSCodeTerminalKeymaps", { clear = true }),
  callback = function(event)
    local b = event.buf
    local topts = { buffer = b, silent = true }

    -- Buka / Sembunyikan Panel Terminal
    vim.keymap.set({ "t", "n" }, "<C-t>", M.toggle_bottom_terminal, topts)
    vim.keymap.set({ "t", "n" }, "<C-\\>", M.toggle_bottom_terminal, topts)
    vim.keymap.set({ "t", "n" }, "<F7>", M.toggle_bottom_terminal, topts)

    -- Tambah Terminal Baru (#2, #3, dst.), Split Terminal, Pindah Terminal, Hapus Terminal
    vim.keymap.set({ "t", "n" }, "<A-=>", M.new_terminal, topts)
    vim.keymap.set({ "t", "n" }, "<C-S-t>", M.new_terminal, topts)
    vim.keymap.set({ "t", "n" }, "<A-\\>", M.split_terminal, topts)
    vim.keymap.set({ "t", "n" }, "<A-]>", M.next_terminal, topts)
    vim.keymap.set({ "t", "n" }, "<A-[>", M.prev_terminal, topts)
    vim.keymap.set({ "t", "n" }, "<A-Right>", M.next_terminal, topts)
    vim.keymap.set({ "t", "n" }, "<A-Left>", M.prev_terminal, topts)
    vim.keymap.set({ "t", "n" }, "<A-x>", M.kill_active_terminal, topts)

    -- Keluar ke Normal mode di dalam Terminal
    vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], topts)
    vim.keymap.set("t", "jk", [[<C-\><C-n>]], topts)
    vim.keymap.set("n", "q", M.close_terminal, topts)

    -- Pindah kursor dari Terminal ke Editor/Sidebar
    vim.keymap.set("t", "<C-Up>", [[<C-\><C-n><C-w>k]], topts)
    vim.keymap.set("t", "<C-Left>", [[<C-\><C-n><C-w>h]], topts)
    vim.keymap.set("t", "<C-Right>", [[<C-\><C-n><C-w>l]], topts)
  end,
})

-- Saat membuka folder (misal: nvim .), ubah buffer direktori kosong menjadi buffer editor bersih + buka Sidebar Kiri
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("VSCodeAutoSidebar", { clear = true }),
  callback = function(data)
    local is_dir = vim.fn.isdirectory(data.file) == 1
    if is_dir then
      local dir_buf = vim.api.nvim_get_current_buf()
      vim.cmd.cd(data.file)
      vim.schedule(function()
        -- Jika ada index.html atau README.md di folder, atau buat buffer baru yang bersih
        if vim.fn.filereadable("index.html") == 1 then
          vim.cmd("edit index.html")
        else
          vim.cmd("enew")
        end
        if vim.api.nvim_buf_is_valid(dir_buf) and vim.fn.isdirectory(vim.api.nvim_buf_get_name(dir_buf)) == 1 then
          pcall(vim.cmd, "bwipeout! " .. dir_buf)
        end
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
vim.keymap.set("i", "<C-d>", M.duplicate_line_down, { desc = "📑 Duplikat Baris ke Bawah (Ctrl+D)" })
vim.keymap.set("v", "<C-d>", ":t'><CR>gv", { desc = "📑 Duplikat Blok Teks ke Bawah (Ctrl+D)" })

vim.keymap.set("n", "<S-A-Down>", M.duplicate_line_down, { desc = "📑 Duplikat Baris ke Bawah (Shift+Alt+Down)" })
vim.keymap.set("i", "<S-A-Down>", M.duplicate_line_down, { desc = "📑 Duplikat Baris ke Bawah (Shift+Alt+Down)" })
vim.keymap.set("v", "<S-A-Down>", ":t'><CR>gv", { desc = "📑 Duplikat Blok Teks ke Bawah (Shift+Alt+Down)" })

vim.keymap.set("n", "<S-A-Up>", M.duplicate_line_up, { desc = "📑 Duplikat Baris ke Atas (Shift+Alt+Up)" })
vim.keymap.set("i", "<S-A-Up>", M.duplicate_line_up, { desc = "📑 Duplikat Baris ke Atas (Shift+Alt+Up)" })
vim.keymap.set("v", "<S-A-Up>", ":t'<-1<CR>gv", { desc = "📑 Duplikat Blok Teks ke Atas (Shift+Alt+Up)" })

-- B. Komentar Cepat (Ctrl + /)
vim.keymap.set("n", "<C-_>", M.toggle_comment_line, { desc = "💬 Toggle Komentar Baris (Ctrl+/)" })
vim.keymap.set("n", "<C-/>", M.toggle_comment_line, { desc = "💬 Toggle Komentar Baris (Ctrl+/)" })
vim.keymap.set("i", "<C-_>", M.toggle_comment_line, { desc = "💬 Toggle Komentar Baris (Ctrl+/)" })
vim.keymap.set("i", "<C-/>", M.toggle_comment_line, { desc = "💬 Toggle Komentar Baris (Ctrl+/)" })
vim.keymap.set("v", "<C-_>", M.toggle_comment_visual, { desc = "💬 Toggle Komentar Blok (Ctrl+/)" })
vim.keymap.set("v", "<C-/>", M.toggle_comment_visual, { desc = "💬 Toggle Komentar Blok (Ctrl+/)" })

-- C. Buat File Baru (Ctrl+N), Buat Directory/Folder Baru (Alt+N / Ctrl+Shift+N), Rename (F2), Hapus File (Alt+Delete)
vim.keymap.set({ "n", "i", "v" }, "<C-n>", M.create_new_file, { desc = "📄 Buat File Baru (Ctrl+N)" })
vim.keymap.set({ "n", "i", "v" }, "<A-n>", M.create_new_directory, { desc = "📁 Buat Directory/Folder Baru (Alt+N)" })
vim.keymap.set({ "n", "i", "v" }, "<C-S-n>", M.create_new_directory, { desc = "📁 Buat Directory/Folder Baru (Ctrl+Shift+N)" })
vim.keymap.set("n", "<F2>", M.rename_current_file, { desc = "✏️ Rename File Aktif (F2)" })
vim.keymap.set("n", "<A-Del>", M.delete_current_file, { desc = "🗑️ Hapus File Aktif (Alt+Delete)" })

-- D. Find & Replace di File Aktif (Ctrl+R)
vim.keymap.set("n", "<C-r>", M.find_and_replace, { desc = "🔎 Find & Replace Teks di File Ini (Ctrl+R)" })

-- E. Tutup Tab Aktif Tanpa Menutup Sidebar (Alt+X, Alt+W, atau F4)
--    Di buffer code: Alt+X menutup tab code aktif. Di buffer terminal: dioverride lokal oleh TermOpen untuk menutup terminal aktif.
local function close_active_code_tab()
  ensure_normal_mode()
  M.smart_close_buffer()
end
vim.keymap.set({ "n", "i" }, "<A-x>", close_active_code_tab, { desc = "❌ Tutup Tab Code Aktif (Alt+X)" })
vim.keymap.set({ "n", "i" }, "<A-w>", close_active_code_tab, { desc = "❌ Tutup Tab Aktif (Alt+W)" })
vim.keymap.set({ "n", "i" }, "<F4>", close_active_code_tab, { desc = "❌ Tutup Tab Aktif (F4)" })

-- F. Buka / Tutup Terminal & Multi-Terminal Shortcuts
vim.keymap.set({ "n", "i", "t" }, "<C-t>", M.toggle_bottom_terminal, { desc = " Buka/Tutup Panel Terminal Bawah (Ctrl+T)" })
vim.keymap.set({ "n", "i", "t" }, "<C-\\>", M.toggle_bottom_terminal, { desc = " Buka/Tutup Panel Terminal Bawah (Ctrl+\\)" })
vim.keymap.set({ "n", "i", "t" }, "<F7>", M.toggle_bottom_terminal, { desc = " Buka/Tutup Panel Terminal Bawah (F7)" })
vim.keymap.set({ "n", "i", "t" }, "<A-=>", M.new_terminal, { desc = " Tambah Terminal Baru #2, #3... (Alt+=)" })
vim.keymap.set({ "n", "i", "t" }, "<C-S-t>", M.new_terminal, { desc = " Tambah Terminal Baru #2, #3... (Ctrl+Shift+T)" })
vim.keymap.set({ "n", "i", "t" }, "<A-]>", M.next_terminal, { desc = " Pindah ke Terminal Berikutnya (Alt+])" })
vim.keymap.set({ "n", "i", "t" }, "<A-[>", M.prev_terminal, { desc = " Pindah ke Terminal Sebelumnya (Alt+[)" })
vim.keymap.set({ "n", "i", "t" }, "<A-t>", M.toggle_float_terminal, { desc = " Buka/Tutup Floating Terminal (Alt+T)" })

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
vim.api.nvim_create_user_command("TerminalNew", M.new_terminal, { desc = "Tambah Terminal Baru (Alt+=)" })
vim.api.nvim_create_user_command("TerminalSplit", M.split_terminal, { desc = "Split Terminal Kanan-Kiri" })
vim.api.nvim_create_user_command("TerminalNext", M.next_terminal, { desc = "Pindah ke Terminal Berikutnya (Alt+])" })
vim.api.nvim_create_user_command("TerminalPrev", M.prev_terminal, { desc = "Pindah ke Terminal Sebelumnya (Alt+[)" })
vim.api.nvim_create_user_command("TerminalKill", M.kill_active_terminal, { desc = "Matikan Terminal Aktif (Alt+X)" })
vim.api.nvim_create_user_command("TerminalFloat", M.toggle_float_terminal, { desc = "Buka/Tutup Terminal Mengambang (Alt+T)" })
vim.api.nvim_create_user_command("TerminalClose", M.close_terminal, { desc = "Sembunyikan Panel Terminal" })
vim.api.nvim_create_user_command("VSCodeTheme", "colorscheme vscode", { desc = "Gunakan Tema VS Code Dark+" })
vim.api.nvim_create_user_command("TokyoTheme", "colorscheme tokyonight-night", { desc = "Gunakan Tema TokyoNight" })
vim.api.nvim_create_user_command("GitPage", "Neogit", { desc = "Buka Halaman Git Source Control (Alt+G / F9)" })
vim.api.nvim_create_user_command("GitDiff", "DiffviewOpen", { desc = "Buka Halaman Git Diff Side-by-Side (F10)" })
vim.api.nvim_create_user_command("GitHistory", "DiffviewFileHistory", { desc = "Buka Halaman Riwayat Commit Git (F11)" })
vim.api.nvim_create_user_command("RunCode", M.run_current_file, { desc = "Jalankan file aktif (F5)" })
vim.api.nvim_create_user_command("EditConfig", "edit C:/_neovim/init.lua", { desc = "Buka init.lua di C:\\_neovim" })

return M
