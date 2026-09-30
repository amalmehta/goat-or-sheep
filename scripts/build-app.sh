#!/bin/zsh
# Builds "build/Goat or Sheep.app" from the Swift package.
set -euo pipefail
cd "$(dirname "$0")/.."

swift build -c release --product GoatOrSheep
BIN="$(swift build -c release --show-bin-path)/GoatOrSheep"

APP="build/Goat or Sheep.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp "$BIN" "$APP/Contents/MacOS/Goat or Sheep"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Goat or Sheep</string>
  <key>CFBundleDisplayName</key><string>Goat or Sheep</string>
  <key>CFBundleExecutable</key><string>Goat or Sheep</string>
  <key>CFBundleIdentifier</key><string>com.amalmehta.goat-or-sheep</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP"
echo "Built $APP"
