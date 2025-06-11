#!/bin/bash

# Team Management Library - チーム管理用関数集

# チーム設定ファイルのパス
TEAMS_CONFIG_FILE="${WORKSPACE}/config/teams.json"

# チーム設定の初期化
init_teams_config() {
    if [ ! -f "$TEAMS_CONFIG_FILE" ]; then
        cat > "$TEAMS_CONFIG_FILE" << 'EOF'
{
  "project_name": "Master Claude Teams",
  "teams": []
}
EOF
        log_info "teams.jsonを初期化しました"
    fi
}

# チームの詳細を表示
show_team_details() {
    local team_id="$1"
    
    if [ -f "$TEAMS_CONFIG_FILE" ]; then
        jq -r ".teams[] | select(.id == \"$team_id\")" "$TEAMS_CONFIG_FILE"
    fi
}

# アクティブなチーム一覧を表示
list_active_teams() {
    if [ -f "$TEAMS_CONFIG_FILE" ]; then
        echo "=== アクティブなチーム ==="
        jq -r '.teams[] | select(.active == true) | "  - \(.name) (\(.id)): \(.member_count // 4)人"' "$TEAMS_CONFIG_FILE"
    fi
}

# 新しいチームを追加
add_new_team() {
    local team_id="$1"
    local team_name="$2"
    local team_desc="$3"
    local tech_stack="$4"
    local member_count="${5:-4}"
    
    # teams.jsonに追加
    local temp_file=$(mktemp)
    jq ".teams += [{
        \"id\": \"$team_id\",
        \"name\": \"$team_name\",
        \"description\": \"$team_desc\",
        \"tech_stack\": \"$tech_stack\",
        \"member_count\": $member_count,
        \"branch\": \"team/$team_id\",
        \"active\": true
    }]" "$TEAMS_CONFIG_FILE" > "$temp_file"
    
    mv "$temp_file" "$TEAMS_CONFIG_FILE"
    
    # worktreeを作成
    cd "$WORKSPACE"
    local branch="team/$team_id"
    
    if ! git show-ref --verify --quiet "refs/heads/$branch"; then
        git worktree add "$WORKTREES_DIR/$team_id" -b "$branch"
    else
        git worktree add "$WORKTREES_DIR/$team_id" "$branch"
    fi
    
    log_success "チーム '$team_name' を追加しました"
}

# チームブランチを取得
get_team_branch() {
    local team="$1"
    echo "team/$team"
}

# チームウィンドウ名を取得
get_team_window_name() {
    local team="$1"
    case "$team" in
        "frontend") echo "Team-Frontend" ;;
        "backend") echo "Team-Backend" ;;
        "database") echo "Team-Database" ;;
        "devops") echo "Team-DevOps" ;;
        "qa-security") echo "Team-QA-Security" ;;
        *) echo "Team-${team^}" ;;
    esac
}

# メンバーペイン名を取得
get_member_pane_name() {
    local team="$1"
    local role="$2"
    echo "${team}-${role}"
}