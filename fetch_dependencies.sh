#!/bin/bash

# 1. 既に取得済みの `spm_packages.json` を読み込む
INPUT_FILE="spm_packages.json"
OUTPUT_FILE="nested_dependencies.json"

if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ $INPUT_FILE が見つかりません。先に extract_spm_packages.sh を実行してください。"
    exit 1
fi

# JSON 配列の開始
echo "[" > "$OUTPUT_FILE"

echo "🔍 各ライブラリの Package.swift を解析中..."

# 2. JSON からパッケージ一覧を取得
LIBRARIES=$(jq -r '.[].url' "$INPUT_FILE")

for URL in $LIBRARIES
do
    REPO_NAME=$(basename "$URL" .git)
    PACKAGE_SWIFT_URL="$URL/raw/main/Package.swift"

    echo "📦 $REPO_NAME の Package.swift を取得..."
    
    # 3. Package.swift の内容を取得
    PACKAGE_CONTENT=$(curl -s "$PACKAGE_SWIFT_URL")

    if [[ -z "$PACKAGE_CONTENT" ]]; then
        echo "❌ $REPO_NAME の Package.swift が取得できませんでした。"
        continue
    fi

    # 4. `dependencies:` セクションからライブラリ一覧を抽出
    DEPENDENCIES=$(echo "$PACKAGE_CONTENT" | grep -oE 'https://github\.com/[a-zA-Z0-9\.\-]+/[a-zA-Z0-9\.\-]+' | sort -u)

    # 5. JSON に追加
    for DEP_URL in $DEPENDENCIES
    do
        DEP_NAME=$(basename "$DEP_URL" .git)
        echo "{ \"name\": \"$DEP_NAME\", \"url\": \"$DEP_URL\", \"parent\": \"$REPO_NAME\" }," >> "$OUTPUT_FILE"
    done
done

# JSON 配列の終了（最後のカンマを削除）
sed -i '' '$ s/,$//' "$OUTPUT_FILE"
echo "]" >> "$OUTPUT_FILE"

echo "✅ 依存関係を $OUTPUT_FILE に保存しました！"