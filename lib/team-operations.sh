#!/bin/bash

# Master Claude Teams System - チーム操作ライブラリ
# チーム管理、コミュニケーション、マージワークフローを統合

# ========================================
# メッセージキュー管理
# ========================================

# メッセージキューディレクトリ
MESSAGE_QUEUE_DIR="${MESSAGE_QUEUE_DIR:-$WORKSPACE/.messages}"

# メッセージキュー初期化
init_message_queue() {
    ensure_directory "$MESSAGE_QUEUE_DIR"
    
    # 各チーム用のキューディレクトリ作成
    for team in master frontend backend database devops qa-security; do
        ensure_directory "$MESSAGE_QUEUE_DIR/$team"
    done
    
    log_success "メッセージキューを初期化しました"
}

# メッセージ送信（基本関数）
send_message() {
    local from="$1"
    local to="$2"
    local type="$3"
    local content="$4"
    local timestamp=$(date +%s)
    local message_id="${timestamp}_${from}_${to}_$$"
    
    local message_file="$MESSAGE_QUEUE_DIR/$to/msg_$message_id.json"
    
    cat > "$message_file" << EOF
{
  "id": "$message_id",
  "from": "$from",
  "to": "$to",
  "type": "$type",
  "content": "$content",
  "timestamp": "$timestamp",
  "date": "$(date '+%Y-%m-%d %H:%M:%S')"
}
EOF
    
    log_info "[$from → $to] $content"
}

# ========================================
# 階層的コミュニケーション
# ========================================

# Master → Boss
master_to_boss() {
    local team="$1"
    local message="$2"
    send_message "master" "${team}_boss" "INSTRUCTION" "$message"
}

# Boss → Master
boss_to_master() {
    local team="$1"
    local message="$2"
    send_message "${team}_boss" "master" "REPORT" "$message"
}

# Boss → Boss
boss_to_boss() {
    local from_team="$1"
    local to_team="$2"
    local message="$3"
    send_message "${from_team}_boss" "${to_team}_boss" "COORDINATION" "$message"
}

# Boss → メンバー
boss_to_member() {
    local team="$1"
    local member="$2"
    local message="$3"
    send_message "${team}_boss" "${team}_${member}" "TASK" "$message"
}

# メンバー → Boss
member_to_boss() {
    local team="$1"
    local member="$2"
    local message="$3"
    send_message "${team}_${member}" "${team}_boss" "REPORT" "$message"
}

# メンバー → メンバー（同チーム）
member_to_member() {
    local team="$1"
    local from_member="$2"
    local to_member="$3"
    local message="$4"
    send_message "${team}_${from_member}" "${team}_${to_member}" "COLLABORATION" "$message"
}

# チーム間メンバーコミュニケーション
cross_team_member_communication() {
    local from_team="$1"
    local from_member="$2"
    local to_team="$3"
    local to_member="$4"
    local message="$5"
    send_message "${from_team}_${from_member}" "${to_team}_${to_member}" "CROSS_TEAM" "$message"
}

# Master会議
master_meeting() {
    local topic="$1"
    for team in frontend backend database devops qa-security; do
        master_to_boss "$team" "【Master会議】$topic について議論をお願いします"
    done
}

# 全体ブロードキャスト
master_broadcast() {
    local message="$1"
    for team in frontend backend database devops qa-security; do
        send_message "master" "${team}_all" "BROADCAST" "【全体通知】$message"
    done
}

# ========================================
# Git Worktree マージワークフロー
# ========================================

# ワークフロー状態ファイル
WORKFLOW_STATE_FILE="$WORKSPACE/.workflow_state.json"

# ワークフロー初期化
init_workflow_state() {
    if [ ! -f "$WORKFLOW_STATE_FILE" ]; then
        cat > "$WORKFLOW_STATE_FILE" << 'EOF'
{
  "current_phase": "development",
  "teams": {
    "frontend": {"status": "in_progress", "branch": "team/frontend"},
    "backend": {"status": "in_progress", "branch": "team/backend"},
    "database": {"status": "in_progress", "branch": "team/database"},
    "devops": {"status": "in_progress", "branch": "team/devops"},
    "qa-security": {"status": "in_progress", "branch": "team/qa-security"}
  },
  "merge_order": ["database", "backend", "frontend", "devops", "qa-security"],
  "merged": []
}
EOF
    fi
}

