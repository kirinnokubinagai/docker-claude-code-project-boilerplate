#!/bin/bash
# Playwright MCPコンテナ管理スクリプト

# カラー定義
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# プロジェクト名とネットワーク名を取得
PROJECT_NAME=${PROJECT_NAME:-$(basename $(pwd))}
NETWORK_NAME="${PROJECT_NAME}_network"
CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-/opt/claude-system}"

# Playwright コンテナを起動
start_playwright_container() {
    local port=$1
    local container_name="playwright-mcp-${PROJECT_NAME}-${port}"
    
    # 既存のコンテナをチェック
    if docker ps -a --format "{{.Names}}" | grep -q "^${container_name}$"; then
        echo -e "${YELLOW}[INFO]${NC} 既存のコンテナ ${container_name} を削除中..."
        docker rm -f "$container_name" >/dev/null 2>&1
    fi
    
    echo -e "${BLUE}[INFO]${NC} Playwright MCPコンテナを起動中..."
    echo "  コンテナ名: $container_name"
    echo "  ポート: $port"
    
    # Dockerfileが存在するか確認
    if [ ! -f "${CLAUDE_PROJECT_DIR}/DockerfilePlaywright" ]; then
        echo -e "${RED}[ERROR]${NC} DockerfilePlaywright が見つかりません"
        return 1
    fi
    
    # イメージをビルド（キャッシュを使用）
    echo -e "${BLUE}[INFO]${NC} Dockerイメージをビルド中..."
    if ! docker build -t playwright-mcp:latest -f "${CLAUDE_PROJECT_DIR}/DockerfilePlaywright" "${CLAUDE_PROJECT_DIR}" >/dev/null 2>&1; then
        echo -e "${RED}[ERROR]${NC} Dockerイメージのビルドに失敗しました"
        return 1
    fi
    
    # コンテナを起動
    if docker run -d \
        --name "$container_name" \
        --network "$NETWORK_NAME" \
        -p "${port}:8931" \
        --restart unless-stopped \
        playwright-mcp:latest >/dev/null 2>&1; then
        
        # 起動確認
        echo -e "${BLUE}[INFO]${NC} コンテナの起動を確認中..."
        for i in {1..10}; do
            if docker ps --format "{{.Names}}" | grep -q "^${container_name}$"; then
                echo -e "${GREEN}[SUCCESS]${NC} Playwright MCPコンテナが起動しました"
                echo "  内部URL: http://${container_name}:8931/sse"
                echo "  外部URL: http://host.docker.internal:${port}/sse"
                return 0
            fi
            sleep 1
        done
        
        echo -e "${RED}[ERROR]${NC} コンテナの起動確認に失敗しました"
        return 1
    else
        echo -e "${RED}[ERROR]${NC} コンテナの起動に失敗しました"
        return 1
    fi
}

# すべてのPlaywright コンテナを停止
stop_all_playwright_containers() {
    echo -e "${BLUE}[INFO]${NC} すべてのPlaywright MCPコンテナを停止中..."
    
    local containers=$(docker ps -a --format "{{.Names}}" | grep "^playwright-mcp-${PROJECT_NAME}-")
    if [ -z "$containers" ]; then
        echo -e "${YELLOW}[INFO]${NC} 停止するコンテナがありません"
        return 0
    fi
    
    for container in $containers; do
        echo "  停止中: $container"
        docker rm -f "$container" >/dev/null 2>&1
    done
    
    echo -e "${GREEN}[SUCCESS]${NC} すべてのコンテナを停止しました"
}

# Playwright コンテナの状態を表示
list_playwright_containers() {
    echo -e "${BLUE}[INFO]${NC} Playwright MCPコンテナの状態:"
    echo ""
    
    local containers=$(docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep "playwright-mcp-${PROJECT_NAME}-")
    if [ -z "$containers" ]; then
        echo "  実行中のPlaywright MCPコンテナはありません"
    else
        echo "$containers"
    fi
}

# メイン処理
case "${1:-list}" in
    start)
        if [ -z "$2" ]; then
            echo "使用方法: $0 start <port>"
            exit 1
        fi
        start_playwright_container "$2"
        ;;
    stop)
        stop_all_playwright_containers
        ;;
    list)
        list_playwright_containers
        ;;
    *)
        echo "使用方法: $0 {start|stop|list} [port]"
        echo ""
        echo "コマンド:"
        echo "  start <port>  - 指定ポートでPlaywright MCPコンテナを起動"
        echo "  stop          - すべてのPlaywright MCPコンテナを停止"
        echo "  list          - Playwright MCPコンテナの状態を表示"
        exit 1
        ;;
esac