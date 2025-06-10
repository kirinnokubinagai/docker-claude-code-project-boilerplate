#!/bin/bash

# チーム間通信ライブラリ

# メッセージキューディレクトリ
MESSAGE_QUEUE_DIR="$WORKSPACE/.team-messages"

# 通信プロトコル定義（互換性のため関数ベース）
get_message_type() {
    local type="$1"
    case "$type" in
        "REQUEST") echo "依頼" ;;
        "RESPONSE") echo "返答" ;;
        "NOTIFY") echo "通知" ;;
        "HELP") echo "ヘルプ要請" ;;
        "UPDATE") echo "進捗更新" ;;
        *) echo "$type" ;;
    esac
}

# メッセージキューの初期化
init_message_queue() {
    ensure_directory "$MESSAGE_QUEUE_DIR"
    ensure_directory "$MESSAGE_QUEUE_DIR/inbox"
    ensure_directory "$MESSAGE_QUEUE_DIR/outbox"
    ensure_directory "$MESSAGE_QUEUE_DIR/processed"
    
    # 各チーム用のキューディレクトリ作成
    for team in master frontend backend database devops; do
        ensure_directory "$MESSAGE_QUEUE_DIR/inbox/$team"
    done
    
    log_success "メッセージキューを初期化しました"
}

# メッセージの送信
send_team_message() {
    local from_team="$1"
    local to_team="$2"
    local message_type="$3"
    local content="$4"
    local priority="${5:-normal}"  # high, normal, low
    
    local timestamp=$(date +%s)
    local message_id="${from_team}_${to_team}_${timestamp}_$$"
    local message_file="$MESSAGE_QUEUE_DIR/inbox/$to_team/${priority}_${message_id}.msg"
    
    # メッセージをJSON形式で保存
    cat > "$message_file" << EOF
{
    "id": "$message_id",
    "from": "$from_team",
    "to": "$to_team",
    "type": "$message_type",
    "priority": "$priority",
    "timestamp": "$timestamp",
    "content": "$content",
    "status": "unread"
}
EOF
    
    log_info "[$from_team → $to_team] $(get_message_type "$message_type"): $content"
    
    # 受信側のペインに通知
    local to_pane=$(get_team_pane "$to_team")
    if [ -n "$to_pane" ]; then
        send_to_pane "$SESSION_NAME" "Teams.$to_pane" "# 📨 新着メッセージ from $from_team: $content"
    fi
}

# チーム名からペイン番号を取得
get_team_pane() {
    local team="$1"
    case "$team" in
        "master") echo "0" ;;
        "frontend") echo "1" ;;
        "database") echo "2" ;;
        "backend") echo "3" ;;
        "devops") echo "4" ;;
        *) echo "" ;;
    esac
}

# メッセージの受信チェック
check_team_messages() {
    local team="$1"
    local inbox_dir="$MESSAGE_QUEUE_DIR/inbox/$team"
    
    if [ ! -d "$inbox_dir" ]; then
        return 0
    fi
    
    # 優先度順にメッセージを処理
    for priority in high normal low; do
        for msg_file in "$inbox_dir"/${priority}_*.msg 2>/dev/null; do
            [ -f "$msg_file" ] || continue
            
            # メッセージを読み込み（jq代替）
            local message=$(cat "$msg_file")
            local from=$(echo "$message" | sed -n 's/.*"from": *"\([^"]*\)".*/\1/p')
            local type=$(echo "$message" | sed -n 's/.*"type": *"\([^"]*\)".*/\1/p')
            local content=$(echo "$message" | sed -n 's/.*"content": *"\([^"]*\)".*/\1/p')
            
            # 処理済みディレクトリに移動
            mv "$msg_file" "$MESSAGE_QUEUE_DIR/processed/"
            
            # メッセージを返す
            echo "[$from] $type: $content"
            return 0  # 1件だけ返す（非同期処理のため）
        done
    done
    
    return 1  # メッセージなし
}

# チーム間協調コマンド生成
generate_team_commands() {
    cat << 'EOF'

# 🤝 チーム間通信コマンド

## 他チームへの依頼
```bash
# Frontend → Backend: API仕様の確認
send_team_message "frontend" "backend" "REQUEST" "ユーザー認証APIの仕様を教えてください" "high"

# Backend → Database: スキーマ変更依頼
send_team_message "backend" "database" "REQUEST" "注文テーブルにステータスカラムを追加してください" "normal"

# Database → DevOps: パフォーマンス問題
send_team_message "database" "devops" "HELP" "クエリが遅いので最適化を手伝ってください" "high"
```

## メッセージチェック（各チームで定期実行）
```bash
# 自チームのメッセージをチェック
while true; do
    msg=$(check_team_messages "frontend")
    if [ $? -eq 0 ]; then
        echo "受信: $msg"
        # メッセージに基づいて処理を実行
    fi
    sleep 5
done
```

## 非同期タスク処理
```bash
# タスクキューに追加しながら別の作業を継続
add_async_task "frontend" "コンポーネント作成" "normal" &
continue_current_work "frontend"
```

## ブロードキャスト
```bash
# 全チームへの通知
broadcast_to_teams "master" "NOTIFY" "仕様変更: 認証方式をJWTに統一します"
```

EOF
}

