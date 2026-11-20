-- ============================================================================
-- PLUGIN MODULE: VS Code Multi-Tab Sidebar (Neo-tree), Autopairs, Comment & Terminal
-- Shortcut Standar VS Code Tanpa Kombinasi <Space>
-- ============================================================================

return {
  -- 1. NEO-TREE: Sidebar Multi-Tab Bergaya VS Code (Ctrl+B / Alt+E)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<C-b>", "<cmd>Neotree toggle filesystem left<CR>", mode = { "n", "i", "v" }, desc = " Buka/Tutup Sidebar Explorer (Ctrl+B)" },
      { "<A-e>", "<cmd>Neotree focus filesystem left<CR>", mode = { "n", "i", "v" }, desc = " Fokus ke Sidebar File Explorer (Alt+E)" },
      { "<A-s>", "<cmd>Neotree show git_status left<CR>", mode = { "n", "i", "v" }, desc = " Buka Tab Git di Sidebar Kiri (Alt+S)" },
    },
    config = function()
      -- State & helper untuk Mouse Drag-and-Drop file/folder di Sidebar Explorer (Neo-tree)
      local drag_state = {
        active = false,
        dragged = false,
        winid = nil,
        start_line = nil,
        source_path = nil,
        source_name = nil,
      }

      local function normalize_path(p)
        if not p then
          return ""
        end
        local norm = p:gsub("\\", "/"):gsub("/+$", "")
        if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
          norm = norm:lower()
        end
        return norm
      end

      local function feed_mouse(key)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "n", false)
      end

      local function handle_drag_mouse_down(state)
        local pos = vim.fn.getmousepos()
        local cur_win = vim.api.nvim_get_current_win()
        if pos.winid ~= cur_win or pos.line <= 0 then
          drag_state.active = false
          drag_state.dragged = false
          feed_mouse("<LeftMouse>")
          return
        end

        pcall(vim.api.nvim_win_set_cursor, cur_win, { pos.line, math.max(0, pos.column - 1) })
        local node = state.tree:get_node(pos.line)
        if
          node
          and (node.type == "file" or node.type == "directory")
          and normalize_path(node:get_id()) ~= normalize_path(state.path)
        then
          drag_state.active = true
          drag_state.dragged = false
          drag_state.winid = cur_win
          drag_state.start_line = pos.line
          drag_state.source_path = node:get_id()
          drag_state.source_name = node.name
        else
          drag_state.active = false
          drag_state.dragged = false
        end
      end

      local function handle_drag_mouse_move(state)
        if not drag_state.active then
          feed_mouse("<LeftDrag>")
          return
        end

        local pos = vim.fn.getmousepos()
        if pos.winid == drag_state.winid and pos.line > 0 then
          pcall(vim.api.nvim_win_set_cursor, pos.winid, { pos.line, 0 })
          if pos.line ~= drag_state.start_line then
            drag_state.dragged = true
            local target = state.tree:get_node(pos.line)
            if target and (target.type == "file" or target.type == "directory") then
              local target_dir = target.type == "directory" and target:get_id() or vim.fn.fnamemodify(target:get_id(), ":h")
              local folder_label = vim.fn.fnamemodify(target_dir, ":t")
              vim.api.nvim_echo({
                {
                  string.format("📦 Drag '%s' → '%s/' (lepas mouse untuk pindahkan)", drag_state.source_name, folder_label),
                  "WarningMsg",
                },
              }, false, {})
            end
          end
        end
      end

      local function handle_drag_mouse_release(state)
        local was_dragging = drag_state.active and drag_state.dragged
        local src_path = drag_state.source_path
        local src_name = drag_state.source_name
        local winid = drag_state.winid

        drag_state.active = false
        drag_state.dragged = false

        if not was_dragging then
          return
        end

        vim.api.nvim_echo({ { "" } }, false, {})

        local pos = vim.fn.getmousepos()
        if pos.winid ~= winid or pos.line <= 0 then
          vim.notify("ℹ️ Drag dibatalkan (lepas di luar Sidebar Explorer).", vim.log.levels.INFO)
          return
        end

        local target = state.tree:get_node(pos.line)
        if not target or (target.type ~= "file" and target.type ~= "directory") then
          return
        end

        local target_dir = target.type == "directory" and target:get_id() or vim.fn.fnamemodify(target:get_id(), ":h")
        local src_norm = normalize_path(src_path)
        local src_parent_norm = normalize_path(vim.fn.fnamemodify(src_path, ":h"))
        local target_norm = normalize_path(target_dir)

        if src_norm == target_norm or src_parent_norm == target_norm then
          vim.notify("ℹ️ '" .. src_name .. "' sudah berada di folder tersebut.", vim.log.levels.INFO)
          return
        end

        if target_norm:sub(1, #src_norm + 1) == src_norm .. "/" then
          vim.notify("⚠️ Tidak bisa memindahkan folder ke dalam dirinya sendiri.", vim.log.levels.WARN)
          return
        end

        local fs_actions = require("neo-tree.sources.filesystem.lib.fs_actions")
        local utils = require("neo-tree.utils")
        local manager = require("neo-tree.sources.manager")
        local dest = target_dir .. utils.path_separator .. src_name

        fs_actions.move_node(src_path, dest, function()
          manager.refresh("filesystem")
          vim.notify(
            string.format("📦 Dipindahkan: %s → %s/", src_name, vim.fn.fnamemodify(target_dir, ":t")),
            vim.log.levels.INFO
          )
        end, target_dir)
      end

      require("neo-tree").setup({
        close_if_last_window = false,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,

        source_selector = {
          winbar = true,
          statusline = false,
          show_scrolled_off_parent_node = false,
          sources = {
            { source = "filesystem", display_name = "  Files " },
            { source = "git_status", display_name = "  Git " },
            { source = "buffers", display_name = " 󰓩 Tabs " },
          },
          content_layout = "center",
          tabs_layout = "equal",
        },

        default_component_configs = {
          indent = {
            indent_size = 2,
            padding = 1,
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "└",
            expander_collapsed = "",
            expander_expanded = "",
          },
          icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "󰜌",
            folder_empty_open = "󰷏",
            default = "󰈙",
          },
          modified = {
            symbol = "●",
            highlight = "NeoTreeModified",
          },
          diagnostics = {
            symbols = {
              hint = "󰌵",
              info = "",
              warn = "",
              error = "",
            },
          },
          git_status = {
            symbols = {
              added = "✚",
              modified = "",
              deleted = "✖",
              renamed = "󰁕",
              untracked = "★",
              ignored = "◌",
              unstaged = "󰄱",
              staged = "",
              conflict = "",
            },
          },
        },

        window = {
          position = "left",
          width = 34,
          mappings = {
            ["<space>"] = "none",
            ["<cr>"] = "open",
            ["<2-LeftMouse>"] = "open",
            ["l"] = "open",
            ["h"] = "close_node",
            ["s"] = "open_vsplit",
            ["S"] = "open_split",
            ["t"] = "open_tabnew",
            -- Shortcut Buat File & Buat Directory langsung dari Sidebar (Popup Modal Tengah):
            ["<C-n>"] = function()
              require("custom").create_new_file()
            end,
            ["<A-n>"] = function()
              require("custom").create_new_directory()
            end,
            ["n"] = function()
              require("custom").create_new_file()
            end,
            ["N"] = function()
              require("custom").create_new_directory()
            end,
            ["a"] = function()
              require("custom").create_new_file()
            end,
            ["A"] = function()
              require("custom").create_new_directory()
            end,
            ["<F2>"] = "rename",
            ["r"] = "rename",
            ["<Del>"] = "delete",
            ["d"] = "delete",
            -- Copy / Cut / Paste File & Folder ala VS Code (Duplikat & Pindah)
            ["<C-c>"] = "copy_to_clipboard",
            ["y"] = "copy_to_clipboard",
            ["<C-x>"] = "cut_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["<C-v>"] = "paste_from_clipboard",
            ["p"] = "paste_from_clipboard",
            ["<Esc>"] = "clear_clipboard",
            ["c"] = "copy",
            ["m"] = "move",
            -- Copy Path Lengkap ke Clipboard Windows (Y) & Buka di Windows Explorer (o)
            ["Y"] = function(state)
              local node = state.tree:get_node()
              if node then
                local path = node:get_id()
                vim.fn.setreg("+", path)
                vim.notify("📋 Path disalin ke Clipboard: " .. path, vim.log.levels.INFO)
              end
            end,
            ["o"] = function(state)
              local node = state.tree:get_node()
              if node then
                local path = node:get_id()
                vim.fn.jobstart(string.format('cmd /c start "" "%s"', path), { detach = true })
                vim.notify("🪟 Membuka di Windows: " .. vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
              end
            end,
            ["q"] = "close_window",
            ["R"] = "refresh",
            ["?"] = "show_help",
            ["<"] = "prev_source",
            [">"] = "next_source",
          },
        },

        filesystem = {
          window = {
            mappings = {
              -- Mouse Drag-and-Drop file/folder langsung ke folder tujuan di Sidebar
              ["<LeftMouse>"] = handle_drag_mouse_down,
              ["<LeftDrag>"] = handle_drag_mouse_move,
              ["<LeftRelease>"] = handle_drag_mouse_release,
            },
          },
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = {
            enabled = true,
            leave_dirs_open = false,
          },
          use_libuv_file_watcher = true,
        },

        git_status = {
          window = {
            position = "left",
            mappings = {
              ["A"] = "git_add_all",
              ["gu"] = "git_unstage_file",
              ["ga"] = "git_add_file",
              ["gr"] = "git_revert_file",
              ["gc"] = "git_commit",
              ["gp"] = "git_push",
              ["gg"] = "git_commit_and_push",
            },
          },
        },
      })
    end,
  },

  -- 2. Nvim-Autopairs (Tutup Otomatis Kurung & Tanda Kutip)
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
    },
  },

  -- 3. Comment.nvim (Komentar Cepat dengan Ctrl + /)
  {
    "numToStr/Comment.nvim",
    lazy = false,
    opts = {},
  },

  -- 4. TOGGLETERM: Mendukung Multi-Terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    lazy = false,
    config = function()
      require("toggleterm").setup({
        size = 13,
        hide_numbers = true,
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = false,
        terminal_mappings = false,
        persist_size = true,
        persist_mode = true,
        direction = "horizontal",
        close_on_exit = true,
        float_opts = {
          border = "rounded",
          title_pos = "center",
        },
      })
    end,
  },
}
