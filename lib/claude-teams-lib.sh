#!/bin/bash

# Claude Teams共通ライブラリ

# macOS互換のtimeout関数（gtimeoutまたは代替実装）
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

# 色定義
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export NC='\033[0m'

# ロギング関数（-e オプション互換性対応）
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
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

# バナー表示
show_banner() {
    local title="$1"
    local subtitle="$2"
    
    printf "${PURPLE}╔════════════════════════════════════════════╗${NC}\n"
    printf "${PURPLE}║%-44s║${NC}\n" "  $title"
    printf "${PURPLE}║%-44s║${NC}\n" "  $subtitle"
    printf "${PURPLE}╚════════════════════════════════════════════╝${NC}\n"
    echo ""
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

# tmuxセッション管理
kill_tmux_session() {
    local session="$1"
    
    log_info "tmuxセッション '$session' の確認中..."
    
    # タイムアウト付きでセッション存在確認
    if run_with_timeout 5 tmux has-session -t "$session" 2>/dev/null; then
        log_info "既存のセッション '$session' をクリーンアップ中..."
        
        # タイムアウト付きでセッション削除
        if run_with_timeout 10 tmux kill-session -t "$session" 2>/dev/null; then
            log_success "セッション '$session' を正常に削除しました"
        else
            log_warning "セッション削除がタイムアウトしました。強制終了を試みます..."
            tmux kill-server 2>/dev/null || true
        fi
    else
        log_info "セッション '$session' は存在しません（またはタイムアウト）"
    fi
}

# git worktree管理
cleanup_worktree() {
    local workspace="$1"
    local worktree_name="$2"
    local branch_name="$3"
    
    cd "$workspace" || return 1
    
    # worktreeが存在する場合は削除
    if git worktree list | grep -q "worktrees/$worktree_name"; then
        log_info "既存のworktree '$worktree_name' を削除中..."
        git worktree remove --force "worktrees/$worktree_name" 2>/dev/null || true
    fi
    
    # ブランチが存在する場合は削除
    if git branch | grep -q "$branch_name"; then
        log_info "既存のブランチ '$branch_name' を削除中..."
        git branch -D "$branch_name" 2>/dev/null || true
    fi
}

# gitリポジトリ初期化
init_git_repo() {
    local workspace="$1"
    
    if [ ! -d "$workspace/.git" ]; then
        log_info "Gitリポジトリを初期化中..."
        cd "$workspace" || return 1
        git init
        echo "# Project" > README.md
        git add README.md
        git commit -m "Initial commit" || {
            log_error "初期コミットに失敗しました"
            return 1
        }
        log_success "Gitリポジトリを初期化しました"
    fi
}

# tmuxペインにコマンドを送信
send_to_pane() {
    local session="$1"
    local pane="$2"
    local message="$3"
    
    tmux send-keys -t "$session:$pane" "$message" Enter
}

# 進捗確認
capture_pane_output() {
    local session="$1"
    local pane="$2"
    local lines="${3:-10}"
    
    tmux capture-pane -t "$session:$pane" -p | tail -"$lines"
}

# ファイルの存在確認と作成
ensure_file() {
    local file="$1"
    local content="$2"
    
    if [ ! -f "$file" ]; then
        echo "$content" > "$file"
        log_success "ファイルを作成しました: $file"
    else
        log_info "ファイルは既に存在します: $file"
    fi
}

# ディレクトリの存在確認と作成
ensure_directory() {
    local dir="$1"
    
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log_success "ディレクトリを作成しました: $dir"
    fi
}

# プロセスの待機
wait_for_process() {
    local seconds="$1"
    local message="${2:-待機中...}"
    
    log_info "$message ($seconds秒)"
    sleep "$seconds"
}

# 安全なtrap設定
setup_trap() {
    local cleanup_function="$1"
    
    # 引数チェック
    if [ -z "$cleanup_function" ]; then
        log_error "cleanup関数が指定されていません"
        return 1
    fi
    
    # trap設定
    if trap "$cleanup_function" EXIT INT TERM; then
        log_info "trap設定完了: $cleanup_function"
    else
        log_error "trap設定に失敗しました"
        return 1
    fi
}