# 非同期タスクの追加
add_async_task() {
    local team="$1"
    local task="$2"
    local priority="${3:-normal}"
    
    local task_file="$MESSAGE_QUEUE_DIR/tasks/${team}_$(date +%s).task"
    ensure_directory "$MESSAGE_QUEUE_DIR/tasks"
    
    cat > "$task_file" << EOF
{
    "team": "$team",
    "task": "$task",
    "priority": "$priority",
    "status": "pending",
    "created": "$(date +%s)"
}
EOF
    
    log_info "[$team] 非同期タスクを追加: $task"
}

# 現在の作業を継続
continue_current_work() {
    local team="$1"
    log_info "[$team] メイン作業を継続中..."
}

# 全チームへのブロードキャスト
broadcast_to_teams() {
    local from_team="$1"
    local message_type="$2"
    local content="$3"
    local priority="${4:-normal}"
    
    for team in master frontend backend database devops; do
        if [ "$team" != "$from_team" ]; then
            send_team_message "$from_team" "$team" "$message_type" "$content" "$priority"
        fi
    done
}

# チーム監視機能（旧team-monitor.shから統合）

# バックグラウンドでメッセージ監視を開始
start_message_monitor() {
    local team_name="$1"
    
    while true; do
        # メッセージをチェック
        if msg=$(check_team_messages "$team_name" 2>/dev/null); then
            if [ -n "$msg" ]; then
                # 新着メッセージを処理
                echo ""
                echo "📨 [受信] $msg"
                echo ""
                
                # メッセージタイプに応じて自動応答
                if echo "$msg" | grep -q "HELP"; then
                    echo "🤝 ヘルプ要請を受信しました。対応を検討します。"
                elif echo "$msg" | grep -q "REQUEST"; then
                    echo "📋 タスク依頼を受信しました。現在のタスク完了後に対応します。"
                elif echo "$msg" | grep -q "UPDATE"; then
                    echo "ℹ️ 進捗更新を確認しました。"
                fi
            fi
        fi
        
        sleep "$MESSAGE_CHECK_INTERVAL"
    done
}

# タスクキューを処理
process_task_queue() {
    local team_name="$1"
    local task_dir="$MESSAGE_QUEUE_DIR/tasks"
    
    while true; do
        for task_file in "$task_dir"/${team_name}_*.task 2>/dev/null; do
            [ -f "$task_file" ] || continue
            
            local task_content=$(cat "$task_file")
            local task=$(echo "$task_content" | sed -n 's/.*"task": *"\([^"]*\)".*/\1/p')
            
            echo ""
            echo "🔄 [非同期タスク] $task を処理中..."
            
            # 処理済みにマーク
            mv "$task_file" "$MESSAGE_QUEUE_DIR/processed/"
        done
        
        sleep 5
    done
}

# 定期的な状態報告
periodic_status_update() {
    local team_name="$1"
    
    while true; do
        # 設定された間隔で状態を更新
        sleep "$STATUS_UPDATE_INTERVAL"
        
        monitor_team_status "$team_name"
        
        # Masterに進捗報告
        send_team_message "$team_name" "master" "UPDATE" "定期報告: 正常に作業中" "low"
    done
}

# チーム監視システム起動
start_team_monitoring() {
    local team_name="$1"
    
    log_info "[$team_name] メッセージ監視システムを起動しました"
    log_info "- メッセージチェック間隔: ${MESSAGE_CHECK_INTERVAL}秒"
    log_info "- 非同期タスク処理: 有効"
    log_info "- 定期状態報告: $((STATUS_UPDATE_INTERVAL / 60))分ごと"
    
    # バックグラウンドでモニターを起動
    start_message_monitor "$team_name" &
    process_task_queue "$team_name" &
    periodic_status_update "$team_name" &
    
    log_success "[$team_name] 監視システムが正常に起動しました"
}

# チーム状態の監視
monitor_team_status() {
    local team="$1"
    local status_file="$MESSAGE_QUEUE_DIR/status/${team}.status"
    ensure_directory "$MESSAGE_QUEUE_DIR/status"
    
    cat > "$status_file" << EOF
{
    "team": "$team",
    "status": "active",
    "current_task": "",
    "last_update": "$(date +%s)",
    "pending_messages": $(ls "$MESSAGE_QUEUE_DIR/inbox/$team" 2>/dev/null | wc -l)
}
EOF
}

# インテリジェントルーティング
route_message_intelligently() {
    local from_team="$1"
    local content="$2"
    
    # キーワードに基づいて適切なチームにルーティング
    if echo "$content" | grep -qi "api\|endpoint\|認証"; then
        send_team_message "$from_team" "backend" "REQUEST" "$content" "normal"
    elif echo "$content" | grep -qi "ui\|画面\|コンポーネント"; then
        send_team_message "$from_team" "frontend" "REQUEST" "$content" "normal"
    elif echo "$content" | grep -qi "テーブル\|スキーマ\|インデックス"; then
        send_team_message "$from_team" "database" "REQUEST" "$content" "normal"
    elif echo "$content" | grep -qi "デプロイ\|ci\|cd\|docker"; then
        send_team_message "$from_team" "devops" "REQUEST" "$content" "normal"
    else
        send_team_message "$from_team" "master" "HELP" "$content" "high"
    fi
}