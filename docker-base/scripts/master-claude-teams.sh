#!/bin/bash

# Master Claude Teams System - v7.0
# 改善版：team-tasks.json廃止、Masterがrequirements.mdを参照してtmuxで指示

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# 設定
SESSION_NAME="claude-teams"
WORKSPACE="/workspace"
TEAMS_CONFIG_FILE="/opt/claude-system/config/teams.json"
TEAMS_TEMPLATE_FILE="/opt/claude-system/templates/teams.json.example"
REQUIREMENTS_FILE="$WORKSPACE/requirements.md"
TEAM_LOG_FILE="$WORKSPACE/team-communication.log"

# デバッグモード
DEBUG=${DEBUG:-false}

# ログ関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_debug() {
    if [ "$DEBUG" = "true" ]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

# 設定ファイルのチェック
check_config_files() {
    local has_error=false
    
    # teams.jsonのチェック
    if [ ! -f "$TEAMS_CONFIG_FILE" ]; then
        if [ -f "$TEAMS_TEMPLATE_FILE" ]; then
            log_error "teams.json が見つかりません"
            echo ""
            echo "以下のコマンドでテンプレートファイルをコピーして開始できます："
            echo -e "${CYAN}cp $TEAMS_TEMPLATE_FILE $TEAMS_CONFIG_FILE${NC}"
            echo ""
            echo "その後、プロジェクトに合わせてファイルを編集してください。"
            echo ""
        else
            log_error "teams.json およびテンプレートファイルが見つかりません"
        fi
        has_error=true
    else
        # JSONの妥当性チェック
        if ! jq empty "$TEAMS_CONFIG_FILE" 2>/dev/null; then
            log_error "teams.json の形式が正しくありません"
            has_error=true
        fi
    fi
    
    # requirements.mdのチェック（オプショナル）
    if [ ! -f "$REQUIREMENTS_FILE" ]; then
        log_warning "requirements.md が見つかりません"
        echo "Masterが参照する要件定義書がありません。"
        echo "プロジェクトの要件定義を $REQUIREMENTS_FILE に作成してください。"
    fi
    
    if [ "$has_error" = "true" ]; then
        return 1
    fi
    
    return 0
}

# チーム構成の検証
validate_teams_config() {
    # 必須フィールドのチェック
    local validation_errors=0
    local teams=$(jq -r '.teams[]?' "$TEAMS_CONFIG_FILE" 2>/dev/null)
    
    if [ -z "$teams" ]; then
        log_error "teams配列が見つかりません"
        return 1
    fi
    
    # 各チームの検証
    local team_ids=$(jq -r '.teams[].id' "$TEAMS_CONFIG_FILE" 2>/dev/null)
    for id in $team_ids; do
        # 必須フィールドチェック
        local name=$(jq -r ".teams[] | select(.id == \"$id\") | .name" "$TEAMS_CONFIG_FILE")
        local member_count=$(jq -r ".teams[] | select(.id == \"$id\") | .member_count" "$TEAMS_CONFIG_FILE")
        if [ -z "$name" ] || [ "$name" = "null" ]; then
            log_error "チーム $id: name フィールドが必須です"
            validation_errors=$((validation_errors + 1))
        fi
        
        if [ -z "$member_count" ] || [ "$member_count" = "null" ]; then
            log_error "チーム $id: member_count フィールドが必須です"
            validation_errors=$((validation_errors + 1))
        elif ! [[ "$member_count" =~ ^[1-4]$ ]]; then
            log_error "チーム $id: member_count は1-4の数値である必要があります"
            validation_errors=$((validation_errors + 1))
        fi
    done
    
    if [ $validation_errors -gt 0 ]; then
        log_error "設定ファイルに $validation_errors 個のエラーがあります"
        return 1
    fi
    
    return 0
}

# ペインインデックスを取得（改善版）
get_pane_index_for_team() {
    local team_id=$1
    local member_index=$2  # 1-based
    
    # 累積インデックスを計算
    local pane_idx=1  # Masterペインが1
    
    # すべてのチームを対象
    local teams=$(jq -r '.teams[].id' "$TEAMS_CONFIG_FILE" 2>/dev/null)
    
    for t in $teams; do
        if [ "$t" = "$team_id" ]; then
            pane_idx=$((pane_idx + member_index))
            break
        else
            local count=$(jq -r ".teams[] | select(.id == \"$t\") | .member_count // 1" "$TEAMS_CONFIG_FILE" 2>/dev/null)
            pane_idx=$((pane_idx + count))
        fi
    done
    
    echo $pane_idx
}

