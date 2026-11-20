-- ============================================================================
-- CUSTOM MODULE: External Drag-and-Drop & Windows Explorer Paste to Neo-tree
-- Memungkinkan drag file/folder dari Windows Explorer langsung ke Sidebar
-- atau Copy (Ctrl+C) di Windows Explorer lalu Paste (Ctrl+V / Alt+V / p)
-- ke folder tujuan di Sidebar Neo-tree (persis seperti VS Code).
-- ============================================================================

local M = {}

local uv = vim.uv or vim.loop
local sep = package.config:sub(1, 1)

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function exists(path)
  if not path or path == "" then
    return false
  end
  return uv.fs_stat(path) ~= nil
end

local function normalize_sep(path)
  if sep == "\\" then
    return path:gsub("/", "\\")
  end
  return path:gsub("\\", "/")
end

-- Parse path file/folder Windows dari teks yang di-drop Windows Terminal
function M.parse_dropped_paths(lines)
  if not lines or #lines == 0 then
    return {}
  end

  local found = {}
  local seen = {}

  local function add_if_exists(candidate)
    if not candidate then
      return
    end
    local p = trim(candidate)
    -- Lepas tanda kutip pembungkus ('...' atau "...")
    p = p:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
    -- Lepas backslash escape jika terminal meng-escape spasi
    p = trim(p)
    if p == "" then
      return
    end
    -- Cek apakah path valid di disk
    if exists(p) then
      local key = p:lower()
      if not seen[key] then
        seen[key] = true
        table.insert(found, p)
      end
    end
  end

  -- 1. Cek tiap baris utuh dulu (handle single path berspasi tanpa tanda kutip)
  for _, line in ipairs(lines) do
    local cleaned = trim(line)
    if cleaned ~= "" then
      if exists(cleaned:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")) then
        add_if_exists(cleaned)
      else
        -- 2. Ekstrak semua path bertanda kutip "..." atau '...'
        local rest = cleaned
        for quoted in cleaned:gmatch('"([^"]+)"') do
          add_if_exists(quoted)
        end
        for quoted in cleaned:gmatch("'([^']+)'") do
          add_if_exists(quoted)
        end
        rest = trim(rest:gsub('"[^"]+"', "\n"):gsub("'[^']+'", "\n"))

        -- 3. Pisahkan beberapa path Windows tanpa kutip yang mungkin mengandung spasi
        --    (contoh: C:\Users\MUH BINTANG\a.png C:\Users\MUH BINTANG\b.png)
        if rest ~= "" then
          -- Sisipkan newline tepat sebelum setiap drive letter baru (" C:\" atau " D:/") atau UNC (" \\")
          local split_text = rest
            :gsub("%s+([A-Za-z]:[/\\])", "\n%1")
            :gsub("%s+(\\\\)", "\n%1")
          for part in split_text:gmatch("[^\r\n]+") do
            add_if_exists(part)
          end
        end
      end
    end
  end

  return found
end

-- Cari nama tujuan unik jika file/folder dengan nama sama sudah ada (photo (1).png, dst.)
local function unique_dest_path(target_dir, base_name)
  local dest = normalize_sep(target_dir .. sep .. base_name)
  if not exists(dest) then
    return dest, base_name
  end

  local stem, ext = base_name:match("^(.*)(%.[^%.]+)$")
  if not stem or stem == "" then
    stem = base_name
    ext = ""
  end

  for i = 1, 999 do
    local alt_name = string.format("%s (%d)%s", stem, i, ext)
    local alt_dest = normalize_sep(target_dir .. sep .. alt_name)
    if not exists(alt_dest) then
      return alt_dest, alt_name
    end
  end

  return dest, base_name
end

-- Copy rekursif pure Lua/libuv (aman untuk file & folder berspasi / Unicode di Windows)
local function copy_recursive(src, dst)
  local st = uv.fs_stat(src)
  if not st then
    return false, "Sumber tidak ditemukan: " .. tostring(src)
  end

  if st.type == "file" then
    local ok, err = uv.fs_copyfile(src, dst)
    if not ok then
      return false, err
    end
    return true
  elseif st.type == "directory" then
    vim.fn.mkdir(dst, "p")
    local handle, err = uv.fs_scandir(src)
    if not handle then
      return false, err
    end
    while true do
      local name = uv.fs_scandir_next(handle)
      if not name then
        break
      end
      local ok, cerr = copy_recursive(src .. sep .. name, dst .. sep .. name)
      if not ok then
        return false, cerr
      end
    end
    return true
  end

  return false, "Tipe file tidak didukung: " .. tostring(st.type)
end

function M.get_target_dir(state)
  if state and state.tree then
    local node = state.tree:get_node()
    if node and node.type ~= "message" then
      if node.type == "directory" then
        return node:get_id()
      end
      return vim.fn.fnamemodify(node:get_id(), ":h")
    end
  end
  if state and state.path then
    return state.path
  end
  return vim.fn.getcwd()
end

function M.copy_external_paths_to_dir(paths, target_dir)
  if not paths or #paths == 0 then
    return false
  end

  local copied_names = {}
  local errors = {}

  for _, raw_src in ipairs(paths) do
    local src = normalize_sep(raw_src)
    local base_name = vim.fn.fnamemodify(src, ":t")
    if base_name == "" then
      -- Jika folder diakhiri slash
      local stripped = src:gsub("[/\\]+$", "")
      base_name = vim.fn.fnamemodify(stripped, ":t")
      src = stripped
    end

    -- Cegah copy folder ke dalam dirinya sendiri
    local src_l = src:gsub("\\", "/"):gsub("/+$", ""):lower()
    local tgt_l = target_dir:gsub("\\", "/"):gsub("/+$", ""):lower()
    if tgt_l == src_l or tgt_l:sub(1, #src_l + 1) == src_l .. "/" then
      table.insert(errors, base_name .. " (tidak bisa copy folder ke dalam dirinya sendiri)")
    else
      local dest, final_name = unique_dest_path(target_dir, base_name)
      local ok, err = copy_recursive(src, dest)
      if ok then
        table.insert(copied_names, final_name)
      else
        table.insert(errors, base_name .. ": " .. tostring(err))
      end
    end
  end

  if #copied_names > 0 then
    local ok_mgr, manager = pcall(require, "neo-tree.sources.manager")
    if ok_mgr then
      pcall(manager.refresh, "filesystem")
    end
    local folder_label = vim.fn.fnamemodify(target_dir, ":t")
    local preview = table.concat(copied_names, ", ")
    if #preview > 70 then
      preview = preview:sub(1, 67) .. "..."
    end
    vim.notify(
      string.format("📥 Berhasil memasukkan %d item ke '%s/': %s", #copied_names, folder_label, preview),
      vim.log.levels.INFO
    )
  end

  if #errors > 0 then
    vim.notify("⚠️ Gagal menyalin sebagian file: " .. table.concat(errors, "; "), vim.log.levels.WARN)
  end

  return #copied_names > 0
end

-- Ambil daftar file yang sedang di-Copy (Ctrl+C) di Windows File Explorer secara async
function M.get_windows_clipboard_files_async(callback)
  if vim.fn.has("win32") ~= 1 and vim.fn.has("win64") ~= 1 then
    callback({})
    return
  end

  local ps_cmd = table.concat({
    "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;",
    "Add-Type -AssemblyName System.Windows.Forms;",
    "$list = [System.Windows.Forms.Clipboard]::GetFileDropList();",
    "foreach ($item in $list) { Write-Output $item }",
  }, " ")

  vim.system(
    { "powershell", "-NoProfile", "-STA", "-Command", ps_cmd },
    { text = true },
    vim.schedule_wrap(function(res)
      if res.code ~= 0 or not res.stdout or res.stdout == "" then
        callback({})
        return
      end
      local paths = {}
      for line in res.stdout:gmatch("[^\r\n]+") do
        local p = trim(line)
        if p ~= "" and exists(p) then
          table.insert(paths, p)
        end
      end
      callback(paths)
    end)
  )
end

-- Paste pintar di Sidebar Neo-tree:
-- 1) Jika ada file eksternal dari Drag-and-Drop Windows Explorer → langsung copy ke folder aktif
-- 2) Jika clipboard internal Neo-tree (y/x) ada isinya → jalankan paste Neo-tree
-- 3) Jika Windows Explorer Clipboard punya file hasil Ctrl+C → copy ke folder aktif
function M.smart_paste_in_neotree(state, pasted_lines)
  if not state then
    local ok_mgr, manager = pcall(require, "neo-tree.sources.manager")
    if ok_mgr then
      state = manager.get_state("filesystem")
    end
  end
  if not state then
    return
  end

  local target_dir = M.get_target_dir(state)

  -- Prioritas 1: File/folder yang di-drag langsung dari Windows Explorer ke Windows Terminal
  if pasted_lines and #pasted_lines > 0 then
    local dropped = M.parse_dropped_paths(pasted_lines)
    if #dropped > 1 then
      M.copy_external_paths_to_dir(dropped, target_dir)
      return
    elseif #dropped == 1 then
      -- Jika hanya 1 path masuk lewat bracketed paste (mis. saat Ctrl+V banyak file di Windows Explorer),
      -- cek juga Windows Clipboard FileDropList supaya SEMUA file yang dipilih ikut ter-paste!
      M.get_windows_clipboard_files_async(function(win_files)
        if #win_files > 1 then
          M.copy_external_paths_to_dir(win_files, target_dir)
        else
          M.copy_external_paths_to_dir(dropped, target_dir)
        end
      end)
      return
    end
  end

  -- Prioritas 2: Clipboard internal Neo-tree (hasil y / Alt+C / x / Alt+X di Sidebar)
  if state.clipboard and next(state.clipboard) ~= nil then
    local ok_cmd, fs_cmds = pcall(require, "neo-tree.sources.filesystem.commands")
    if ok_cmd then
      state.config = state.config or {}
      fs_cmds.paste_from_clipboard(state)
      return
    end
  end

  -- Prioritas 3: File/folder hasil Ctrl+C dari Windows File Explorer (Clipboard FileDropList)
  M.get_windows_clipboard_files_async(function(win_files)
    if #win_files > 0 then
      M.copy_external_paths_to_dir(win_files, target_dir)
    else
      vim.notify(
        "💡 Cara memasukkan file ke folder Sidebar: Drag file dari Windows Explorer ke sini, atau Ctrl+C file di Windows Explorer lalu tekan Ctrl+V / Alt+V / p di folder tujuan.",
        vim.log.levels.INFO
      )
    end
  end)
end

return M
