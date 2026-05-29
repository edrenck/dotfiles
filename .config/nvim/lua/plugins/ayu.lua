return {
  {
    "shatur/neovim-ayu",
    config = function()
      require("ayu").setup({
        overrides = {
          Normal = { bg = "None" },
          NormalFloat = { bg = "none" },
          ColorColumn = { bg = "None" },
          SignColumn = { bg = "None" },
          Folded = { bg = "None" },
          FoldColumn = { bg = "None" },
          CursorLine = { bg = "None" },
          CursorColumn = { bg = "None" },
          VertSplit = { bg = "None" },
        },
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = {
      theme = "ayu",
      component_separators = "",
      section_separators = { left = "", right = "" },
      sections = {
        lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
        lualine_z = {
          { "location", separator = { right = "" }, left_padding = 2 },
        },
      },
    },
  },

  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        indicator = {
          style = "none",
        },
        show_buffer_close_icons = false,
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "ayu",
    },
  },
}
