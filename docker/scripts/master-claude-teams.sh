#!/bin/bash

# Master Claude Teams System - 修正版
# シンプルで確実な動的チーム管理システム

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# 設定
SESSION_NAME="claude-teams"
WORKSPACE="/workspace"
TEAMS_CONFIG_FILE="$WORKSPACE/docker/config/teams.json"
TASKS_CONFIG_FILE="$WORKSPACE/docker/config/team-tasks.json"

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

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# ペインインデックスを取得
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

# タスクをペインに送信
send_task_to_pane() {
    local pane_idx=$1
    local task=$2
    
    # タスクを送信（ウィンドウ番号は1）
    tmux send-keys -t "$SESSION_NAME:1.$pane_idx" "$task" Enter
    
    return 0
}

# タスクを割り当て
assign_tasks() {
    if [ ! -f "$TASKS_CONFIG_FILE" ]; then
        log_warning "team-tasks.json が見つかりません。タスク割り当てをスキップします"
        return 0
    fi
    
    log_info "タスクを各Claude Codeに割り当て中..."
    
    # Claude Codeの起動完了を待つ（プロンプトが表示されるまで）
    log_info "Claude Codeの起動を待機中..."
    sleep 15  # Claude Codeが完全に起動するまで十分に待つ
    
    # Master Claudeに役割とタスクを送信
    local master_prompt=$(jq -r '.master.initial_prompt // ""' "$TASKS_CONFIG_FILE" 2>/dev/null)
    if [ -n "$master_prompt" ]; then
        send_task_to_pane 1 "$master_prompt"
        log_success "Master: タスク送信完了"
    fi
    
    # 各チームのタスクを送信
    local teams=$(jq -r '.teams[] | select(.active == true) | .id' "$TEAMS_CONFIG_FILE" 2>/dev/null)
    
    for team in $teams; do
        local team_name=$(jq -r ".teams[] | select(.id == \"$team\") | .name" "$TEAMS_CONFIG_FILE" 2>/dev/null)
        local member_count=$(jq -r ".teams[] | select(.id == \"$team\") | .member_count // 1" "$TEAMS_CONFIG_FILE" 2>/dev/null)
        
        # 各チームメンバーへのタスク送信はMasterが行うため、ここではスキップ
        log_info "$team_name チーム: Masterからの指示を待機中..."
    done
    
    log_success "全てのタスク割り当てが完了しました"
}

