-- Detect if we're docked (external displays) or undocked (built-in only)
-- When undocked, the MacBook notch means we want the bar tight to the top/edges
local function isDocked()
  local handle = io.popen("system_profiler SPDisplaysDataType 2>/dev/null | grep -c 'Resolution:'")
  if handle then
    local result = handle:read("*a")
    handle:close()
    local count = tonumber(result:match("%d+")) or 1
    return count > 1
  end
  return false
end

local docked = isDocked()

-- Undocked (notch): bar sits in the notch area, closer to edges and top
-- Docked (external): more breathing room since there's no notch
local padding <const> = {
  background = 8,
  icon = 10,
  label = 8,
  bar = docked and 39 or 6,
  left = docked and 12 or 6,
  right = docked and 12 or 6,
  item = 18,
  popup = 8,
}

local graphics <const> = {
  bar = {
    height = 36,
    offset = docked and 12 or 4,
  },
  background = {
    height = 24,
    corner_radius = 9,
  },
  slider = {
    height = 20,
  },
  popup = {
    width = 200,
    large_width = 300,
  },
  blur_radius = 30,
}

local text <const> = {
  icon = 16.0,
  label = 14.0,
}

return {
  padding = padding,
  graphics = graphics,
  text = text,
}
