-- ============================================================================
-- CORE MODULE: Autocommands (lua/core/autocmds.lua)
-- ============================================================================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- 1. Beri efek highlight singkat saat menyalin teks (Yank)
autocmd("TextYankPost", {
  group = augroup("HighlightYank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 180 })
  end,
})

-- 2. Kembalikan posisi kursor terakhir saat membuka kembali sebuah file
autocmd("BufReadPost", {
  group = augroup("RestoreCursor", { clear = true }),
  callback = function(event)
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- 3. Tutup window bantuan/info cukup dengan menekan tombol 'q'
autocmd("FileType", {
  group = augroup("CloseWithQ", { clear = true }),
  pattern = { "help", "lspinfo", "man", "notify", "qf", "checkhealth" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})

-- 4. Hapus spasi berlebih di ujung baris saat menyimpan file
autocmd("BufWritePre", {
  group = augroup("TrimTrailingWhitespace", { clear = true }),
  pattern = { "*.lua", "*.js", "*.ts", "*.css", "*.html", "*.json", "*.py", "*.c", "*.cpp" },
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- 5. Pastikan buffer prompt internal Neo-tree tidak menghalangi :q atau :qa
autocmd({ "QuitPre", "ExitPre", "BufWinLeave" }, {
  group = augroup("CleanNeoTreePrompt", { clear = true }),
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) then
        local bt = vim.bo[buf].buftype
        local ft = vim.bo[buf].filetype
        if bt == "prompt" or ft == "neo-tree-popup" or ft == "neo-tree" then
          vim.bo[buf].modified = false
        end
      end
    end
  end,
})
