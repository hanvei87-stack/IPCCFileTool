#!/bin/sh
set -eu

cd "$(dirname "$0")"

SCHEME="IPCCFileTool"
DERIVED_DATA_PATH="$PWD/build/DerivedData"
APP_PATH="$DERIVED_DATA_PATH/Build/Products/Release-iphoneos/IPCCFileTool.app"
IPA_PATH="$PWD/build/IPCCFileTool_unsigned.ipa"

echo "Building unsigned app..."
xcodebuild \
  -project IPCCFileTool.xcodeproj \
  -scheme "$SCHEME" \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  DEVELOPMENT_TEAM="" \
  build

echo "Packaging unsigned IPA..."
rm -rf "$PWD/build/Payload" "$IPA_PATH"
mkdir -p "$PWD/build/Payload"
cp -R "$APP_PATH" "$PWD/build/Payload/"

cd "$PWD/build"
/usr/bin/zip -qry "$IPA_PATH" Payload

echo "Unsigned IPA created at: $IPA_PATH"
