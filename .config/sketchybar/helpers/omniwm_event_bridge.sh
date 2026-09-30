#!/usr/bin/env sh

set -eu

OMNIWMCTL="/opt/homebrew/bin/omniwmctl"
SKETCHYBAR="/opt/homebrew/bin/sketchybar"

if [ ! -x "$OMNIWMCTL" ] || [ ! -x "$SKETCHYBAR" ]; then
  exit 0
fi

if ! "$OMNIWMCTL" query active-workspace --json >/dev/null 2>&1; then
  exit 0
fi

trigger_workspace_change() {
  workspace_name=$(
    "$OMNIWMCTL" query active-workspace --json 2>/dev/null \
      | /usr/bin/jq -r '.result.payload.workspace.rawName // .workspace.rawName // empty'
  )

  if [ -n "$workspace_name" ]; then
    "$SKETCHYBAR" --trigger omniwm_workspace_changed FOCUSED_WORKSPACE="$workspace_name"
  else
    "$SKETCHYBAR" --trigger omniwm_workspace_changed
  fi
}

trigger_workspace_change

"$OMNIWMCTL" watch active-workspace,workspace-bar --exec /bin/sh -c '
  if [ "${OMNIWM_EVENT_CHANNEL:-}" = "active-workspace" ]; then
    workspace_name=$(/usr/bin/jq -r ".result.payload.workspace.rawName // .workspace.rawName // empty" 2>/dev/null || true)
    if [ -n "$workspace_name" ]; then
      /opt/homebrew/bin/sketchybar --trigger omniwm_workspace_changed FOCUSED_WORKSPACE="$workspace_name"
    else
      /opt/homebrew/bin/sketchybar --trigger omniwm_workspace_changed
    fi
  else
    /opt/homebrew/bin/sketchybar --trigger space_windows_change
  fi
'
