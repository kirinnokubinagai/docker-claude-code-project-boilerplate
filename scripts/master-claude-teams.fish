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
set -g TEAMS_CONFIG_FILE $WORKSPACE/config/teams.json

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
    
    # セッション作成確認
    if not tmux has-session -t $SESSION_NAME 2>/dev/null
        log_error "セッションの作成に失敗しました"
        return 1
    end
    
    # 最初のペインはMaster（既に存在）
    log_success "Master用ペイン作成完了"
    
    # worktreeディレクトリを作成
    mkdir -p $WORKSPACE/worktrees
    
    # 各チームのペインを作成
    set -l pane_index 1
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
    
    # 各ペインでClaude Codeを起動
    log_info "各ペインでClaude Codeを起動中..."
    # 実際のペイン数を再度取得（tmuxのインデックスが0から始まることを考慮）
    set -l actual_panes (tmux list-panes -t $SESSION_NAME 2>/dev/null | wc -l | string trim)
    if test -n "$actual_panes" -a "$actual_panes" -gt 0
        for i in (seq 0 (math $actual_panes - 1))
            tmux send-keys -t $SESSION_NAME.$i 'claude --dangerously-skip-permissions' Enter
            sleep 0.5
        end
    else
        # フォールバック
        for i in (seq 0 (math $final_panes - 1))
            tmux send-keys -t $SESSION_NAME.$i 'claude --dangerously-skip-permissions' Enter
            sleep 0.5
        end
    end
    
    log_success "全てのClaude Codeを起動しました"
    
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