#!/bin/bash

# Auto-assign tasks to team members in Claude Teams
# 
# このスクリプトは動的チーム編成システムで自動的にタスクを割り当てます

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# 設定
SESSION_NAME="claude-teams"
WORKSPACE="/workspace"
TEAMS_CONFIG_FILE="/opt/claude-system/config/teams.json"
TASKS_CONFIG_FILE="/opt/claude-system/config/team-tasks.json"
WORKFLOW_STATE_FILE="/opt/claude-system/config/workflow_state.json"

# ヘルプメッセージ
show_help() {
    echo -e "${CYAN}${BOLD}Auto-assign Tasks Script${NC}"
    echo ""
    echo "使い方:"
    echo "  auto-assign-tasks.sh [オプション]"
    echo ""
    echo "オプション:"
    echo "  --update-tasks   team-tasks.jsonを再読み込みしてタスクを更新"
    echo "  --redistribute   タスクを再分配（チームメンバー間でバランス調整）"
    echo "  --status         現在のタスク割り当て状況を表示"
    echo "  --help           このヘルプを表示"
    echo ""
    echo "例:"
    echo "  auto-assign-tasks.sh                  # 通常の自動割り当て"
    echo "  auto-assign-tasks.sh --update-tasks   # タスクファイルを再読み込み"
    echo "  auto-assign-tasks.sh --status         # 現在の状況を確認"
}

# ログ関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_task() {
    echo -e "${MAGENTA}[TASK]${NC} $1"
}

# ペインインデックスを取得する関数
get_pane_index_for_team() {
    local team_id=$1
    local member_index=$2  # 1-based
    
    # 累積インデックスを計算（tmuxのペインは1から始まる）
    local pane_idx=1  # Masterペインが1
    
    # teams.jsonから各チームのメンバー数を取得
    local teams=$(jq -r '.teams[] | select(.active == true) | .id' "$TEAMS_CONFIG_FILE" 2>/dev/null)
    
    for t in $teams; do
        if [ "$t" = "$team_id" ]; then
            # 該当チームのメンバーインデックスを追加
            pane_idx=$((pane_idx + member_index))
            break
        else
            # このチームのメンバー数を追加
            local count=$(jq -r ".teams[] | select(.id == \"$t\") | .member_count // 1" "$TEAMS_CONFIG_FILE" 2>/dev/null)
            pane_idx=$((pane_idx + count))
        fi
    done
    
    echo $pane_idx
}

# タスクを送信する関数
send_task_to_pane() {
    local pane_idx=$1
    local task=$2
    
    # タスクを送信（ウィンドウ番号は1）
    tmux send-keys -t "$SESSION_NAME:1.$pane_idx" "$task" Enter
}

# タスク状況を表示
show_status() {
    echo -e "${CYAN}${BOLD}=== タスク割り当て状況 ===${NC}"
    echo ""
    
    if [ ! -f "$WORKFLOW_STATE_FILE" ]; then
        echo "ワークフロー状態ファイルが見つかりません"
        return
    fi
    
    # 各チームの状況を表示
    local teams=$(jq -r '.teams[] | select(.active == true) | .id' "$TEAMS_CONFIG_FILE" 2>/dev/null)
    
    for team in $teams; do
        local team_name=$(jq -r ".teams[] | select(.id == \"$team\") | .name" "$TEAMS_CONFIG_FILE" 2>/dev/null)
        echo -e "${BOLD}$team_name:${NC}"
        
        # チームメンバーのタスクを表示
        local tasks=$(jq -r ".teams.$team.tasks[]?" "$WORKFLOW_STATE_FILE" 2>/dev/null)
        if [ -n "$tasks" ]; then
            echo "$tasks" | while IFS= read -r task; do
                echo "  - $task"
            done
        else
            echo "  （タスクなし）"
        fi
        echo ""
    done
}

# メイン処理
main() {
    # 引数処理
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        --status)
            show_status
            exit 0
            ;;
        --update-tasks)
            log_info "タスクファイルを更新中..."
            ;;
        --redistribute)
            log_info "タスクを再分配中..."
            ;;
    esac
    
    # 必要なファイルの確認
    if [ ! -f "$TEAMS_CONFIG_FILE" ]; then
        log_error "teams.json が見つかりません"
        echo "master コマンドを先に実行してください"
        exit 1
    fi
    
    if [ ! -f "$TASKS_CONFIG_FILE" ]; then
        log_error "team-tasks.json が見つかりません"
        exit 1
    fi
    
    # セッションの確認
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_error "Claude Teamsセッションが見つかりません"
        echo "master コマンドを先に実行してください"
        exit 1
    fi
    
    echo -e "${CYAN}${BOLD}=== Auto-assign Tasks ===${NC}"
    echo ""
    
    # Masterへのタスク送信
    log_info "Masterにプロジェクト全体の統括タスクを送信中..."
    local master_prompt=$(jq -r '.master.initial_prompt // ""' "$TASKS_CONFIG_FILE" 2>/dev/null)
    if [ -n "$master_prompt" ]; then
        send_task_to_pane 1 "$master_prompt"
        log_success "Master: タスク送信完了"
    fi
    
    # 各チームへのタスク送信
    log_info "各チームにタスクを割り当て中..."
    
    local teams=$(jq -r '.teams[] | select(.active == true) | .id' "$TEAMS_CONFIG_FILE" 2>/dev/null)
    
    for team in $teams; do
        local team_name=$(jq -r ".teams[] | select(.id == \"$team\") | .name" "$TEAMS_CONFIG_FILE" 2>/dev/null)
        local member_count=$(jq -r ".teams[] | select(.id == \"$team\") | .member_count // 1" "$TEAMS_CONFIG_FILE" 2>/dev/null)
        
        echo -e "${BOLD}$team_name チーム ($member_count 人)${NC}"
        
        # ボス（最初のメンバー）にタスクを送信
        local boss_prompt=$(jq -r ".$team.boss.initial_prompt // \"\"" "$TASKS_CONFIG_FILE" 2>/dev/null)
        if [ -n "$boss_prompt" ]; then
            local boss_pane_idx=$(get_pane_index_for_team "$team" 1)
            send_task_to_pane "$boss_pane_idx" "$boss_prompt"
            log_task "ボス → タスク送信完了"
        fi
        
        # メンバータスクを送信
        for i in $(seq 2 "$member_count"); do
            local member_key="member$((i-1))"  # member1, member2...
            local member_prompt=$(jq -r ".$team.$member_key.initial_prompt // \"\"" "$TASKS_CONFIG_FILE" 2>/dev/null)
            
            if [ -n "$member_prompt" ]; then
                local member_pane_idx=$(get_pane_index_for_team "$team" "$i")
                send_task_to_pane "$member_pane_idx" "$member_prompt"
                log_task "メンバー $i → タスク送信完了"
            fi
        done
        
        echo ""
    done
    
    # ワークフロー状態を更新
    if [ "$1" = "--update-tasks" ] || [ "$1" = "--redistribute" ]; then
        log_info "ワークフロー状態を更新中..."
        # 状態ファイルの更新処理（必要に応じて実装）
    fi
    
    echo ""
    log_success "全てのタスク割り当てが完了しました！"
    echo ""
    echo "📍 セッションに接続するには:"
    echo "   tmux attach -t $SESSION_NAME"
    echo ""
}

# スクリプトの実行
main "$@"