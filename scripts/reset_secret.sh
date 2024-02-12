set -exu

EMPTY_STRING=""

# reset info.plist
# /usr/libexec/PlistBuddy -c "Set :AliAK $EMPTY_STRING" "$INFO_PLIST_PATH"
# /usr/libexec/PlistBuddy -c "Set :AliSK $EMPTY_STRING" "$INFO_PLIST_PATH"
# /usr/libexec/PlistBuddy -c "Set :BaiduAK $EMPTY_STRING" "$INFO_PLIST_PATH"
# /usr/libexec/PlistBuddy -c "Set :BaiduSK $EMPTY_STRING" "$INFO_PLIST_PATH"
# /usr/libexec/PlistBuddy -c "Set :VolcengineAK $EMPTY_STRING" "$INFO_PLIST_PATH"
# /usr/libexec/PlistBuddy -c "Set :VolcengineSK $EMPTY_STRING" "$INFO_PLIST_PATH"
# /usr/libexec/PlistBuddy -c "Set :NiuTransSK $EMPTY_STRING" "$INFO_PLIST_PATH"
# /usr/libexec/PlistBuddy -c "Set :BigHugeThesaurusSK $EMPTY_STRING" "$INFO_PLIST_PATH"

find liltr/Utils/Provider -type f -name "*.swift" -exec sed -i '' "s/$ALI_AK/###ALI_AK###/g" {} +
find liltr/Utils/Provider -type f -name "*.swift" -exec sed -i '' "s/$ALI_SK/###ALI_SK###/g" {} +
find liltr/Utils/Provider -type f -name "*.swift" -exec sed -i '' "s/$BAIDU_AK/###BAIDU_AK###/g" {} +
find liltr/Utils/Provider -type f -name "*.swift" -exec sed -i '' "s/$BAIDU_SK/###BAIDU_SK###/g" {} +
find liltr/Utils/Provider -type f -name "*.swift" -exec sed -i '' "s/$VOLCENGINE_AK/###VOLCENGINE_AK###/g" {} +
find liltr/Utils/Provider -type f -name "*.swift" -exec sed -i '' "s/$VOLCENGINE_SK/###VOLCENGINE_SK###/g" {} +
find liltr/Utils/Provider -type f -name "*.swift" -exec sed -i '' "s/$NIUTRANS_SK/###NIUTRANS_SK###/g" {} +
find liltr/Utils/Provider -type f -name "*.swift" -exec sed -i '' "s/$BIGHUGETHESAURUS_SK/###BIGHUGETHESAURUS_SK###/g" {} +

# clean up
security delete-keychain $RUNNER_TEMP/app-signing.keychain-db
rm -rf *_tmp.txt