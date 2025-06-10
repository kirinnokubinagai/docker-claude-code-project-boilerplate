#!/bin/bash

# Claude Code Orchestrator
# 親プロセスのClaude Codeが要件定義を分析して、子プロセスに指示を出すシステム

set -e

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# プロジェクト設定
WORKSPACE_DIR="/workspace"
WORKTREES_DIR="$WORKSPACE_DIR/worktrees"
REQUIREMENTS_FILE="$WORKSPACE_DIR/requirements.md"

# ログ出力
log() {
    echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# tmuxセッション確認
check_tmux_session() {
    if ! tmux has-session -t company 2>/dev/null; then
        echo -e "${RED}エラー: tmuxセッション'company'が見つかりません${NC}"
        echo "先に以下を実行してください:"
        echo "  1. company"
        echo "  2. roles"
        exit 1
    fi
}

# Git worktreeを準備
prepare_worktrees() {
    log "Git worktreeを準備中..."
    
    cd "$WORKSPACE_DIR"
    
    # Gitリポジトリ初期化
    if [ ! -d .git ]; then
        git init
        git config user.name "Claude Code"
        git config user.email "claude@anthropic.com"
        echo "# Project" > README.md
        git add README.md
        git commit -m "Initial commit" || true
    fi
    
    # worktreesディレクトリ作成
    mkdir -p "$WORKTREES_DIR"
    
    # 部門別worktree作成
    local departments=("frontend" "backend" "database" "devops" "qa")
    
    for dept in "${departments[@]}"; do
        local branch="feature/$dept"
        local worktree_path="$WORKTREES_DIR/$dept"
        
        if [ ! -d "$worktree_path" ]; then
            git branch "$branch" 2>/dev/null || true
            git worktree add "$worktree_path" "$branch" 2>/dev/null || true
            echo -e "${GREEN}✓${NC} Worktree作成: $worktree_path"
        fi
    done
}

# 子プロセスにworktreeで作業開始を指示
setup_child_processes() {
    log "子プロセスをworktreeに配置中..."
    
    local pane_ids=($(tmux list-panes -t company -F "#{pane_id}"))
    local departments=("frontend" "backend" "database" "devops" "qa")
    
    for i in {1..5}; do
        local pane=${pane_ids[$i]}
        local dept=${departments[$((i-1))]}
        local worktree="$WORKTREES_DIR/$dept"
        
        # worktreeに移動
        tmux send-keys -t $pane "cd $worktree" Enter
        sleep 0.5
        
        echo -e "${GREEN}✓${NC} $dept部門を$worktreeに配置"
    done
}

# 親プロセスから要件定義分析を開始
start_requirements_analysis() {
    local requirements=$1
    
    log "親プロセスで要件定義を分析中..."
    
    # 要件定義ファイルを作成
    cat > "$REQUIREMENTS_FILE" << EOF
# プロジェクト要件定義

作成日時: $(date '+%Y-%m-%d %H:%M:%S')

## 要件
$requirements

## 実装指示
この要件を分析して、以下の部門別にタスクを分割してください：
- Frontend部門: UI/UX、画面実装
- Backend部門: API、認証、ビジネスロジック
- Database部門: データモデル、テーブル設計
- DevOps部門: 環境構築、CI/CD
- QA部門: テスト計画、自動テスト

各部門には以下のMCPツールが利用可能です：
- Frontend: Playwright, Obsidian, Context7, Stripe
- Backend: Supabase, Stripe, Context7, LINE Bot
- Database: Supabase, Obsidian
- DevOps: Supabase, Playwright, LINE Bot, Obsidian
- QA: Playwright, Obsidian, LINE Bot, Context7
EOF

    # 親プロセス（Manager pane）に要件分析を依頼
    local manager_pane=${pane_ids[0]}
    
    tmux send-keys -t $manager_pane "clear" Enter
    sleep 0.5
    
    tmux send-keys -t $manager_pane "以下の要件を分析して、各部門にタスクを割り振ってください。" Enter
    tmux send-keys -t $manager_pane "" Enter
    tmux send-keys -t $manager_pane "要件: $requirements" Enter
    tmux send-keys -t $manager_pane "" Enter
    tmux send-keys -t $manager_pane "手順:" Enter
    tmux send-keys -t $manager_pane "1. 要件を分析してタスクに分解" Enter
    tmux send-keys -t $manager_pane "2. 各部門に以下のコマンドでタスクを送信:" Enter
    tmux send-keys -t $manager_pane "   tmux send-keys -t %27 'Frontend: [具体的なタスク]' Enter" Enter
    tmux send-keys -t $manager_pane "   tmux send-keys -t %28 'Backend: [具体的なタスク]' Enter" Enter
    tmux send-keys -t $manager_pane "   tmux send-keys -t %29 'Database: [具体的なタスク]' Enter" Enter
    tmux send-keys -t $manager_pane "   tmux send-keys -t %30 'DevOps: [具体的なタスク]' Enter" Enter
    tmux send-keys -t $manager_pane "   tmux send-keys -t %31 'QA: [具体的なタスク]' Enter" Enter
    tmux send-keys -t $manager_pane "" Enter
    tmux send-keys -t $manager_pane "3. 各部門のタスクにはMCPツールの使用を含めてください" Enter
    tmux send-keys -t $manager_pane "4. Context7で最新技術を調査するよう指示してください" Enter
    
    echo -e "${GREEN}✓${NC} 親プロセスに要件分析を依頼しました"
}

# 簡易版：直接タスクを配布
quick_distribute() {
    local task_type=$1
    
    log "クイックタスク配布: $task_type"
    
    local pane_ids=($(tmux list-panes -t company -F "#{pane_id}"))
    
    case $task_type in
        "auth")
            tmux send-keys -t ${pane_ids[1]} "ログイン/サインアップ画面を作成してください。Playwrightでテストも作成。" Enter
            tmux send-keys -t ${pane_ids[2]} "Supabase認証を実装してください。use context7で最新の認証方法を確認。" Enter
            tmux send-keys -t ${pane_ids[3]} "ユーザーテーブルとセッション管理を設計してください。" Enter
            ;;
        "payment")
            tmux send-keys -t ${pane_ids[1]} "Stripe決済フォームを実装してください。use context7でStripe最新機能確認。" Enter
            tmux send-keys -t ${pane_ids[2]} "Stripe Webhookとサブスクリプション処理を実装してください。" Enter
            tmux send-keys -t ${pane_ids[3]} "決済履歴テーブルを設計してください。" Enter
            ;;
        "crud")
            tmux send-keys -t ${pane_ids[1]} "CRUD画面（一覧、作成、編集、削除）を実装してください。" Enter
            tmux send-keys -t ${pane_ids[2]} "CRUD APIを実装してください。Supabase RLSも設定。" Enter
            tmux send-keys -t ${pane_ids[3]} "メインエンティティのテーブル設計をしてください。" Enter
            ;;
        *)
            echo -e "${RED}不明なタスクタイプ: $task_type${NC}"
            echo "利用可能: auth, payment, crud"
            ;;
    esac
}

