return {
  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "go",
        "json",
        "lua",
        "markdown",
        "python",
        "vim",
        "yaml",
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = function(_, opts)
      -- Ensure highlight groups exist before plugin loads
      vim.api.nvim_set_hl(0, "IblChar", { fg = "#3b3b3b" })
      vim.api.nvim_set_hl(0, "IblScopeChar", { fg = "#5c5c5c" })
      return opts
    end,
  },
}
