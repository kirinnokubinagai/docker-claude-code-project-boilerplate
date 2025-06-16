#!/bin/bash

# Set pane titles for Claude Teams
# tmuxペインのタイトルを設定するスクリプト

# カラー定義
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 設定
SESSION_NAME="claude-teams"
TEAMS_CONFIG_FILE="/opt/claude-system/config/teams.json"
TEAMS_TEMPLATE_FILE="/opt/claude-system/templates/teams.json.example"

echo -e "${BLUE}[INFO]${NC} ペインタイトルを設定中..."

# Masterペインの設定
tmux select-pane -t "$SESSION_NAME:1.1" -T "Master"

# 各チームのペインを設定
pane_index=2

if [ -f "$TEAMS_CONFIG_FILE" ]; then
    teams=$(jq -r '.teams[] | select(.active == true) | .id' "$TEAMS_CONFIG_FILE" 2>/dev/null)
    
    for team in $teams; do
        team_name=$(jq -r ".teams[] | select(.id == \"$team\") | .name" "$TEAMS_CONFIG_FILE" 2>/dev/null)
        member_count=$(jq -r ".teams[] | select(.id == \"$team\") | .member_count // 1" "$TEAMS_CONFIG_FILE" 2>/dev/null)
        
        for member in $(seq 1 "$member_count"); do
            if [ $member -eq 1 ]; then
                # ボス（部長）
                tmux select-pane -t "$SESSION_NAME:1.$pane_index" -T "$team_name ボス"
            else
                # メンバー
                tmux select-pane -t "$SESSION_NAME:1.$pane_index" -T "$team_name #$member"
            fi
            pane_index=$((pane_index + 1))
        done
    done
fi

echo -e "${GREEN}[SUCCESS]${NC} ペインタイトル設定完了"