local constants = require("constants")
local settings = require("config.settings")

-- workspaceName -> { label = sbarItem, apps = { [windowId] = sbarItem }, appOrder = { windowId, ... } }
local spaces = {}

local spaceConfigs <const> = {
  ["1"] = { icon = "1", name = "Notes" },
  ["2"] = { icon = "2", name = "Terminal" },
  ["3"] = { icon = "3", name = "Browser" },
  ["4"] = { icon = "4", name = "AltBrowser" },
  ["5"] = { icon = "5", name = "Remote" },
  ["6"] = { icon = "6", name = "Planner" },
  ["7"] = { icon = "7", name = "Chat" },
  ["8"] = { icon = "8", name = "Mail" },
  ["9"] = { icon = "9", name = "Music" },
}

-- Ordered workspace names so the bar lays out predictably
local workspaceOrder <const> = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }

local focusedWorkspace = nil

local swapWatcher = sbar.add("item", {
  drawing = false,
  updates = true,
})

local currentWorkspaceWatcher = sbar.add("item", {
  drawing = false,
  updates = true,
})

local function bracketName(workspaceName)
  return "workspaces." .. workspaceName .. ".bracket"
end

local function labelName(workspaceName)
  return "workspaces." .. workspaceName .. ".label"
end

local function appItemName(workspaceName, windowId)
  return "workspaces." .. workspaceName .. ".app." .. windowId
end

-- Rebuild the bracket for a workspace so it covers its current members
-- (label + ordered app icons). Brackets in sketchybar don't auto-discover
-- items added after creation, and regex members are unreliable; rebuilding
-- with an explicit member list is the cleanest way to guarantee the pill
-- spans the label and all current app icons as one continuous background.
local function rebuildBracket(workspaceName)
  local space = spaces[workspaceName]
  if space == nil then return end

  local bname = bracketName(workspaceName)
  local isSelected = (workspaceName == focusedWorkspace)
  local bgColor = isSelected and settings.colors.white or settings.colors.bg1

  -- Build member list: label first, then app icons in insertion order.
  local members = { labelName(workspaceName) }
  for _, windowId in ipairs(space.appOrder) do
    table.insert(members, appItemName(workspaceName, windowId))
  end

  local membersCli = table.concat(members, " ")

  -- Issue remove + add + set as a single chained command so there is no
  -- async race window where the freshly-recreated bracket exists with a
  -- stale color before the highlight set lands.
  local cmd = string.format(
    "/opt/homebrew/bin/sketchybar " ..
    "--remove %s " ..
    "--add bracket %s %s " ..
    "--set %s background.drawing=on background.color=0x%08x " ..
    "background.border_width=0 background.height=%d background.corner_radius=%d " ..
    ">/dev/null 2>&1",
    bname,
    bname, membersCli,
    bname, bgColor,
    settings.dimens.graphics.background.height,
    settings.dimens.graphics.background.corner_radius
  )
  sbar.exec(cmd)
end

local function applyHighlight(workspaceName, isSelected)
  local space = spaces[workspaceName]
  if space == nil then return end

  local fgColor = isSelected and settings.colors.bg1 or settings.colors.white
  local bgColor = isSelected and settings.colors.white or settings.colors.bg1

  -- Item contents (icons) recolor to contrast with pill.
  space.label:set({
    icon = { color = fgColor },
    label = { color = fgColor },
  })

  for _, appItem in pairs(space.apps) do
    appItem:set({
      icon = { color = fgColor },
    })
  end

  -- Update bracket background color.
  sbar.exec(string.format(
    "/opt/homebrew/bin/sketchybar --set %s background.color=0x%08x",
    bracketName(workspaceName), bgColor
  ))
end

local function selectCurrentWorkspace(focusedWorkspaceName)
  focusedWorkspace = focusedWorkspaceName
  for _, workspaceName in ipairs(workspaceOrder) do
    applyHighlight(workspaceName, workspaceName == focusedWorkspaceName)
  end
end

local function findAndSelectCurrentWorkspace()
  sbar.exec(constants.aerospace.GET_CURRENT_WORKSPACE, function(focusedWorkspaceOutput)
    local focusedName = focusedWorkspaceOutput:match("[^\r\n]+")
    selectCurrentWorkspace(focusedName)
  end)
end

local function addAppItem(workspaceName, windowId, appName, afterItemName)
  local space = spaces[workspaceName]
  if space == nil then return end

  local glyph = settings.icons.apps[appName] or settings.icons.apps["default"]
  local itemName = appItemName(workspaceName, windowId)

  space.apps[windowId] = sbar.add("item", itemName, {
    position = "left",
    icon = {
      string = glyph,
      font = settings.fonts.icons(),
      color = settings.colors.white,
      padding_left = 4,
      padding_right = 4,
    },
    label = { drawing = false },
    background = { drawing = false },
    click_script = "aerospace workspace " .. workspaceName,
  })
  table.insert(space.appOrder, windowId)

  -- Position right after the workspace's tail so icons stay grouped.
  if afterItemName ~= nil then
    sbar.exec("/opt/homebrew/bin/sketchybar --move " .. itemName .. " after " .. afterItemName)
  end
