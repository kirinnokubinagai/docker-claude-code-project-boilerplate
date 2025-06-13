#!/usr/bin/fish

# Set pane titles for claude-teams session
# ペインタイトルを手動で設定するスクリプト

set -g SESSION_NAME claude-teams
set -g WORKSPACE /workspace
set -g TEAMS_CONFIG_FILE $WORKSPACE/docker/config/teams.json

# カラー定義
set -g GREEN (set_color green 2>/dev/null; or echo "")
set -g BLUE (set_color blue 2>/dev/null; or echo "")
set -g NC (set_color normal 2>/dev/null; or echo "")

echo "$BLUE[INFO]$NC ペインタイトルを設定中..."

# グローバル設定
tmux set-option -g pane-border-status top
tmux set-option -g pane-border-format " #{pane_title} "

# 各ペインにタイトルを設定
tmux select-pane -t $SESSION_NAME:1.1 -T "Master"

set -l pane_idx 2
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

echo "$GREEN[SUCCESS]$NC ペインタイトル設定完了"

# 現在の設定を表示
echo ""
echo "現在のペイン構成:"
tmux list-panes -t $SESSION_NAME -F "Pane #{pane_index}: #{pane_title}"