#!/bin/bash
set -euo pipefail

APP="FinderBinder"
BUNDLE=".build/release/${APP}.app"

swift build --disable-sandbox -c release

mkdir -p "${BUNDLE}/Contents/MacOS"
cp ".build/release/${APP}" "${BUNDLE}/Contents/MacOS/"
cp "${APP}/Info.plist" "${BUNDLE}/Contents/"

cp -r "${BUNDLE}" /Applications/

echo "Installed /Applications/${APP}.app"