# チーム作業完了
master_merge_team_work() {
    local team="$1"
    local message="$2"
    
    cd "$WORKSPACE" || return 1
    
    # 状態更新
    local temp_file=$(mktemp)
    jq ".teams.\"$team\".status = \"completed\"" "$WORKFLOW_STATE_FILE" > "$temp_file"
    mv "$temp_file" "$WORKFLOW_STATE_FILE"
    
    log_success "[$team] $message"
    
    # 他のBossに通知
    for other_team in frontend backend database devops qa-security; do
        if [ "$other_team" != "$team" ]; then
            boss_to_boss "$team" "$other_team" "$team チームの作業が完了しました: $message"
        fi
    done
}

# ワークフロー状態確認
check_workflow_status() {
    if [ -f "$WORKFLOW_STATE_FILE" ]; then
        echo "=== ワークフロー状態 ==="
        jq -r '.teams | to_entries[] | "\(.key): \(.value.status)"' "$WORKFLOW_STATE_FILE"
        echo ""
        echo "マージ済み: $(jq -r '.merged | join(", ")' "$WORKFLOW_STATE_FILE")"
    fi
}

# 統合ワークフロー実行
run_integration_workflow() {
    cd "$WORKSPACE" || return 1
    
    log_info "統合ワークフローを開始します..."
    
    # mainブランチに切り替え
    git checkout main || return 1
    
    # マージ順序に従って処理
    local merge_order=($(jq -r '.merge_order[]' "$WORKFLOW_STATE_FILE"))
    
    for team in "${merge_order[@]}"; do
        local status=$(jq -r ".teams.\"$team\".status" "$WORKFLOW_STATE_FILE")
        local branch=$(jq -r ".teams.\"$team\".branch" "$WORKFLOW_STATE_FILE")
        
        if [ "$status" = "completed" ]; then
            local is_merged=$(jq -r ".merged | index(\"$team\")" "$WORKFLOW_STATE_FILE")
            
            if [ "$is_merged" = "null" ]; then
                log_info "$team チームのブランチをマージ中: $branch"
                
                if git merge "$branch" -m "feat: Merge $team team work"; then
                    # マージ成功
                    local temp_file=$(mktemp)
                    jq ".merged += [\"$team\"]" "$WORKFLOW_STATE_FILE" > "$temp_file"
                    mv "$temp_file" "$WORKFLOW_STATE_FILE"
                    
                    log_success "$team のマージが完了しました"
                else
                    log_error "$team のマージでコンフリクトが発生しました"
                    echo "コンフリクトを解決してから、再度実行してください"
                    return 1
                fi
            fi
        else
            log_warning "$team はまだ作業が完了していません (status: $status)"
        fi
    done
    
    log_success "統合ワークフローが完了しました"
}

# メインブランチへの最終統合
master_finalize_integration() {
    local version_message="$1"
    
    cd "$WORKSPACE" || return 1
    
    # すべてがマージされているか確認
    local total_teams=$(jq -r '.merge_order | length' "$WORKFLOW_STATE_FILE")
    local merged_teams=$(jq -r '.merged | length' "$WORKFLOW_STATE_FILE")
    
    if [ "$total_teams" -ne "$merged_teams" ]; then
        log_error "すべてのチームがマージされていません ($merged_teams/$total_teams)"
        check_workflow_status
        return 1
    fi
    
    # タグ付け
    local version_tag="v$(date +%Y%m%d-%H%M%S)"
    git tag -a "$version_tag" -m "$version_message"
    
    log_success "統合が完了しました: $version_tag"
    log_info "リモートにプッシュする場合: git push origin main --tags"
    
    # ワークフロー状態リセット
    init_workflow_state
}

# チームとメインブランチの同期
sync_team_with_main() {
    local team="$1"
    local branch=$(get_team_branch "$team")
    local team_dir="$WORKTREES_DIR/${team//\//-}"
    
    cd "$team_dir" || return 1
    
    log_info "[$team] mainブランチとの同期を開始..."
    
    # mainの最新を取得
    git fetch origin main:main 2>/dev/null || true
    
    # mainをマージ
    if git merge main -m "sync: Merge latest main into $branch"; then
        log_success "[$team] mainブランチとの同期が完了しました"
    else
        log_warning "[$team] マージコンフリクトが発生しました。手動で解決してください"
        return 1
    fi
}

