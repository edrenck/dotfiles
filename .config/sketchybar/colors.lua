return {
  black       = 0xff0b0e14,
  white       = 0xffe6e1cf,
  red         = 0xfff07178,
  green       = 0xffc2d94c,
  blue        = 0xff59c2ff,
  yellow      = 0xffffd580,
  orange      = 0xffff8f40,
  magenta     = 0xffd2a6ff,
  grey        = 0xff8a9199,
  transparent = 0x00000000,

  bar = {
    bg     = 0x8c0b0e14,
    border = 0x4059c2ff,
  },
  popup = {
    bg     = 0xe011151c,
    border = 0x6659c2ff,
  },

  bg_solid = 0xff11151c,
  bg0      = 0xcc11151c,
  bg05     = 0x803a4355,
  bg1      = 0x40222934,
  bg2      = 0x4d3a4355,
with_alpha = function(color, alpha)
if alpha > 1.0 or alpha < 0.0 then return color end
return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end,
}