# タスクをペインに送信（改善版）
send_task_to_pane() {
    local pane_idx=$1
    local task=$2
    
    # ペインの存在確認
    if ! tmux list-panes -t "$SESSION_NAME:1" -F "#{pane_index}" | grep -q "^${pane_idx}$"; then
        log_error "ペイン $pane_idx が存在しません"
        return 1
    fi
    
    # タスクを送信
    tmux send-keys -t "$SESSION_NAME:1.$pane_idx" "$task" Enter
    
    return 0
}

# Masterの初期設定（改善版）
setup_master() {
    log_info "Master Claudeを設定中..."
    
    # Claude Codeの起動を待つ（プログレスバー付き）
    echo -n "Claude Codeの起動を待機中 "
    for i in {1..15}; do
        echo -n "."
        sleep 1
    done
    echo " 完了"
    
    # requirements.mdの確認
    local master_prompt
    if [ -f "$REQUIREMENTS_FILE" ]; then
        master_prompt="私はMaster Claudeです。requirements.mdを確認して、各チームのBossに適切なタスクを割り当てます。Bossを常に監視し、指示待ち状態を作らず、完了報告を受けたら即座に次のタスクを投入します。Bossは部下を同様に監視し、メンバーは必ずBossに確認を取り、Bossは必ず私に確認を取ります。重要: 各タスク完了時には必ずテスト(Playwright E2E/ユニットテスト)を作成・実行し、全テスト通過後のみコミットを許可します。"
    else
        master_prompt="私はMaster Claudeです。プロジェクト全体を統括します。まず requirements.md を作成して要件定義を行います。"
    fi
    
    # Master Claudeに初期プロンプトを送信
    if send_task_to_pane 1 "$master_prompt"; then
        log_success "Master: 初期設定完了"
    fi
    
    # チーム情報をMasterに送信
    sleep 2
    local team_info="現在のチーム構成:"
    local teams=$(jq -r '.teams[].id' "$TEAMS_CONFIG_FILE" 2>/dev/null)
    
    for team in $teams; do
        local team_name=$(jq -r ".teams[] | select(.id == \"$team\") | .name" "$TEAMS_CONFIG_FILE" 2>/dev/null)
        local member_count=$(jq -r ".teams[] | select(.id == \"$team\") | .member_count // 1" "$TEAMS_CONFIG_FILE" 2>/dev/null)
        team_info="$team_info\\n- $team_name: $member_count 人（1人目がBoss）"
    done
    
    send_task_to_pane 1 "echo -e \"$team_info\""
    
    log_info "Masterは各チームのBossに指示を出し、常に監視します"
    log_info "指示待ちゼロシステム: タスク完了を検知したら即座に次のタスクを投入"
    log_info "例: "
    log_info "  tmux send-keys -t claude-teams:1.2 \"Frontend Boss、認証UIを実装してください\""
    log_info "  tmux send-keys -t claude-teams:1.2 Enter"
    log_info ""
    log_info "確認体制: メンバー→Boss、Boss→Masterの確認フローを徹底"
    log_info "テスト必須: 各タスク完了時にテスト作成・実行（tests/e2e/, tests/backend/, tests/unit/）"
    
    # ログファイルの初期化
    echo "[$(date)] Master Claude Teams System 起動" > "$TEAM_LOG_FILE"
}

# ペイン作成（改善版）
create_team_panes() {
    local team=$1
    local team_name=$2
    local member_count=$3
    local worktree_path=$4
    local start_pane_index=$5
    
    log_info "チーム: $team_name ($member_count 人)"
    
    for member in $(seq 1 "$member_count"); do
        # ペインを分割
        if tmux split-window -t "$SESSION_NAME" -c "$worktree_path" 2>/dev/null; then
            local current_pane_index=$((start_pane_index + member - 1))
            
            # ペイン名を設定
            local pane_title
            if [ $member -eq 1 ]; then
                pane_title="$team_name Boss"
            else
                pane_title="$team_name #$member"
            fi
            
            # タイトル設定（複数の方法で確実に設定）
            sleep 0.1
            tmux select-pane -t "$SESSION_NAME:1.$current_pane_index" -T "$pane_title" 2>/dev/null
            tmux set-option -t "$SESSION_NAME:1.$current_pane_index" pane-border-format " $pane_title " 2>/dev/null
            
            log_success "  → $pane_title のペイン作成"
            
            # レイアウト調整（3ペイン以上で実行）
            if [ $current_pane_index -ge 3 ]; then
                tmux select-layout -t "$SESSION_NAME" tiled 2>/dev/null
            fi
        else
            log_error "  → メンバー $member のペイン作成失敗"
            return 1
        fi
    done
    
    return 0
}

