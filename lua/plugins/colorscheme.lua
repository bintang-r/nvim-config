-- ============================================================================
-- PLUGIN MODULE: Colorschemes (VS Code Dark+, TokyoNight & Catppuccin)
-- ============================================================================

return {
  -- 1. TokyoNight (Modern Dark IDE Theme)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        sidebars = "dark",
        floats = "dark",
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },

  -- 2. Official VS Code Dark+ / Light+ Theme (ketik :colorscheme vscode)
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 900,
    opts = {
      transparent = false,
      italic_comments = true,
    },
  },

  -- 3. Catppuccin Mocha (ketik :colorscheme catppuccin-mocha)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = {
      flavour = "mocha",
    },
  },
}
