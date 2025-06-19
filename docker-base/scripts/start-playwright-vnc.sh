#!/bin/bash

# Playwright MCP with VNC サポートを有効化するスクリプト

set -e

# 環境変数を設定してVNCサポートを有効化
export PLAYWRIGHT_VNC_ENABLED=true

# プロジェクト名を取得
PROJECT_NAME="${PROJECT_NAME:-$(basename $(pwd))}"
CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$HOME/claude-project}"

echo "======================================"
echo "Playwright MCP with VNC サポートを有効化"
echo "======================================"
echo ""
echo "プロジェクト: $PROJECT_NAME"
echo ""

# ポートを指定（引数またはデフォルト）
PORT="${1:-30001}"

echo "使用するポート: $PORT"
echo "VNCポート: $((PORT + 10000))"
echo "Web VNCポート: $((PORT + 20000))"
echo ""

# manage-playwright-containers.shを使用してコンテナを起動
echo "VNC対応のPlaywright MCPを起動中..."
"${CLAUDE_PROJECT_DIR}/docker-base/scripts/manage-playwright-containers.sh" start "$PORT"

echo ""
echo "======================================"
echo "📺 VNCの使い方："
echo ""
echo "1. ブラウザで確認する場合:"
echo "   export PLAYWRIGHT_VNC_ENABLED=true"
echo "   ./manage-playwright-containers.sh start [ポート番号]"
echo ""
echo "2. 通常版に戻す場合:"
echo "   unset PLAYWRIGHT_VNC_ENABLED"
echo "   ./manage-playwright-containers.sh start [ポート番号]"
echo "======================================"