#!/bin/bash

# チーム管理ライブラリ
# 動的なチーム追加・削除・管理機能

# チーム設定ファイルのパス
TEAMS_CONFIG_FILE="$WORKSPACE/.teams/teams-config.json"
TEAMS_MEMBERS_DIR="$WORKSPACE/.teams/members"

# チーム設定の初期化
init_teams_config() {
    mkdir -p "$WORKSPACE/.teams/members"
    
    if [ ! -f "$TEAMS_CONFIG_FILE" ]; then
        cat > "$TEAMS_CONFIG_FILE" << 'EOF'
{
  "teams": [
    {
      "id": "frontend",
      "name": "Frontend",
      "description": "UI/UX開発チーム",
      "tech_stack": "Next.js, React, TypeScript, Tailwind CSS",
      "member_count": 4,
      "branch": "team/frontend",
      "active": true
    },
    {
      "id": "backend",
      "name": "Backend",
      "description": "API/サーバー開発チーム",
      "tech_stack": "Node.js, Express, Supabase, Edge Functions",
      "member_count": 4,
      "branch": "team/backend",
      "active": true
    },
    {
      "id": "database",
      "name": "Database",
      "description": "データベース設計・最適化チーム",
      "tech_stack": "PostgreSQL, Prisma, Redis, pgvector",
      "member_count": 4,
      "branch": "team/database",
      "active": true
    },
    {
      "id": "devops",
      "name": "DevOps",
      "description": "インフラ・CI/CDチーム",
      "tech_stack": "Docker, GitHub Actions, Vercel, Monitoring",
      "member_count": 4,
      "branch": "team/devops",
      "active": true
    },
    {
      "id": "qa-security",
      "name": "QA/Security",
      "description": "品質保証・セキュリティチーム",
      "tech_stack": "Playwright, Jest, OWASP ZAP, Lighthouse",
      "member_count": 4,
      "branch": "team/qa-security",
      "active": true
    }
  ],
  "total_members": 21,
  "master_count": 1,
  "created_at": "$(date -Iseconds)",
  "updated_at": "$(date -Iseconds)"
}
EOF
    fi
}

# 新しいチームを追加
add_new_team() {
    local team_id="$1"
    local team_name="$2"
    local description="$3"
    local tech_stack="$4"
    local member_count="${5:-4}"  # デフォルト4人
    
    # チームIDの検証
    if [[ ! "$team_id" =~ ^[a-z0-9-]+$ ]]; then
        log_error "チームIDは小文字英数字とハイフンのみ使用可能です"
        return 1
    fi
    
    # 既存チームの確認
    if jq -e ".teams[] | select(.id == \"$team_id\")" "$TEAMS_CONFIG_FILE" > /dev/null 2>&1; then
        log_error "チーム '$team_id' は既に存在します"
        return 1
    fi
    
    # 新しいチームのJSON
    local new_team=$(cat << EOF
{
  "id": "$team_id",
  "name": "$team_name",
  "description": "$description",
  "tech_stack": "$tech_stack",
  "member_count": $member_count,
  "branch": "team/$team_id",
  "active": true
}
EOF
)
    
    # チーム設定を更新
    local updated_config=$(jq ".teams += [$new_team] | .total_members += $member_count | .updated_at = \"$(date -Iseconds)\"" "$TEAMS_CONFIG_FILE")
    echo "$updated_config" > "$TEAMS_CONFIG_FILE"
    
    # チームのディレクトリ構造を作成
    local team_dir="$WORKTREES_DIR/$team_id"
    mkdir -p "$team_dir"
    mkdir -p "$TEAMS_MEMBERS_DIR/$team_id"
    
    # Git worktreeの作成
    cd "$WORKSPACE"
    git worktree add "$team_dir" -b "team/$team_id" || {
        log_error "worktreeの作成に失敗しました: $team_id"
        return 1
    }
    
    # チーム設定ファイルを作成
    create_team_base_config "$team_dir" "$team_id"
    
    # メンバー設定ファイルを作成
    for role in boss senior mid junior; do
        create_member_config "$team_dir" "$team_id" "$role"
    done
    
    log_success "チーム '$team_name' を追加しました（ID: $team_id, メンバー: $member_count人）"
    
    # tmuxウィンドウの追加が必要な場合の指示
    echo ""
    echo "📝 次のステップ:"
    echo "1. tmuxセッションで新しいウィンドウを作成:"
    echo "   tmux new-window -t $SESSION_NAME -n \"Team-${team_name}\" -c \"$team_dir\""
    echo ""
    echo "2. 4ペインに分割:"
    echo "   tmux split-window -h -p 50"
    echo "   tmux split-window -v -p 50 -t 0"
    echo "   tmux split-window -v -p 50 -t 2"
    echo ""
    echo "3. 各ペインでClaude Codeを起動"
    
    return 0
}