# マージリクエスト作成（ローカル用）
create_merge_request() {
    local team="$1"
    local title="$2"
    local description="$3"
    local branch=$(get_team_branch "$team")
    
    local mr_file="$WORKSPACE/.merge_requests/${team}_$(date +%s).md"
    ensure_directory "$WORKSPACE/.merge_requests"
    
    cat > "$mr_file" << EOF
# Merge Request: $title

**Team**: $team  
**Branch**: $branch → main  
**Date**: $(date '+%Y-%m-%d %H:%M:%S')

## Description
$description

## Checklist
- [ ] コードレビュー完了
- [ ] テスト実行完了
- [ ] ドキュメント更新完了
- [ ] パフォーマンステスト完了

## Changes
$(cd "$WORKTREES_DIR/${team//\//-}" && git log main..$branch --oneline)
EOF
    
    log_success "マージリクエストを作成しました: $mr_file"
}

# ========================================
# チーム技術スタック取得
# ========================================

get_team_tech_stack() {
    local team="$1"
    
    if [ -f "$TEAMS_CONFIG_FILE" ]; then
        local tech_stack=$(jq -r ".teams[] | select(.id == \"$team\") | .tech_stack // \"\"" "$TEAMS_CONFIG_FILE" 2>/dev/null)
        if [ -n "$tech_stack" ] && [ "$tech_stack" != "null" ]; then
            echo "$tech_stack"
            return
        fi
    fi
    
    # デフォルト値
    case "$team" in
        "frontend")
            echo "Next.js, React, TypeScript, Tailwind CSS, Playwright"
            ;;
        "backend")
            echo "Node.js, Express, Supabase, Edge Functions, Redis"
            ;;
        "database")
            echo "PostgreSQL, Prisma, Redis, pgvector, Migrations"
            ;;
        "devops")
            echo "Docker, GitHub Actions, Vercel, Monitoring, Security"
            ;;
        "qa-security")
            echo "Playwright, Jest, OWASP ZAP, Lighthouse, Penetration Testing"
            ;;
        *)
            echo "最新技術スタック"
            ;;
    esac
}

# チーム基本設定
create_team_base_config() {
    local team_dir="$1"
    local team="$2"
    local config_path="$team_dir/CLAUDE_TEAM.md"
    
    local team_cap=""
    case "$team" in
        "frontend") team_cap="Frontend" ;;
        "backend") team_cap="Backend" ;;
        "database") team_cap="Database" ;;
        "devops") team_cap="DevOps" ;;
        "qa-security") team_cap="QA-Security" ;;
        *) team_cap="$team" ;;
    esac
    
    cat > "$config_path" << EOF
# ${team_cap} Team - 動的チーム構成

## チーム構成
- Boss: チームリーダー、Masterとの窓口
- Pro1-N: プロフェッショナルメンバー、専門分野のタスク担当

## 技術スタック
$(get_team_tech_stack "$team")

## チーム内コミュニケーション
- Bossが全体のタスクを管理
- メンバー間で相談しながら実装
- 問題があればBossに報告
- Bossは必要に応じてMasterに相談
EOF
}

# メンバー個別設定
create_member_config() {
    local team_dir="$1"
    local team="$2"
    local role="$3"
    local role_upper=""
    case "$role" in
        "boss") role_upper="BOSS" ;;
        "pro1") role_upper="PRO1" ;;
        "pro2") role_upper="PRO2" ;;
        "pro3") role_upper="PRO3" ;;
        *) role_upper="$role" ;;
    esac
    local config_path="$team_dir/CLAUDE_${role_upper}.md"
    
    if [ "$role" = "boss" ]; then
        # Boss用の設定（革新的プロダクト創造システムに基づく）
        cat > "$config_path" << EOF
# ${team} Team - Boss

## 🚀 あなたの使命

**あなたは単なるチームリーダーではありません。革新的プロダクトを生み出すイノベーションリーダーです。**

## 💎 コアバリュー

