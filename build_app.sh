#!/bin/bash

# Exit on error
set -e

APP_NAME="QueueSync"
BUILD_DIR=$(swift build -c release --show-bin-path)
APP_BUNDLE_DIR="Release/$APP_NAME.app"

echo "🔨 Building QueueSync for Release..."
swift build -c release --product QueueSyncApp

echo "📦 Creating macOS App Bundle..."
# Create bundle structure
mkdir -p "$APP_BUNDLE_DIR/Contents/MacOS"
mkdir -p "$APP_BUNDLE_DIR/Contents/Resources"

# Copy the executable
cp "$BUILD_DIR/QueueSyncApp" "$APP_BUNDLE_DIR/Contents/MacOS/$APP_NAME"

# Copy the Info.plist
cp "Sources/QueueSyncApp/Info.plist" "$APP_BUNDLE_DIR/Contents/Info.plist"

if [ -f "./appIcon/appicon.png" ]; then
    echo "🖼  Processing App Icon..."
    ICON_DIR="AppIcon.iconset"
    mkdir -p "$ICON_DIR"
    
    sips -z 16 16     ./appIcon/appicon.png --out "$ICON_DIR/icon_16x16.png" > /dev/null
    sips -z 32 32     ./appIcon/appicon.png --out "$ICON_DIR/icon_16x16@2x.png" > /dev/null
    sips -z 32 32     ./appIcon/appicon.png --out "$ICON_DIR/icon_32x32.png" > /dev/null
    sips -z 64 64     ./appIcon/appicon.png --out "$ICON_DIR/icon_32x32@2x.png" > /dev/null
    sips -z 128 128   ./appIcon/appicon.png --out "$ICON_DIR/icon_128x128.png" > /dev/null
    sips -z 256 256   ./appIcon/appicon.png --out "$ICON_DIR/icon_128x128@2x.png" > /dev/null
    sips -z 256 256   ./appIcon/appicon.png --out "$ICON_DIR/icon_256x256.png" > /dev/null
    sips -z 512 512   ./appIcon/appicon.png --out "$ICON_DIR/icon_256x256@2x.png" > /dev/null
    sips -z 512 512   ./appIcon/appicon.png --out "$ICON_DIR/icon_512x512.png" > /dev/null
    sips -z 1024 1024 ./appIcon/appicon.png --out "$ICON_DIR/icon_512x512@2x.png" > /dev/null
    
    iconutil -c icns "$ICON_DIR" -o "$APP_BUNDLE_DIR/Contents/Resources/AppIcon.icns"
    rm -rf "$ICON_DIR"
fi

echo "🧹 Cleaning up permissions..."
chmod +x "$APP_BUNDLE_DIR/Contents/MacOS/$APP_NAME"

echo "✅ App Bundle created successfully at: $APP_BUNDLE_DIR"

echo "💿 Creating DMG Installer..."
DMG_NAME="QueueSync_Installer.dmg"
DMG_TMP="Release/dmg_tmp"

# Clean up old DMG
echo "🧹 Cleaning previous build artifacts..."
hdiutil detach "/Volumes/QueueSync Installer" -force 2>/dev/null || true
rm -f "Release/$DMG_NAME"
rm -rf "$DMG_TMP"
mkdir -p "$DMG_TMP"

# Copy App to temp folder and add Applications shortcut
cp -R "$APP_BUNDLE_DIR" "$DMG_TMP/"
ln -s /Applications "$DMG_TMP/Applications"

# Sync to ensure all files are written
sync

# Create the DMG
hdiutil create -volname "QueueSync Installer" -srcfolder "$DMG_TMP" -ov -format UDZO "Release/$DMG_NAME"

# Clean up
rm -rf "$DMG_TMP"

echo "✨ DMG created successfully at: Release/$DMG_NAME"
echo "You can now upload the .dmg to GitHub Releases!"
