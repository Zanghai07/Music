#!/bin/sh
set -eu

APP_NAME="MusicPlayer"
BUILD_DIR="build"
IPA_PATH="$BUILD_DIR/$APP_NAME.ipa"

if [ -z "${THEOS:-}" ]; then
  echo "THEOS is not set. Install Theos first, or build with GitHub Actions." >&2
  exit 1
fi

make clean package FINALPACKAGE=1
rm -rf "$BUILD_DIR/Payload" "$IPA_PATH"
mkdir -p "$BUILD_DIR/Payload"
cp -R ".theos/_/Applications/$APP_NAME.app" "$BUILD_DIR/Payload/"

cd "$BUILD_DIR"
/usr/bin/zip -qry "$APP_NAME.ipa" Payload
cd - >/dev/null

echo "$IPA_PATH"