end

local function removeAppItem(workspaceName, windowId)
  local space = spaces[workspaceName]
  if space == nil or space.apps[windowId] == nil then return end
  sbar.remove(appItemName(workspaceName, windowId))
  space.apps[windowId] = nil
  for i, id in ipairs(space.appOrder) do
    if id == windowId then
      table.remove(space.appOrder, i)
      break
    end
  end
end

local function refreshWorkspaceApps()
  sbar.exec(constants.aerospace.LIST_ALL_WINDOWS, function(output)
    local current = {}
    for _, name in ipairs(workspaceOrder) do current[name] = {} end

    for line in output:gmatch("[^\r\n]+") do
      local workspace, app, id = line:match("^([^|]+)|([^|]+)|([^|]+)$")
      if workspace and app and id then
        workspace = workspace:gsub("^%s+", ""):gsub("%s+$", "")
        app = app:gsub("^%s+", ""):gsub("%s+$", "")
        id = id:gsub("^%s+", ""):gsub("%s+$", "")
        if current[workspace] then
          current[workspace][id] = app
        end
      end
    end

    for _, workspaceName in ipairs(workspaceOrder) do
      local space = spaces[workspaceName]
      if space ~= nil then
        local desired = current[workspaceName] or {}
        local changed = false

        -- Remove items no longer present.
        local toRemove = {}
        for windowId, _ in pairs(space.apps) do
          if desired[windowId] == nil then
            table.insert(toRemove, windowId)
          end
        end
        for _, windowId in ipairs(toRemove) do
          removeAppItem(workspaceName, windowId)
          changed = true
        end

        -- Determine tail for positioning.
        local tail = labelName(workspaceName)
        if #space.appOrder > 0 then
          tail = appItemName(workspaceName, space.appOrder[#space.appOrder])
        end

        -- Add new items, ordered by numeric window id for stability.
        local newIds = {}
        for windowId, _ in pairs(desired) do
          if space.apps[windowId] == nil then
            table.insert(newIds, windowId)
          end
        end
        table.sort(newIds, function(a, b) return tonumber(a) < tonumber(b) end)
        for _, windowId in ipairs(newIds) do
          addAppItem(workspaceName, windowId, desired[windowId], tail)
          tail = appItemName(workspaceName, windowId)
          changed = true
        end

        if changed then
          rebuildBracket(workspaceName)
          -- Defensive: explicitly reassert the highlight for this workspace
          -- after rebuild to avoid any visual race where the freshly created
          -- bracket renders with a stale color.
          applyHighlight(workspaceName, workspaceName == focusedWorkspace)
        end
      end
    end

    findAndSelectCurrentWorkspace()
  end)
end

local function createWorkspaces()
  for _, workspaceName in ipairs(workspaceOrder) do
    local spaceConfig = spaceConfigs[workspaceName]
    if spaceConfig ~= nil then
      local lname = labelName(workspaceName)

      local labelItem = sbar.add("item", lname, {
        position = "left",
        label = { drawing = false },
        icon = {
          string = spaceConfig.icon,
          color = settings.colors.white,
          padding_left = 8,
          padding_right = 6,
        },
        background = { drawing = false },
        click_script = "aerospace workspace " .. workspaceName,
      })

      sbar.add("item", "workspaces." .. workspaceName .. ".padding", {
        position = "left",
        width = settings.dimens.padding.label,
        background = { drawing = false },
        icon = { drawing = false },
        label = { drawing = false },
      })

      spaces[workspaceName] = {
        label = labelItem,
        apps = {},
        appOrder = {},
      }

      -- Create the initial bracket with just the label.
      rebuildBracket(workspaceName)
    end
  end

  refreshWorkspaceApps()
end

swapWatcher:subscribe(constants.events.SWAP_MENU_AND_SPACES, function(env)
  local isShowingSpaces = env.isShowingMenu == "off" and true or false
  sbar.set("/workspaces\\..*/", { drawing = isShowingSpaces })
end)

currentWorkspaceWatcher:subscribe(constants.events.AEROSPACE_WORKSPACE_CHANGED, function(env)
  selectCurrentWorkspace(env.FOCUSED_WORKSPACE)
  refreshWorkspaceApps()
end)

currentWorkspaceWatcher:subscribe(constants.events.SPACE_WINDOWS_CHANGE, function()
  refreshWorkspaceApps()
end)

currentWorkspaceWatcher:subscribe(constants.events.FRONT_APP_SWITCHED, function()
  refreshWorkspaceApps()
end)

createWorkspaces()