# ステータス監視
monitor_status() {
    echo -e "${CYAN}=== 各部門の現在の状態 ===${NC}"
    
    local pane_ids=($(tmux list-panes -t company -F "#{pane_id}"))
    local departments=("Manager" "Frontend" "Backend" "Database" "DevOps" "QA")
    
    for i in {0..5}; do
        echo -e "${BLUE}--- ${departments[$i]} (Pane ${pane_ids[$i]}) ---${NC}"
        tmux capture-pane -t ${pane_ids[$i]} -p | tail -5
        echo ""
    done
}

# メイン処理
main() {
    echo -e "${PURPLE}=== Claude Code Orchestrator ===${NC}"
    
    local command=${1:-"help"}
    
    case $command in
        init)
            # 初期化：tmux確認 → worktree作成 → 子プロセス配置
            check_tmux_session
            prepare_worktrees
            setup_child_processes
            echo -e "${GREEN}初期化完了！${NC}"
            echo "次のコマンド: ./claude-orchestrator.sh analyze '要件'"
            ;;
            
        analyze)
            # 要件分析：親プロセスに要件を渡して分析開始
            if [ -z "$2" ]; then
                echo -e "${RED}エラー: 要件を指定してください${NC}"
                exit 1
            fi
            check_tmux_session
            start_requirements_analysis "$2"
            ;;
            
        quick)
            # クイックタスク配布
            if [ -z "$2" ]; then
                echo -e "${RED}エラー: タスクタイプを指定してください${NC}"
                echo "利用可能: auth, payment, crud"
                exit 1
            fi
            check_tmux_session
            quick_distribute "$2"
            ;;
            
        status)
            # ステータス確認
            check_tmux_session
            monitor_status
            ;;
            
        help|*)
            echo "使用方法:"
            echo "  ./claude-orchestrator.sh init         - 初期化（worktree作成）"
            echo "  ./claude-orchestrator.sh analyze '要件' - 要件分析とタスク配布"
            echo "  ./claude-orchestrator.sh quick <type>  - クイックタスク配布"
            echo "  ./claude-orchestrator.sh status        - ステータス確認"
            echo ""
            echo "例:"
            echo "  ./claude-orchestrator.sh init"
            echo "  ./claude-orchestrator.sh analyze 'ECサイトを作成。ユーザー認証、商品管理、決済機能を含む'"
            echo "  ./claude-orchestrator.sh quick auth"
            echo ""
            echo "前提条件:"
            echo "  1. tmux companyセッションが起動済み（companyコマンド実行）"
            echo "  2. 各部門にClaude Codeが起動済み（rolesコマンド実行）"
            ;;
    esac
}

# スクリプト実行
main "$@"