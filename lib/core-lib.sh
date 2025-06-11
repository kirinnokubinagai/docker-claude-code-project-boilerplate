#!/bin/bash

# Master Claude Teams System - コアライブラリ
# 基本的な機能をすべてまとめた統合ライブラリ

# ========================================
# 基本設定
# ========================================

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# バナー表示
show_banner() {
    local title="$1"
    local subtitle="$2"
    echo -e "${CYAN}${BOLD}"
    echo "======================================"
    echo " $title"
    [ -n "$subtitle" ] && echo " $subtitle"
    echo "======================================"
    echo -e "${NC}"
}

# ========================================
# タイムアウトとプロセス管理
# ========================================

# macOS互換のtimeout関数
run_with_timeout() {
    local timeout_sec="$1"
    shift
    
    if command -v gtimeout >/dev/null 2>&1; then
        gtimeout "$timeout_sec" "$@"
    elif command -v timeout >/dev/null 2>&1; then
        timeout "$timeout_sec" "$@"
    else
        "$@" &
        local pid=$!
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
        
        if wait "$pid" 2>/dev/null; then
            kill -TERM "$timeout_pid" 2>/dev/null || true
            return 0
        else
            local exit_code=$?
            wait "$timeout_pid" 2>/dev/null
            return $exit_code
        fi
    fi
}

# プロセス待機
wait_for_process() {
    local duration="$1"
    local message="${2:-待機中}"
    
    log_info "$message ($duration秒)..."
    sleep "$duration"
}

# ========================================
# Git操作
# ========================================

# Gitリポジトリ初期化
init_git_repo() {
    local dir="$1"
    
    cd "$dir" || return 1
    
    if [ ! -d .git ]; then
        log_info "Gitリポジトリを初期化中..."
        git init || return 1
        
        # 初期コミットが必要な場合
        if ! git rev-parse HEAD >/dev/null 2>&1; then
            echo "# Project" > README.md
            git add README.md
            git commit -m "Initial commit" || return 1
        fi
    fi
    
    return 0
}

# worktreeのクリーンアップ
cleanup_worktree() {
    local workspace="$1"
    local dir_name="$2"
    local branch="$3"
    
    cd "$workspace" || return 1
    
    # 既存のworktreeを削除
    if [ -d "worktrees/$dir_name" ]; then
        log_info "既存のworktree削除: $dir_name"
        git worktree remove "worktrees/$dir_name" --force 2>/dev/null || true
    fi
    
    # ブランチをクリーンアップ（必要に応じて）
    if [ "$CLEANUP_BRANCHES" = "true" ] && git show-ref --verify --quiet "refs/heads/$branch"; then
        log_info "ブランチ削除: $branch"
        git branch -D "$branch" 2>/dev/null || true
    fi
}

# ========================================
# tmux操作
# ========================================

# tmuxセッション存在確認
tmux_session_exists() {
    local session="$1"
    tmux has-session -t "$session" 2>/dev/null
}

# tmuxセッション削除
kill_tmux_session() {
    local session="$1"
    
    if tmux_session_exists "$session"; then
        log_info "既存のtmuxセッション削除: $session"
        tmux kill-session -t "$session" 2>/dev/null || true
    fi
}

# tmuxペインにコマンド送信
send_to_pane() {
    local session="$1"
    local target="$2"
    local command="$3"
    
    tmux send-keys -t "$session:$target" "$command" Enter
}

# ========================================
# チーム設定
# ========================================

# チームブランチ名取得
get_team_branch() {
    local team="$1"
    
    if [ -f "$TEAMS_CONFIG_FILE" ]; then
        local branch=$(jq -r ".teams[] | select(.id == \"$team\") | .branch // \"team/$team\"" "$TEAMS_CONFIG_FILE" 2>/dev/null)
        echo "${branch:-team/$team}"
    else
        echo "team/$team"
    fi
}

# チームウィンドウ名取得
get_team_window_name() {
    local team="$1"
    case "$team" in
        "frontend") echo "Team-Frontend" ;;
        "backend") echo "Team-Backend" ;;
        "database") echo "Team-Database" ;;
        "devops") echo "Team-DevOps" ;;
        "qa-security") echo "Team-QA-Security" ;;
        *) echo "Team-$team" ;;
    esac
}

# メンバーペイン名取得
get_member_pane_name() {
    local team="$1"
    local role="$2"
    local team_cap=""
    local role_cap=""
    
    case "$team" in
        "frontend") team_cap="Frontend" ;;
        "backend") team_cap="Backend" ;;
        "database") team_cap="Database" ;;
        "devops") team_cap="DevOps" ;;
        "qa-security") team_cap="QA-Security" ;;
        *) team_cap="$team" ;;
    esac
    
    case "$role" in
        "boss") role_cap="Boss" ;;
        "pro1") role_cap="Pro1" ;;
        "pro2") role_cap="Pro2" ;;
        "pro3") role_cap="Pro3" ;;
        *) role_cap="$role" ;;
    esac
    
    echo "${team_cap}-${role_cap}"
}

# ========================================
# ユーティリティ
# ========================================

# ディレクトリ作成
ensure_directory() {
    local dir="$1"
    
    if [ ! -d "$dir" ]; then
        log_info "ディレクトリ作成: $dir"
        mkdir -p "$dir"
    fi
}

# 依存関係チェック
check_dependencies() {
    local missing=()
    
    for cmd in "$@"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "必要なコマンドがインストールされていません: ${missing[*]}"
        return 1
    fi
    
    return 0
}

# トラップ設定
setup_trap() {
    local cleanup_func="$1"
    trap "$cleanup_func" EXIT INT TERM
}

# ========================================
# 共通変数設定
# ========================================

# セッション名
SESSION_NAME="${SESSION_NAME:-claude-teams}"

# ワークスペース
WORKSPACE="${WORKSPACE:-$(pwd)}"

# worktreeディレクトリ
WORKTREES_DIR="$WORKSPACE/worktrees"

# Claudeコマンド
CLAUDE_CMD="${CLAUDE_CMD:-claude --dangerously-skip-permissions}"

# 待機時間
CLAUDE_STARTUP_WAIT="${CLAUDE_STARTUP_WAIT:-5}"
INITIAL_MESSAGE_WAIT="${INITIAL_MESSAGE_WAIT:-3}"

# チーム設定ファイル
TEAMS_CONFIG_FILE="$WORKSPACE/config/teams.json"

# ブランチクリーンアップフラグ
CLEANUP_BRANCHES="${CLEANUP_BRANCHES:-false}"