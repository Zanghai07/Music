#!/bin/sh
set -eu

APP_NAME="MusicPlayer"
BUNDLE_ID="com.local.musicplayer"
BUILD_DIR="build"
APP_DIR="$BUILD_DIR/Payload/$APP_NAME.app"
IPA_PATH="$BUILD_DIR/$APP_NAME.ipa"

rm -rf "$BUILD_DIR/Payload" "$IPA_PATH"
mkdir -p "$APP_DIR"

SDK_PATH="$(xcrun --sdk iphoneos --show-sdk-path)"
CLANG="$(xcrun --sdk iphoneos -f clang)"

"$CLANG" \
  -arch arm64 \
  -isysroot "$SDK_PATH" \
  -miphoneos-version-min=10.0 \
  Sources/main.m \
  -o "$APP_DIR/$APP_NAME" \
  -framework UIKit \
  -framework MediaPlayer \
  -framework QuartzCore

cp Resources/Info.plist "$APP_DIR/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$APP_DIR/Info.plist"

if command -v codesign >/dev/null 2>&1; then
  codesign -f -s - --entitlements entitlements.plist "$APP_DIR"
fi

cd "$BUILD_DIR"
/usr/bin/zip -qry "$APP_NAME.ipa" Payload
cd - >/dev/null

echo "$IPA_PATH"
