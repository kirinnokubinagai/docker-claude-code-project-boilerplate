#!/bin/bash

# Claude Code Company Orchestrator
# 親プロセスから子プロセスへの自動指示システム

set -e

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# プロジェクト設定
PROJECT_NAME="${PROJECT_NAME:-myproject}"
WORKSPACE_DIR="/workspace"
WORKTREES_DIR="$WORKSPACE_DIR/worktrees"
TASKS_DIR="$WORKSPACE_DIR/tasks"
CLAUDE_MD_PATH="docker/claude/CLAUDE.md"

# ログ出力
log() {
    echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# tmuxセッション確認
check_tmux_session() {
    if ! tmux has-session -t company 2>/dev/null; then
        error "tmuxセッション'company'が見つかりません。先に'company'コマンドを実行してください。"
    fi
}

# pane IDを取得
get_pane_ids() {
    tmux list-panes -t company -F "#{pane_id}"
}

# 部門別にタスクを送信
send_task_to_department() {
    local department=$1
    local task=$2
    local worktree=$3
    
    local pane_ids=($(get_pane_ids))
    local manager_pane=${pane_ids[0]}
    local target_pane=""
    local dept_name=""
    
    case $department in
        frontend)
            target_pane=${pane_ids[1]}
            dept_name="Frontend"
            ;;
        backend)
            target_pane=${pane_ids[2]}
            dept_name="Backend"
            ;;
        database)
            target_pane=${pane_ids[3]}
            dept_name="Database"
            ;;
        devops)
            target_pane=${pane_ids[4]}
            dept_name="DevOps"
            ;;
        qa)
            target_pane=${pane_ids[5]}
            dept_name="QA"
            ;;
        *)
            error "不明な部門: $department"
            ;;
    esac
    
    # worktreeに移動してタスクを実行
    local command="cd $worktree && $task 完了時は tmux send-keys -t $manager_pane '[$dept_name] 完了: ${task:0:50}...' Enter で報告してください。"
    
    log "${dept_name}部門にタスク送信: $task"
    tmux send-keys -t $target_pane "$command" Enter
}

# 要件定義ファイルを作成
create_requirements() {
    local requirements=$1
    
    log "要件定義ファイルを作成中..."
    
    # タスクディレクトリ作成
    mkdir -p "$TASKS_DIR"
    
    # 親プロセスで要件定義を作成
    cat > "$TASKS_DIR/requirements.md" << EOF
# プロジェクト要件定義

作成日: $(date '+%Y-%m-%d %H:%M:%S')

## 概要
$requirements

## 技術スタック
- Frontend: (Context7で最新技術を調査)
- Backend: (Context7で最新技術を調査)
- Database: PostgreSQL (Supabase)
- Testing: Playwright
- Documentation: Obsidian
- Payment: Stripe
- Notification: LINE Bot

## 部門別タスク

### Frontend部門
- [ ] UI/UXデザイン設計
- [ ] コンポーネント実装
- [ ] Playwrightテスト作成

### Backend部門
- [ ] API設計
- [ ] 認証システム実装
- [ ] 決済システム実装

### Database部門
- [ ] データモデル設計
- [ ] マイグレーション作成
- [ ] インデックス最適化

### DevOps部門
- [ ] 開発環境構築
- [ ] CI/CDパイプライン設定
- [ ] デプロイ設定

### QA部門
- [ ] テスト計画作成
- [ ] E2Eテスト実装
- [ ] パフォーマンステスト
EOF

    success "要件定義ファイル作成完了: $TASKS_DIR/requirements.md"
}

# タスクファイルを部門別に作成
create_task_files() {
    log "部門別タスクファイルを作成中..."
    
    # Frontend Tasks
    cat > "$TASKS_DIR/frontend_tasks.md" << 'EOF'
# Frontend部門タスク

## Phase 1: 設計
1. Context7で最新のフロントエンドフレームワーク調査
2. UI/UXデザイン設計（Obsidianでドキュメント化）
3. コンポーネント設計

## Phase 2: 実装
1. 基本レイアウト実装
2. 認証画面実装
3. メイン機能画面実装
4. Stripe決済UI実装

## Phase 3: テスト
1. Playwright E2Eテスト作成
2. ビジュアルリグレッションテスト
3. パフォーマンステスト
EOF

    # Backend Tasks
    cat > "$TASKS_DIR/backend_tasks.md" << 'EOF'
# Backend部門タスク

## Phase 1: 設計
1. Context7で最新のバックエンドフレームワーク調査
2. API設計（RESTful/GraphQL）
3. 認証フロー設計

## Phase 2: 実装
1. Supabase認証システム実装
2. CRUD API実装
3. Stripe決済処理実装
4. LINE Bot通知システム実装

## Phase 3: テスト
1. ユニットテスト作成
2. 統合テスト作成
3. 負荷テスト実装
EOF

    # Database Tasks
    cat > "$TASKS_DIR/database_tasks.md" << 'EOF'
# Database部門タスク

## Phase 1: 設計
1. ER図作成（Obsidianでドキュメント化）
2. テーブル設計
3. インデックス設計

## Phase 2: 実装
1. Supabaseマイグレーション作成
2. 初期データ投入
3. ストアドプロシージャ実装

## Phase 3: 最適化
1. クエリ最適化
2. インデックス調整
3. パフォーマンスチューニング
EOF

    # DevOps Tasks
    cat > "$TASKS_DIR/devops_tasks.md" << 'EOF'
# DevOps部門タスク

## Phase 1: 環境構築
1. 開発環境セットアップ
2. Supabaseプロジェクト作成
3. Docker環境構築

## Phase 2: CI/CD
1. GitHub Actions設定
2. Playwrightテスト自動化
3. デプロイパイプライン構築

## Phase 3: 監視
1. ログ収集設定
2. LINE Bot通知設定
3. エラー監視設定
EOF

    # QA Tasks
    cat > "$TASKS_DIR/qa_tasks.md" << 'EOF'
# QA部門タスク

## Phase 1: 計画
1. テスト計画作成（Obsidianでドキュメント化）
2. テストケース設計
3. テストデータ準備

## Phase 2: 実装
1. Playwright E2Eテスト実装
2. APIテスト実装
3. パフォーマンステスト実装

## Phase 3: 実行
1. 回帰テスト実行
2. 負荷テスト実行
3. LINE Botでテスト結果通知
EOF

    success "部門別タスクファイル作成完了"
}

