#!/bin/bash

# Master Claude Teams System - 動的チーム管理
# Master + 可変数のチームとメンバーで柔軟な大規模チーム管理

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# WORKSPACE環境変数を明示的に設定（Docker外実行時の対応）
export WORKSPACE="${WORKSPACE:-$SCRIPT_DIR}"

# ライブラリをロード
source "$SCRIPT_DIR/lib/core-lib.sh"
source "$SCRIPT_DIR/lib/team-operations.sh"
source "$SCRIPT_DIR/lib/universal-characteristics.sh"
source "$SCRIPT_DIR/config/teams.conf"
source "$SCRIPT_DIR/config/team-structure.conf"

# クリーンアップ関数
cleanup() {
    log_warning "クリーンアップを実行中..."
    
    # プロセスタイムアウトでクリーンアップを強制終了
    run_with_timeout 10 kill_tmux_session "$SESSION_NAME" || {
        log_warning "tmuxセッションのクリーンアップがタイムアウトしました（10秒）"
        tmux kill-server 2>/dev/null || true
    }
    
    log_info "クリーンアップ完了"
}

# worktreeのセットアップ（既存の関数を使用）
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
    
    # チーム設定ファイルがある場合のみチームのworktreeを作成
    if [ -f "$TEAMS_CONFIG_FILE" ]; then
        # アクティブなチームのみ処理
        local active_teams=($(jq -r '.teams[] | select(.active == true) | .id' "$TEAMS_CONFIG_FILE"))
        
        if [ ${#active_teams[@]} -eq 0 ]; then
            log_info "アクティブなチームがありません。Masterのみで起動します。"
            # TEAMSを空にして、デフォルトチームが作成されないようにする
            TEAMS=()
            return 0
        fi
        
        # 既存のworktreeをクリーンアップ
        for team in "${active_teams[@]}"; do
            local branch=$(get_team_branch "$team")
            local dir_name="${team//\//-}"  # qa/security -> qa-security
            cleanup_worktree "$WORKSPACE" "$dir_name" "$branch"
        done
        
        # 新しいworktreeを作成
        for team in "${active_teams[@]}"; do
            local branch=$(get_team_branch "$team")
            local dir_name="${team//\//-}"  # qa/security -> qa-security
            log_info "worktree作成: $dir_name -> $branch"
            
            # ブランチが既に存在する場合は、既存のブランチを使用
            if git show-ref --verify --quiet "refs/heads/$branch"; then
                git worktree add "$WORKTREES_DIR/$dir_name" "$branch" || {
                    log_error "worktreeの作成に失敗しました: $dir_name (既存ブランチ)"
                    return 1
                }
            else
                # 新しいブランチを作成
                git worktree add "$WORKTREES_DIR/$dir_name" -b "$branch" || {
                    log_error "worktreeの作成に失敗しました: $dir_name (新規ブランチ)"
                    return 1
                }
            fi
        done
    else
        log_info "チーム設定ファイルがありません。Masterのみで起動します。"
        # TEAMSを空にして、デフォルトチームが作成されないようにする
        TEAMS=()
    fi
    
    log_success "worktreeのセットアップが完了しました"
}

# チームのペインを作成（メンバー数に応じて）
create_team_panes() {
    local window_name="$1"
    local team_dir="$2"
    local member_count="$3"
    
    # メンバー数に応じてレイアウトを選択
    if [ $member_count -gt 1 ]; then
        for ((i=1; i<$member_count; i++)); do
            tmux split-window -t "$SESSION_NAME:$window_name"
        done
        
        # メンバー数が少ない場合は縦に並べる
        if [ $member_count -le 4 ]; then
            tmux select-layout -t "$SESSION_NAME:$window_name" even-vertical
        else
            # 5人以上の場合はtiledレイアウト
            tmux select-layout -t "$SESSION_NAME:$window_name" tiled
        fi
    fi
}

# tmuxレイアウトを作成（動的チーム構成）
create_tmux_layout() {
    # 現在のチーム数と総人数を計算
    local total_members=1  # Master
    if [ -f "$TEAMS_CONFIG_FILE" ]; then
        local active_teams=$(jq '[.teams[] | select(.active == true)] | length' "$TEAMS_CONFIG_FILE")
        local team_members=$(jq '[.teams[] | select(.active == true) | .member_count // 4] | add // 0' "$TEAMS_CONFIG_FILE")
        total_members=$((total_members + team_members))
        log_info "動的チーム構成のtmuxセッションを構築中... (総計${total_members}人)"
    else
        log_info "Masterのみのtmuxセッションを構築中..."
    fi
    
    # メインセッション作成（Masterウィンドウ）
    tmux new-session -d -s "$SESSION_NAME" -n "Master" -c "$WORKSPACE"
    tmux set-option -t "$SESSION_NAME" -g mouse on
    
    # Masterウィンドウは1ペインのみ
    tmux select-pane -t "$SESSION_NAME:Master.0" -T "Master-Architect"
    
    # 各チームのウィンドウを作成
    if [ -f "$TEAMS_CONFIG_FILE" ] && [ "$(jq -r '.teams | length' "$TEAMS_CONFIG_FILE")" -gt 0 ]; then
        # 設定ファイルから動的に読み込む
        jq -c '.teams[] | select(.active == true)' "$TEAMS_CONFIG_FILE" | while read -r team_json; do
            local team=$(echo "$team_json" | jq -r '.id')
            local team_name=$(echo "$team_json" | jq -r '.name')
            local member_count=$(echo "$team_json" | jq -r '.member_count // 4')
            local window_name=$(get_team_window_name "$team")
            local team_dir="$WORKTREES_DIR/${team//\//-}"
            
            log_info "チームウィンドウ作成: $window_name (${member_count}人)"
            
            # 新しいウィンドウを作成
            tmux new-window -t "$SESSION_NAME" -n "$window_name" -c "$team_dir"
            
            # メンバー数に応じてペインを分割
            create_team_panes "$window_name" "$team_dir" "$member_count"
            
            # 各ペインに名前を設定
            local i=0
            local roles=("boss")
            # メンバー数に応じてロールを追加
            for ((j=1; j<$member_count && j<=3; j++)); do
                roles+=("pro$j")
            done
            
            for role in "${roles[@]}"; do
                local pane_name=$(get_member_pane_name "$team" "$role")
                tmux select-pane -t "$SESSION_NAME:$window_name.$i" -T "$pane_name"
                ((i++))
            done
        done
    else
        # デフォルトのチーム設定を使用
        for team in "${TEAMS[@]}"; do
            local window_name=$(get_team_window_name "$team")
            local team_dir="$WORKTREES_DIR/${team//\//-}"
            
            log_info "チームウィンドウ作成: $window_name"
            
            # 新しいウィンドウを作成
            tmux new-window -t "$SESSION_NAME" -n "$window_name" -c "$team_dir"
            
            # 4人チームとして作成
            create_team_panes "$window_name" "$team_dir" 4
            
            # 各ペインに名前を設定
            local i=0
            for role in "${TEAM_ROLES[@]}"; do
                local pane_name=$(get_member_pane_name "$team" "$role")
                tmux select-pane -t "$SESSION_NAME:$window_name.$i" -T "$pane_name"
                ((i++))
            done
        done
    fi
    
    # 最初のウィンドウ（Master）に戻る
    tmux select-window -t "$SESSION_NAME:Master"
    
    log_success "動的チーム構成のtmuxレイアウトを作成しました"
    
    # レイアウト情報を表示
    log_info "チーム構成:"
    log_info "  Window 0: Master (1人)"
    local window_num=1
    
    if [ -f "$TEAMS_CONFIG_FILE" ] && [ "$(jq -r '.teams | length' "$TEAMS_CONFIG_FILE")" -gt 0 ]; then
        # 設定ファイルから読み込む
        jq -r '.teams[] | select(.active == true) | "\(.name) (\(.member_count // 4)人)"' "$TEAMS_CONFIG_FILE" | while read -r team_info; do
            log_info "  Window $window_num: $team_info"
            ((window_num++))
        done
    elif [ ${#TEAMS[@]} -gt 0 ]; then
        # デフォルト表示（TEAMSが空でない場合のみ）
        for team in "${TEAMS[@]}"; do
            log_info "  Window $window_num: $team (4人: boss, pro1, pro2, pro3)"
            ((window_num++))
        done
    fi
}

# チーム設定ファイルを作成（動的チーム構成）
create_team_configurations() {
    log_info "設定ファイルを作成中..."
    
    # Master設定
    create_master_config "$WORKSPACE"
    
    # チーム設定ファイルがある場合のみチーム設定を作成
    if [ -f "$TEAMS_CONFIG_FILE" ] && [ "$(jq -r '.teams | length' "$TEAMS_CONFIG_FILE")" -gt 0 ]; then
        # アクティブなチームのみ処理
        jq -c '.teams[] | select(.active == true)' "$TEAMS_CONFIG_FILE" | while read -r team_json; do
            local team=$(echo "$team_json" | jq -r '.id')
            local team_dir="$WORKTREES_DIR/${team//\//-}"
            
            # チーム共通設定
            create_team_base_config "$team_dir" "$team"
            
            # 各メンバーの個別設定
            for role in "${TEAM_ROLES[@]}"; do
                create_member_config "$team_dir" "$team" "$role"
            done
        done
    fi
    
    log_success "全ての設定ファイルを作成しました"
}

create_master_config() {
    local config_path="$1/CLAUDE_MASTER.md"
    
    cat > "$config_path" << EOF
# Master Architect - 動的チーム構成の統括者

あなたは大規模開発チームを統括するMaster Architectです。
チーム数とメンバー数はプロジェクトの規模に応じて動的に変化します。

## ⚠️ 重要：新しいコミュニケーションルール

**より良いサービスを作るため、すべてのコミュニケーションが推奨されます！**
- ✅ 各チームのBossと頻繁に会話
- ✅ 必要に応じてチームメンバーとも直接対話
- ✅ Master会議で全Boss を招集して議論
- ✅ 全体ブロードキャストで重要事項を共有

## 🎯 役割と責任

### 1. ビジョンと戦略
- プロジェクト全体のビジョンを設定
- 技術戦略の立案と決定
- 各チームへの大局的な指示

### 2. チームボスとの連携
- 5つのチームボスと直接コミュニケーション
- 各チームへのタスク配分
- 進捗の監視と調整

### 3. 品質とスケジュール管理
- 全体的な品質基準の設定
- マイルストーンの管理
- リスクの早期発見と対応

## 📋 チーム構成

1. **Frontend Team** (4人)
   - Boss: UI/UX戦略、タスク配分 ← **あなたの直接の対話相手**
   - Pro1: 専門的なコンポーネント開発
   - Pro2: 高度な機能実装
   - Pro3: パフォーマンス最適化

2. **Backend Team** (4人)
   - Boss: API設計、タスク配分 ← **あなたの直接の対話相手**
   - Pro1: アーキテクチャ設計・実装
   - Pro2: 高度なAPI実装
   - Pro3: セキュリティ対策

3. **Database Team** (4人)
   - Boss: データ設計、タスク配分 ← **あなたの直接の対話相手**
   - Pro1: 高度なクエリ最適化
   - Pro2: スキーマ設計・実装
   - Pro3: パフォーマンスチューニング

4. **DevOps Team** (4人)
   - Boss: インフラ戦略、タスク配分 ← **あなたの直接の対話相手**
   - Pro1: 高度なインフラ自動化
   - Pro2: CI/CDパイプライン設計
   - Pro3: 監視・アラート設定

5. **QA/Security Team** (4人)
   - Boss: テスト戦略、タスク配分 ← **あなたの直接の対話相手**
   - Pro1: セキュリティ監査・設計
   - Pro2: E2Eテスト戦略・実装
   - Pro3: 品質保証プロセス設計

## 🔄 柔軟で協調的なコミュニケーション

```
Master (あなた)
  ↕️ ↔️ ↕️
各チームBoss (動的) ←→ Boss同士の横連携
  ↕️ ↔️ ↕️
チームメンバー (各チーム1-N人) ←→ チーム間連携
```

- ✅ Master ↔ Boss: 頻繁な対話
- ✅ Boss ↔ Boss: 積極的な横連携
- ✅ Master → メンバー: 必要に応じて直接対話
- ✅ チーム間連携: より良いサービスのため推奨

## 💡 コミュニケーション関数

```bash
# Boss への指示
master_to_boss "frontend" "ユーザー認証UIを実装してください。期限は3日です。"
master_to_boss "backend" "認証APIを設計・実装してください。"

# Master会議の開催
master_meeting "新機能の技術選定について"

# 全体ブロードキャスト
master_broadcast "本日より新プロジェクトを開始します！"

# Boss からの報告を確認
check_boss_reports  # 各Bossからの最新報告を確認

# 直接メンバーと対話（必要時）
cross_team_member_communication "master" "master" "frontend" "pro1" "UIデザインについて相談があります"
```

## 🔄 マージワークフロー

```bash
# 各チームの成果をマージ
master_merge_team_work "frontend" "認証UIの実装完了"
master_merge_team_work "backend" "認証APIの実装完了"

# ワークフロー状態の確認
check_workflow_status

# 統合ワークフローの実行
run_integration_workflow

# メインブランチへの統合
master_finalize_integration "v1.0 - 認証機能の実装完了"
```

## 📊 進捗管理

- 各チームBossから定期的に進捗報告を受ける
- 問題が発生した場合はBossを通じて対応
- チーム間の調整もBoss間で実施
- メンバーの詳細な状況はBossに確認

## 🌟 推奨事項

- Boss同士の積極的な連携を促進
- チーム間の技術共有を推進
- 定期的なMaster会議の開催
- 必要に応じた柔軟なコミュニケーション
- より良いサービスのための協調作業

---

$(get_universal_characteristics)
EOF
}

# チーム基本設定とメンバー個別設定は team-operations.sh に移動済み

# 各チーム・メンバーを起動（動的チーム構成）
launch_all_teams() {
    log_info "Claude Codeを起動中..."
    
    # Masterを起動
    send_to_pane "$SESSION_NAME" "Master.0" "$CLAUDE_CMD"
    wait_for_process "$CLAUDE_STARTUP_WAIT" "Master起動待機中"
    
    # チーム設定ファイルがある場合のみチームを起動
    if [ -f "$TEAMS_CONFIG_FILE" ] && [ "$(jq -r '.teams | length' "$TEAMS_CONFIG_FILE")" -gt 0 ]; then
        # アクティブなチームを起動
        jq -c '.teams[] | select(.active == true)' "$TEAMS_CONFIG_FILE" | while read -r team_json; do
            local team=$(echo "$team_json" | jq -r '.id')
            local member_count=$(echo "$team_json" | jq -r '.member_count // 4')
            local window_name=$(get_team_window_name "$team")
            
            # 各メンバーを起動
            for ((i=0; i<$member_count; i++)); do
                send_to_pane "$SESSION_NAME" "$window_name.$i" "$CLAUDE_CMD"
            done
            
            wait_for_process "$CLAUDE_STARTUP_WAIT" "$team チーム起動待機中"
        done
    fi
    
    wait_for_process "$INITIAL_MESSAGE_WAIT" "初期化待機中"
    
    # 初期メッセージを送信
    # Master
    send_to_pane "$SESSION_NAME" "Master.0" \
        "私はMaster Architectです。プロジェクトを統括します。チームがいる場合は各チームのBossと連携して進めます。"
    
    # チーム設定ファイルがある場合のみチームメッセージを送信
    if [ -f "$TEAMS_CONFIG_FILE" ] && [ "$(jq -r '.teams | length' "$TEAMS_CONFIG_FILE")" -gt 0 ]; then
        jq -c '.teams[] | select(.active == true)' "$TEAMS_CONFIG_FILE" | while read -r team_json; do
            local team=$(echo "$team_json" | jq -r '.id')
            local team_name=$(echo "$team_json" | jq -r '.name')
            local member_count=$(echo "$team_json" | jq -r '.member_count // 4')
            local window_name=$(get_team_window_name "$team")
            
            # チーム名を大文字化
            local team_cap=""
            case "$team" in
                "frontend") team_cap="Frontend" ;;
                "backend") team_cap="Backend" ;;
                "database") team_cap="Database" ;;
                "devops") team_cap="DevOps" ;;
                "qa-security") team_cap="QA-Security" ;;
                *) team_cap="$team_name" ;;
            esac
            
            # 各メンバーにメッセージを送信
            local i=0
            local roles=("boss")
            for ((j=1; j<$member_count && j<=3; j++)); do
                roles+=("pro$j")
            done
            
            for role in "${roles[@]}"; do
                case "$role" in
                    "boss")
                        send_to_pane "$SESSION_NAME" "$window_name.$i" \
                            "私は${team_cap} TeamのBossです。Masterからの指示を受け、チームメンバーにタスクを配分します。"
                        ;;
                    "pro1")
                        send_to_pane "$SESSION_NAME" "$window_name.$i" \
                            "私は${team_cap} Teamのプロフェッショナル1です。専門分野のタスクを自律的に遂行します。"
                        ;;
                    "pro2")
                        send_to_pane "$SESSION_NAME" "$window_name.$i" \
                            "私は${team_cap} Teamのプロフェッショナル2です。専門分野のタスクを自律的に遂行します。"
                        ;;
                    "pro3")
                        send_to_pane "$SESSION_NAME" "$window_name.$i" \
                            "私は${team_cap} Teamのプロフェッショナル3です。専門分野のタスクを自律的に遂行します。"
                        ;;
                esac
                ((i++))
            done
        done
    fi
    
    log_success "起動が完了しました"
}

