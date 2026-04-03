local constants = require("constants")
local settings = require("config.settings")

local cpu = sbar.add("item", constants.items.CPU, {
  position = "right",
  update_freq = 5,
  icon = {
    string = settings.icons.text.cpu,
    color = settings.colors.white,
  },
  label = {
    font = {
      family = settings.fonts.numbers,
      style = settings.fonts.styles.bold,
      size = settings.dimens.text.label,
    },
    string = "??%",
  },
})

cpu:subscribe({ "routine", "forced" }, function()
  sbar.exec("ps -A -o %cpu | awk '{s+=$1} END {printf \"%.0f\", s}'", function(result)
    local usage = tonumber(result) or 0

    -- Get the number of CPU cores to calculate relative usage
    sbar.exec("sysctl -n hw.logicalcpu", function(cores)
      local numCores = tonumber(cores) or 1
      local percent = math.floor(usage / numCores + 0.5)

      local color = settings.colors.white
      if percent > 80 then
        color = settings.colors.red
      elseif percent > 50 then
        color = settings.colors.orange
      elseif percent > 30 then
        color = settings.colors.yellow
      end

      local label = percent .. "%"
      if percent < 10 then
        label = " " .. label
      end

      cpu:set({
        icon = { color = color },
        label = {
          string = label,
          color = color,
        },
      })
    end)
  end)
end)
