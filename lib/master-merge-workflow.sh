#!/bin/bash

# Master Merge Workflow - Masterが各チームの成果をマージして配布

# ライブラリをロード
source "$SCRIPT_DIR/lib/common-lib.sh"
source "$SCRIPT_DIR/lib/hierarchical-communication.sh"

# メインブランチの設定
MAIN_BRANCH="${MAIN_BRANCH:-main}"
INTEGRATION_BRANCH="integration/master"

# Masterによるブランチマージ
master_merge_team_work() {
    local team="$1"
    local merge_message="$2"
    
    log_info "[Master] ${team} チームの成果をマージ中..."
    
    cd "$WORKSPACE" || return 1
    
    # インテグレーションブランチに切り替え
    git checkout "$INTEGRATION_BRANCH" 2>/dev/null || {
        # インテグレーションブランチが存在しない場合は作成
        git checkout -b "$INTEGRATION_BRANCH" "$MAIN_BRANCH"
    }
    
    # 最新のmainを取り込む
    git merge "$MAIN_BRANCH" --no-edit
    
    # チームブランチをマージ
    local team_branch="team/$team"
    if git show-ref --verify --quiet "refs/heads/$team_branch"; then
        log_info "ブランチ $team_branch をマージ中..."
        
        # マージコミットメッセージ
        local full_message="[Master Merge] ${team} チームの成果を統合

$merge_message

統合者: Master Architect
チーム: ${team}
日時: $(date '+%Y-%m-%d %H:%M:%S')"
        
        # マージ実行
        if git merge "$team_branch" -m "$full_message"; then
            log_success "${team} チームの成果をマージしました"
            
            # 各チームに通知
            master_broadcast "【統合完了】${team} チームの成果をインテグレーションブランチにマージしました"
            
            # マージ記録を作成
            record_merge_history "$team" "$merge_message"
        else
            log_error "マージ中にコンフリクトが発生しました"
            
            # コンフリクト解決の指示
            echo ""
            echo "📝 コンフリクト解決手順:"
            echo "1. コンフリクトを解決してください"
            echo "2. git add <解決したファイル>"
            echo "3. git commit"
            echo ""
            
            # 関係チームに通知
            master_to_boss "$team" "マージコンフリクトが発生しました。確認をお願いします。"
            
            return 1
        fi
    else
        log_warning "ブランチ $team_branch が見つかりません"
        return 1
    fi
}

# 統合ブランチをメインにマージ
master_finalize_integration() {
    local release_notes="$1"
    
    log_info "[Master] 統合ブランチをメインブランチにマージ中..."
    
    cd "$WORKSPACE" || return 1
    
    # メインブランチに切り替え
    git checkout "$MAIN_BRANCH"
    
    # 統合ブランチをマージ
    local merge_message="[Master Release] 統合された変更をリリース

$release_notes

承認者: Master Architect
統合ブランチ: $INTEGRATION_BRANCH
リリース日時: $(date '+%Y-%m-%d %H:%M:%S')"
    
    if git merge "$INTEGRATION_BRANCH" -m "$merge_message" --no-ff; then
        log_success "統合ブランチをメインブランチにマージしました"
        
        # 全チームに通知
        master_broadcast "【リリース完了】新しいバージョンがメインブランチにマージされました。各チーム、最新の変更を取り込んでください。"
        
        # リリースタグを作成
        local version_tag="v$(date +%Y%m%d-%H%M%S)"
        git tag -a "$version_tag" -m "$release_notes"
        
        log_success "リリースタグを作成しました: $version_tag"
        
        # 各チームに更新指示
        for team in "${TEAMS[@]}"; do
            master_to_boss "$team" "最新のメインブランチを取り込んでください。タグ: $version_tag"
        done
        
        return 0
    else
        log_error "メインブランチへのマージに失敗しました"
        return 1
    fi
}

# 各チームが最新の変更を取り込む
team_sync_with_main() {
    local team="$1"
    local team_dir="$WORKTREES_DIR/$team"
    
    log_info "[$team] 最新のメインブランチを取り込み中..."
    
    cd "$team_dir" || return 1
    
    # 現在の作業を保存
    git stash push -m "Auto-stash before sync with main"
    
    # メインブランチの最新を取得
    git fetch origin "$MAIN_BRANCH"
    
    # チームブランチにメインをマージ
    if git merge "origin/$MAIN_BRANCH" -m "[$team] Sync with main branch"; then
        log_success "最新のメインブランチを取り込みました"
        
        # Bossに通知
        boss_to_master "$team" "最新のメインブランチを取り込みました"
        
        # スタッシュを戻す
        git stash pop 2>/dev/null || true
        
        return 0
    else
        log_error "マージ中にコンフリクトが発生しました"
        
        # Masterに報告
        boss_to_master "$team" "メインブランチとのマージでコンフリクトが発生しました。サポートが必要です。"
        
        return 1
    fi
}

