require("install.sbar")

sbar = require("sketchybar")

sbar.begin_config()
sbar.hotload(true)

local constants = require("constants")
require("config")

-- Register custom events
sbar.add("event", constants.events.AEROSPACE_WORKSPACE_CHANGED)
sbar.add("event", constants.events.UPDATE_WINDOWS)
sbar.add("event", constants.events.FRONT_APP_SWITCHED)
sbar.add("event", constants.events.SWAP_MENU_AND_SPACES)

require("bar")
require("default")
require("items")

sbar.end_config()
sbar.event_loop()
