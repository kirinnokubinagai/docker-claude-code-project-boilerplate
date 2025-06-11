#!/bin/bash

# Master Claude Teams - 6つのチームを並列管理するシステム
# 旧master-claude.shの機能も統合

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# WORKSPACE環境変数を明示的に設定（Docker外実行時の対応）
export WORKSPACE="${WORKSPACE:-$SCRIPT_DIR}"

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
    run_with_timeout 10 kill_tmux_session "$SESSION_NAME" || {
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
    
    # Gitリポジトリの状態を確認
    if [ ! -d ".git" ]; then
        log_error "Gitリポジトリが初期化されていません"
        return 1
    fi
    
    if ! git rev-parse HEAD >/dev/null 2>&1; then
        log_error "初期コミットが存在しません"
        return 1
    fi
    
    # 既存のworktreeをクリーンアップ
    for team in frontend backend database devops qa security; do
        local branch=$(get_team_branch "$team")
        cleanup_worktree "$WORKSPACE" "$team" "$branch"
    done
    
    # 新しいworktreeを作成
    for team in frontend backend database devops qa security; do
        local branch=$(get_team_branch "$team")
        log_info "worktree作成: $team -> $branch"
        
        # ブランチが既に存在する場合は、既存のブランチを使用
        if git show-ref --verify --quiet "refs/heads/$branch"; then
            git worktree add "$WORKTREES_DIR/$team" "$branch" || {
                log_error "worktreeの作成に失敗しました: $team (既存ブランチ)"
                return 1
            }
        else
            # 新しいブランチを作成
            git worktree add "$WORKTREES_DIR/$team" -b "$branch" || {
                log_error "worktreeの作成に失敗しました: $team (新規ブランチ)"
                return 1
            }
        fi
    done
    
    log_success "全てのworktreeを作成しました"
}

# tmuxレイアウトを作成
create_tmux_layout() {
    log_info "tmuxセッションを構築中..."
    
    # セッション作成（Masterペイン = ペイン0）
    tmux new-session -d -s "$SESSION_NAME" -n "Teams" -c "$WORKSPACE"
    
    # マウスサポートを有効化（クリックでペイン選択、スクロール可能）
    tmux set-option -t "$SESSION_NAME" -g mouse on
    
    # 6ペイン均等分割レイアウト（2x3グリッド）
    # まず縦に2分割
    tmux split-window -h -p 50
    
    # 左側を3分割
    tmux select-pane -t "$SESSION_NAME:Teams.0"
    tmux split-window -v -p 66 -c "$WORKTREES_DIR/frontend"
    tmux select-pane -t "$SESSION_NAME:Teams.1"
    tmux split-window -v -p 50 -c "$WORKTREES_DIR/backend"
    
    # 右側を3分割
    tmux select-pane -t "$SESSION_NAME:Teams.3"
    tmux split-window -v -p 66 -c "$WORKTREES_DIR/database"
    tmux select-pane -t "$SESSION_NAME:Teams.4"
    tmux split-window -v -p 50 -c "$WORKTREES_DIR/devops"
    
    # 作成されたペインを整理
    # ペイン配置:
    # [0:Master]    [3:Database]
    # [1:Frontend]  [4:DevOps]
    # [2:Backend]   [5:QA/Security]
    
    # QA/Securityのペインは最後に作成
    tmux select-pane -t "$SESSION_NAME:Teams.5"
    cd "$WORKTREES_DIR/qa" 2>/dev/null || cd "$WORKTREES_DIR/security" 2>/dev/null || cd "$WORKSPACE"
    
    # レイアウト確認のためのデバッグ情報
    log_info "tmuxペイン配置 (2x3グリッド):"
    log_info "  0: Master      3: Database"
    log_info "  1: Frontend    4: DevOps"
    log_info "  2: Backend     5: QA/Security"
    
    # ペイン名を設定
    tmux select-pane -t "$SESSION_NAME:Teams.0" -T "Master"
    tmux select-pane -t "$SESSION_NAME:Teams.1" -T "Frontend"
    tmux select-pane -t "$SESSION_NAME:Teams.2" -T "Backend"
    tmux select-pane -t "$SESSION_NAME:Teams.3" -T "Database"
    tmux select-pane -t "$SESSION_NAME:Teams.4" -T "DevOps"
    tmux select-pane -t "$SESSION_NAME:Teams.5" -T "QA/Security"
    
    # 最初のペイン（Master）を選択
    tmux select-pane -t "$SESSION_NAME:Teams.0"
    
    log_success "tmuxレイアウトを作成しました（6ペイン: 2x3グリッド）"
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
    
    # QA
    create_qa_config "$WORKTREES_DIR/qa"
    
    # Security
    create_security_config "$WORKTREES_DIR/security"
    
    # Master commands
    create_master_commands "$WORKSPACE"
    
    log_success "全ての設定ファイルを作成しました"
}

# Claude Code設定を最初に行う
setup_claude_code() {
    log_info "Claude Code設定を実行中..."
    
    # 現在のシェルでClaude Codeを起動して設定
    log_info "MCPサーバーの設定を開始します..."
    
    # 設定確認のプロンプト
    cat << 'EOF'
    
========================================
Claude Code セットアップ
========================================

これからClaude Codeを起動してMCPサーバーの設定を行います。

1. Claude Codeが起動したら、MCPが正しく設定されているか確認してください
2. 必要に応じて追加の設定を行ってください
3. 設定が完了したら "exit" と入力してください

準備ができたらEnterキーを押してください...
EOF
    
    read -p ""
    
    # Claude Codeを対話的に起動
    claude --dangerously-skip-permissions
    
    log_success "Claude Code設定が完了しました"
}

# チームを起動（tmux内で）
launch_all_teams() {
    log_info "各チームのClaude Codeを起動中..."
    
    # 各ペインでClaude Codeを起動
    for i in {0..5}; do
        send_to_pane "$SESSION_NAME" "Teams.$i" "$CLAUDE_CMD"
        wait_for_process "$CLAUDE_STARTUP_WAIT" "チーム$i の起動待機中"
    done
    
    wait_for_process "$INITIAL_MESSAGE_WAIT" "初期化待機中"
    
    # 初期メッセージを送信（実際のペイン番号順）
    local -a initial_messages=(
        "私はMaster Architectです。全体設計と各チームの調整を行います。他の5チームと連携してプロジェクトを進めます。要件を教えてください。"
        "私はFrontend Teamです。UI/UX開発を担当します。CLAUDE.mdの設定に従って作業します。定期的に他チームからのメッセージを確認します。"
        "私はBackend Teamです。API開発を担当します。CLAUDE.mdの設定に従って作業します。定期的に他チームからのメッセージを確認します。"
        "私はDatabase Teamです。DB設計と最適化を担当します。CLAUDE.mdの設定に従って作業します。定期的に他チームからのメッセージを確認します。"
        "私はDevOps Teamです。インフラとCI/CDを担当します。CLAUDE.mdの設定に従って作業します。定期的に他チームからのメッセージを確認します。"
        "私はQA/Security Teamです。品質保証とセキュリティを担当します。CLAUDE.mdの設定に従って作業します。定期的に他チームからのメッセージを確認します。"
    )
    
    for i in {0..5}; do
        send_to_pane "$SESSION_NAME" "Teams.$i" "${initial_messages[$i]}"
    done
    
    log_success "全チームの起動が完了しました"
}

# メイン処理
main() {
    # バナー表示
    show_banner "Master Claude Teams System v3.0" "6チーム並列開発オーケストレーター"
    
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
    
    # Claude Code設定を最初に実行
    setup_claude_code
    
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