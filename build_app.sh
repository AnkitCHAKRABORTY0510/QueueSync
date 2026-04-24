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

echo "🧹 Cleaning up permissions..."
chmod +x "$APP_BUNDLE_DIR/Contents/MacOS/$APP_NAME"

echo "✅ App Bundle created successfully at: $APP_BUNDLE_DIR"
echo "You can now right-click this .app file, select 'Compress', and upload the .zip to GitHub Releases!"
