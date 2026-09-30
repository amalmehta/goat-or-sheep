#!/bin/zsh
# Builds "build/Goat or Sheep.app" from the Swift package.
set -euo pipefail
cd "$(dirname "$0")/.."

swift build -c release --product GoatOrSheep
BIN="$(swift build -c release --show-bin-path)/GoatOrSheep"

APP="build/Goat or Sheep.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/Goat or Sheep"

# App icon: Resources/Icon.png (made by `swift run RenderIcon`) -> AppIcon.icns
ICONSET="build/AppIcon.iconset"
rm -rf "$ICONSET" && mkdir -p "$ICONSET"
for size in 16 32 128 256 512; do
  sips -z $size $size Resources/Icon.png --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
  sips -z $((size * 2)) $((size * 2)) Resources/Icon.png --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Goat or Sheep</string>
  <key>CFBundleDisplayName</key><string>Goat or Sheep</string>
  <key>CFBundleExecutable</key><string>Goat or Sheep</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
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
