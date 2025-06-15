#!/usr/bin/fish

# Master Claude Teams System - 修正版
# シンプルで確実な動的チーム管理システム

# カラー定義
set -g RED (set_color red 2>/dev/null; or echo "")
set -g GREEN (set_color green 2>/dev/null; or echo "")
set -g YELLOW (set_color yellow 2>/dev/null; or echo "")
set -g BLUE (set_color blue 2>/dev/null; or echo "")
set -g CYAN (set_color cyan 2>/dev/null; or echo "")
set -g BOLD (set_color --bold 2>/dev/null; or echo "")
set -g NC (set_color normal 2>/dev/null; or echo "")

# 設定
set -g SESSION_NAME claude-teams
set -g WORKSPACE /workspace
set -g TEAMS_CONFIG_FILE $WORKSPACE/docker/config/teams.json
set -g TASKS_CONFIG_FILE $WORKSPACE/docker/config/team-tasks.json

# ログ関数
function log_info
    printf "%s[INFO]%s %s\n" $BLUE $NC "$argv"
end

function log_success
    printf "%s[SUCCESS]%s %s\n" $GREEN $NC "$argv"
end

function log_error
    printf "%s[ERROR]%s %s\n" $RED $NC "$argv"
end

function log_warning
    printf "%s[WARN]%s %s\n" $YELLOW $NC "$argv"
end

# ペインインデックスを取得
function get_pane_index_for_team
    set -l team_id $argv[1]
    set -l member_index $argv[2]  # 1-based
    
    # 累積インデックスを計算（tmuxのペインは1から始まる）
    set -l pane_idx 1  # Masterペインが1
    
    # teams.jsonから各チームのメンバー数を取得
    set -l teams (jq -r '.teams[] | select(.active == true) | .id' $TEAMS_CONFIG_FILE 2>/dev/null)
    
    for t in $teams
        if test "$t" = "$team_id"
            # 該当チームのメンバーインデックスを追加
            set pane_idx (math $pane_idx + $member_index)
            break
        else
            # このチームのメンバー数を追加
            set -l count (jq -r ".teams[] | select(.id == \"$t\") | .member_count // 1" $TEAMS_CONFIG_FILE 2>/dev/null)
            set pane_idx (math $pane_idx + $count)
        end
    end
    
    echo $pane_idx
end

# タスクをペインに送信
function send_task_to_pane
    set -l pane_idx $argv[1]
    set -l task $argv[2]
    
    # タスクを送信（ウィンドウ番号は1）
    tmux send-keys -t $SESSION_NAME:1.$pane_idx "$task" Enter
    
    return 0
end

# タスクを割り当て
function assign_tasks
    if not test -f $TASKS_CONFIG_FILE
        log_warning "team-tasks.json が見つかりません。タスク割り当てをスキップします"
        return 0
    end
    
    log_info "タスクを各Claude Codeに割り当て中..."
    
    # Claude Codeの起動完了を待つ（プロンプトが表示されるまで）
    log_info "Claude Codeの起動を待機中..."
    sleep 15  # Claude Codeが完全に起動するまで十分に待つ
    
    # Master Claudeに役割とタスクを送信
    set -l master_prompt (jq -r '.master.initial_prompt // ""' $TASKS_CONFIG_FILE 2>/dev/null)
    if test -n "$master_prompt"
        send_task_to_pane 1 "$master_prompt"
        log_success "Master: タスク送信完了"
    end
    
    # 各チームのタスクを送信
    set -l teams (jq -r '.teams[] | select(.active == true) | .id' $TEAMS_CONFIG_FILE 2>/dev/null)
    
    for team in $teams
        set -l team_name (jq -r ".teams[] | select(.id == \"$team\") | .name" $TEAMS_CONFIG_FILE 2>/dev/null)
        set -l member_count (jq -r ".teams[] | select(.id == \"$team\") | .member_count // 1" $TEAMS_CONFIG_FILE 2>/dev/null)
        
        # 各チームメンバーへのタスク送信はMasterが行うため、ここではスキップ
        log_info "$team_name チーム: Masterからの指示を待機中..."
    end
    
    log_success "全てのタスク割り当てが完了しました"
end

