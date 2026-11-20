-- ============================================================================
-- PLUGIN MODULE: Treesitter Syntax Highlighting (lua/plugins/treesitter.lua)
-- ============================================================================

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local ok_install, ts_install = pcall(require, "nvim-treesitter.install")
      if ok_install then
        ts_install.compilers = { "gcc", "clang", "cl", "zig" }
        ts_install.prefer_git = false
      end

      local ok_configs, ts_configs = pcall(require, "nvim-treesitter.configs")
      if ok_configs then
        ts_configs.setup({
          -- Parser dasar yang sudah tersedia atau ringan dikompilasi
          ensure_installed = {
            "lua",
            "vim",
            "vimdoc",
            "query",
            "markdown",
            "markdown_inline",
          },
          auto_install = false,
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
          indent = {
            enable = true,
          },
        })
      end
    end,
  },
}
