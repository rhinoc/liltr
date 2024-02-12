set -exu

# info.plist
# /usr/libexec/PlistBuddy -c "Set :AliAK $ALI_AK" "$INFO_PLIST_PATH"
# /usr/libexec/PlistBuddy -c "Set :AliSK $ALI_SK" "$INFO_PLIST_PATH"
# /usr/libexec/PlistBuddy -c "Set :BaiduAK $BAIDU_AK" "$INFO_PLIST_PATH"
# /usr/libexec/PlistBuddy -c "Set :BaiduSK $BAIDU_SK" "$INFO_PLIST_PATH"
# /usr/libexec/PlistBuddy -c "Set :VolcengineAK $VOLCENGINE_AK" "$INFO_PLIST_PATH"
# /usr/libexec/PlistBuddy -c "Set :VolcengineSK $VOLCENGINE_SK" "$INFO_PLIST_PATH"
# /usr/libexec/PlistBuddy -c "Set :NiuTransSK $NIUTRANS_SK" "$INFO_PLIST_PATH"
# /usr/libexec/PlistBuddy -c "Set :BigHugeThesaurusSK $BIGHUGETHESAURUS_SK" "$INFO_PLIST_PATH"

find liltr/Utils/Provider -type f -name "*.swift" -exec sed -i '' "s/###ALI_AK###/$ALI_AK/g" {} +
find liltr/Utils/Provider -type f -name "*.swift" -exec sed -i '' "s/###ALI_SK###/$ALI_SK/g" {} +
find liltr/Utils/Provider -type f -name "*.swift" -exec sed -i '' "s/###BAIDU_AK###/$BAIDU_AK/g" {} +
find liltr/Utils/Provider -type f -name "*.swift" -exec sed -i '' "s/###BAIDU_SK###/$BAIDU_SK/g" {} +
find liltr/Utils/Provider -type f -name "*.swift" -exec sed -i '' "s/###VOLCENGINE_AK###/$VOLCENGINE_AK/g" {} +
find liltr/Utils/Provider -type f -name "*.swift" -exec sed -i '' "s/###VOLCENGINE_SK###/$VOLCENGINE_SK/g" {} +
find liltr/Utils/Provider -type f -name "*.swift" -exec sed -i '' "s/###NIUTRANS_SK###/$NIUTRANS_SK/g" {} +
find liltr/Utils/Provider -type f -name "*.swift" -exec sed -i '' "s/###BIGHUGETHESAURUS_SK###/$BIGHUGETHESAURUS_SK/g" {} +