-- ============================================================================
-- PLUGIN MODULE: Icons (Devicons + Mini.Icons), Top Tabs, Statusbar & Dashboard
-- Font: FiraCode Nerd Font | Shortcut 100% Standar VS Code (Tanpa <Space>)
-- ============================================================================

return {
  -- 1. NVIM-WEB-DEVICONS: Paket Ikon Utama untuk File, Tab, Sidebar & Statusline
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    priority = 950,
    config = function()
      require("nvim-web-devicons").setup({
        color_icons = true,
        default = true,
        strict = true,
        override_by_extension = {
          ["html"] = { icon = "", color = "#e34c26", name = "Html" },
          ["css"]  = { icon = "", color = "#264de4", name = "Css" },
          ["js"]   = { icon = "", color = "#f7df1e", name = "Js" },
          ["json"] = { icon = "", color = "#cbcb41", name = "Json" },
          ["md"]   = { icon = "", color = "#519aba", name = "Md" },
          ["lua"]  = { icon = "", color = "#51a0cf", name = "Lua" },
          ["py"]   = { icon = "", color = "#ffbc03", name = "Py" },
          ["png"]  = { icon = "󰸭", color = "#a074c4", name = "Png" },
          ["jpg"]  = { icon = "󰸭", color = "#a074c4", name = "Jpg" },
          ["svg"]  = { icon = "󰜡", color = "#FFB13B", name = "Svg" },
          ["cmd"]  = { icon = "", color = "#4d5a5e", name = "Cmd" },
        },
        override_by_filename = {
          ["readme.md"]       = { icon = "󰂺", color = "#519aba", name = "Readme" },
          ["index.html"]      = { icon = "", color = "#e44d26", name = "IndexHtml" },
          [".gitignore"]      = { icon = "", color = "#f1502f", name = "GitIgnore" },
          ["lazy-lock.json"]  = { icon = "󰒲", color = "#51a0cf", name = "LazyLock" },
        },
      })
    end,
  },

  -- 2. MINI.ICONS: Ikon Tambahan untuk UI & Plugin Modern
  {
    "echasnovski/mini.icons",
    lazy = false,
    opts = {},
  },

  -- 3. BUFFERLINE: Baris Tab Atas Bergaya VS Code (Tab / Shift+Tab / Alt+1..9 / Alt+W)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<Tab>", "<cmd>BufferLineCycleNext<CR>", desc = "📑 Tab Berikutnya (Tab)" },
      { "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", desc = "📑 Tab Sebelumnya (Shift+Tab)" },
      { "<A-p>", "<cmd>BufferLineTogglePin<CR>", desc = "📌 Pin / Unpin Tab Aktif (Alt+P)" },
      { "<A-1>", "<cmd>BufferLineGoToBuffer 1<CR>", desc = "Pindah ke Tab 1" },
      { "<A-2>", "<cmd>BufferLineGoToBuffer 2<CR>", desc = "Pindah ke Tab 2" },
      { "<A-3>", "<cmd>BufferLineGoToBuffer 3<CR>", desc = "Pindah ke Tab 3" },
      { "<A-4>", "<cmd>BufferLineGoToBuffer 4<CR>", desc = "Pindah ke Tab 4" },
      { "<A-5>", "<cmd>BufferLineGoToBuffer 5<CR>", desc = "Pindah ke Tab 5" },
      { "<A-6>", "<cmd>BufferLineGoToBuffer 6<CR>", desc = "Pindah ke Tab 6" },
      { "<A-7>", "<cmd>BufferLineGoToBuffer 7<CR>", desc = "Pindah ke Tab 7" },
      { "<A-8>", "<cmd>BufferLineGoToBuffer 8<CR>", desc = "Pindah ke Tab 8" },
      { "<A-9>", "<cmd>BufferLineGoToBuffer 9<CR>", desc = "Pindah ke Tab 9" },
    },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          themable = true,
          numbers = "ordinal",
          close_command = function(bufnum)
            require("custom").smart_close_buffer(bufnum)
          end,
          right_mouse_command = function(bufnum)
            require("custom").smart_close_buffer(bufnum)
          end,
          indicator = {
            icon = "▎",
            style = "icon",
          },
          buffer_close_icon = "󰅖",
          modified_icon = "●",
          close_icon = "",
          left_trunc_marker = "",
          right_trunc_marker = "",
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          diagnostics_indicator = function(count, level)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
          end,
          offsets = {
            {
              filetype = "neo-tree",
              text = "󰙅  EXPLORER  ( Files •  Git • 󰓩 Tabs)",
              highlight = "Title",
              text_align = "left",
              separator = true,
            },
          },
          color_icons = true,
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = true,
          persist_buffer_sort = true,
          separator_style = "slant",
          enforce_regular_tabs = false,
          always_show_bufferline = true,
          hover = {
            enabled = true,
            delay = 150,
            reveal = { "close" },
          },
        },
      })
    end,
  },

  -- 4. LUALINE: Statusbar Bawah Bergaya VS Code (Dengan Ikon & Tombol Klik Terminal)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local function terminal_toggle_badge()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == "toggleterm" or vim.bo[buf].buftype == "terminal" then
            return " Tutup Terminal [Ctrl+T]"
          end
        end
        return " Buka Terminal [Ctrl+T]"
      end

      local function font_badge()
        return "󰛖 FiraCode"
      end

      local function lsp_status()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then
          return "󰒋 Ready"
        end
        local names = {}
        for _, client in ipairs(clients) do
          table.insert(names, client.name)
        end
        return "󰅩 " .. table.concat(names, ", ")
      end

      require("lualine").setup({
        options = {
          theme = "auto",
          globalstatus = true,
          component_separators = { left = "│", right = "│" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = { statusline = { "alpha" } },
        },
        sections = {
          lualine_a = { { "mode", icon = "" } },
          lualine_b = {
            { "branch", icon = "" },
            {
              "diff",
              symbols = { added = " ", modified = " ", removed = " " },
            },
            {
              "diagnostics",
              symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
            },
          },
          lualine_c = {
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1, symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" } },
          },
          lualine_x = {
            {
              terminal_toggle_badge,
              color = { fg = "#7dcfff", gui = "bold" },
              on_click = function()
                require("custom").toggle_bottom_terminal()
              end,
            },
            { lsp_status },
            { font_badge },
            "encoding",
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { { "location", icon = "" } },
        },
      })
    end,
  },

  -- 5. ALPHA DASHBOARD: Halaman Sambutan Bergaya VS Code (Tanpa <Space>)
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗  ",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║  ",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║  ",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║  ",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║  ",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝  ",
        "  󰛖 FIRA CODE NERD FONT • VS CODE SHORTCUTS • NO SPACE  ",
      }

      dashboard.section.buttons.val = {
        dashboard.button("n", "󰈔  Buat File Baru (Create New File)             [Ctrl+N]", "<cmd>lua require('custom').create_new_file()<CR>"),
        dashboard.button("d", "  Buat Directory / Folder Baru                 [Alt+N]", "<cmd>lua require('custom').create_new_directory()<CR>"),
        dashboard.button("e", "󰙅  Buka/Tutup Sidebar Explorer (Files/Git/Tabs) [Ctrl+B]", "<cmd>Neotree toggle filesystem left<CR>"),
        dashboard.button("f", "  Cari & Buka File Cepat (Quick Open)          [Ctrl+P]", "<cmd>Telescope find_files<CR>"),
        dashboard.button("t", "  Buka/Tutup Panel Terminal Bawah              [Ctrl+T / F7]", "<cmd>lua require('custom').toggle_bottom_terminal()<CR>"),
        dashboard.button("g", "  Halaman Git Source Control (Neogit)          [Alt+G / F9]", "<cmd>Neogit<CR>"),
        dashboard.button("v", "  Halaman Git Diff Side-by-Side (Diffview)     [F10]", "<cmd>DiffviewOpen<CR>"),
        dashboard.button("h", "  Halaman Riwayat Commit Git (Git Log)         [Alt+H / F11]", "<cmd>DiffviewFileHistory<CR>"),
        dashboard.button("w", "󰊄  Cari Teks di Seluruh Project (Live Grep)     [Alt+F / F3]", "<cmd>Telescope live_grep<CR>"),
        dashboard.button("c", "  Ganti Tema Warna (TokyoNight / VS Code)      [F6]", "<cmd>lua require('custom').cycle_theme()<CR>"),
        dashboard.button("k", "  Daftar Semua Shortcut Keyboard               [F1]", "<cmd>Telescope keymaps<CR>"),
        dashboard.button("q", "󰈆  Keluar dari Neovim                           [Ctrl+Q]", "<cmd>confirm qa<CR>"),
      }

      local v = vim.version()
      dashboard.section.footer.val = string.format(
        "Neovim v%d.%d.%d  •  Ctrl+N: File Baru  •  Alt+N: Folder Baru  •  Ctrl+Z: Undo  •  Ctrl+D: Duplikat  •  Ctrl+T: Terminal",
        v.major,
        v.minor,
        v.patch
      )

      alpha.setup(dashboard.opts)
    end,
  },

  -- 6. Indent Blankline (Garis Panduan Indentasi)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
      exclude = {
        filetypes = { "help", "alpha", "dashboard", "neo-tree", "NeogitStatus", "DiffviewFiles", "lazy", "mason", "toggleterm" },
      },
    },
  },
}
