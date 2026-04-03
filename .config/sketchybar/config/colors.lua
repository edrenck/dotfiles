-- Catppuccin Mocha palette
-- https://github.com/catppuccin/catppuccin
local colors <const> = {
  black = 0xff11111b,       -- crust
  white = 0xffcdd6f4,       -- text
  red = 0xfff38ba8,         -- red
  green = 0xffa6e3a1,       -- green
  blue = 0xff89b4fa,        -- blue
  yellow = 0xfff9e2af,      -- yellow
  orange = 0xfffab387,      -- peach
  magenta = 0xfff5c2e7,     -- pink
  purple = 0xffcba6f7,      -- mauve
  other_purple = 0xff45475a, -- surface1
  cyan = 0xff94e2d5,        -- teal
  grey = 0xff6c7086,        -- overlay0
  dirty_white = 0xc8bac2de, -- subtext0 with alpha
  dark_grey = 0xff313244,   -- surface0
  transparent = 0x00000000,
  bar = {
    bg = 0xf11e1e2e,        -- base
    border = 0xff313244,    -- surface0
    transparent = 0x001e1e2e,
  },
  popup = {
    bg = 0xf11e1e2e,        -- base
    border = 0xff313244,    -- surface0
  },
  slider = {
    bg = 0xf11e1e2e,        -- base
    border = 0xff313244,    -- surface0
  },
  bg1 = 0xd31e1e2e,         -- base with alpha
  bg2 = 0xff45475a,         -- surface1

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}

return colors
