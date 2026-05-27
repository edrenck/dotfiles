return {
  "b0o/incline.nvim",
  config = function()
    require("incline").setup({
      hide = {
        cursorline = true,
        focused_win = false,
        only_win = false,
      },
      render = function(props)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
        local icon, color = require("nvim-web-devicons").get_icon_color(filename)
        if icon == nil then
          icon = ""
          color = "Normal"
        end
        return {
          { " " .. icon .. " ", guifg = color },
          { " " .. filename .. " ", gui = "bold", guifg = "Normal" },
        }
      end,
    })
  end,
  event = "VeryLazy",
}
