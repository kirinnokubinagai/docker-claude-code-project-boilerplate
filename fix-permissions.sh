#!/bin/bash

# 既存のGitリポジトリの権限を修正するスクリプト

set -e

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 Git権限を修正します${NC}"

# 現在のユーザー情報を取得
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

echo -e "${BLUE}ℹ️  現在のユーザー:${NC}"
echo "   UID: $CURRENT_UID"
echo "   GID: $CURRENT_GID"

# .gitディレクトリの権限を修正
if [ -d ".git" ]; then
    echo -e "${BLUE}📁 .gitディレクトリの権限を修正中...${NC}"
    sudo chown -R $CURRENT_UID:$CURRENT_GID .git
    echo -e "${GREEN}✅ 完了${NC}"
fi

# worktreesディレクトリの権限を修正
if [ -d "worktrees" ]; then
    echo -e "${BLUE}📁 worktreesディレクトリの権限を修正中...${NC}"
    sudo chown -R $CURRENT_UID:$CURRENT_GID worktrees
    echo -e "${GREEN}✅ 完了${NC}"
fi

echo -e "${GREEN}✅ 権限修正が完了しました！${NC}"
echo ""
echo -e "${BLUE}次のコマンドでコンテナを起動できます:${NC}"
echo "./start-with-user.sh"