# メイン処理
main() {
    echo ""
    echo -e "${CYAN}${BOLD}======================================${NC}"
    echo -e "${CYAN}${BOLD} Master Claude Teams System v5.0${NC}"
    echo -e "${CYAN}${BOLD} シンプル版${NC}"
    echo -e "${CYAN}${BOLD}======================================${NC}"
    echo ""
    
    # tmuxサーバー起動
    tmux start-server 2>/dev/null
    
    # 既存セッションをクリーンアップ
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_info "既存のセッションをクリーンアップ中..."
        tmux kill-session -t "$SESSION_NAME"
    fi
    
    # 総メンバー数を計算
    local total_members=1  # Master分
    if [ -f "$TEAMS_CONFIG_FILE" ]; then
        local teams=$(jq -r '.teams[] | select(.active == true) | .id' "$TEAMS_CONFIG_FILE" 2>/dev/null)
        for team in $teams; do
            local member_count=$(jq -r ".teams[] | select(.id == \"$team\") | .member_count // 1" "$TEAMS_CONFIG_FILE" 2>/dev/null)
            total_members=$((total_members + member_count))
        done
    fi
    
    log_info "総メンバー数: $total_members 人"
    
    # TMUX環境変数をクリア（ネストを回避）
    unset TMUX
    
    # セッションとウィンドウを作成
    log_info "tmuxセッションを作成中..."
    tmux new-session -d -s "$SESSION_NAME" -n "All-Teams" -c "$WORKSPACE"
    
    # ペインボーダーの設定（グローバルに設定）
    tmux set-option -g pane-border-status top
    tmux set-option -g pane-border-format " #{pane_title} "
    
    # セッション作成確認
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_error "セッションの作成に失敗しました"
        return 1
    fi
    
    # 最初のペインはMaster（既に存在）
    log_success "Master用ペイン作成完了"
    
    # 少し待機してからMasterペインの名前を設定
    sleep 0.5
    tmux select-pane -t "$SESSION_NAME:1.1" -T "Master"
    
    # worktreeディレクトリを作成
    mkdir -p "$WORKSPACE/worktrees"
    
    # 各チームのペインを作成
    local pane_index=2  # Masterが1なので、2から開始
    if [ -f "$TEAMS_CONFIG_FILE" ]; then
        local teams=$(jq -r '.teams[] | select(.active == true) | .id' "$TEAMS_CONFIG_FILE" 2>/dev/null)
        
        for team in $teams; do
            local team_name=$(jq -r ".teams[] | select(.id == \"$team\") | .name" "$TEAMS_CONFIG_FILE" 2>/dev/null)
            local member_count=$(jq -r ".teams[] | select(.id == \"$team\") | .member_count // 1" "$TEAMS_CONFIG_FILE" 2>/dev/null)
            local worktree_path="$WORKSPACE/worktrees/$team"
            
            # worktreeディレクトリを作成
            mkdir -p "$worktree_path"
            
            log_info "チーム: $team_name ($member_count 人)"
            
            for member in $(seq 1 "$member_count"); do
                # シンプルにペインを分割
                local split_result=$(tmux split-window -t "$SESSION_NAME" -c "$worktree_path" 2>&1)
                local split_status=$?
                if [ $split_status -eq 0 ]; then
                    log_success "  → メンバー $member のペイン作成"
                    
                    # ペインの名前を設定（作成直後に設定）
                    sleep 0.2
                    if [ $member -eq 1 ]; then
                        # ボス（部長）
                        tmux select-pane -t "$SESSION_NAME:1.$pane_index" -T "$team_name ボス"
                    else
                        # メンバー
                        tmux select-pane -t "$SESSION_NAME:1.$pane_index" -T "$team_name #$member"
                    fi
                    
                    # 名前設定を確実にするため再度実行
                    sleep 0.1
                    if [ $member -eq 1 ]; then
                        tmux set-option -t "$SESSION_NAME:1.$pane_index" pane-border-format " $team_name ボス "
                    else
                        tmux set-option -t "$SESSION_NAME:1.$pane_index" pane-border-format " $team_name #$member "
                    fi
                    
                    # 3ペイン以上の場合はレイアウトを調整
                    if [ $pane_index -ge 3 ]; then
                        tmux select-layout -t "$SESSION_NAME" tiled 2>/dev/null
                    fi
                else
                    log_error "  → メンバー $member のペイン作成失敗: $split_result"
                fi
                pane_index=$((pane_index + 1))
            done
        done
    fi
    
    # レイアウトを調整
    log_info "レイアウトを調整中..."
    tmux select-layout -t "$SESSION_NAME" tiled
    
    # ペイン数を確認（少し待機してから）
    sleep 1
    local final_panes=$(tmux list-panes -t "$SESSION_NAME" 2>/dev/null | wc -l | tr -d ' ')
    if [ -z "$final_panes" ] || [ "$final_panes" = "0" ]; then
        log_error "ペインの作成に失敗しました"
        # 再度カウント
        final_panes=$pane_index
    fi
    log_success "合計 $final_panes ペインを作成しました"
    
    # 各ペインの名前を再設定（Claude Code起動前に確実に設定）
    log_info "ペイン名を設定中..."
    local pane_idx=1
    tmux select-pane -t "$SESSION_NAME:1.1" -T "Master"
    pane_idx=2
    
    if [ -f "$TEAMS_CONFIG_FILE" ]; then
        local teams=$(jq -r '.teams[] | select(.active == true) | .id' "$TEAMS_CONFIG_FILE" 2>/dev/null)
        
        for team in $teams; do
            local team_name=$(jq -r ".teams[] | select(.id == \"$team\") | .name" "$TEAMS_CONFIG_FILE" 2>/dev/null)
            local member_count=$(jq -r ".teams[] | select(.id == \"$team\") | .member_count // 1" "$TEAMS_CONFIG_FILE" 2>/dev/null)
            
            for member in $(seq 1 "$member_count"); do
                if [ $member -eq 1 ]; then
                    tmux select-pane -t "$SESSION_NAME:1.$pane_idx" -T "$team_name ボス"
                else
                    tmux select-pane -t "$SESSION_NAME:1.$pane_idx" -T "$team_name #$member"
                fi
                pane_idx=$((pane_idx + 1))
            done
        done
    fi
    
    # 各ペインでClaude Codeを起動
    log_info "各ペインでClaude Codeを起動中..."
    # 実際のペイン数を再度取得（tmuxのペインインデックスは1から始まる）
    local actual_panes=$(tmux list-panes -t "$SESSION_NAME" 2>/dev/null | wc -l | tr -d ' ')
    if [ -n "$actual_panes" ] && [ "$actual_panes" -gt 0 ]; then
        for i in $(seq 1 "$actual_panes"); do
            tmux send-keys -t "$SESSION_NAME:1.$i" 'claude --dangerously-skip-permissions' Enter
            sleep 0.5
        done
    else
        # フォールバック
        for i in $(seq 1 "$final_panes"); do
            tmux send-keys -t "$SESSION_NAME:1.$i" 'claude --dangerously-skip-permissions' Enter
            sleep 0.5
        done
    fi
    
    log_success "全てのClaude Codeを起動しました"
    
    # タスクの自動割り当て
    assign_tasks
    
    echo ""
    echo "✅ セットアップ完了！"
    echo ""
    echo "📋 チーム構成："
    echo "  - Master: 1人"
    if [ -f "$TEAMS_CONFIG_FILE" ]; then
        jq -r '.teams[] | select(.active == true) | "  - \(.name): \(.member_count // 1)人"' "$TEAMS_CONFIG_FILE" 2>/dev/null
    fi
    echo ""
    
    # --no-attachオプションの確認
    if [[ " $@ " != *" --no-attach "* ]]; then
        log_info "セッションにアタッチします..."
        sleep 2
        tmux attach-session -t "$SESSION_NAME"
    else
        echo "📍 接続方法："
        echo "   tmux attach -t $SESSION_NAME"
        echo ""
    fi
}

# エントリーポイント
main "$@"