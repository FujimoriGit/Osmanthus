#!/bin/bash

# 依存関係のリストが保存されている JSON ファイル
INPUT_FILE="nested_dependencies.json"
OUTPUT_FILE="licenses.json"
RESOURCES_DIR="Resources"

# Resources フォルダがなければ作成
mkdir -p "$RESOURCES_DIR"

# JSON 配列の開始
echo "[" > "$OUTPUT_FILE"

echo "🔍 各ライブラリの LICENSE を取得中..."

# JSON からライブラリ一覧を取得
LIBRARIES=$(jq -r '.[].url' "$INPUT_FILE")

for URL in $LIBRARIES
do
    REPO_NAME=$(basename "$URL")
    LICENSE_URL="$URL/raw/main/LICENSE"

    echo "📜 $REPO_NAME の LICENSE を取得..."
    
    # LICENSE ファイルの内容を取得
    LICENSE=$(curl -s "$LICENSE_URL")

    if [[ -z "$LICENSE" ]]; then
        echo "❌ $REPO_NAME の LICENSE が取得できませんでした。"
        continue
    fi

    # JSON に追加
    echo "{ \"name\": \"$REPO_NAME\", \"url\": \"$URL\", \"license\": \"$(echo "$LICENSE" | sed -e 's/"/\\"/g' -e ':a;N;$!ba;s/\n/\\n/g')\" }," >> "$OUTPUT_FILE"
done

# JSON 配列の終了（最後のカンマを削除）
sed -i '' '$ s/,$//' "$OUTPUT_FILE"
echo "]" >> "$OUTPUT_FILE"

echo "✅ ライセンス情報を $OUTPUT_FILE に保存しました！"