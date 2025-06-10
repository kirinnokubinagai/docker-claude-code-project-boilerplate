#!/bin/bash

# チーム監視スクリプト - 各チームに自動インジェクトされる

# チーム名を引数から取得
TEAM_NAME="${1:-unknown}"

# メッセージチェック間隔（秒）
MESSAGE_CHECK_INTERVAL=10

# バックグラウンドでメッセージ監視を開始
start_message_monitor() {
    while true; do
        # メッセージをチェック
        if msg=$(check_team_messages "$TEAM_NAME" 2>/dev/null); then
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
    local task_dir="$MESSAGE_QUEUE_DIR/tasks"
    
    while true; do
        for task_file in "$task_dir"/${TEAM_NAME}_*.task 2>/dev/null; do
            [ -f "$task_file" ] || continue
            
            local task_content=$(cat "$task_file")
            local task=$(echo "$task_content" | jq -r '.task')
            
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
    while true; do
        # 30分ごとに状態を更新
        sleep 1800
        
        monitor_team_status "$TEAM_NAME"
        
        # Masterに進捗報告
        send_team_message "$TEAM_NAME" "master" "UPDATE" "定期報告: 正常に作業中" "low"
    done
}

# スマート応答システム
smart_response() {
    local from="$1"
    local content="$2"
    
    # 内容に基づいて適切な応答を生成
    if echo "$content" | grep -qi "仕様.*確認\|spec"; then
        echo "仕様を確認して返答します。"
    elif echo "$content" | grep -qi "進捗\|status"; then
        echo "現在のタスク進捗を共有します。"
    elif echo "$content" | grep -qi "ブロック\|待機\|wait"; then
        echo "ブロッカーを確認し、必要に応じて他チームに相談します。"
    fi
}

# メイン処理
echo "🚀 [$TEAM_NAME] メッセージ監視システムを起動しました"
echo "- メッセージチェック間隔: ${MESSAGE_CHECK_INTERVAL}秒"
echo "- 非同期タスク処理: 有効"
echo "- 定期状態報告: 30分ごと"

# バックグラウンドでモニターを起動
start_message_monitor &
process_task_queue &
periodic_status_update &

echo "✅ 監視システムが正常に起動しました"