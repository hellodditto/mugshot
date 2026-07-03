#!/bin/bash
# Assemble build/Mugshot.app from the SwiftPM binary. No Xcode needed.
set -euo pipefail
cd "$(dirname "$0")/.."

CONFIG="${1:-release}"
swift build -c "$CONFIG"

APP="build/Mugshot.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp ".build/$CONFIG/Mugshot" "$APP/Contents/MacOS/Mugshot"
cp scripts/Info.plist "$APP/Contents/Info.plist"
cp -R Resources/*.lproj "$APP/Contents/Resources/"

# Ad-hoc signature: enough for SMAppService (launch at login) locally.
codesign --force --sign - "$APP"
echo "✓ $APP"
