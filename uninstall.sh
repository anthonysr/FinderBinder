#!/bin/bash
set -euo pipefail

APP="FinderBinder"

# Quit if running
osascript -e "tell application \"${APP}\" to quit" 2>/dev/null || true

rm -rf "/Applications/${APP}.app"
defaults delete com.finderbinder.app 2>/dev/null || true

echo "Uninstalled ${APP}"
