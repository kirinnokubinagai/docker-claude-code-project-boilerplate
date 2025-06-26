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
# Docker-in-Dockerなので、ホスト側のパスを使用
CLAUDE_PROJECT_DIR="/Users/kirinnokubinagaiyo/Claude-Project"

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
    
    # Dockerfileの存在確認をスキップ（Docker-in-Dockerでは直接アクセスできないため）
    # ビルド時にエラーが出る場合はその時点で処理
    
    # VNCサポートの有無を確認
    local use_vnc="${PLAYWRIGHT_VNC_ENABLED:-false}"
    local image_name="playwright-mcp:latest"
    local dockerfile="${CLAUDE_PROJECT_DIR}/DockerfilePlaywright"
    
    if [ "$use_vnc" = "true" ]; then
        image_name="playwright-mcp-vnc:latest"
        dockerfile="${CLAUDE_PROJECT_DIR}/DockerfilePlaywrightVNC"
        echo -e "${BLUE}[INFO]${NC} VNCサポートを有効化"
    fi
    
    # イメージが存在するか確認
    echo -e "${BLUE}[INFO]${NC} Dockerイメージを確認中..."
    if ! docker image inspect "$image_name" >/dev/null 2>&1; then
        echo -e "${YELLOW}[WARN]${NC} Dockerイメージが見つかりません"
        echo -e "${RED}===============================================${NC}"
        echo -e "${RED}[ERROR] Playwright MCPイメージのビルドが必要です${NC}"
        echo -e "${RED}===============================================${NC}"
        echo ""
        echo "以下の手順でイメージをビルドしてください："
        echo ""
        echo "1. ${BOLD}ホストマシン${NC}で新しいターミナルを開く"
        echo ""
        echo "2. 以下のコマンドを実行："
        echo ""
        echo -e "   ${GREEN}cd ${CLAUDE_PROJECT_DIR}${NC}"
        echo -e "   ${GREEN}docker build -t playwright-mcp:latest -f DockerfilePlaywright .${NC}"
        if [ "$use_vnc" = "true" ]; then
            echo -e "   ${GREEN}docker build -t playwright-mcp-vnc:latest -f DockerfilePlaywrightVNC .${NC}"
        fi
        echo ""
        echo "3. ビルドが完了したら、再度 master コマンドを実行"
        echo ""
        echo -e "${YELLOW}注意: これらのコマンドはホストマシンで実行する必要があります${NC}"
        echo -e "${YELLOW}      コンテナ内からは実行できません${NC}"
        echo ""
        echo -e "${RED}===============================================${NC}"
        return 1
    fi
    
    # ホストネットワークモードで起動
    local docker_run_cmd="docker run -d --name $container_name --network host"
    
    if [ "$use_vnc" = "true" ]; then
        # 環境変数からベースポートを取得（デフォルトは元の値）
        local playwright_base=${PLAYWRIGHT_PORT_RANGE%%\-*}
        local vnc_base=${VNC_PORT_RANGE%%\-*}
        local webvnc_base=${WEBVNC_PORT_RANGE%%\-*}
        
        # デフォルト値の設定
        playwright_base=${playwright_base:-30000}
        vnc_base=${vnc_base:-40000}
        webvnc_base=${webvnc_base:-50000}
        
        # ポートオフセットを計算
        local offset=$((port - playwright_base))
        local vnc_port=$((vnc_base + offset))
        local webvnc_port=$((webvnc_base + offset))
        docker_run_cmd="$docker_run_cmd -p ${vnc_port}:5900 -p ${webvnc_port}:6080"
    fi
    
    # ホストネットワークモードではポートを環境変数で指定
    docker_run_cmd="$docker_run_cmd --restart unless-stopped -e MCP_PORT=$port $image_name"
    
    # コンテナを起動
    if eval "$docker_run_cmd" >/dev/null 2>&1; then
        
        # 起動確認
        echo -e "${BLUE}[INFO]${NC} コンテナの起動を確認中..."
        for i in {1..10}; do
            if docker ps --format "{{.Names}}" | grep -q "^${container_name}$"; then
                echo -e "${GREEN}[SUCCESS]${NC} Playwright MCPコンテナが起動しました"
                echo "  URL: http://localhost:${port}/sse"
                
                if [ "$use_vnc" = "true" ]; then
                    # 環境変数からベースポートを取得（デフォルトは元の値）
                    local playwright_base=${PLAYWRIGHT_PORT_RANGE%%\-*}
                    local vnc_base=${VNC_PORT_RANGE%%\-*}
                    local webvnc_base=${WEBVNC_PORT_RANGE%%\-*}
                    
                    # デフォルト値の設定
                    playwright_base=${playwright_base:-30000}
                    vnc_base=${vnc_base:-40000}
                    webvnc_base=${webvnc_base:-50000}
                    
                    # ポートオフセットを計算
                    local offset=$((port - playwright_base))
                    local vnc_port=$((vnc_base + offset))
                    local webvnc_port=$((webvnc_base + offset))
                    echo ""
                    echo -e "${GREEN}[VNC]${NC} ブラウザ画面を確認できます:"
                    echo "  Web UI: http://localhost:${webvnc_port}/vnc.html"
                    echo "  VNC: vnc://localhost:${vnc_port} (パスワード: playwright)"
                fi
                
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