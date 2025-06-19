#!/bin/bash
# 空いているポート範囲を見つけるスクリプト

# 引数: 開始ポート、範囲のサイズ
find_free_port_range() {
    local start_port=${1:-30000}
    local range_size=${2:-1000}
    local max_attempts=100
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        local port=$start_port
        local all_free=true
        
        # 範囲内のすべてのポートが空いているかチェック（サンプリング）
        # 全ポートをチェックすると遅いので、100ポートごとにチェック
        for ((i=0; i<$range_size; i+=100)); do
            check_port=$((port + i))
            if lsof -Pi :$check_port -sTCP:LISTEN -t >/dev/null 2>&1; then
                all_free=false
                break
            fi
        done
        
        if [ "$all_free" = true ]; then
            # 範囲の最初と最後もチェック
            if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 && \
               ! lsof -Pi :$((port + range_size - 1)) -sTCP:LISTEN -t >/dev/null 2>&1; then
                echo $port
                return 0
            fi
        fi
        
        # 次の範囲を試す
        start_port=$((start_port + range_size))
        attempt=$((attempt + 1))
    done
    
    # デフォルトに戻す
    echo $1
    return 1
}

# メイン処理
if [ "$1" = "playwright" ]; then
    # Playwright MCP用のポート範囲を探す
    PLAYWRIGHT_BASE=$(find_free_port_range 30000 1000)
    echo "PLAYWRIGHT_PORT_BASE=$PLAYWRIGHT_BASE"
    echo "PLAYWRIGHT_PORT_RANGE=$PLAYWRIGHT_BASE-$((PLAYWRIGHT_BASE + 999))"
elif [ "$1" = "vnc" ]; then
    # VNC用のポート範囲を探す
    VNC_BASE=$(find_free_port_range 40000 1000)
    echo "VNC_PORT_BASE=$VNC_BASE"
    echo "VNC_PORT_RANGE=$VNC_BASE-$((VNC_BASE + 999))"
elif [ "$1" = "webvnc" ]; then
    # Web VNC用のポート範囲を探す
    WEBVNC_BASE=$(find_free_port_range 50000 1000)
    echo "WEBVNC_PORT_BASE=$WEBVNC_BASE"
    echo "WEBVNC_PORT_RANGE=$WEBVNC_BASE-$((WEBVNC_BASE + 999))"
else
    # すべてのポート範囲を探す
    PLAYWRIGHT_BASE=$(find_free_port_range 30000 1000)
    VNC_BASE=$(find_free_port_range $((PLAYWRIGHT_BASE + 1000)) 1000)
    WEBVNC_BASE=$(find_free_port_range $((VNC_BASE + 1000)) 1000)
    
    echo "# 空いているポート範囲"
    echo "PLAYWRIGHT_PORT_RANGE=$PLAYWRIGHT_BASE-$((PLAYWRIGHT_BASE + 999))"
    echo "VNC_PORT_RANGE=$VNC_BASE-$((VNC_BASE + 999))"
    echo "WEBVNC_PORT_RANGE=$WEBVNC_BASE-$((WEBVNC_BASE + 999))"
fi