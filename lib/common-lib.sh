#!/bin/bash

# Docker Claude Code共通ライブラリ
# すべてのスクリプトで共有される関数とユーティリティ

# 色定義
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export NC='\033[0m'

# ログ関数
log_info() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

log_success() {
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

log_warning() {
    printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
}

log_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

# エラー終了関数
error_exit() {
    log_error "$1"
    exit 1
}

# 環境変数ユーティリティ
get_user_uid() {
    echo "${USER_UID:-$(id -u)}"
}

get_user_gid() {
    echo "${USER_GID:-$(id -g)}"
}

get_project_name() {
    if [ -f ".env" ]; then
        grep "^PROJECT_NAME=" .env | cut -d'=' -f2 | tr -d '"' | tr -d "'"
    else
        echo "${PROJECT_NAME:-default}"
    fi
}

# 依存関係チェック
check_dependencies() {
    local deps=("$@")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "以下のコマンドがインストールされていません:"
        for cmd in "${missing[@]}"; do
            echo "  - $cmd"
        done
        return 1
    fi
    
    return 0
}

# Docker関連ユーティリティ
is_docker_running() {
    if docker info >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

ensure_docker_running() {
    if ! is_docker_running; then
        error_exit "Docker daemonが実行されていません。Dockerを起動してください。"
    fi
}

# コンテナの状態確認
is_container_running() {
    local container_name="$1"
    docker ps --format "table {{.Names}}" | grep -q "^${container_name}$"
}

# プロジェクトのルートディレクトリを取得
get_project_root() {
    local current_dir="$(pwd)"
    
    # .gitまたはdocker-compose.ymlを探して上位に移動
    while [ "$current_dir" != "/" ]; do
        if [ -f "$current_dir/docker-compose.yml" ] || [ -d "$current_dir/.git" ]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done
    
    # 見つからない場合は現在のディレクトリ
    echo "$(pwd)"
}

# ファイル・ディレクトリ操作
ensure_directory() {
    local dir="$1"
    
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log_success "ディレクトリを作成しました: $dir"
    fi
}

ensure_file() {
    local file="$1"
    local content="${2:-}"
    
    if [ ! -f "$file" ]; then
        if [ -n "$content" ]; then
            echo "$content" > "$file"
        else
            touch "$file"
        fi
        log_success "ファイルを作成しました: $file"
    fi
}

# プロセス管理
wait_for_process() {
    local seconds="$1"
    local message="${2:-待機中...}"
    
    log_info "$message ($seconds秒)"
    sleep "$seconds"
}

# OS判定
is_macos() {
    [[ "$OSTYPE" == "darwin"* ]]
}

is_linux() {
    [[ "$OSTYPE" == "linux-gnu"* ]]
}

# sed互換性対応
portable_sed() {
    local sed_args=("$@")
    
    if is_macos; then
        sed -i '' "${sed_args[@]}"
    else
        sed -i "${sed_args[@]}"
    fi
}

# タイムアウト互換性対応
run_with_timeout() {
    local timeout_sec="$1"
    shift
    
    # gtimeout（brewでインストール可能）があれば使用
    if command -v gtimeout >/dev/null 2>&1; then
        gtimeout "$timeout_sec" "$@"
    # GNU timeout（Linux）があれば使用
    elif command -v timeout >/dev/null 2>&1; then
        timeout "$timeout_sec" "$@"
    else
        # 代替実装：バックグラウンドで実行してsleepで制御
        "$@" &
        local pid=$!
        
        # タイムアウト監視をバックグラウンドで実行
        (
            sleep "$timeout_sec"
            if kill -0 "$pid" 2>/dev/null; then
                kill -TERM "$pid" 2>/dev/null || true
                sleep 2
                if kill -0 "$pid" 2>/dev/null; then
                    kill -KILL "$pid" 2>/dev/null || true
                fi
            fi
        ) &
        local timeout_pid=$!
        
        # メインプロセスの完了を待機
        if wait "$pid" 2>/dev/null; then
            kill "$timeout_pid" 2>/dev/null || true
            return 0
        else
            kill "$timeout_pid" 2>/dev/null || true
            return 124  # timeoutコマンドの終了コード
        fi
    fi
}

# クリーンアップハンドラー
setup_cleanup_handler() {
    local cleanup_function="${1:-cleanup}"
    
    # 引数チェック
    if ! declare -F "$cleanup_function" >/dev/null; then
        log_warning "cleanup関数 '$cleanup_function' が定義されていません"
        return 1
    fi
    
    # trap設定
    trap "$cleanup_function" EXIT INT TERM
    log_info "クリーンアップハンドラーを設定しました: $cleanup_function"
}

# バナー表示
show_banner() {
    local title="$1"
    local subtitle="${2:-}"
    
    printf "${PURPLE}╔════════════════════════════════════════════╗${NC}\n"
    printf "${PURPLE}║%-44s║${NC}\n" "  $title"
    [ -n "$subtitle" ] && printf "${PURPLE}║%-44s║${NC}\n" "  $subtitle"
    printf "${PURPLE}╚════════════════════════════════════════════╝${NC}\n"
    echo ""
}