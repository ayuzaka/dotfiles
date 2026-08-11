#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Chrome Incognito
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤐

osascript <<'APPLESCRIPT'
tell application "System Events"
  set chromeRunning to exists process "Google Chrome"
end tell

if chromeRunning then
  tell application "Google Chrome"
    repeat with w in windows
      if mode of w is "incognito" then
        set index of w to 1
        activate
        return
      end if
    end repeat

    make new window with properties {mode:"incognito"}
    activate
  end tell
else
  do shell script "open -na 'Google Chrome' --args --incognito"
end if
APPLESCRIPT