# チームを削除
remove_team() {
    local team_id="$1"
    
    # チームの存在確認
    if ! jq -e ".teams[] | select(.id == \"$team_id\")" "$TEAMS_CONFIG_FILE" > /dev/null 2>&1; then
        log_error "チーム '$team_id' が見つかりません"
        return 1
    fi
    
    # チームのメンバー数を取得
    local member_count=$(jq -r ".teams[] | select(.id == \"$team_id\") | .member_count" "$TEAMS_CONFIG_FILE")
    
    # チーム設定を更新（非アクティブ化）
    local updated_config=$(jq "(.teams[] | select(.id == \"$team_id\") | .active) = false | .total_members -= $member_count | .updated_at = \"$(date -Iseconds)\"" "$TEAMS_CONFIG_FILE")
    echo "$updated_config" > "$TEAMS_CONFIG_FILE"
    
    # Git worktreeの削除
    local team_dir="$WORKTREES_DIR/$team_id"
    if [ -d "$team_dir" ]; then
        git worktree remove "$team_dir" --force
    fi
    
    log_success "チーム '$team_id' を削除しました"
    
    echo ""
    echo "📝 tmuxウィンドウを手動で閉じてください:"
    echo "   tmux kill-window -t $SESSION_NAME:Team-$team_id"
    
    return 0
}

# アクティブなチーム一覧を表示
list_active_teams() {
    echo "🏢 アクティブなチーム一覧:"
    echo ""
    
    jq -r '.teams[] | select(.active == true) | "  - \(.name) (\(.id)): \(.member_count)人 - \(.description)"' "$TEAMS_CONFIG_FILE"
    
    echo ""
    echo "📊 統計:"
    local active_teams=$(jq '[.teams[] | select(.active == true)] | length' "$TEAMS_CONFIG_FILE")
    local total_members=$(jq '.total_members' "$TEAMS_CONFIG_FILE")
    echo "  - アクティブチーム数: $active_teams"
    echo "  - 総メンバー数: $total_members人（Master含む）"
}

# チームの詳細情報を表示
show_team_details() {
    local team_id="$1"
    
    # チームの存在確認
    if ! jq -e ".teams[] | select(.id == \"$team_id\")" "$TEAMS_CONFIG_FILE" > /dev/null 2>&1; then
        log_error "チーム '$team_id' が見つかりません"
        return 1
    fi
    
    echo "📋 チーム詳細情報:"
    jq -r ".teams[] | select(.id == \"$team_id\")" "$TEAMS_CONFIG_FILE" | jq .
}

# チームのメンバー構成を変更
update_team_members() {
    local team_id="$1"
    local new_count="$2"
    
    # チームの存在確認
    if ! jq -e ".teams[] | select(.id == \"$team_id\")" "$TEAMS_CONFIG_FILE" > /dev/null 2>&1; then
        log_error "チーム '$team_id' が見つかりません"
        return 1
    fi
    
    # 現在のメンバー数を取得
    local current_count=$(jq -r ".teams[] | select(.id == \"$team_id\") | .member_count" "$TEAMS_CONFIG_FILE")
    local diff=$((new_count - current_count))
    
    # チーム設定を更新
    local updated_config=$(jq "(.teams[] | select(.id == \"$team_id\") | .member_count) = $new_count | .total_members += $diff | .updated_at = \"$(date -Iseconds)\"" "$TEAMS_CONFIG_FILE")
    echo "$updated_config" > "$TEAMS_CONFIG_FILE"
    
    log_success "チーム '$team_id' のメンバー数を $current_count人 から $new_count人 に変更しました"
}