# ヘルパー関数：チームボスにメッセージを送る
send_to_team_boss() {
    local team="$1"
    local message="$2"
    local window_name=$(get_team_window_name "$team")
    
    # Bossは常にペイン0
    send_to_pane "$SESSION_NAME" "$window_name.0" "$message"
}

# メイン処理
main() {
    # バナー表示
    show_banner "Master Claude Teams System v4.0" "動的チーム管理"
    
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
    
    # ワークフロー状態の初期化
    init_workflow_state
    
    # Claude Code設定を最初に実行（現在は不要）
    # setup_claude_code
    
    # 既存セッションのクリーンアップ
    kill_tmux_session "$SESSION_NAME"
    
    # メイン処理の実行
    setup_worktrees || exit 1
    create_tmux_layout || exit 1
    create_team_configurations || exit 1
    launch_all_teams || exit 1
    
    # 使用方法の表示
    log_info "システムの準備が完了しました！"
    echo ""
    
    if [ -f "$TEAMS_CONFIG_FILE" ] && [ "$(jq -r '.teams | length' "$TEAMS_CONFIG_FILE")" -gt 0 ]; then
        local active_teams=($(jq -r '.teams[] | select(.active == true) | .id' "$TEAMS_CONFIG_FILE"))
        if [ ${#active_teams[@]} -gt 0 ]; then
            log_info "チーム構成:"
            echo "  - Master: 1人（全体統括）"
            jq -r '.teams[] | select(.active == true) | "  - \(.name): \(.member_count // 4)人"' "$TEAMS_CONFIG_FILE"
        else
            log_info "Masterのみで起動中"
            echo "  - Master: 1人（全体統括）"
            echo ""
            echo "  チームを追加するには teams.json にチームを定義してください"
        fi
    else
        log_info "Masterのみで起動中"
        echo "  - Master: 1人（全体統括）"
        echo ""
        echo "  チームを追加するには teams.json にチームを定義してください"
    fi
    
    echo ""
    log_info "tmuxコマンド:"
    echo "  - Ctrl+a → 数字: ウィンドウ切り替え"
    echo "  - Ctrl+a → 矢印: ペイン間移動"
    echo "  - Ctrl+a → z: ペイン最大化"
    echo ""
    log_success "セッションにアタッチします..."
    wait_for_process 2
    
    # セッションにアタッチ
    tmux attach-session -t "$SESSION_NAME"
}

# エントリーポイント
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi