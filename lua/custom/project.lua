-- ============================================================================
-- CUSTOM MODULE: Project / Directory Picker (lua/custom/project.lua)
-- Cari folder project lewat Telescope, lalu pindah cwd Neovim ke folder itu.
-- Shortcut: Ctrl+Shift+O | Command: :OpenProject | Dashboard: [p]
-- ============================================================================

local M = {}

local RECENT_FILE = vim.fn.stdpath("data") .. "/nvim-projects"

local IGNORED = {
  ["node_modules"] = true,
  [".git"] = true,
  ["appdata"] = true,
  [".cache"] = true,
  ["vendor"] = true,
  ["target"] = true,
  ["dist"] = true,
  ["build"] = true,
  [".venv"] = true,
  ["venv"] = true,
  ["__pycache__"] = true,
  [".next"] = true,
  [".nuxt"] = true,
  [".idea"] = true,
  [".vscode"] = true,
  ["site-packages"] = true,
  ["windows"] = true,
  ["program files"] = true,
  ["program files (x86)"] = true,
  ["programdata"] = true,
  ["system volume information"] = true,
  ["$recycle.bin"] = true,
  ["perflogs"] = true,
  ["recovery"] = true,
  ["boot"] = true,
  ["efi"] = true,
}

local function normalize(path)
  return (vim.fn.fnamemodify(path, ":p"):gsub("\\", "/")):lower()
end

local function is_allowed(path)
  local normalized = normalize(path)
  for part in normalized:gmatch("[^/]+") do
    if IGNORED[part] then
      return false
    end
  end
  return true
end

local function read_recent()
  local ok, lines = pcall(vim.fn.readfile, RECENT_FILE)
  if not ok then
    return {}
  end
  local result = {}
  for _, line in ipairs(lines) do
    if line ~= "" and vim.fn.isdirectory(line) == 1 then
      table.insert(result, vim.fn.fnamemodify(line, ":p"))
    end
  end
  return result
end

local function save_recent(path)
  local list = { path }
  local seen = { [normalize(path)] = true }
  for _, item in ipairs(read_recent()) do
    local key = normalize(item)
    if not seen[key] then
      seen[key] = true
      table.insert(list, item)
    end
    if #list >= 12 then
      break
    end
  end
  pcall(vim.fn.writefile, list, RECENT_FILE)
end

-- Root paling luar: semua drive yang terpasang (C:\, D:\, ...) + home + cwd.
-- Folder sistem dipangkas lebih awal supaya scan tetap cepat.
local function default_roots()
  local roots = {}
  if vim.fn.has("win32") == 1 then
    for byte = string.byte("A"), string.byte("Z") do
      local drive = string.char(byte) .. ":\\"
      if vim.fn.isdirectory(drive) == 1 then
        table.insert(roots, drive)
      end
    end
  else
    table.insert(roots, "/")
  end
  table.insert(roots, vim.fn.expand("~"))
  table.insert(roots, vim.fn.getcwd())
  return roots
end

-- Telusuri anak directory satu per satu agar folder terlarang tidak ikut discan.
local function scan_children(path, depth)
  local found = {}
  local pattern = path:gsub("[\\/]+$", "") .. "/*"

  for _, child in ipairs(vim.fn.glob(pattern, true, true)) do
    if vim.fn.isdirectory(child) == 1 and is_allowed(child) then
      table.insert(found, child)
      if depth > 1 then
        vim.list_extend(found, scan_children(child, depth - 1))
      end
    end
  end

  return found
end

-- Kumpulkan kandidat directory dari root paling luar.
-- Bisa di-override: vim.g.nvim_project_roots = { "D:/project", "C:/work" }
-- Kedalaman: vim.g.nvim_project_depth = 3 (default, bisa dinaikkan).
function M.directories()
  local roots = vim.g.nvim_project_roots
  if type(roots) ~= "table" or #roots == 0 then
    roots = default_roots()
  end

  local depth = vim.g.nvim_project_depth or 3
  local results = {}
  local seen = {}

  local function add(path)
    local absolute = vim.fn.fnamemodify(path, ":p")
    local key = normalize(absolute)
    if not seen[key] and vim.fn.isdirectory(absolute) == 1 then
      seen[key] = true
      table.insert(results, absolute)
    end
  end

  for _, root in ipairs(roots) do
    if vim.fn.isdirectory(root) == 1 then
      add(root)
      for _, dir in ipairs(scan_children(root, depth)) do
        add(dir)
      end
    end
  end

  return results
end

-- Pindahkan seluruh sesi Neovim ke directory pilihan.
function M.open(path)
  local i18n = require("core.i18n")
  local target = vim.fn.fnamemodify(path, ":p")

  if vim.fn.isdirectory(target) ~= 1 then
    vim.notify(i18n.t("project_none") .. ": " .. target, vim.log.levels.WARN)
    return
  end

  local ok, err = pcall(vim.cmd, "cd " .. vim.fn.fnameescape(target))
  if not ok then
    vim.notify(tostring(err), vim.log.levels.ERROR)
    return
  end

  save_recent(target)

  -- Pastikan project dibuka di editor utama, bukan di panel terminal/sidebar.
  local custom = require("custom")
  custom.ensure_normal_mode()
  custom.focus_editor()

  -- Tutup halaman dashboard supaya langsung masuk ke ruang kerja project.
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "alpha" then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end

  -- Sidebar Neo-tree mengikuti cwd yang baru (didorong juga oleh DirChanged).
  pcall(vim.cmd, "Neotree show filesystem left")
  pcall(function()
    local manager = require("neo-tree.sources.manager")
    manager.refresh("filesystem")
    manager.refresh("git_status")
    manager.refresh("buffers")
  end)

  vim.notify(i18n.t("project_opened") .. ": " .. target, vim.log.levels.INFO, {
    title = i18n.t("open_project"),
  })
end

-- Buka picker Telescope berisi project terakhir + directory yang ditemukan.
function M.pick()
  -- Dipanggil dari tengah mengetik: keluar dari insert/terminal dan arahkan
  -- fokus ke editor dulu supaya picker tidak terbuka di panel terminal.
  local custom = require("custom")
  custom.ensure_normal_mode()
  custom.focus_editor()
  require("lazy").load({ plugins = { "telescope.nvim" } })

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local i18n = require("core.i18n")

  local items = {}
  local seen = {}

  local function add(path, recent)
    local absolute = vim.fn.fnamemodify(path, ":p")
    local key = normalize(absolute)
    if not seen[key] and vim.fn.isdirectory(absolute) == 1 then
      seen[key] = true
      table.insert(items, { path = absolute, recent = recent })
    end
  end

  for _, path in ipairs(read_recent()) do
    add(path, true)
  end
  for _, path in ipairs(M.directories()) do
    add(path, false)
  end

  if #items == 0 then
    vim.notify(i18n.t("project_none"), vim.log.levels.WARN, { title = i18n.t("open_project") })
    return
  end

  pickers.new({}, {
    prompt_title = i18n.t("project_prompt"),
    finder = finders.new_table({
      results = items,
      entry_maker = function(item)
        local display = (item.recent and "󰊄  " or "  ") .. vim.fn.fnamemodify(item.path, ":~")
        return { value = item.path, display = display, ordinal = display }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = false,
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if entry then
          M.open(entry.value)
        end
      end)
      return true
    end,
  }):find()
end

vim.keymap.set({ "n", "i", "v" }, "<C-S-o>", M.pick, {
  desc = "󰉋 Buka Project / Open Project (Ctrl+Shift+O)",
})
-- Di terminal, keluar dulu dari terminal-mode sebelum membuka picker.
vim.keymap.set("t", "<C-S-o>", function()
  vim.cmd("stopinsert")
  M.pick()
end, { desc = "󰉋 Buka Project dari Terminal (Ctrl+Shift+O)" })

vim.api.nvim_create_user_command("OpenProject", M.pick, {
  desc = "Cari project / directory · Find project / directory",
})

return M