# チームの技術スタックを更新
update_team_tech_stack() {
    local team_id="$1"
    local new_tech_stack="$2"
    
    # チームの存在確認
    if ! jq -e ".teams[] | select(.id == \"$team_id\")" "$TEAMS_CONFIG_FILE" > /dev/null 2>&1; then
        log_error "チーム '$team_id' が見つかりません"
        return 1
    fi
    
    # チーム設定を更新
    local updated_config=$(jq "(.teams[] | select(.id == \"$team_id\") | .tech_stack) = \"$new_tech_stack\" | .updated_at = \"$(date -Iseconds)\"" "$TEAMS_CONFIG_FILE")
    echo "$updated_config" > "$TEAMS_CONFIG_FILE"
    
    log_success "チーム '$team_id' の技術スタックを更新しました"
}

# 動的なtmuxセッション再構築
rebuild_tmux_session() {
    log_info "アクティブなチームに基づいてtmuxセッションを再構築中..."
    
    # 既存セッションを終了
    tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true
    
    # 新しいセッションを作成（Master）
    tmux new-session -d -s "$SESSION_NAME" -n "Master" -c "$WORKSPACE"
    tmux set-option -t "$SESSION_NAME" -g mouse on
    
    # アクティブなチームごとにウィンドウを作成
    jq -c '.teams[] | select(.active == true)' "$TEAMS_CONFIG_FILE" | while read -r team_json; do
        local team_id=$(echo "$team_json" | jq -r '.id')
        local team_name=$(echo "$team_json" | jq -r '.name')
        local member_count=$(echo "$team_json" | jq -r '.member_count // 4')
        local team_dir="$WORKTREES_DIR/$team_id"
        
        # ウィンドウ名をシンプルに（スペースを除去）
        local window_name="Team-${team_name// /-}"
        
        # ウィンドウを作成
        tmux new-window -t "$SESSION_NAME" -n "$window_name" -c "$team_dir"
        
        # メンバー数に応じてペインを分割
        case $member_count in
            1)
                # 1人の場合は分割なし
                ;;
            2)
                # 2人の場合は縦に2分割
                tmux split-window -h -p 50 -t "$SESSION_NAME:$window_name.0"
                ;;
            3)
                # 3人の場合は3分割
                tmux split-window -h -p 66 -t "$SESSION_NAME:$window_name.0"
                tmux split-window -h -p 50 -t "$SESSION_NAME:$window_name.1"
                ;;
            4)
                # 4人の場合は2x2グリッド
                if command -v xpanes >/dev/null 2>&1; then
                    tmux send-keys -t "$SESSION_NAME:$window_name" "xpanes -d -e -c 'cd $team_dir && {}' 'echo Boss' 'echo Pro1' 'echo Pro2' 'echo Pro3'" Enter
                else
                    tmux split-window -h -p 50 -t "$SESSION_NAME:$window_name.0"
                    tmux split-window -v -p 50 -t "$SESSION_NAME:$window_name.0"
                    tmux split-window -v -p 50 -t "$SESSION_NAME:$window_name.2"
                fi
                ;;
            5|6)
                # 5-6人の場合は3x2グリッド
                tmux split-window -h -p 50 -t "$SESSION_NAME:$window_name.0"
                tmux split-window -v -p 66 -t "$SESSION_NAME:$window_name.0"
                tmux split-window -v -p 50 -t "$SESSION_NAME:$window_name.1"
                tmux split-window -v -p 66 -t "$SESSION_NAME:$window_name.3"
                if [ $member_count -eq 6 ]; then
                    tmux split-window -v -p 50 -t "$SESSION_NAME:$window_name.4"
                fi
                ;;
            *)
                # それ以上の場合はtiledレイアウトを使用
                for ((i=1; i<$member_count; i++)); do
                    tmux split-window -t "$SESSION_NAME:$window_name"
                done
                tmux select-layout -t "$SESSION_NAME:$window_name" tiled
                ;;
        esac
    done
    
    # Masterウィンドウに戻る
    tmux select-window -t "$SESSION_NAME:Master"
    
    log_success "tmuxセッションを再構築しました"
    
    # チーム構成サマリーを表示
    echo ""
    echo "📊 チーム構成:"
    echo "  Window 0: Master (1人)"
    local window_num=1
    jq -r '.teams[] | select(.active == true) | "\(.name) (\(.member_count // 4)人)"' "$TEAMS_CONFIG_FILE" | while read -r team_info; do
        echo "  Window $window_num: $team_info"
        ((window_num++))
    done
}