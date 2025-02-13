#!/bin/bash

# 取得するライブラリのリスト（GitHubのURLからLICENSEを取得）
PACKAGES=(
    "https://raw.githubusercontent.com/Alamofire/Alamofire/master/LICENSE"
    "https://raw.githubusercontent.com/realm/realm-swift/master/LICENSE"
)

OUTPUT="licenses.json"

# JSON 配列の開始
echo "[" > $OUTPUT

# 各ライブラリのライセンスを取得
for URL in "${PACKAGES[@]}"
do
    NAME=$(echo $URL | awk -F'/' '{print $(NF-2)}')
    LICENSE=$(curl -s $URL | sed -e 's/"/\\"/g' | awk '{printf "%s\\n", $0}') # " をエスケープし、改行を \n に変換

    # JSON フォーマットに変換
    echo "{ \"name\": \"$NAME\", \"url\": \"${URL%/LICENSE}\", \"license\": \"$LICENSE\" }," >> $OUTPUT
done

# JSON 配列の終了（最後のカンマを削除）
sed -i '' '$ s/,$//' $OUTPUT
echo "]" >> $OUTPUT

echo "licenses.json を更新しました。"
