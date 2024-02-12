#!/usr/bin/env bash

set -exu
minimumSystemVersion="$(awk -F ' = ' '/MACOSX_DEPLOYMENT_TARGET/ { print substr($2, 1, length($2) - 1); exit }' < $PROJECT_PATH)"
dmgName="$APP_NAME $VERSION.dmg"
githubDmgName="$APP_NAME.$VERSION.dmg"
edSignatureAndLength=$(scripts/sign_update -s $SPARKLE_ED_PRIVATE_KEY "$XCODE_BUILD_PATH/$dmgName")
date="$(date +'%a, %d %b %Y %H:%M:%S %z')"

echo "
    <item>
      <title>Version $VERSION</title>
      <sparkle:version>$VERSION</sparkle:version>
      <pubDate>$date</pubDate>
      <sparkle:minimumSystemVersion>$minimumSystemVersion</sparkle:minimumSystemVersion>
      <enclosure
        url=\"https://github.com/rhinoc/liltr/releases/download/v$VERSION/$githubDmgName\"
        $edSignatureAndLength
        type=\"application/octet-stream\"/>
    </item>
" > appcast_tmp.txt

sed -i '' -e "/<\/language>/r appcast_tmp.txt" appcast.xml