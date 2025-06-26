#!/bin/bash
# 各tmuxペインで自動的にPlaywright MCPを設定するスクリプト

# カラー定義
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# tmuxセッション内かチェック
if [ -z "$TMUX" ]; then
    echo -e "${RED}[ERROR]${NC} このスクリプトはtmuxセッション内で実行する必要があります"
    exit 1
fi

# セッション名とペインインデックスを取得
SESSION_NAME=$(tmux display-message -p '#S')
PANE_INDEX=$(tmux display-message -p '#{pane_index}')
WINDOW_INDEX=$(tmux display-message -p '#{window_index}')

# 環境変数からポート範囲を取得（デフォルトは30000-30999）
PLAYWRIGHT_PORT_RANGE=${PLAYWRIGHT_PORT_RANGE:-"30000-30999"}
PORT_BASE=${PLAYWRIGHT_PORT_RANGE%%\-*}
PORT_MAX=${PLAYWRIGHT_PORT_RANGE##*\-}
PORT_RANGE_SIZE=$((PORT_MAX - PORT_BASE + 1))

# デフォルト値の設定
PORT_BASE=${PORT_BASE:-30000}
PORT_BASE=$((PORT_BASE + 1))  # 30001から開始

# 環境変数が既に設定されている場合はそれを使用
if [ -z "$PLAYWRIGHT_MCP_PORT" ]; then
    # ユニークなポートを生成
    # ウィンドウとペインの組み合わせでユニークにする
    PORT_OFFSET=$((WINDOW_INDEX * 100 + PANE_INDEX))
    PLAYWRIGHT_MCP_PORT=$((PORT_BASE + PORT_OFFSET))
    
    # ポートが範囲内か確認
    if [ $PLAYWRIGHT_MCP_PORT -gt $PORT_MAX ]; then
        # 範囲を超えた場合はハッシュを使用
        PORT_HASH=$(echo -n "${SESSION_NAME}${WINDOW_INDEX}${PANE_INDEX}" | cksum | cut -d' ' -f1)
        PLAYWRIGHT_MCP_PORT=$((PORT_BASE + (PORT_HASH % (PORT_RANGE_SIZE - 1))))
    fi
fi

echo -e "${GREEN}[INFO]${NC} Playwright MCP設定:"
echo "  セッション: $SESSION_NAME"
echo "  ウィンドウ: $WINDOW_INDEX"
echo "  ペイン: $PANE_INDEX"
echo "  ポート: $PLAYWRIGHT_MCP_PORT"

# 環境変数を設定
export PLAYWRIGHT_MCP_PORT

# Playwright コンテナを起動（manage-playwright-containersを使用）
echo -e "${BLUE}[INFO]${NC} Playwright MCPコンテナを起動中..."
/opt/claude-system/scripts/manage-playwright-containers.sh start $PLAYWRIGHT_MCP_PORT

if [ $? -eq 0 ]; then
    # コンテナ名を生成
    CONTAINER_NAME="playwright-mcp-${PROJECT_NAME}-${PLAYWRIGHT_MCP_PORT}"
    
    # MCPサーバーを再設定
    echo -e "${BLUE}[INFO]${NC} MCPサーバーを再設定中..."
    
    # 既存のmcp-playwrightを削除
    claude mcp remove -s user mcp-playwright >/dev/null 2>&1
    
    # ホストネットワークモードでは直接ポートでアクセス
    claude mcp add -s user mcp-playwright -t sse "http://localhost:${PLAYWRIGHT_MCP_PORT}/sse"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} MCP設定が完了しました"
        echo "  URL: http://localhost:${PLAYWRIGHT_MCP_PORT}/sse"
    else
        echo -e "${RED}[ERROR]${NC} MCP設定に失敗しました"
    fi
else
    echo -e "${RED}[ERROR]${NC} Playwright MCPコンテナの起動に失敗しました"
    exit 1
fi