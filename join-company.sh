#!/bin/bash

# join-company.sh - チームテンプレートから新しいチームを追加

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ライブラリをロード
source "$SCRIPT_DIR/lib/common-lib.sh"
source "$SCRIPT_DIR/lib/team-management.sh"

# 使用方法を表示
usage() {
    cat << EOF
使用方法: $0 <team-template.json>

チームテンプレートからMaster Claude Teams Systemに新しいチームを追加します。

引数:
  team-template.json    チーム定義のJSONファイル

例:
  $0 team-templates/frontend-team.json
  $0 team-templates/new-team.json

利用可能なテンプレート:
$(ls -1 "$SCRIPT_DIR/team-templates/"*.json 2>/dev/null | xargs -n1 basename || echo "  テンプレートが見つかりません")
EOF
    exit 1
}

# 引数チェック
if [ $# -ne 1 ]; then
    usage
fi

TEMPLATE_FILE="$1"

# テンプレートファイルの存在確認
if [ ! -f "$TEMPLATE_FILE" ]; then
    log_error "テンプレートファイルが見つかりません: $TEMPLATE_FILE"
    
    # 相対パスの場合、team-templatesディレクトリも確認
    if [ ! -f "$SCRIPT_DIR/team-templates/$TEMPLATE_FILE" ]; then
        exit 1
    else
        TEMPLATE_FILE="$SCRIPT_DIR/team-templates/$TEMPLATE_FILE"
        log_info "テンプレートファイルを使用: $TEMPLATE_FILE"
    fi
fi

# JSONファイルの検証
if ! jq empty "$TEMPLATE_FILE" 2>/dev/null; then
    log_error "無効なJSONファイルです: $TEMPLATE_FILE"
    exit 1
fi

# チーム情報を読み込み
TEAM_ID=$(jq -r '.id' "$TEMPLATE_FILE")
TEAM_NAME=$(jq -r '.name' "$TEMPLATE_FILE")
TEAM_DESC=$(jq -r '.description' "$TEMPLATE_FILE")
TECH_STACK=$(jq -r '.tech_stack' "$TEMPLATE_FILE")
MEMBER_COUNT=$(jq -r '.member_count // 4' "$TEMPLATE_FILE")
BRANCH=$(jq -r '.branch' "$TEMPLATE_FILE")

# 必須フィールドの確認
if [ -z "$TEAM_ID" ] || [ "$TEAM_ID" = "null" ] || [ "$TEAM_ID" = "your-team-id" ]; then
    log_error "チームIDが設定されていません。JSONファイルの 'id' フィールドを設定してください。"
    exit 1
fi

if [ -z "$TEAM_NAME" ] || [ "$TEAM_NAME" = "null" ] || [ "$TEAM_NAME" = "Your Team Name" ]; then
    log_error "チーム名が設定されていません。JSONファイルの 'name' フィールドを設定してください。"
    exit 1
fi

# 環境の確認
if [ ! -d "$WORKSPACE" ]; then
    log_error "ワークスペースが見つかりません。プロジェクトディレクトリ内で実行してください。"
    exit 1
fi

# Git リポジトリの確認
cd "$WORKSPACE"
if [ ! -d ".git" ]; then
    log_error "Gitリポジトリが初期化されていません。"
    exit 1
fi

# チーム設定の初期化
init_teams_config

# 既存チームの確認
if jq -e ".teams[] | select(.id == \"$TEAM_ID\")" "$TEAMS_CONFIG_FILE" > /dev/null 2>&1; then
    log_error "チーム '$TEAM_ID' は既に存在します。"
    
    # チームの詳細を表示
    show_team_details "$TEAM_ID"
    
    echo ""
    read -p "このチームを再アクティブ化しますか？ (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # チームを再アクティブ化
        jq "(.teams[] | select(.id == \"$TEAM_ID\") | .active) = true" "$TEAMS_CONFIG_FILE" > "$TEAMS_CONFIG_FILE.tmp"
        mv "$TEAMS_CONFIG_FILE.tmp" "$TEAMS_CONFIG_FILE"
        log_success "チーム '$TEAM_NAME' を再アクティブ化しました"
    fi
    exit 0
fi

# 確認
echo ""
log_info "以下のチームを追加します:"
echo "  ID: $TEAM_ID"
echo "  名前: $TEAM_NAME"
echo "  説明: $TEAM_DESC"
echo "  技術: $TECH_STACK"
echo "  人数: $MEMBER_COUNT"
echo "  ブランチ: $BRANCH"
echo ""

# ロール情報を表示
echo "チームメンバー構成:"
echo "  - Boss: $(jq -r '.roles.boss.title' "$TEMPLATE_FILE")"
echo "    責任: $(jq -r '.roles.boss.responsibilities' "$TEMPLATE_FILE")"
echo "  - Pro1: $(jq -r '.roles.pro1.title' "$TEMPLATE_FILE")"
echo "    責任: $(jq -r '.roles.pro1.responsibilities' "$TEMPLATE_FILE")"
echo "  - Pro2: $(jq -r '.roles.pro2.title' "$TEMPLATE_FILE")"
echo "    責任: $(jq -r '.roles.pro2.responsibilities' "$TEMPLATE_FILE")"
echo "  - Pro3: $(jq -r '.roles.pro3.title' "$TEMPLATE_FILE")"
echo "    責任: $(jq -r '.roles.pro3.responsibilities' "$TEMPLATE_FILE")"
echo ""

# 初期タスクを表示
echo "初期タスク:"
jq -r '.initial_tasks[]' "$TEMPLATE_FILE" | while read -r task; do
    echo "  - $task"
done
echo ""

read -p "続行しますか？ (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_warning "キャンセルされました"
    exit 0
fi

# チームを追加
log_info "チームを追加中..."
add_new_team "$TEAM_ID" "$TEAM_NAME" "$TEAM_DESC" "$TECH_STACK" "$MEMBER_COUNT"

# チーム固有の設定ファイルを作成
TEAM_DIR="$WORKTREES_DIR/$TEAM_ID"
if [ -d "$TEAM_DIR" ]; then
    # ロール情報をファイルに保存
    cp "$TEMPLATE_FILE" "$TEAM_DIR/team-definition.json"
    
    # 初期タスクをTODOリストとして作成
    TASKS_FILE="$TEAM_DIR/initial-tasks.md"
    cat > "$TASKS_FILE" << EOF
# $TEAM_NAME - 初期タスク

## TODO
EOF
    
    jq -r '.initial_tasks[]' "$TEMPLATE_FILE" | while read -r task; do
        echo "- [ ] $task" >> "$TASKS_FILE"
    done
    
    echo "" >> "$TASKS_FILE"
    echo "## 完了したタスク" >> "$TASKS_FILE"
    echo "(完了したタスクはここに移動してください)" >> "$TASKS_FILE"
    
    # 各メンバーの詳細設定を作成
    for role in boss pro1 pro2 pro3; do
        ROLE_TITLE=$(jq -r ".roles.$role.title" "$TEMPLATE_FILE")
        ROLE_RESP=$(jq -r ".roles.$role.responsibilities" "$TEMPLATE_FILE")
        
        # 既存のCLAUDE_*.mdファイルに役割情報を追記
        ROLE_FILE="$TEAM_DIR/CLAUDE_${role^^}.md"
        if [ -f "$ROLE_FILE" ]; then
            # 役割情報を追記
            cat >> "$ROLE_FILE" << EOF

## 🎯 専門分野
**$ROLE_TITLE**

### 責任範囲
$ROLE_RESP

### 初期タスク
$(jq -r '.initial_tasks[]' "$TEMPLATE_FILE" | head -2 | sed 's/^/- /')
EOF
        fi
    done
    
    log_success "チーム固有の設定ファイルを作成しました"
fi

# アクティブなチーム一覧を表示
echo ""
list_active_teams

# tmuxセッションへの追加方法を案内
echo ""
log_info "チームの追加が完了しました！"
echo ""
echo "📝 tmuxセッションに追加するには:"
echo ""
echo "1. 既存のtmuxセッションに追加:"
echo "   tmux new-window -t claude-teams -n \"Team-$TEAM_NAME\" -c \"$TEAM_DIR\""
echo "   tmux split-window -h -p 50"
echo "   tmux split-window -v -p 50 -t 0"
echo "   tmux split-window -v -p 50 -t 2"
echo ""
echo "2. または、セッション全体を再構築:"
echo "   ./master-claude-teams.sh"
echo ""
echo "✨ 新しいチーム '$TEAM_NAME' へようこそ！"