# Git worktreeを作成
create_worktrees() {
    log "Git worktreeを作成中..."
    
    # worktreesディレクトリ作成
    mkdir -p "$WORKTREES_DIR"
    
    # メインブランチを確認
    cd "$WORKSPACE_DIR"
    if [ ! -d .git ]; then
        git init
        git add .
        git commit -m "Initial commit" || true
    fi
    
    # 部門別worktree作成
    local departments=("frontend" "backend" "database" "devops" "qa")
    
    for dept in "${departments[@]}"; do
        local branch_name="feature/$dept-implementation"
        local worktree_path="$WORKTREES_DIR/$dept"
        
        # ブランチ作成
        git branch "$branch_name" 2>/dev/null || true
        
        # worktree作成
        if [ ! -d "$worktree_path" ]; then
            git worktree add "$worktree_path" "$branch_name"
            success "Worktree作成: $worktree_path ($branch_name)"
        else
            warning "Worktree既存: $worktree_path"
        fi
    done
}

# 子プロセスにclaude codeを起動
launch_child_processes() {
    log "子プロセスでClaude Codeを起動中..."
    
    local pane_ids=($(get_pane_ids))
    local departments=("frontend" "backend" "database" "devops" "qa")
    
    for i in {1..5}; do
        local pane_id=${pane_ids[$i]}
        local dept=${departments[$((i-1))]}
        local worktree_path="$WORKTREES_DIR/$dept"
        
        # worktreeに移動してclaude codeを起動
        tmux send-keys -t $pane_id "cd $worktree_path" Enter
        sleep 0.5
        tmux send-keys -t $pane_id "claude --dangerously-skip-permissions" Enter
        sleep 2
        
        # 部門の役割を説明
        case $dept in
            frontend)
                tmux send-keys -t $pane_id "あなたはFrontend部門です。$TASKS_DIR/frontend_tasks.mdのタスクを実行してください。" Enter
                ;;
            backend)
                tmux send-keys -t $pane_id "あなたはBackend部門です。$TASKS_DIR/backend_tasks.mdのタスクを実行してください。" Enter
                ;;
            database)
                tmux send-keys -t $pane_id "あなたはDatabase部門です。$TASKS_DIR/database_tasks.mdのタスクを実行してください。" Enter
                ;;
            devops)
                tmux send-keys -t $pane_id "あなたはDevOps部門です。$TASKS_DIR/devops_tasks.mdのタスクを実行してください。" Enter
                ;;
            qa)
                tmux send-keys -t $pane_id "あなたはQA部門です。$TASKS_DIR/qa_tasks.mdのタスクを実行してください。" Enter
                ;;
        esac
        
        success "$dept部門のClaude Code起動完了"
    done
}

# 自動タスク配布
distribute_tasks() {
    log "タスクを自動配布中..."
    
    # Phase 1: 設計フェーズ
    send_task_to_department "frontend" "Context7で最新技術調査してUI/UX設計を開始してください" "$WORKTREES_DIR/frontend"
    send_task_to_department "backend" "Context7でAPI設計のベストプラクティスを調査してください" "$WORKTREES_DIR/backend"
    send_task_to_department "database" "データモデル設計を開始してください" "$WORKTREES_DIR/database"
    send_task_to_department "devops" "Supabaseプロジェクトを作成してください" "$WORKTREES_DIR/devops"
    send_task_to_department "qa" "テスト計画を作成してください" "$WORKTREES_DIR/qa"
    
    success "Phase 1タスク配布完了"
}

# メイン処理
main() {
    echo -e "${PURPLE}=== Claude Code Company Orchestrator ===${NC}"
    
    # 引数処理
    local command=${1:-"help"}
    
    case $command in
        init)
            # 初期化: 要件定義 → タスク作成 → worktree → 子プロセス起動
            local requirements=${2:-"Webアプリケーションを作成"}
            
            check_tmux_session
            create_requirements "$requirements"
            create_task_files
            create_worktrees
            launch_child_processes
            
            success "オーケストレーター初期化完了！"
            echo ""
            echo "次のコマンドを実行してタスクを配布:"
            echo "  ./orchestrator.sh distribute"
            ;;
            
        distribute)
            # タスク配布
            check_tmux_session
            distribute_tasks
            ;;
            
        status)
            # ステータス確認
            check_tmux_session
            log "各部門のステータスを確認中..."
            tmux list-panes -t company -F "#{pane_id} #{pane_title}"
            ;;
            
        help|*)
            echo "使用方法:"
            echo "  ./orchestrator.sh init [要件]     - プロジェクト初期化"
            echo "  ./orchestrator.sh distribute      - タスク自動配布"
            echo "  ./orchestrator.sh status          - ステータス確認"
            echo ""
            echo "例:"
            echo "  ./orchestrator.sh init 'ECサイトを作成'"
            echo ""
            echo "前提条件:"
            echo "  1. tmux company セッションが起動していること"
            echo "  2. Docker環境内で実行すること"
            ;;
    esac
}

# スクリプト実行
main "$@"