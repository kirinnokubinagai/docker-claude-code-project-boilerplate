#!/bin/bash

# 階層的コミュニケーションシステム
# Master ↔ Boss ↔ Team Members

# チーム名を大文字化
capitalize_team() {
    local team="$1"
    case "$team" in
        "frontend") echo "Frontend" ;;
        "backend") echo "Backend" ;;
        "database") echo "Database" ;;
        "devops") echo "DevOps" ;;
        "qa-security") echo "QA-Security" ;;
        *) echo "$team" ;;
    esac
}

# ロール名を大文字化
capitalize_role() {
    local role="$1"
    case "$role" in
        "boss") echo "Boss" ;;
        "pro1") echo "Pro1" ;;
        "pro2") echo "Pro2" ;;
        "pro3") echo "Pro3" ;;
        "master") echo "Master" ;;
        *) echo "$role" ;;
    esac
}

# コミュニケーションルールの検証（より柔軟なルール）
validate_communication() {
    local from_role="$1"
    local to_role="$2"
    local from_team="$3"
    local to_team="$4"
    
    # すべてのコミュニケーションを許可（より良いサービスのため）
    return 0
}

# Masterからチームボスへのメッセージ送信
master_to_boss() {
    local team="$1"
    local message="$2"
    local window_name=$(get_team_window_name "$team")
    
    local team_cap=$(capitalize_team "$team")
    log_info "[Master → ${team_cap} Boss] $message"
    
    # メッセージファイルに記録
    local msg_file="$WORKSPACE/.team-messages/master-to-${team}-boss.msg"
    mkdir -p "$(dirname "$msg_file")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Master → ${team_cap} Boss: $message" >> "$msg_file"
    
    # tmuxペインに送信（Bossは常にペイン0）
    send_to_pane "$SESSION_NAME" "$window_name.0" "$message"
}

# Bossから部下へのメッセージ送信
boss_to_member() {
    local team="$1"
    local member_role="$2"  # pro1, pro2, pro3
    local message="$3"
    local window_name=$(get_team_window_name "$team")
    
    # roleからペイン番号を取得
    local pane_num
    case "$member_role" in
        "pro1") pane_num=1 ;;
        "pro2") pane_num=2 ;;
        "pro3") pane_num=3 ;;
        *) log_error "無効なロール: $member_role"; return 1 ;;
    esac
    
    local team_cap=$(capitalize_team "$team")
    local role_cap=$(capitalize_role "$member_role")
    log_info "[${team_cap} Boss → ${role_cap}] $message"
    
    # メッセージファイルに記録
    local msg_file="$WORKSPACE/.team-messages/${team}-boss-to-${member_role}.msg"
    mkdir -p "$(dirname "$msg_file")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${team_cap} Boss → ${role_cap}: $message" >> "$msg_file"
    
    # tmuxペインに送信
    send_to_pane "$SESSION_NAME" "$window_name.$pane_num" "$message"
}

# BossからMasterへのメッセージ送信
boss_to_master() {
    local team="$1"
    local message="$2"
    
    local team_cap=$(capitalize_team "$team")
    log_info "[${team_cap} Boss → Master] $message"
    
    # メッセージファイルに記録
    local msg_file="$WORKSPACE/.team-messages/${team}-boss-to-master.msg"
    mkdir -p "$(dirname "$msg_file")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${team_cap} Boss → Master: $message" >> "$msg_file"
    
    # Masterペインに送信
    send_to_pane "$SESSION_NAME" "Master.0" "$message"
}

# 部下からBossへのメッセージ送信
member_to_boss() {
    local team="$1"
    local member_role="$2"  # pro1, pro2, pro3
    local message="$3"
    local window_name=$(get_team_window_name "$team")
    
    local team_cap=$(capitalize_team "$team")
    local role_cap=$(capitalize_role "$member_role")
    log_info "[${team_cap} ${role_cap} → Boss] $message"
    
    # メッセージファイルに記録
    local msg_file="$WORKSPACE/.team-messages/${team}-${member_role}-to-boss.msg"
    mkdir -p "$(dirname "$msg_file")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${team_cap} ${role_cap} → Boss: $message" >> "$msg_file"
    
    # Bossペインに送信（ペイン0）
    send_to_pane "$SESSION_NAME" "$window_name.0" "$message"
}

