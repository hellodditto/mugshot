#!/bin/bash
# Assemble build/Mugshot.app from the SwiftPM binary. No Xcode needed.
set -euo pipefail
cd "$(dirname "$0")/.."

CONFIG="${1:-release}"

# MUGSHOT_UNIVERSAL=1 builds an arm64 + x86_64 fat binary (used by the
# release workflow); the default single-arch build stays fast for local use.
if [ -n "${MUGSHOT_UNIVERSAL:-}" ]; then
  swift build -c "$CONFIG" --arch arm64 --arch x86_64
  case "$CONFIG" in
    release) BIN=".build/apple/Products/Release/Mugshot" ;;
    *)       BIN=".build/apple/Products/Debug/Mugshot" ;;
  esac
else
  swift build -c "$CONFIG"
  BIN=".build/$CONFIG/Mugshot"
fi

APP="build/Mugshot.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/Mugshot"
cp scripts/Info.plist "$APP/Contents/Info.plist"
cp -R Resources/*.lproj "$APP/Contents/Resources/"

# Ad-hoc signature: enough for SMAppService (launch at login) locally.
# The release workflow re-signs with the Developer ID identity afterwards.
codesign --force --sign - "$APP"
echo "✓ $APP"
