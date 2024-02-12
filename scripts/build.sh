#!/usr/bin/env bash

set -exu

appFile="$APP_NAME.app"
xcodebuild -project liltr.xcodeproj -scheme liltr -derivedDataPath $XCODE_BUILD_DIR -configuration Release
file $XCODE_BUILD_PATH/liltr.app/Contents/MacOS/liltr.app
cd $XCODE_BUILD_PATH
npx create-dmg "$appFile" --overwrite || true