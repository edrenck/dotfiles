local colors = require("colors")
local settings = require("settings")

local vpn_icons = {
  surfshark = ":surfshark:",
  tailscale = ":tailscale:",
}

local function vpn_status_from_scutil(raw)
  local surfshark_active = false
  local tailscale_active = false

  if raw == nil then
    return surfshark_active, tailscale_active
  end

  for line in raw:gmatch("[^\r\n]+") do
    local lower = line:lower()
    local connected = lower:match("%(connected%)") ~= nil

    if connected and lower:match("surfshark") then
      surfshark_active = true
    end

    if connected and lower:match("tailscale") then
      tailscale_active = true
    end
  end

  return surfshark_active, tailscale_active
end

local function tailscale_running(raw)
  if raw == nil then
    return nil
  end

  if type(raw) == "table" then
    local state = raw.BackendState
    if type(state) ~= "string" then
      return nil
    end
    return state == "Running"
  end

  if type(raw) ~= "string" then
    return nil
  end

  local state = raw:match('"BackendState"%s*:%s*"([^"]+)"')
  if state == nil then
    return nil
  end

  return state == "Running"
end

local vpn = Sbar.add("item", "widgets.vpn", {
  position = "right",
  updates = true,
  update_freq = 5,
  icon = {
    string = vpn_icons.surfshark,
    font = {
      family = "sketchybar-app-font",
      style = settings.font.style_map["Regular"],
      size = 14.0,
    },
    color = colors.grey,
  },
  label = {
    string = vpn_icons.tailscale,
    font = {
      family = "sketchybar-app-font",
      style = settings.font.style_map["Regular"],
      size = 14.0,
    },
    y_offset = 0,
    color = colors.grey,
  },
})

local function refresh_vpn()
  Sbar.exec("scutil --nc list", function(raw)
    local surfshark_active, tailscale_service_connected = vpn_status_from_scutil(raw)

    local function apply(tailscale_active)
      vpn:set({
        icon = { color = surfshark_active and colors.white or colors.grey },
        label = {
          color = tailscale_active and colors.white or colors.grey,
        },
      })
    end

    apply(tailscale_service_connected)

    if not tailscale_service_connected then
      return
    end

    Sbar.exec("sh -lc 'command -v tailscale >/dev/null 2>&1 && tailscale status --json 2>/dev/null || true'", function(tailscale_raw)
      local tailscale_active = tailscale_running(tailscale_raw)
      if tailscale_active ~= nil then
        apply(tailscale_active)
      end
    end)
  end)
end

vpn:subscribe({ "routine", "forced", "system_woke", "wifi_change" }, refresh_vpn)
vpn:subscribe("mouse.clicked", refresh_vpn)

refresh_vpn()

Sbar.add("bracket", "widgets.vpn.bracket", { vpn.name }, {
  background = {
    color = colors.bg05,
    border_color = colors.bg1,
    border_width = 1,
  },
})

Sbar.add("item", "widgets.vpn.padding", {
  position = "right",
  width = settings.group_paddings,
})
