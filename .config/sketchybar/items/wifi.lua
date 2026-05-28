local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local popup_width = 250
local network_interface = "en0"
local last_rx_bytes = nil
local last_tx_bytes = nil
local last_sample_time = nil

local wifi = Sbar.add("item", "widgets.wifi.padding", {
  position = "right",
  updates = true,
  update_freq = 2,
  icon = {
    string = icons.wifi.connected,
    color = colors.white,
  },
  label = {
    string = icons.wifi.download .. " 0B " .. icons.wifi.upload .. " 0B",
    font = { family = settings.font.numbers, size = 10.0 },
    y_offset = 1,
  },
})

-- Background around the item
local wifi_bracket = Sbar.add("bracket", "widgets.wifi.bracket", {
  wifi.name,
}, {
    background = { color = colors.bg05, border_color = colors.bg1, border_width = 1 },
    padding_right=1,
  popup = { align = "center", height = 30, blur_radius = 16, background = { border_width = 1, border_color = colors.bg2, color = colors.bg1 } }
})

local ssid = Sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    font = {
      style = settings.font.style_map["Bold"]
    },
    string = icons.wifi.router,
  },
  width = popup_width,
  align = "center",
  label = {
    font = {
      size = 15,
      style = settings.font.style_map["Bold"]
    },
    max_chars = 18,
    string = "????????????",
  },
  background = {
    height = 2,
    color = colors.grey,
    y_offset = -15
  }
})

local hostname = Sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "hostname ~>",
    width = popup_width / 2,
  },
  label = {
    max_chars = 20,
    string = "????????????",
    width = popup_width / 2,
    align = "right",
  }
})

local ip = Sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "IP:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  }
})

local mask = Sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "Subnet mask:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  }
})

local router = Sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "Router:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  },
})

Sbar.add("item", { position = "right", width = settings.group_paddings })

local function format_speed(bytes_per_second)
  local value = tonumber(bytes_per_second) or 0
  if value < 1 then return "0B" end

  local units = { "B", "K", "M", "G" }
  local unit = 1
  while value >= 1024 and unit < #units do
    value = value / 1024
    unit = unit + 1
  end

  if unit == 1 then
    return string.format("%.0f%s", value, units[unit])
  end
  if value >= 10 then
    return string.format("%.0f%s", value, units[unit])
  end
  return string.format("%.1f%s", value, units[unit])
end

local function parse_netstat(raw)
  if raw == nil then return nil, nil end

  for line in raw:gmatch("[^\r\n]+") do
    if line:match("^" .. network_interface .. "%s+") and line:match("<Link") then
      local fields = {}
      for field in line:gmatch("%S+") do
        fields[#fields + 1] = field
      end
      return tonumber(fields[7]), tonumber(fields[10])
    end
  end

  return nil, nil
end

local function refresh_status()
  Sbar.exec("ipconfig getifaddr " .. network_interface, function(ip)
    local connected = not (ip == "")
    wifi:set({
      icon = {
        string = connected and icons.wifi.connected or icons.wifi.disconnected,
        color = connected and colors.white or colors.red,
      },
    })
  end)
end

local function refresh_network()
  Sbar.exec("netstat -ibn -I " .. network_interface, function(raw)
    local rx_bytes, tx_bytes = parse_netstat(raw)
    if rx_bytes == nil or tx_bytes == nil then return end

    local now = os.time()
    local rx_rate = 0
    local tx_rate = 0

    if last_rx_bytes ~= nil and last_tx_bytes ~= nil and last_sample_time ~= nil then
      local elapsed = math.max(1, now - last_sample_time)
      rx_rate = math.max(0, (rx_bytes - last_rx_bytes) / elapsed)
      tx_rate = math.max(0, (tx_bytes - last_tx_bytes) / elapsed)
    end

    last_rx_bytes = rx_bytes
    last_tx_bytes = tx_bytes
    last_sample_time = now

    wifi:set({
      label = {
        string = icons.wifi.download .. " " .. format_speed(rx_rate) .. " " .. icons.wifi.upload .. " " .. format_speed(tx_rate),
      },
    })
  end)
end

wifi:subscribe({ "wifi_change", "system_woke" }, function()
  refresh_status()
  refresh_network()
end)

wifi:subscribe({ "routine", "forced" }, refresh_network)

local function hide_details()
  wifi_bracket:set({ popup = { drawing = false } })
end

local function toggle_details()
  local should_draw = wifi_bracket:query().popup.drawing == "off"
  if should_draw then
    wifi_bracket:set({ popup = { drawing = true }})
    Sbar.exec("networksetup -getcomputername", function(result)
      hostname:set({ label = result })
        end)
    Sbar.exec("ipconfig getifaddr " .. network_interface, function(result)
      ip:set({ label = result })
    end)
    Sbar.exec("ipconfig getsummary " .. network_interface .. " | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(result)
      ssid:set({ label = result })
    end)
    Sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Subnet mask: ' '/^Subnet mask: / {print $2}'", function(result)
      mask:set({ label = result })
    end)
    Sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Router: ' '/^Router: / {print $2}'", function(result)
      router:set({ label = result })
    end)
  else
    hide_details()
  end
end

wifi:subscribe("mouse.clicked", toggle_details)
wifi_bracket:subscribe("mouse.exited", hide_details)

local function copy_label_to_clipboard(env)
  local label = Sbar.query(env.NAME).label.value
  Sbar.exec("echo \"" .. label .. "\" | pbcopy")
  Sbar.set(env.NAME, { label = { string = icons.clipboard, align="center" } })
  Sbar.delay(1, function()
    Sbar.set(env.NAME, { label = { string = label, align = "right" } })
  end)
end

ssid:subscribe("mouse.clicked", copy_label_to_clipboard)
hostname:subscribe("mouse.clicked", copy_label_to_clipboard)
ip:subscribe("mouse.clicked", copy_label_to_clipboard)
mask:subscribe("mouse.clicked", copy_label_to_clipboard)
router:subscribe("mouse.clicked", copy_label_to_clipboard)

refresh_status()
refresh_network()
