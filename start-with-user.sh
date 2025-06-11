#!/bin/bash

# 現在のユーザーのUIDとGIDで Docker Compose を起動するスクリプト

set -e

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Docker Compose をユーザー権限で起動します${NC}"

# 現在のユーザーのUIDとGIDを取得
export UID=$(id -u)
export GID=$(id -g)

echo -e "${BLUE}ℹ️  ユーザー情報:${NC}"
echo "   UID: $UID"
echo "   GID: $GID"

# .envファイルの存在確認
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ .envファイルが見つかりません${NC}"
    echo "init-project.sh を実行してプロジェクトを初期化してください"
    exit 1
fi

# Docker Compose 起動
echo -e "${BLUE}🐳 Docker Compose を起動中...${NC}"
docker-compose up -d

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 起動完了！${NC}"
    echo ""
    echo -e "${BLUE}📋 次のコマンドでコンテナに接続できます:${NC}"
    echo "docker-compose exec -w /workspace claude-code developer-fish"
else
    echo -e "${RED}❌ 起動に失敗しました${NC}"
    exit 1
fi