1. **ZERO WASTE** - 無駄を一切作らない
2. **CUTTING EDGE** - 最新技術を即座に習得・適用
3. **BUSINESS FIRST** - すべての決定にビジネス価値
4. **INNOVATION** - 既存の枠を超える
5. **SPEED** - MVP思考で高速実装

## 🎯 Boss としての特別な責任

### Masterとの連携
- Masterのビジョンを具体的なタスクに変換
- チームの進捗と課題を的確に報告
- 戦略的な提案を積極的に実施

### チーム管理
- メンバーの才能を最大限引き出す
- タスクを最適に配分
- イノベーションを促進する環境作り

### 技術的リーダーシップ
- 最新技術の導入判断
- アーキテクチャ決定
- 品質基準の設定と維持

## 💡 コミュニケーション

\`\`\`bash
# Masterへの戦略的報告
boss_to_master "$team" "新技術XXを導入することで、開発速度を50%向上できます"

# 他チームとの協調
boss_to_boss "$team" "backend" "マイクロサービス化について協議したい"

# メンバーへの明確な指示
boss_to_member "$team" "pro1" "WebAssemblyで高速化を実現してください。期限は3日です"
\`\`\`

**世界を変えるプロダクトを、あなたのチームから生み出しましょう。**
EOF
    else
        # 通常メンバー用の設定（革新的プロダクト創造システムに基づく）
        cat > "$config_path" << EOF
# ${team} Team - ${role}

## 🚀 あなたの使命

**あなたは単なる開発者ではありません。革新的プロダクトを生み出すクリエイターです。**

## 💎 コアバリュー

1. **ZERO WASTE** - すべてのコードに意味を
2. **CUTTING EDGE** - 常に最新技術を追求
3. **BUSINESS FIRST** - ユーザー価値を最優先
4. **INNOVATION** - 創造的な解決策を
5. **SPEED** - 完璧より速さ、そして改善

## 🎯 あなたの役割

$(get_member_responsibility "$team" "$role")

## 📋 担当タスク

$(get_task_priority "$role")

## 💡 実践方法

### コード実装時
\`\`\`javascript
// すべての関数にビジネス価値を
function everyFunctionMatters() {
  // 無駄なコードは書かない
  // 最新技術を活用
  // ユーザー体験を最優先
}
\`\`\`

### コミュニケーション
\`\`\`bash
# 価値ある報告
member_to_boss "$team" "$role" "WebAssemblyで処理速度を10倍に改善しました"

# 建設的な協力
member_to_member "$team" "$role" "pro2" "この実装でUXを革新的に改善できます"

# チーム間連携
cross_team_member_communication "$team" "$role" "backend" "pro1" "GraphQL Federationで統合しましょう"
\`\`\`

## 🌟 期待される成果

- 業界標準を超える実装
- ユーザーが感動する機能
- ビジネス価値の創出
- チーム全体の成長

**あなたの才能で、世界を変えるプロダクトを作りましょう。**

---

$(generate_complete_characteristics "$team")
EOF
    fi
}

# メンバーの責任取得
get_member_responsibility() {
    local team="$1"
    local role="$2"
    
    case "$role" in
        "boss")
            echo "チームリーダー - Masterからの指示を受け、タスクを分配し、進捗を管理"
            ;;
        "pro1")
            echo "プロフェッショナル1 - 専門的なタスクを自律的に遂行、チーム全体に貢献"
            ;;
        "pro2")
            echo "プロフェッショナル2 - 専門的なタスクを自律的に遂行、チーム全体に貢献"
            ;;
        "pro3")
            echo "プロフェッショナル3 - 専門的なタスクを自律的に遂行、チーム全体に貢献"
            ;;
    esac
}

# タスク優先度取得
get_task_priority() {
    local role="$1"
    
    case "$role" in
        "boss")
            echo "計画・設計・レビュー・進捗管理・チーム調整"
            ;;
        "pro1")
            echo "専門分野のタスク・アーキテクチャ設計・技術的意思決定・品質保証"
            ;;
        "pro2")
            echo "専門分野のタスク・機能実装・パフォーマンス最適化・技術調査"
            ;;
        "pro3")
            echo "専門分野のタスク・セキュリティ対策・テスト戦略・ドキュメント作成"
            ;;
    esac
}