# メイン処理
function main
    echo ""
    echo "$CYAN$BOLD======================================$NC"
    echo "$CYAN$BOLD Master Claude Teams System v5.0$NC"
    echo "$CYAN$BOLD シンプル版$NC"
    echo "$CYAN$BOLD======================================$NC"
    echo ""
    
    # tmuxサーバー起動
    tmux start-server 2>/dev/null
    
    # 既存セッションをクリーンアップ
    if tmux has-session -t $SESSION_NAME 2>/dev/null
        log_info "既存のセッションをクリーンアップ中..."
        tmux kill-session -t $SESSION_NAME
    end
    
    # 総メンバー数を計算
    set -l total_members 1  # Master分
    if test -f $TEAMS_CONFIG_FILE
        set -l teams (jq -r '.teams[] | select(.active == true) | .id' $TEAMS_CONFIG_FILE 2>/dev/null)
        for team in $teams
            set -l member_count (jq -r ".teams[] | select(.id == \"$team\") | .member_count // 1" $TEAMS_CONFIG_FILE 2>/dev/null)
            set total_members (math $total_members + $member_count)
        end
    end
    
    log_info "総メンバー数: $total_members 人"
    
    # TMUX環境変数をクリア（ネストを回避）
    set -e TMUX
    
    # セッションとウィンドウを作成
    log_info "tmuxセッションを作成中..."
    tmux new-session -d -s $SESSION_NAME -n "All-Teams" -c $WORKSPACE
    
    # ペインボーダーの設定（グローバルに設定）
    tmux set-option -g pane-border-status top
    tmux set-option -g pane-border-format " #{pane_title} "
    
    # セッション作成確認
    if not tmux has-session -t $SESSION_NAME 2>/dev/null
        log_error "セッションの作成に失敗しました"
        return 1
    end
    
    # 最初のペインはMaster（既に存在）
    log_success "Master用ペイン作成完了"
    
    # 少し待機してからMasterペインの名前を設定
    sleep 0.5
    tmux select-pane -t $SESSION_NAME:1.1 -T "Master"
    
    # worktreeディレクトリを作成
    mkdir -p $WORKSPACE/worktrees
    
    # 各チームのペインを作成
    set -l pane_index 2  # Masterが1なので、2から開始
    if test -f $TEAMS_CONFIG_FILE
        set -l teams (jq -r '.teams[] | select(.active == true) | .id' $TEAMS_CONFIG_FILE 2>/dev/null)
        
        for team in $teams
            set -l team_name (jq -r ".teams[] | select(.id == \"$team\") | .name" $TEAMS_CONFIG_FILE 2>/dev/null)
            set -l member_count (jq -r ".teams[] | select(.id == \"$team\") | .member_count // 1" $TEAMS_CONFIG_FILE 2>/dev/null)
            set -l worktree_path $WORKSPACE/worktrees/$team
            
            # worktreeディレクトリを作成
            mkdir -p $worktree_path
            
            log_info "チーム: $team_name ($member_count 人)"
            
            for member in (seq 1 $member_count)
                # シンプルにペインを分割
                set -l split_result (tmux split-window -t $SESSION_NAME -c $worktree_path 2>&1)
                set -l split_status $status
                if test $split_status -eq 0
                    log_success "  → メンバー $member のペイン作成"
                    
                    # ペインの名前を設定（作成直後に設定）
                    sleep 0.1
                    if test $member -eq 1
                        # ボス（部長）
                        tmux select-pane -t $SESSION_NAME:1.$pane_index -T "$team_name ボス"
                    else
                        # メンバー
                        tmux select-pane -t $SESSION_NAME:1.$pane_index -T "$team_name #$member"
                    end
                    
                    # 3ペイン以上の場合はレイアウトを調整
                    if test $pane_index -ge 3
                        tmux select-layout -t $SESSION_NAME tiled 2>/dev/null
                    end
                else
                    log_error "  → メンバー $member のペイン作成失敗: $split_result"
                end
                set pane_index (math $pane_index + 1)
            end
        end
    end
    
    # レイアウトを調整
    log_info "レイアウトを調整中..."
    tmux select-layout -t $SESSION_NAME tiled
    
    # ペイン数を確認（少し待機してから）
    sleep 1
    set -l final_panes (tmux list-panes -t $SESSION_NAME 2>/dev/null | wc -l | string trim)
    if test -z "$final_panes" -o "$final_panes" = "0"
        log_error "ペインの作成に失敗しました"
        # 再度カウント
        set final_panes $pane_index
    end
    log_success "合計 $final_panes ペインを作成しました"
    
    # 各ペインの名前を再設定（Claude Code起動前に確実に設定）
    log_info "ペイン名を設定中..."
    set -l pane_idx 1
    tmux select-pane -t $SESSION_NAME:1.1 -T "Master"
    set pane_idx 2
    
    if test -f $TEAMS_CONFIG_FILE
        set -l teams (jq -r '.teams[] | select(.active == true) | .id' $TEAMS_CONFIG_FILE 2>/dev/null)
        
        for team in $teams
            set -l team_name (jq -r ".teams[] | select(.id == \"$team\") | .name" $TEAMS_CONFIG_FILE 2>/dev/null)
            set -l member_count (jq -r ".teams[] | select(.id == \"$team\") | .member_count // 1" $TEAMS_CONFIG_FILE 2>/dev/null)
            
            for member in (seq 1 $member_count)
                if test $member -eq 1
                    tmux select-pane -t $SESSION_NAME:1.$pane_idx -T "$team_name ボス"
                else
                    tmux select-pane -t $SESSION_NAME:1.$pane_idx -T "$team_name #$member"
                end
                set pane_idx (math $pane_idx + 1)
            end
        end
    end
    
    # 各ペインでClaude Codeを起動
    log_info "各ペインでClaude Codeを起動中..."
    # 実際のペイン数を再度取得（tmuxのペインインデックスは1から始まる）
    set -l actual_panes (tmux list-panes -t $SESSION_NAME 2>/dev/null | wc -l | string trim)
    if test -n "$actual_panes" -a "$actual_panes" -gt 0
        for i in (seq 1 $actual_panes)
            tmux send-keys -t $SESSION_NAME:1.$i 'claude --dangerously-skip-permissions' Enter
            sleep 0.5
        end
    else
        # フォールバック
        for i in (seq 1 $final_panes)
            tmux send-keys -t $SESSION_NAME:1.$i 'claude --dangerously-skip-permissions' Enter
            sleep 0.5
        end
    end
    
    log_success "全てのClaude Codeを起動しました"
    
    # タスクの自動割り当て
    assign_tasks
    
    echo ""
    echo "✅ セットアップ完了！"
    echo ""
    echo "📋 チーム構成："
    echo "  - Master: 1人"
    if test -f $TEAMS_CONFIG_FILE
        jq -r '.teams[] | select(.active == true) | "  - \(.name): \(.member_count // 1)人"' $TEAMS_CONFIG_FILE 2>/dev/null
    end
    echo ""
    
    # --no-attachオプションの確認
    if not contains -- "--no-attach" $argv
        log_info "セッションにアタッチします..."
        sleep 2
        tmux attach-session -t $SESSION_NAME
    else
        echo "📍 接続方法："
        echo "   tmux attach -t $SESSION_NAME"
        echo ""
    end
end

# エントリーポイント
main $argv