# メイン処理
main() {
    echo ""
    echo -e "${CYAN}${BOLD}======================================${NC}"
    echo -e "${CYAN}${BOLD} Master Claude Teams System v7.0${NC}"
    echo -e "${CYAN}${BOLD} Dynamic Task Assignment${NC}"
    echo -e "${CYAN}${BOLD}======================================${NC}"
    echo ""
    
    # 設定ファイルのチェック
    if ! check_config_files; then
        echo ""
        echo "設定ファイルを準備してから再度実行してください。"
        exit 1
    fi
    
    # チーム構成の検証
    if ! validate_teams_config; then
        echo ""
        echo "teams.json の設定を修正してから再度実行してください。"
        exit 1
    fi
    
    # tmuxサーバー起動
    tmux start-server 2>/dev/null
    
    # 既存セッションのチェック
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_warning "既存のセッションが見つかりました"
        echo ""
        echo "既存のセッションをどうしますか？"
        echo "1) 削除して新規作成"
        echo "2) 既存のセッションにアタッチ"
        echo "3) キャンセル"
        echo ""
        read -p "選択してください [1-3]: " choice
        
        case $choice in
            1)
                log_info "既存のセッションを削除中..."
                tmux kill-session -t "$SESSION_NAME"
                ;;
            2)
                log_info "既存のセッションにアタッチします..."
                tmux attach-session -t "$SESSION_NAME"
                exit 0
                ;;
            *)
                log_info "キャンセルしました"
                exit 0
                ;;
        esac
    fi
    
    # 総メンバー数を計算
    local total_members=1  # Master分
    local teams=$(jq -r '.teams[].id' "$TEAMS_CONFIG_FILE" 2>/dev/null)
    for team in $teams; do
        local member_count=$(jq -r ".teams[] | select(.id == \"$team\") | .member_count // 1" "$TEAMS_CONFIG_FILE" 2>/dev/null)
        total_members=$((total_members + member_count))
    done
    
    log_info "総メンバー数: $total_members 人"
    
    # メモリ使用量の推定警告
    local estimated_memory=$((total_members * 300))  # 各Claudeが約300MB使用と仮定
    local available_memory=16384  # 16GB
    local system_reserved=4096    # システム用に4GB確保
    local docker_overhead=2048    # Docker用に2GB
    local max_safe_memory=$((available_memory - system_reserved - docker_overhead))
    
    if [ $estimated_memory -gt $max_safe_memory ]; then
        log_warning "推定メモリ使用量: 約 ${estimated_memory}MB"
        log_warning "利用可能メモリ: 約 ${max_safe_memory}MB"
        log_warning "メモリ不足の可能性があります。"
        echo ""
        echo "推奨される対策："
        echo "1) チーム数を減らす（現在: $total_members 人）"
        echo "2) 段階的に起動する（--phased オプション）"
        echo "3) 軽量モードで起動（--lightweight オプション）"
        echo ""
        echo "続行しますか？ [y/N]"
        read -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # TMUX環境変数をクリア
    unset TMUX
    
    # セッション作成
    log_info "tmuxセッションを作成中..."
    tmux new-session -d -s "$SESSION_NAME" -n "All-Teams" -c "$WORKSPACE"
    
    # ペインボーダーの設定
    tmux set-option -g pane-border-status top
    tmux set-option -g pane-border-format " #{pane_title} "
    
    # セッション作成確認
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_error "セッションの作成に失敗しました"
        exit 1
    fi
    
    # Masterペインの設定
    tmux select-pane -t "$SESSION_NAME:1.1" -T "Master"
    log_success "Master用ペイン作成完了"
    
    # worktreeディレクトリを作成
    mkdir -p "$WORKSPACE/worktrees"
    
    # 各チームのペインを作成
    local pane_index=2  # Masterが1なので、2から開始
    
    for team in $teams; do
        local team_name=$(jq -r ".teams[] | select(.id == \"$team\") | .name" "$TEAMS_CONFIG_FILE" 2>/dev/null)
        local member_count=$(jq -r ".teams[] | select(.id == \"$team\") | .member_count // 1" "$TEAMS_CONFIG_FILE" 2>/dev/null)
        local worktree_path="$WORKSPACE/worktrees/$team"
        
        # worktreeディレクトリを作成
        mkdir -p "$worktree_path"
        
        # チームのペインを作成
        if ! create_team_panes "$team" "$team_name" "$member_count" "$worktree_path" "$pane_index"; then
            log_error "チーム $team_name のペイン作成中にエラーが発生しました"
        fi
        
        pane_index=$((pane_index + member_count))
    done
    
    # レイアウトを最適化
    log_info "レイアウトを最適化中..."
    tmux select-layout -t "$SESSION_NAME" tiled
    
    # 最終的なペイン数を確認
    sleep 0.5
    local final_panes=$(tmux list-panes -t "$SESSION_NAME" 2>/dev/null | wc -l | tr -d ' ')
    log_success "合計 $final_panes ペインを作成しました"
    
    # 各ペインでClaude Codeを起動
    log_info "各ペインでClaude Codeを起動中..."
    
    # 段階的起動オプションのチェック
    if [[ " $@ " == *" --phased "* ]]; then
        log_info "段階的起動モード: メモリ使用量を分散します"
        # Masterを最初に起動
        tmux send-keys -t "$SESSION_NAME:1.1" 'claude --dangerously-skip-permissions' Enter
        log_success "Master Claude起動完了 (1/$final_panes)"
        sleep 5
        
        # チームごとに段階的に起動
        local current_pane=2
        local teams=$(jq -r '.teams[].id' "$TEAMS_CONFIG_FILE" 2>/dev/null)
        
        for team in $teams; do
            local team_name=$(jq -r ".teams[] | select(.id == \"$team\") | .name" "$TEAMS_CONFIG_FILE" 2>/dev/null)
            local member_count=$(jq -r ".teams[] | select(.id == \"$team\") | .member_count // 1" "$TEAMS_CONFIG_FILE" 2>/dev/null)
            
            log_info "$team_name チームを起動中..."
            for member in $(seq 1 "$member_count"); do
                tmux send-keys -t "$SESSION_NAME:1.$current_pane" 'claude --dangerously-skip-permissions' Enter
                log_success "  → メンバー $member 起動完了 ($current_pane/$final_panes)"
                current_pane=$((current_pane + 1))
                sleep 3  # メモリ負荷を分散
            done
            sleep 2  # チーム間の間隔
        done
    else
        # 通常の起動
        for i in $(seq 1 "$final_panes"); do
            tmux send-keys -t "$SESSION_NAME:1.$i" 'claude --dangerously-skip-permissions' Enter
            # 起動を分散させる
            sleep 0.5
        done
    fi
    
    log_success "全てのClaude Codeを起動しました"
    
    # Masterの初期設定
    # --phasedオプションの場合は全起動完了を待つ
    if [[ " $@ " == *" --phased "* ]]; then
        log_info "段階的起動が完了するまで待機中..."
        # 追加で10秒待機
        sleep 10
    fi
    setup_master
    
    # サマリー表示
    echo ""
    echo -e "${GREEN}${BOLD}✅ セットアップ完了！${NC}"
    echo ""
    echo "📋 チーム構成："
    echo "  - Master: 1人（統括）"
    jq -r '.teams[] | "  - \(.name): \(.member_count // 1)人（1人目:Boss）"' "$TEAMS_CONFIG_FILE" 2>/dev/null
    echo ""
    echo "📊 システム情報："
    echo "  - 総ペイン数: $final_panes"
    echo "  - セッション名: $SESSION_NAME"
    echo "  - 作業ディレクトリ: $WORKSPACE"
    echo ""
    
    # アタッチオプションの確認
    if [[ " $@ " != *" --no-attach "* ]]; then
        echo "3秒後にセッションにアタッチします..."
        echo "（Ctrl+Cでキャンセル）"
        sleep 3
        tmux attach-session -t "$SESSION_NAME"
    else
        echo "📍 接続方法："
        echo "   tmux attach -t $SESSION_NAME"
        echo ""
        echo "🔧 便利なtmuxコマンド："
        echo "   Ctrl+b d     - デタッチ（セッションから離れる）"
        echo "   Ctrl+b z     - ペインを最大化/元に戻す"
        echo "   Ctrl+b 矢印  - ペイン間を移動"
        echo ""
    fi
}

# エラーハンドリング
trap 'log_error "予期しないエラーが発生しました"; exit 1' ERR

# ヘルプ表示
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    echo "使用方法: master [オプション]"
    echo ""
    echo "オプション:"
    echo "  --no-attach    セッション作成後にアタッチしない"
    echo "  --phased       段階的起動（メモリ使用量を分散）"
    echo "  --help, -h     このヘルプを表示"
    echo ""
    echo "メモリ最適化のアドバイス:"
    echo "  16GBマシンでの推奨チーム構成："
    echo "    - 小規模: 2-3チーム（6-9人）"
    echo "    - 中規模: 4チーム（12人）※段階的起動推奨"
    echo "    - 大規模: 5チーム以上（15人以上）※要注意"
    echo ""
    echo "使用例:"
    echo "  master                 # 通常起動"
    echo "  master --phased        # 段階的起動（メモリ負荷軽減）"
    echo "  master --no-attach     # バックグラウンド起動"
    echo ""
    echo "環境変数:"
    echo "  DEBUG=true     デバッグモードを有効化"
    echo ""
    exit 0
fi

# エントリーポイント
main "$@"