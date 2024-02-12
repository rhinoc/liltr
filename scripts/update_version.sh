set -exu

# get old version
PREV_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFO_PLIST_PATH")

# get new version
NEXT_VERSION=$(npx semver -i patch $PREV_VERSION)

# update info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEXT_VERSION" "$INFO_PLIST_PATH"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEXT_VERSION" "$INFO_PLIST_PATH"
sed -i '' -e "s/MARKETING_VERSION = .*;/MARKETING_VERSION = ${NEXT_VERSION};/" liltr.xcodeproj/project.pbxproj
sed -i '' -e "s/CURRENT_PROJECT_VERSION = .*;/CURRENT_PROJECT_VERSION = ${NEXT_VERSION};/" liltr.xcodeproj/project.pbxproj
echo $NEXT_VERSION