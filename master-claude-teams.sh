#!/bin/bash

# Master Claude Teams - 5つのチームを並列管理するシステム
# 旧master-claude.shの機能も統合

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ライブラリと設定をロード
source "$SCRIPT_DIR/lib/claude-teams-lib.sh"
source "$SCRIPT_DIR/lib/team-configs.sh"
source "$SCRIPT_DIR/lib/team-communication.sh"
source "$SCRIPT_DIR/lib/auto-documentation.sh"
source "$SCRIPT_DIR/config/teams.conf"

# クリーンアップ関数
cleanup() {
    log_warning "クリーンアップを実行中..."
    
    # プロセスタイムアウトでクリーンアップを強制終了
    timeout 10 kill_tmux_session "$SESSION_NAME" || {
        log_warning "tmuxセッションのクリーンアップがタイムアウトしました（10秒）"
        # 強制的にtmuxセッションを終了
        tmux kill-server 2>/dev/null || true
    }
    
    log_info "クリーンアップ完了"
}

# worktreeのセットアップ
setup_worktrees() {
    log_info "各チーム用のworktreeを作成中..."
    
    cd "$WORKSPACE" || {
        log_error "ワークスペースディレクトリにアクセスできません: $WORKSPACE"
        return 1
    }
    
    # 既存のworktreeをクリーンアップ
    for team in frontend backend database devops; do
        local branch=$(get_team_branch "$team")
        cleanup_worktree "$WORKSPACE" "$team" "$branch"
    done
    
    # 新しいworktreeを作成
    for team in frontend backend database devops; do
        local branch=$(get_team_branch "$team")
        log_info "worktree作成: $team -> $branch"
        git worktree add "$WORKTREES_DIR/$team" -b "$branch" || {
            log_error "worktreeの作成に失敗しました: $team"
            return 1
        }
    done
    
    log_success "全てのworktreeを作成しました"
}

# tmuxレイアウトを作成
create_tmux_layout() {
    log_info "tmuxセッションを構築中..."
    
    # セッション作成
    tmux new-session -d -s "$SESSION_NAME" -n "Teams" -c "$WORKSPACE"
    
    # レイアウト作成: 左1/3にマスター、右2/3を4分割
    tmux split-window -h -p 67 -c "$(get_pane_dir 1)"
    tmux select-pane -t 1
    tmux split-window -v -p 50 -c "$(get_pane_dir 3)"
    tmux select-pane -t 1
    tmux split-window -h -p 50 -c "$(get_pane_dir 2)"
    tmux select-pane -t 3
    tmux split-window -h -p 50 -c "$(get_pane_dir 4)"
    
    # ペイン名を設定
    for i in {0..4}; do
        tmux select-pane -t $i -T "$(get_pane_name $i)"
    done
    
    log_success "tmuxレイアウトを作成しました"
}

# チーム設定ファイルを作成
create_team_configurations() {
    log_info "各チームの設定ファイルを作成中..."
    
    # Frontend
    create_frontend_config "$WORKTREES_DIR/frontend"
    
    # Backend
    create_backend_config "$WORKTREES_DIR/backend"
    
    # Database
    create_database_config "$WORKTREES_DIR/database"
    
    # DevOps
    create_devops_config "$WORKTREES_DIR/devops"
    
    # Master commands
    create_master_commands "$WORKSPACE"
    
    log_success "全ての設定ファイルを作成しました"
}

# チームを起動
launch_all_teams() {
    log_info "各チームのClaude Codeを起動中..."
    
    # 各ペインでClaude Codeを起動
    for i in {0..4}; do
        send_to_pane "$SESSION_NAME" "Teams.$i" "$CLAUDE_CMD"
        wait_for_process "$CLAUDE_STARTUP_WAIT" "チーム$i の起動待機中"
    done
    
    wait_for_process "$INITIAL_MESSAGE_WAIT" "初期化待機中"
    
    # 初期メッセージを送信
    local -a initial_messages=(
        "私はMaster Architectです。全体設計と各チームの調整を行います。他の4チームと連携してプロジェクトを進めます。要件を教えてください。"
        "私はFrontend Teamです。UI/UX開発を担当します。CLAUDE.mdの設定に従って作業します。定期的に他チームからのメッセージを確認します。"
        "私はDatabase Teamです。DB設計と最適化を担当します。CLAUDE.mdの設定に従って作業します。定期的に他チームからのメッセージを確認します。"
        "私はBackend Teamです。API開発を担当します。CLAUDE.mdの設定に従って作業します。定期的に他チームからのメッセージを確認します。"
        "私はDevOps Teamです。インフラとCI/CDを担当します。CLAUDE.mdの設定に従って作業します。定期的に他チームからのメッセージを確認します。"
    )
    
    for i in {0..4}; do
        send_to_pane "$SESSION_NAME" "Teams.$i" "${initial_messages[$i]}"
    done
    
    log_success "全チームの起動が完了しました"
}

# メイン処理
main() {
    # バナー表示
    show_banner "Master Claude Teams System v3.0" "5チーム並列開発オーケストレーター"
    
    # 依存関係チェック
    check_dependencies tmux claude git || exit 1
    
    # トラップ設定
    setup_trap cleanup
    
    # ディレクトリ作成
    ensure_directory "$WORKTREES_DIR"
    
    # Git初期化
    init_git_repo "$WORKSPACE" || exit 1
    
    # メッセージキューの初期化
    init_message_queue
    
    # ドキュメントシステムの初期化
    init_documentation_system
    
    # 既存セッションのクリーンアップ
    kill_tmux_session "$SESSION_NAME"
    
    # メイン処理の実行
    setup_worktrees || exit 1
    create_tmux_layout || exit 1
    create_team_configurations || exit 1
    launch_all_teams || exit 1
    
    # 使用方法の表示
    log_info "使用方法の詳細は以下を参照してください:"
    echo "  - $WORKSPACE/team-commands.md"
    echo ""
    log_success "全ての準備が完了しました！"
    echo ""
    echo "セッションにアタッチします..."
    wait_for_process 2
    
    # セッションにアタッチ
    tmux attach-session -t "$SESSION_NAME"
}

# エントリーポイント
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi