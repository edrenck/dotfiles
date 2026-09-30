local colors = require("colors")

-- Equivalent to the --bar domain
Sbar.bar({
  height = 37,
  color = colors.bar.bg,
  border_color = colors.bar.border,
  border_width = 0,
  padding_right = 2,
  padding_left = 2,
  font_smoothing = true,
  y_offset = 0,
  blur_radius = 64,
  corner_radius = 0,
  margin = 0,
})
