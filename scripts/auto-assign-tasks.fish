#!/usr/bin/fish

# Auto Assign Tasks to Claude Code Sessions
# teams.jsonとteam-tasks.jsonを使って各Claude Codeにタスクを自動割り当て

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

# 設定ファイルの存在確認
function check_config_files
    if not test -f $TEAMS_CONFIG_FILE
        log_error "teams.json が見つかりません: $TEAMS_CONFIG_FILE"
        return 1
    end
    
    if not test -f $TASKS_CONFIG_FILE
        log_error "team-tasks.json が見つかりません: $TASKS_CONFIG_FILE"
        return 1
    end
    
    return 0
end

# ペインインデックスを取得
function get_pane_index
    set -l team_id $argv[1]
    set -l member_index $argv[2]  # 1-based
    
    # 累積インデックスを計算
    set -l pane_idx 0  # Masterペイン
    
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
    
    # エスケープ処理
    set -l escaped_task (string escape "$task")
    
    # Claude Codeのプロンプトに送信
    # 改行を送信してから、タスクを送信
    tmux send-keys -t $SESSION_NAME.$pane_idx C-c  # 現在の入力をクリア
    sleep 0.2
    tmux send-keys -t $SESSION_NAME.$pane_idx "$task"
    sleep 0.1
    tmux send-keys -t $SESSION_NAME.$pane_idx Enter
    
    return 0
end

# メイン処理
function main
    echo ""
    echo "$CYAN$BOLD======================================$NC"
    echo "$CYAN$BOLD Auto Task Assignment System$NC"
    echo "$CYAN$BOLD======================================$NC"
    echo ""
    
    # 設定ファイルの確認
    if not check_config_files
        return 1
    end
    
    # tmuxセッションの確認
    if not tmux has-session -t $SESSION_NAME 2>/dev/null
        log_error "tmuxセッション '$SESSION_NAME' が見つかりません"
        log_info "先に 'master' コマンドを実行してください"
        return 1
    end
    
    # Master Claudeにタスクを送信
    log_info "Master Claudeにタスクを送信中..."
    set -l master_prompt (jq -r '.master.initial_prompt // ""' $TASKS_CONFIG_FILE 2>/dev/null)
    if test -n "$master_prompt"
        send_task_to_pane 0 "$master_prompt"
        log_success "Master: タスク送信完了"
    end
    
    sleep 1
    
    # 各チームのタスクを送信
    set -l teams (jq -r '.teams[] | select(.active == true) | .id' $TEAMS_CONFIG_FILE 2>/dev/null)
    
    for team in $teams
        set -l team_name (jq -r ".teams[] | select(.id == \"$team\") | .name" $TEAMS_CONFIG_FILE 2>/dev/null)
        set -l member_count (jq -r ".teams[] | select(.id == \"$team\") | .member_count // 1" $TEAMS_CONFIG_FILE 2>/dev/null)
        
        log_info "チーム: $team_name"
        
        # ボス（最初のメンバー）にタスクを送信
        set -l boss_prompt (jq -r ".$team.boss.initial_prompt // \"\"" $TASKS_CONFIG_FILE 2>/dev/null)
        if test -n "$boss_prompt"
            set -l boss_pane_idx (get_pane_index $team 1)
            send_task_to_pane $boss_pane_idx "$boss_prompt"
            log_success "  → $team_name ボス: タスク送信完了"
        end
        
        # メンバータスクを送信（member1, member2等の個別オブジェクトから取得）
        for i in (seq 2 $member_count)
            set -l member_key "member"(math $i - 1)  # member1, member2...
            set -l member_prompt (jq -r ".$team.$member_key.initial_prompt // \"\"" $TASKS_CONFIG_FILE 2>/dev/null)
            
            if test -n "$member_prompt"
                set -l member_pane_idx (get_pane_index $team $i)
                send_task_to_pane $member_pane_idx "$member_prompt"
                log_success "  → メンバー $i: タスク送信完了"
            end
        end
        
        sleep 0.5
    end
    
    echo ""
    log_success "全てのタスク割り当てが完了しました！"
    echo ""
    echo "📋 割り当て結果："
    echo "  - Master: 初期プロンプト送信済み"
    
    for team in $teams
        set -l team_name (jq -r ".teams[] | select(.id == \"$team\") | .name" $TEAMS_CONFIG_FILE 2>/dev/null)
        set -l member_count (jq -r ".teams[] | select(.id == \"$team\") | .member_count // 1" $TEAMS_CONFIG_FILE 2>/dev/null)
        echo "  - $team_name: $member_count 人にタスク送信済み"
    end
    
    echo ""
    echo "💡 ヒント:"
    echo "  - 各Claude Codeがタスクの処理を開始します"
    echo "  - tmux attach -t $SESSION_NAME で進捗を確認できます"
    echo "  - 必要に応じて手動でタスクを追加・修正してください"
end

# エントリーポイント
main $argv