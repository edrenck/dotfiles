local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local function parse_cpu_load(raw)
  if raw == nil then return nil end

  local idle = raw:match("CPU usage:%s+[%d%.]+%%%s+user,%s+[%d%.]+%%%s+sys,%s+([%d%.]+)%%%s+idle")
  idle = tonumber(idle)
  if idle == nil then return nil end

  local load = 100 - idle
  if load < 0 then return 0 end
  if load > 100 then return 100 end
  return load
end

local cpu = Sbar.add("graph", "widgets.cpu" , 42, {
  position = "right",
  updates = true,
  update_freq = 2,
  graph = { color = colors.blue },
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = { string = icons.cpu },
  label = {
    string = "CPU ??%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Medium"],
      size = 10.0,
    },
    align = "right",
    padding_right = 0,
    width = 0,
    y_offset = 4
  },
  padding_right = settings.paddings + 6
})

local function refresh_cpu()
  Sbar.exec("top -l 1 -n 0", function(raw)
    local load = parse_cpu_load(raw)
    if load == nil then return end

    cpu:push({ load / 100 })

    local color = colors.blue
    if load > 30 then
      if load < 60 then
        color = colors.yellow
      elseif load < 80 then
        color = colors.orange
      else
        color = colors.red
      end
    end

    cpu:set({
      graph = { color = color },
      label = { string = string.format("%.0f%%", load), align = "right" },
    })
  end)
end

cpu:subscribe({ "routine", "forced", "system_woke" }, refresh_cpu)
refresh_cpu()

Sbar.add("bracket", "widgets.cpu.bracket", { cpu.name }, {
  background = { color         = colors.bg05,
  border_color  = colors.bg1, border_width = 1 }
})

Sbar.add("item", "widgets.cpu.padding", {
  position = "right",
  width = settings.group_paddings
})
