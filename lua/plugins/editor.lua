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
            ["c"] = "copy",
            ["m"] = "move",
            -- Fitur Baru: Copy Path ke Clipboard (Ctrl+C) & Buka di Aplikasi Windows/Explorer (o)
            ["<C-c>"] = function(state)
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
