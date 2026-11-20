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
      -- Tab / S-Tab sengaja normal-mode saja (di insert dipakai nvim-cmp untuk autocomplete).
      { "<Tab>", "<cmd>BufferLineCycleNext<CR>", desc = "📑 Tab Berikutnya (Tab)" },
      { "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", desc = "📑 Tab Sebelumnya (Shift+Tab)" },
      -- Pindah tab halaman file (aktif di Normal, Insert & Visual — di dalam terminal, Alt+Left/Right dipakai pindah tab terminal).
      { "<A-Right>", "<cmd>BufferLineCycleNext<CR>", mode = { "n", "i", "v" }, desc = "📑 Tab File Berikutnya (Alt+Right)" },
      { "<A-Left>", "<cmd>BufferLineCyclePrev<CR>", mode = { "n", "i", "v" }, desc = "📑 Tab File Sebelumnya (Alt+Left)" },
      { "<C-PageDown>", "<cmd>BufferLineCycleNext<CR>", mode = { "n", "i", "v" }, desc = "📑 Tab File Berikutnya (Ctrl+PageDown)" },
      { "<C-PageUp>", "<cmd>BufferLineCyclePrev<CR>", mode = { "n", "i", "v" }, desc = "📑 Tab File Sebelumnya (Ctrl+PageUp)" },
      { "<C-Tab>", "<cmd>BufferLineCycleNext<CR>", mode = { "n", "i", "v" }, desc = "📑 Tab File Berikutnya (Ctrl+Tab)" },
      { "<C-S-Tab>", "<cmd>BufferLineCyclePrev<CR>", mode = { "n", "i", "v" }, desc = "📑 Tab File Sebelumnya (Ctrl+Shift+Tab)" },
      -- Alt+1..9 tetap bisa dipakai saat sedang mengetik (tidak bentrok dengan cmp).
      { "<A-p>", "<cmd>BufferLineTogglePin<CR>", mode = { "n", "i", "v" }, desc = "📌 Pin / Unpin Tab Aktif (Alt+P)" },
      { "<A-1>", "<cmd>BufferLineGoToBuffer 1<CR>", mode = { "n", "i", "v" }, desc = "Pindah ke Tab 1" },
      { "<A-2>", "<cmd>BufferLineGoToBuffer 2<CR>", mode = { "n", "i", "v" }, desc = "Pindah ke Tab 2" },
      { "<A-3>", "<cmd>BufferLineGoToBuffer 3<CR>", mode = { "n", "i", "v" }, desc = "Pindah ke Tab 3" },
      { "<A-4>", "<cmd>BufferLineGoToBuffer 4<CR>", mode = { "n", "i", "v" }, desc = "Pindah ke Tab 4" },
      { "<A-5>", "<cmd>BufferLineGoToBuffer 5<CR>", mode = { "n", "i", "v" }, desc = "Pindah ke Tab 5" },
      { "<A-6>", "<cmd>BufferLineGoToBuffer 6<CR>", mode = { "n", "i", "v" }, desc = "Pindah ke Tab 6" },
      { "<A-7>", "<cmd>BufferLineGoToBuffer 7<CR>", mode = { "n", "i", "v" }, desc = "Pindah ke Tab 7" },
      { "<A-8>", "<cmd>BufferLineGoToBuffer 8<CR>", mode = { "n", "i", "v" }, desc = "Pindah ke Tab 8" },
      { "<A-9>", "<cmd>BufferLineGoToBuffer 9<CR>", mode = { "n", "i", "v" }, desc = "Pindah ke Tab 9" },
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
      local i18n = require("core.i18n")

      local function terminal_toggle_badge()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == "toggleterm" or vim.bo[buf].buftype == "terminal" then
            return i18n.t("terminal_close")
          end
        end
        return i18n.t("terminal_open")
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
            {
              function()
                return i18n.t("lang_badge")
              end,
              color = { fg = "#ffd479", gui = "bold" },
              on_click = function()
                require("core.i18n").select()
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

  -- 5. ALPHA DASHBOARD: Menu sambutan terkelompok, rapi & bilingual (ID / EN)
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")
      local i18n = require("core.i18n")

      local BUTTON_WIDTH = 54

      -- Highlight mengikuti colorscheme aktif (TokyoNight / VS Code / Catppuccin)
      local function apply_highlights()
        local links = {
          AlphaBanner = "Title",
          AlphaTagline = "String",
          AlphaSection = "Directory",
          AlphaShortcut = "Keyword",
          AlphaFooter = "Comment",
        }
        for group, target in pairs(links) do
          vim.api.nvim_set_hl(0, group, { link = target })
        end
      end
      apply_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_highlights })

      local banner = {
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗  ",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║  ",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║  ",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║  ",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║  ",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝  ",
      }

      local button_refs = {}

      -- Teks tombol dihitung ulang saat bahasa berganti; shortcut tetap sejajar kanan.
      local function apply_button_text(ref)
        local text = i18n.t(ref.key)
        local hint = ref.hint
        local padding = math.max(0, BUTTON_WIDTH - vim.fn.strdisplaywidth(text) - vim.fn.strdisplaywidth(hint))
        local start = #text + padding

        ref.element.val = text
        ref.element.opts.shortcut = hint
        ref.element.opts.hl_shortcut = { { "AlphaShortcut", start, start + #hint } }
      end

      local function button(key, tr_key, hint, action)
        local element = dashboard.button(key, i18n.t(tr_key), action)
        element.opts.width = BUTTON_WIDTH
        element.opts.align_shortcut = "right"
        element.opts.cursor = 3

        local ref = { element = element, key = tr_key, hint = hint }
        table.insert(button_refs, ref)
        apply_button_text(ref)
        return element
      end

      local function group(items)
        return { type = "group", val = items, opts = { spacing = 0 } }
      end

      local function section(tr_key)
        return {
          type = "text",
          val = function()
            local title = i18n.t(tr_key)
            local side = math.max(2, math.floor((BUTTON_WIDTH - vim.fn.strdisplaywidth(title) - 2) / 2))
            return string.rep("─", side) .. " " .. title .. " " .. string.rep("─", side)
          end,
          opts = { position = "center", hl = "AlphaSection" },
        }
      end

      local function text(tr_key, hl)
        return {
          type = "text",
          val = function()
            return i18n.t(tr_key)
          end,
          opts = { position = "center", hl = hl },
        }
      end

      local v = vim.version()
      local version = string.format("%d.%d.%d", v.major, v.minor, v.patch)

      local config = {
        layout = {
          { type = "padding", val = 1 },
          { type = "text", val = banner, opts = { position = "center", hl = "AlphaBanner" } },
          { type = "padding", val = 1 },
          text("tagline", "AlphaTagline"),
          { type = "padding", val = 2 },

          section("section_file"),
          group({
            button("p", "open_project", "[Ctrl+Shift+O]", "<cmd>lua require('custom.project').pick()<CR>"),
            button("n", "new_file", "[Ctrl+N]", "<cmd>lua require('custom').create_new_file()<CR>"),
            button("d", "new_folder", "[Alt+N]", "<cmd>lua require('custom').create_new_directory()<CR>"),
            button("e", "explorer", "[Ctrl+B]", "<cmd>Neotree toggle filesystem left<CR>"),
            button("f", "find_file", "[Ctrl+P]", "<cmd>Telescope find_files<CR>"),
          }),
          { type = "padding", val = 1 },

          section("section_search"),
          group({
            button("t", "terminal", "[Ctrl+T / F7]", "<cmd>lua require('custom').toggle_bottom_terminal()<CR>"),
            button("w", "live_grep", "[Alt+F / F3]", "<cmd>Telescope live_grep<CR>"),
          }),
          { type = "padding", val = 1 },

          section("section_git"),
          group({
            button("g", "neogit", "[Alt+G / F9]", "<cmd>Neogit<CR>"),
            button("v", "diffview", "[F10]", "<cmd>DiffviewOpen<CR>"),
            button("h", "git_log", "[Alt+H / F11]", "<cmd>DiffviewFileHistory<CR>"),
          }),
          { type = "padding", val = 1 },

          section("section_prefs"),
          group({
            button("c", "theme", "[F6]", "<cmd>lua require('custom').cycle_theme()<CR>"),
            button("L", "language", "[L / Alt+L]", "<cmd>lua require('core.i18n').select()<CR>"),
            button("l", "license", "[:LicenseInfo]", "<cmd>LicenseInfo<CR>"),
            button("k", "keymaps", "[F1]", "<cmd>Telescope keymaps<CR>"),
            button("q", "quit", "[Ctrl+Q]", "<cmd>confirm qa<CR>"),
          }),
          { type = "padding", val = 2 },

          {
            type = "text",
            val = function()
              return i18n.t("footer"):format(version)
            end,
            opts = { position = "center", hl = "AlphaFooter" },
          },
        },
        opts = { margin = 5 },
      }

      -- :Lang / Alt+L / tombol Language mengganti teks tanpa rebuild dashboard.
      vim.api.nvim_create_autocmd("User", {
        pattern = "NvimLanguageChanged",
        callback = function()
          for _, ref in ipairs(button_refs) do
            apply_button_text(ref)
          end
        end,
      })

      alpha.setup(config)
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