# チームメンバー間のメッセージ送信
member_to_member() {
    local team="$1"
    local from_role="$2"
    local to_role="$3"
    local message="$4"
    local window_name=$(get_team_window_name "$team")
    
    # roleからペイン番号を取得
    local to_pane_num
    case "$to_role" in
        "boss") to_pane_num=0 ;;
        "pro1") to_pane_num=1 ;;
        "pro2") to_pane_num=2 ;;
        "pro3") to_pane_num=3 ;;
        *) log_error "無効なロール: $to_role"; return 1 ;;
    esac
    
    local team_cap=$(capitalize_team "$team")
    local from_role_cap=$(capitalize_role "$from_role")
    local to_role_cap=$(capitalize_role "$to_role")
    log_info "[${team_cap} ${from_role_cap} → ${to_role_cap}] $message"
    
    # メッセージファイルに記録
    local msg_file="$WORKSPACE/.team-messages/${team}-${from_role}-to-${to_role}.msg"
    mkdir -p "$(dirname "$msg_file")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${team_cap} ${from_role_cap} → ${to_role_cap}: $message" >> "$msg_file"
    
    # tmuxペインに送信
    send_to_pane "$SESSION_NAME" "$window_name.$to_pane_num" "$message"
}

# タスク配分の記録
record_task_assignment() {
    local team="$1"
    local member_role="$2"
    local task="$3"
    local deadline="$4"
    
    local task_file="$WORKSPACE/.team-tasks/${team}-${member_role}-tasks.json"
    mkdir -p "$(dirname "$task_file")"
    
    # JSONフォーマットでタスクを記録
    local task_entry=$(cat << EOF
{
  "id": "$(date +%s)_${team}_${member_role}",
  "team": "$team",
  "assignee": "$member_role",
  "task": "$task",
  "deadline": "$deadline",
  "assigned_at": "$(date -Iseconds)",
  "status": "assigned"
}
EOF
)
    
    # 既存のタスクファイルに追加
    if [ -f "$task_file" ]; then
        echo ",$task_entry" >> "$task_file"
    else
        echo "[$task_entry" > "$task_file"
    fi
}

# 進捗報告の記録
record_progress_report() {
    local team="$1"
    local member_role="$2"
    local task_id="$3"
    local status="$4"  # in_progress, completed, blocked
    local notes="$5"
    
    local progress_file="$WORKSPACE/.team-progress/${team}-progress.json"
    mkdir -p "$(dirname "$progress_file")"
    
    # JSONフォーマットで進捗を記録
    local progress_entry=$(cat << EOF
{
  "task_id": "$task_id",
  "team": "$team",
  "reporter": "$member_role",
  "status": "$status",
  "notes": "$notes",
  "reported_at": "$(date -Iseconds)"
}
EOF
)
    
    # 既存の進捗ファイルに追加
    if [ -f "$progress_file" ]; then
        echo ",$progress_entry" >> "$progress_file"
    else
        echo "[$progress_entry" > "$progress_file"
    fi
}

# チーム状態のサマリー生成
generate_team_summary() {
    local team="$1"
    local summary_file="$WORKSPACE/.team-summaries/${team}-summary.md"
    mkdir -p "$(dirname "$summary_file")"
    
    cat > "$summary_file" << EOF
# $(capitalize_team "$team") Team Summary - $(date '+%Y-%m-%d %H:%M')

## チーム構成
- Boss: タスク管理・進捗監視中
- Pro1: 専門分野のタスク遂行中
- Pro2: 専門分野のタスク遂行中
- Pro3: 専門分野のタスク遂行中

## アクティブタスク
$(grep -l '"status": "assigned"' "$WORKSPACE/.team-tasks/${team}-"*.json 2>/dev/null | wc -l) 件

## 完了タスク
$(grep -l '"status": "completed"' "$WORKSPACE/.team-progress/${team}-"*.json 2>/dev/null | wc -l) 件

## ブロック中のタスク
$(grep -l '"status": "blocked"' "$WORKSPACE/.team-progress/${team}-"*.json 2>/dev/null | wc -l) 件

## 最近のコミュニケーション
$(tail -5 "$WORKSPACE/.team-messages/${team}-"*.msg 2>/dev/null || echo "なし")
EOF
    
    echo "$summary_file"
}

# Boss間のメッセージ送信
boss_to_boss() {
    local from_team="$1"
    local to_team="$2"
    local message="$3"
    local to_window_name=$(get_team_window_name "$to_team")
    
    local from_team_cap=$(capitalize_team "$from_team")
    local to_team_cap=$(capitalize_team "$to_team")
    log_info "[${from_team_cap} Boss → ${to_team_cap} Boss] $message"
    
    # メッセージファイルに記録
    local msg_file="$WORKSPACE/.team-messages/${from_team}-boss-to-${to_team}-boss.msg"
    mkdir -p "$(dirname "$msg_file")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${from_team_cap} Boss → ${to_team_cap} Boss: $message" >> "$msg_file"
    
    # Bossペインに送信（ペイン0）
    send_to_pane "$SESSION_NAME" "$to_window_name.0" "[${from_team_cap} Boss より] $message"
}

