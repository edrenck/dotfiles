local colors   = require("colors")
local settings = require("settings")

local OMNIWMCTL = "/opt/homebrew/bin/omniwmctl"
local MAX_WS    = 10
local MAX_APPS  = 12

---@class OmniWMSlot
---@field num            SbarItem
---@field apps           SbarItem[]
---@field bracket        SbarItem
---@field workspaceRaw   string|nil
---@field workspaceLabel string|nil

---@type OmniWMSlot[]
local slots = {}

---@type table[]
local workspace_entries = {}
local refresh_pending = false

local function name_num(i) return "omniwm.ws." .. i .. ".num" end
local function name_app(i, j) return "omniwm.ws." .. i .. ".app." .. j end
local function name_brk(i) return "omniwm.ws." .. i .. ".bracket" end

local function shell_quote(value)
    return "'" .. tostring(value or ""):gsub("'", [['"'"']]) .. "'"
end

local function normalize_text(value)
    if value == nil then return nil end
    local text = tostring(value):gsub("[\r\n]", "")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then return nil end
    return text
end

local function parse_workspace_bar_payload(response)
    if type(response) ~= "table" then return nil end

    if type(response.monitors) == "table" then
        return response
    end

    local result = response.result
    if type(result) ~= "table" then return nil end

    local payload = result.payload
    if type(payload) == "table" and type(payload.monitors) == "table" then
        return payload
    end

    return nil
end

local function pick_monitor(payload)
    if type(payload) ~= "table" or type(payload.monitors) ~= "table" then
        return nil
    end

    local interaction_monitor_id = normalize_text(payload.interactionMonitorId)
    if interaction_monitor_id then
        for _, monitor in ipairs(payload.monitors) do
            if normalize_text(monitor.id) == interaction_monitor_id then
                return monitor
            end
        end
    end

    for _, monitor in ipairs(payload.monitors) do
        if monitor.enabled ~= false and monitor.isVisible ~= false then
            return monitor
        end
    end

    return payload.monitors[1]
end

local function make_num(i)
    local item = Sbar.add("item", name_num(i), {
        drawing = false,
        icon = {
            string        = tostring(i),
            font          = { family = settings.font.text_round, style = "Bold", size = 12.0 },
            color         = colors.grey,
            padding_left  = 4,
            padding_right = 4,
            y_offset      = 1,
        },
        label = { drawing = false },
    })

    item:subscribe("mouse.clicked", function()
        local slot = slots[i]
        local raw_workspace = slot and slot.workspaceRaw
        if raw_workspace then
            Sbar.exec(OMNIWMCTL .. " workspace focus-name " .. shell_quote(raw_workspace))
        end
    end)

    return item
end

local function make_app(i, j)
    return Sbar.add("item", name_app(i, j), {
        drawing       = false,
        icon          = { drawing = false },
        label         = { drawing = false },
        padding_left  = 2,
        padding_right = 2,
        background    = {
            drawing = true,
            image   = { scale = 0.80, clip = 0.8 },
        },
    })
end

local function make_bracket(i, members)
    return Sbar.add("bracket", name_brk(i), members, {
        blur_radius = 12,
        background  = {
            drawing       = false,
            color         = colors.bg05,
            border_color  = colors.bg1,
            blur_radius   = 32,
            border_width  = 1,
            height        = 32,
            corner_radius = 10,
        },
    })
end

local function build_pool()
    for i = 1, MAX_WS do
        local num = make_num(i)
        local apps = {}
        local members = { num.name }
        for j = 1, MAX_APPS do
            apps[j] = make_app(i, j)
            members[#members + 1] = apps[j].name
        end
        local bracket = make_bracket(i, members)
        slots[i] = {
            num = num,
            apps = apps,
            bracket = bracket,
            workspaceRaw = nil,
            workspaceLabel = nil,
        }
    end
end

local function paint_active_state(slot, active)
    slot.num:set({
        icon = { color = active and colors.white or colors.grey },
    })

    slot.bracket:set({ background = { drawing = active } })

    for j = 1, MAX_APPS do
        slot.apps[j]:set({ background = { image = { scale = active and 1 or 0.80 } } })
    end
end

local function paint_slot(i, entry)
    local slot = slots[i]
    if not slot then return end

    slot.workspaceRaw = entry.raw
    slot.workspaceLabel = entry.label
    slot.num:set({
        drawing = true,
        icon    = { string = entry.label },
    })

    for j = 1, MAX_APPS do
        local app = entry.apps[j]
        local item = slot.apps[j]
        if app then
            item:set({
                drawing    = true,
                background = {
                    drawing     = true,
                    blur_radius = 12,
                    image       = {
                        string = "app." .. app,
                        scale  = entry.focused and 1 or 0.80,
                        clip   = 0.8,
                    },
                    x_offset    = -1,
                },
            })
        else
            item:set({ drawing = false })
        end
    end

    paint_active_state(slot, entry.focused)
end

local function hide_slot(i)
    local slot = slots[i]
    if not slot then return end
    slot.workspaceRaw = nil
    slot.workspaceLabel = nil
    slot.num:set({ drawing = false })
    for j = 1, MAX_APPS do
        slot.apps[j]:set({ drawing = false })
    end
    slot.bracket:set({ background = { drawing = false } })
end

local function render()
    for i = 1, MAX_WS do
        local entry = workspace_entries[i]
        if entry then
            paint_slot(i, entry)
        else
            hide_slot(i)
        end
    end
end

local function apps_from_workspace(workspace)
    local apps = {}
    local windows = type(workspace.windows) == "table" and workspace.windows or {}

    for _, app_entry in ipairs(windows) do
        local app_name = normalize_text(app_entry.appName)
        if app_name then
            local count = tonumber(app_entry.windowCount) or 1
            if count < 1 then count = 1 end
            for _ = 1, count do
                apps[#apps + 1] = app_name
                if #apps >= MAX_APPS then
                    return apps
                end
            end
        end
    end

    return apps
end

local function refresh_layout()
    if refresh_pending then return end
    refresh_pending = true

    Sbar.exec(OMNIWMCTL .. " query workspace-bar --json", function(response)
        refresh_pending = false

        local payload = parse_workspace_bar_payload(response)
        if not payload then return end

        local monitor = pick_monitor(payload)
        if not monitor then return end

        local next_entries = {}
        local workspaces = type(monitor.workspaces) == "table" and monitor.workspaces or {}

        for _, workspace in ipairs(workspaces) do
            local raw = normalize_text(workspace.rawName) or normalize_text(workspace.id)
            local label = normalize_text(workspace.displayName)
                or raw
                or normalize_text(workspace.id)
            if raw and label then
                next_entries[#next_entries + 1] = {
                    raw = raw,
                    label = label,
                    focused = workspace.isFocused == true,
                    apps = apps_from_workspace(workspace),
                }
            end
            if #next_entries >= MAX_WS then
                break
            end
        end

        workspace_entries = next_entries
        Sbar.animate("circ", 30, render)
    end)
end

local function start_event_bridge()
    local command = [[/bin/sh -c 'pgrep -f "[o]mniwm_event_bridge.sh" >/dev/null || nohup "$HOME/.config/sketchybar/helpers/omniwm_event_bridge.sh" >/tmp/omniwm_event_bridge.log 2>&1 &' ]]
    Sbar.exec(command)
end

Sbar.add("event", "omniwm_workspace_changed")

local watcher = Sbar.add("item", "omniwm.watcher", {
    drawing       = false,
    updates       = true,
    update_freq   = 2,
    padding_left  = 0,
    padding_right = 0,
})

watcher:subscribe({ "omniwm_workspace_changed", "space_windows_change", "system_woke", "forced", "routine" }, function()
    start_event_bridge()
    refresh_layout()
end)

Sbar.delay(0.5, function()
    build_pool()
    start_event_bridge()
    refresh_layout()
end)
