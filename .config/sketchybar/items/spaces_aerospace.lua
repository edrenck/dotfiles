local colors   = require("colors")
local settings = require("settings")

local AEROSPACE = "/opt/homebrew/bin/aerospace"
local MAX_WS    = 10
local MAX_APPS  = 12

---@class AeroSpaceSlot
---@field num       SbarItem
---@field apps      SbarItem[]
---@field bracket   SbarItem
---@field workspace string|nil

---@type AeroSpaceSlot[]
local slots = {}

---@type string[]
local workspace_order = {}

---@type table<string, string[]>
local workspace_apps = {}

local active_workspace = nil
local refresh_pending = false

local function name_num(i) return "aerospace.ws." .. i .. ".num" end
local function name_app(i, j) return "aerospace.ws." .. i .. ".app." .. j end
local function name_brk(i) return "aerospace.ws." .. i .. ".bracket" end

local function shell_quote(value)
    return "'" .. tostring(value or ""):gsub("'", [['"'"']]) .. "'"
end

local function normalize_workspace(value)
    if value == nil then return nil end
    local workspace = tostring(value):gsub("[\r\n]", "")
    workspace = workspace:gsub("^%s+", ""):gsub("%s+$", "")
    if workspace == "" then return nil end
    return workspace
end

local function row_workspace(row)
    if type(row) == "table" then
        return normalize_workspace(row.workspace)
    end
    return normalize_workspace(row)
end

local function row_app(row)
    if type(row) ~= "table" then return nil end
    local app = row["app-name"] or row.app
    if app == nil or app == "" then return nil end
    return tostring(app)
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
        local workspace = slot and slot.workspace
        if workspace then
            Sbar.exec(AEROSPACE .. " workspace " .. shell_quote(workspace))
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
        slots[i] = { num = num, apps = apps, bracket = bracket, workspace = nil }
    end
end

local function paint_active_state(slot)
    local active = slot.workspace ~= nil and slot.workspace == active_workspace

    slot.num:set({
        icon = { color = active and colors.white or colors.grey },
    })

    slot.bracket:set({ background = { drawing = active } })

    for j = 1, MAX_APPS do
        slot.apps[j]:set({ background = { image = { scale = active and 1 or 0.80 } } })
    end
end

local function set_active_workspace(workspace)
    active_workspace = normalize_workspace(workspace)
    for i = 1, MAX_WS do
        local slot = slots[i]
        if slot then paint_active_state(slot) end
    end
end

local function paint_slot(i, workspace)
    local slot = slots[i]
    if not slot then return end

    slot.workspace = workspace
    slot.num:set({
        drawing = true,
        icon    = { string = workspace },
    })

    local apps = workspace_apps[workspace] or {}
    local active = workspace == active_workspace

    for j = 1, MAX_APPS do
        local app = apps[j]
        local item = slot.apps[j]
        if app then
            item:set({
                drawing    = true,
                background = {
                    drawing     = true,
                    blur_radius = 12,
                    image       = {
                        string = "app." .. app,
                        scale  = active and 1 or 0.80,
                        clip   = 0.8,
                    },
                    x_offset    = -1,
                },
            })
        else
            item:set({ drawing = false })
        end
    end

    paint_active_state(slot)
end

local function hide_slot(i)
    local slot = slots[i]
    if not slot then return end
    slot.workspace = nil
    slot.num:set({ drawing = false })
    for j = 1, MAX_APPS do slot.apps[j]:set({ drawing = false }) end
    slot.bracket:set({ background = { drawing = false } })
end

local function render()
    for i = 1, MAX_WS do
        local workspace = workspace_order[i]
        if workspace then
            paint_slot(i, workspace)
        else
            hide_slot(i)
        end
    end
end

local function refresh_focused()
    Sbar.exec(AEROSPACE .. " list-workspaces --focused --json", function(result)
        if type(result) ~= "table" then return end
        local workspace = row_workspace(result[1])
        if workspace then set_active_workspace(workspace) end
    end)
end

local function refresh_layout()
    if refresh_pending then return end
    refresh_pending = true

    Sbar.exec(AEROSPACE .. " list-workspaces --all --json", function(workspaces)
        if type(workspaces) ~= "table" then
            refresh_pending = false
            return
        end

        local next_order = {}
        for _, row in ipairs(workspaces) do
            local workspace = row_workspace(row)
            if workspace then next_order[#next_order + 1] = workspace end
        end
        workspace_order = next_order

        local cmd = AEROSPACE .. " list-windows --all --format '%{workspace} %{app-name}' --json"
        Sbar.exec(cmd, function(windows)
            refresh_pending = false
            workspace_apps = {}

            if type(windows) == "table" then
                for _, row in ipairs(windows) do
                    local workspace = row_workspace(row)
                    local app = row_app(row)
                    if workspace and app then
                        workspace_apps[workspace] = workspace_apps[workspace] or {}
                        local apps = workspace_apps[workspace]
                        apps[#apps + 1] = app
                    end
                end
            end

            Sbar.animate("circ", 30, render)
        end)
    end)
end

Sbar.add("event", "aerospace_workspace_changed")

local watcher = Sbar.add("item", "aerospace.watcher", {
    drawing       = false,
    updates       = true,
    padding_left  = 0,
    padding_right = 0,
})

watcher:subscribe("aerospace_workspace_changed", function(env)
    local workspace = env.FOCUSED_WORKSPACE or env.AEROSPACE_FOCUSED_WORKSPACE
    if workspace then
        set_active_workspace(workspace)
    else
        refresh_focused()
    end
end)

watcher:subscribe({ "space_windows_change", "system_woke", "forced" }, function()
    refresh_layout()
end)

Sbar.delay(0.5, function()
    build_pool()
    refresh_focused()
    refresh_layout()
end)
