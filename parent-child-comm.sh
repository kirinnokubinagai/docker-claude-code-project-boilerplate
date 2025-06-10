#!/bin/bash

# Parent-Child Process Communication Helper
# 親子プロセス間の通信を簡単にするヘルパー関数

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 通信ログディレクトリ
COMM_LOG_DIR="/workspace/logs/communications"
mkdir -p "$COMM_LOG_DIR"

# タイムスタンプ付きログ
log_comm() {
    local sender=$1
    local receiver=$2
    local message=$3
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] $sender → $receiver: $message" >> "$COMM_LOG_DIR/comm.log"
}

# 親から子へのメッセージ送信
parent_to_child() {
    local department=$1
    shift
    local message="$@"
    
    # pane IDを取得
    local pane_ids=($(tmux list-panes -t company -F "#{pane_id}"))
    local target_pane=""
    
    case $department in
        frontend) target_pane=${pane_ids[1]} ;;
        backend) target_pane=${pane_ids[2]} ;;
        database) target_pane=${pane_ids[3]} ;;
        devops) target_pane=${pane_ids[4]} ;;
        qa) target_pane=${pane_ids[5]} ;;
        all)
            # 全部門に一斉送信
            for i in {1..5}; do
                tmux send-keys -t ${pane_ids[$i]} "$message" Enter
            done
            log_comm "Parent" "All Departments" "$message"
            return 0
            ;;
        *)
            echo -e "${RED}不明な部門: $department${NC}"
            return 1
            ;;
    esac
    
    # メッセージ送信
    tmux send-keys -t $target_pane "$message" Enter
    log_comm "Parent" "$department" "$message"
    echo -e "${GREEN}✓${NC} $department部門にメッセージ送信: $message"
}

# 子から親への報告用テンプレート
child_report_template() {
    local department=$1
    local status=$2
    local message=$3
    
    local manager_pane=$(tmux list-panes -t company -F "#{pane_id}" | head -1)
    
    case $status in
        start)
            echo "tmux send-keys -t $manager_pane '[$department] 開始: $message' Enter"
            ;;
        progress)
            echo "tmux send-keys -t $manager_pane '[$department] 進行中: $message' Enter"
            ;;
        complete)
            echo "tmux send-keys -t $manager_pane '[$department] 完了: $message' Enter"
            ;;
        error)
            echo "tmux send-keys -t $manager_pane '[$department] エラー: $message' Enter"
            ;;
        help)
            echo "tmux send-keys -t $manager_pane '[$department] 支援要請: $message' Enter"
            ;;
    esac
}

# 進捗モニタリング
monitor_progress() {
    echo -e "${CYAN}=== 進捗モニタリング ===${NC}"
    
    # 通信ログの最新10件を表示
    echo -e "${YELLOW}最新の通信ログ:${NC}"
    tail -10 "$COMM_LOG_DIR/comm.log" 2>/dev/null || echo "通信ログなし"
    
    echo ""
    echo -e "${YELLOW}各部門の最新状態:${NC}"
    
    local pane_ids=($(tmux list-panes -t company -F "#{pane_id}"))
    local departments=("Manager" "Frontend" "Backend" "Database" "DevOps" "QA")
    
    for i in {0..5}; do
        echo -e "${BLUE}--- ${departments[$i]} ---${NC}"
        tmux capture-pane -t ${pane_ids[$i]} -p | tail -3
        echo ""
    done
}

# タスクの自動割り振り
auto_assign_task() {
    local task_type=$1
    
    case $task_type in
        ui)
            parent_to_child frontend "UIコンポーネント作成タスク: $2"
            ;;
        api)
            parent_to_child backend "API実装タスク: $2"
            ;;
        db)
            parent_to_child database "データベース設計タスク: $2"
            ;;
        deploy)
            parent_to_child devops "デプロイ設定タスク: $2"
            ;;
        test)
            parent_to_child qa "テスト作成タスク: $2"
            ;;
        *)
            echo -e "${RED}不明なタスクタイプ: $task_type${NC}"
            ;;
    esac
}

# バッチタスク配布
batch_assign() {
    local task_file=$1
    
    if [ ! -f "$task_file" ]; then
        echo -e "${RED}タスクファイルが見つかりません: $task_file${NC}"
        return 1
    fi
    
    echo -e "${CYAN}バッチタスク配布開始...${NC}"
    
    while IFS='|' read -r department task; do
        # 空行やコメント行をスキップ
        [[ -z "$department" || "$department" =~ ^# ]] && continue
        
        parent_to_child "$department" "$task"
        sleep 0.5
    done < "$task_file"
    
    echo -e "${GREEN}バッチタスク配布完了${NC}"
}

# 緊急指示
emergency_command() {
    local command=$1
    
    echo -e "${RED}🚨 緊急指示: $command${NC}"
    parent_to_child all "🚨 緊急: $command"
}

# ヘルプ表示
show_help() {
    echo -e "${PURPLE}=== Parent-Child Communication Helper ===${NC}"
    echo ""
    echo "使用方法:"
    echo "  source parent-child-comm.sh"
    echo ""
    echo "関数:"
    echo "  parent_to_child <department> <message>  - 特定部門にメッセージ送信"
    echo "  monitor_progress                        - 進捗モニタリング"
    echo "  auto_assign_task <type> <details>       - タスク自動割り振り"
    echo "  batch_assign <file>                     - バッチタスク配布"
    echo "  emergency_command <command>             - 緊急指示（全部門）"
    echo ""
    echo "部門: frontend, backend, database, devops, qa, all"
    echo "タスクタイプ: ui, api, db, deploy, test"
    echo ""
    echo "例:"
    echo "  parent_to_child frontend 'ログイン画面を作成してください'"
    echo "  auto_assign_task ui 'ダッシュボード画面'"
    echo "  emergency_command '全作業を一時停止してください'"
    echo ""
    echo "バッチファイル形式:"
    echo "  frontend|ヘッダーコンポーネント作成"
    echo "  backend|ユーザー認証API実装"
    echo "  database|ユーザーテーブル設計"
}

# メイン処理
if [ "$1" = "help" ]; then
    show_help
else
    echo -e "${GREEN}Parent-Child Communication Helper loaded!${NC}"
    echo "Type 'show_help' for usage information"
fi