# マージ履歴の記録
record_merge_history() {
    local team="$1"
    local message="$2"
    local history_file="$WORKSPACE/.merge-history/$(date +%Y%m).md"
    
    mkdir -p "$WORKSPACE/.merge-history"
    
    # 履歴に追記
    cat >> "$history_file" << EOF

## $(date '+%Y-%m-%d %H:%M:%S') - $team チーム
$message

統合者: Master Architect
ブランチ: team/$team → $INTEGRATION_BRANCH

---
EOF
    
    log_info "マージ履歴を記録しました: $history_file"
}

# ワークフロー状態の確認
check_workflow_status() {
    log_info "[Master] 各チームのワークフロー状態を確認中..."
    
    echo ""
    echo "📊 チーム別ブランチ状態:"
    echo ""
    
    for team in "${TEAMS[@]}"; do
        local team_branch="team/$team"
        local team_dir="$WORKTREES_DIR/$team"
        
        echo "[$team チーム]"
        
        if [ -d "$team_dir" ]; then
            cd "$team_dir"
            
            # 最後のコミット情報
            local last_commit=$(git log -1 --pretty=format:"%h - %s (%cr)" 2>/dev/null || echo "コミットなし")
            echo "  最終コミット: $last_commit"
            
            # メインブランチとの差分
            local behind=$(git rev-list --count HEAD..origin/$MAIN_BRANCH 2>/dev/null || echo "0")
            local ahead=$(git rev-list --count origin/$MAIN_BRANCH..HEAD 2>/dev/null || echo "0")
            
            echo "  メインブランチとの差分: $ahead コミット先行, $behind コミット遅延"
            
            # 未コミットの変更
            local changes=$(git status --porcelain | wc -l)
            if [ "$changes" -gt 0 ]; then
                echo "  ⚠️  未コミットの変更: $changes ファイル"
            fi
        else
            echo "  ❌ ワークツリーが見つかりません"
        fi
        
        echo ""
    done
    
    cd "$WORKSPACE"
}

# Master専用: 統合ワークフローの実行
run_integration_workflow() {
    log_info "[Master] 統合ワークフローを開始します"
    
    # 1. 各チームの状態を確認
    check_workflow_status
    
    # 2. 統合するチームを選択
    echo "統合するチームを選択してください (スペース区切りで複数可):"
    echo "例: frontend backend database"
    echo "利用可能: ${TEAMS[*]}"
    read -r selected_teams
    
    # 3. 各チームの成果をマージ
    for team in $selected_teams; do
        echo ""
        echo "[$team チーム]"
        echo "マージメッセージを入力してください:"
        read -r merge_message
        
        master_merge_team_work "$team" "$merge_message"
    done
    
    # 4. 統合ブランチの確認
    echo ""
    log_info "統合ブランチの状態:"
    git checkout "$INTEGRATION_BRANCH"
    git log --oneline -5
    
    # 5. メインブランチへのマージ確認
    echo ""
    read -p "メインブランチにマージしますか？ (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "リリースノートを入力してください:"
        read -r release_notes
        
        master_finalize_integration "$release_notes"
    else
        log_info "統合ブランチで作業を継続します"
    fi
}

# チーム専用: メインブランチとの同期
sync_team_with_main() {
    local team="$1"
    
    if [ -z "$team" ]; then
        log_error "チームIDを指定してください"
        return 1
    fi
    
    # Boss権限の確認（実際の実装では認証が必要）
    log_info "[$team Boss] メインブランチとの同期を開始します"
    
    # 同期実行
    team_sync_with_main "$team"
    
    # チームメンバーに通知
    boss_to_member "$team" "pro1" "最新のメインブランチを取り込みました。確認してください。"
    boss_to_member "$team" "pro2" "最新のメインブランチを取り込みました。確認してください。"
    boss_to_member "$team" "pro3" "最新のメインブランチを取り込みました。確認してください。"
}

# プルリクエスト風のレビュープロセス
create_merge_request() {
    local team="$1"
    local title="$2"
    local description="$3"
    
    local request_file="$WORKSPACE/.merge-requests/$(date +%Y%m%d-%H%M%S)-$team.md"
    mkdir -p "$WORKSPACE/.merge-requests"
    
    cat > "$request_file" << EOF
# マージリクエスト: $title

**チーム**: $team
**作成日時**: $(date '+%Y-%m-%d %H:%M:%S')
**ブランチ**: team/$team → $INTEGRATION_BRANCH

## 説明
$description

## 変更内容
$(cd "$WORKTREES_DIR/$team" && git log --oneline "$MAIN_BRANCH"..HEAD)

## チェックリスト
- [ ] テストが通過している
- [ ] ドキュメントが更新されている
- [ ] コードレビューが完了している
- [ ] セキュリティチェックが完了している

## レビュアー
- [ ] Master Architect
- [ ] QA/Security Boss
- [ ] 関連チームBoss

## コメント
(レビューコメントをここに記載)

---
EOF
    
    log_success "マージリクエストを作成しました: $request_file"
    
    # Masterに通知
    boss_to_master "$team" "マージリクエストを作成しました: $title"
    
    # 関連チームに通知
    boss_to_boss "$team" "qa-security" "マージリクエストのレビューをお願いします: $title"
}