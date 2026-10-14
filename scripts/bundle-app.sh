#!/bin/bash
set -e

swift build -c release

APP_DIR="MouseFix.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

cp .build/release/MouseFixApp "$MACOS_DIR/MouseFix"

cat << 'EOF' > "$CONTENTS_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>MouseFix</string>
    <key>CFBundleIdentifier</key>
    <string>com.user.MouseFix</string>
    <key>CFBundleName</key>
    <string>MouseFix</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "APPL????" > "$CONTENTS_DIR/PkgInfo"

# Sign bundle so macOS TCC binds bundle ID and permissions
codesign -f -s - --deep "$APP_DIR"

echo "Built and signed $APP_DIR successfully."