# 異なるチーム間のメンバー同士のメッセージ送信
cross_team_member_communication() {
    local from_team="$1"
    local from_role="$2"
    local to_team="$3"
    local to_role="$4"
    local message="$5"
    
    local to_window_name=$(get_team_window_name "$to_team")
    
    # roleからペイン番号を取得
    local to_pane_num
    case "$to_role" in
        "boss") to_pane_num=0 ;;
        "pro1") to_pane_num=1 ;;
        "pro2") to_pane_num=2 ;;
        "pro3") to_pane_num=3 ;;
        *) log_error "無効なロール: $to_role"; return 1 ;;
    esac
    
    local from_team_cap=$(capitalize_team "$from_team")
    local from_role_cap=$(capitalize_role "$from_role")
    local to_team_cap=$(capitalize_team "$to_team")
    local to_role_cap=$(capitalize_role "$to_role")
    
    log_info "[${from_team_cap} ${from_role_cap} → ${to_team_cap} ${to_role_cap}] $message"
    
    # メッセージファイルに記録
    local msg_file="$WORKSPACE/.team-messages/cross-team-${from_team}-${from_role}-to-${to_team}-${to_role}.msg"
    mkdir -p "$(dirname "$msg_file")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${from_team_cap} ${from_role_cap} → ${to_team_cap} ${to_role_cap}: $message" >> "$msg_file"
    
    # tmuxペインに送信
    send_to_pane "$SESSION_NAME" "$to_window_name.$to_pane_num" "[${from_team_cap} ${from_role_cap} より] $message"
}

# Master会議の開催（全Bossを招集）
master_meeting() {
    local topic="$1"
    log_info "[Master会議] トピック: $topic"
    
    # 全Bossに会議通知を送信
    for team in "${TEAMS[@]}"; do
        master_to_boss "$team" "【Master会議】$topic について議論します。ご参加ください。"
    done
    
    # 会議記録ファイルを作成
    local meeting_file="$WORKSPACE/.team-meetings/master-meeting-$(date +%Y%m%d-%H%M%S).md"
    mkdir -p "$(dirname "$meeting_file")"
    cat > "$meeting_file" << EOF
# Master会議 - $(date '+%Y-%m-%d %H:%M')

## トピック
$topic

## 参加者
- Master
$(for team in "${TEAMS[@]}"; do echo "- ${team^} Boss"; done)

## 議事録
（ここに会議内容を記録）

EOF
    
    log_success "Master会議を開始しました: $meeting_file"
}

# Boss会議の開催（特定のBoss同士）
boss_meeting() {
    local teams=("$@")
    local topic="${teams[-1]}"
    unset teams[-1]
    
    log_info "[Boss会議] 参加者: ${teams[*]}, トピック: $topic"
    
    # 参加Bossに会議通知を送信
    for team in "${teams[@]}"; do
        local window_name=$(get_team_window_name "$team")
        send_to_pane "$SESSION_NAME" "$window_name.0" "【Boss会議】$topic について他のBossと議論します。"
    done
    
    # 会議記録ファイルを作成
    local meeting_file="$WORKSPACE/.team-meetings/boss-meeting-$(date +%Y%m%d-%H%M%S).md"
    mkdir -p "$(dirname "$meeting_file")"
    cat > "$meeting_file" << EOF
# Boss会議 - $(date '+%Y-%m-%d %H:%M')

## トピック
$topic

## 参加者
$(for team in "${teams[@]}"; do echo "- ${team^} Boss"; done)

## 議事録
（ここに会議内容を記録）

EOF
    
    log_success "Boss会議を開始しました: $meeting_file"
}

# 全体ブロードキャスト（Master → 全員）
master_broadcast() {
    local message="$1"
    log_info "[Masterブロードキャスト] $message"
    
    # Masterから全チームの全メンバーに送信
    send_to_pane "$SESSION_NAME" "Master.0" "[全体通知] $message"
    
    for team in "${TEAMS[@]}"; do
        local window_name=$(get_team_window_name "$team")
        for i in {0..3}; do
            send_to_pane "$SESSION_NAME" "$window_name.$i" "[Masterより全体通知] $message"
        done
    done
    
    log_success "全体ブロードキャストを送信しました"
}