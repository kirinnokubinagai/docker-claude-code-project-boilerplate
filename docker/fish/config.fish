# ==============================================
# Claude Code Company Fish設定 (Full MCP版)
# ==============================================

# z (ディレクトリジャンプ) の設定
set -g Z_CMD "z"
set -g Z_DATA "$HOME/.z"

# Ctrl+R でfzfを使った履歴検索のキーバインド
function fish_user_key_bindings
    bind \cr 'fzf_history_search'
end

# Ctrl+R でfzfを使った履歴検索
function fzf_history_search
    history | fzf --height=40% --reverse --query=(commandline) | read -l result
    if test -n "$result"
        commandline "$result"
    end
    commandline -f repaint
end

# Claude Code Company用のエイリアス
alias cc='claude --dangerously-skip-permissions'

# ==== MCP統合版 Claude Code Company ====

# 利用可能なMCP情報
set -g MCP_SERVICES "supabase" "playwright" "obsidian" "stripe" "linebot" "context7"
set -g MCP_DESCRIPTIONS \
    "supabase:データベース、認証、API管理" \
    "playwright:ブラウザ自動化、E2Eテスト、スクリーンショット" \
    "obsidian:ノート管理、ナレッジベース、セマンティック検索" \
    "stripe:決済処理、サブスクリプション、顧客管理" \
    "linebot:メッセージ送信、通知、Flexメッセージ" \
    "context7:最新ライブラリドキュメント、API仕様"

# MCP接続確認関数
function check_mcp_services
    echo "🔍 Claude Code Company MCP Services Status"
    echo "==========================================="
    
    echo "📊 利用可能なMCPサーバー:"
    for desc in $MCP_DESCRIPTIONS
        set service_info (string split ":" $desc)
        set service_name $service_info[1]
        set service_desc $service_info[2]
        printf "  %-12s: %s\n" $service_name $service_desc
    end
    
    echo ""
    echo "🔧 MCPサーバーバイナリ確認:"
    
    # Context7
    if command -v npx >/dev/null 2>&1
        echo "✅ Context7: npx @upstash/context7-mcp"
    else
        echo "❌ Context7: npx not found"
    end
    
    # Stripe
    if test -n "$STRIPE_SECRET_KEY"
        echo "✅ Stripe: API Key configured"
    else
        echo "⚠️  Stripe: API Key not configured"
    end
    
    # LINE Bot
    if test -n "$LINE_CHANNEL_ACCESS_TOKEN"
        echo "✅ LINE Bot: Access Token configured"
    else
        echo "⚠️  LINE Bot: Access Token not configured"
    end
    
    # Supabase
    if test -n "$SUPABASE_ACCESS_TOKEN"
        echo "✅ Supabase: Access Token configured"
    else
        echo "⚠️  Supabase: Access Token not configured"
    end
    
    # Obsidian
    if test -d "/obsidian-vault"
        echo "✅ Obsidian: Vault mounted"
    else
        echo "⚠️  Obsidian: Vault not mounted"
    end
    
    # Playwright
    if command -v npx >/dev/null 2>&1
        echo "✅ Playwright: Available via npx"
    else
        echo "❌ Playwright: npx not found"
    end
    
    echo ""
end

# Company初期化関数（MCP統合版）
function company_init_with_mcps
    echo "🏢 Claude Code Company with Full MCP Suite"
    echo "==========================================="
    
    # MCPサービス確認
    check_mcp_services
    
    # 既存のcompanyセッションを削除
    tmux kill-session -t company 2>/dev/null
    
    # 新しいcompanyセッションを作成
    tmux new-session -d -s company -c /workspace
    
    # 5つの子プロセス用paneを作成
    tmux split-window -h -t company:0  # 右に分割
    tmux split-window -v -t company:0.1  # 右下を分割
    tmux select-pane -t company:0.0  # 左上に移動
    tmux split-window -v -t company:0.0  # 左を分割
    tmux select-pane -t company:0.2  # 右上に移動
    tmux split-window -v -t company:0.2  # 右上を分割
    tmux select-pane -t company:0.4  # 右下に移動
    tmux split-window -v -t company:0.4  # 右下を分割
    
    # paneにタイトルを設定
    tmux select-pane -t company:0.0 -T "🏢Manager"
    tmux select-pane -t company:0.1 -T "🎨Frontend"
    tmux select-pane -t company:0.2 -T "⚙️Backend"
    tmux select-pane -t company:0.3 -T "🗄️Database"
    tmux select-pane -t company:0.4 -T "🚀DevOps"
    tmux select-pane -t company:0.5 -T "🧪QA"
    
    echo "✅ Company組織構造作成完了"
    
    # Manager paneに戻る
    tmux select-pane -t company:0.0
    
    # セッションにアタッチ
    tmux attach-session -t company
end

# 各部門にMCP役割を割り当て
function company_assign_mcp_roles
    echo "👥 各部門にMCP統合役割を割り当て中..."
    
    # pane IDを取得
    set pane_ids (tmux list-panes -t company -F "#{pane_id}")
    if test (count $pane_ids) -lt 6
        echo "❌ paneが足りません。company_init_with_mcpsを先に実行してください。"
        return 1
    end
    
    set manager_pane $pane_ids[1]
    set frontend_pane $pane_ids[2]
    set backend_pane $pane_ids[3]
    set database_pane $pane_ids[4]
    set devops_pane $pane_ids[5]
    set qa_pane $pane_ids[6]
    
    # 各部門でClaude Code起動 + MCP統合役割説明
    echo "🎨 Frontend部門セットアップ中..."
    tmux send-keys -t $frontend_pane "cc" Enter
    sleep 2
    tmux send-keys -t $frontend_pane "あなたはFrontend部門です。担当MCP: Playwright(E2Eテスト), Obsidian(UIドキュメント), Context7(最新ライブラリ), Stripe(決済UI)。UI/UX開発、React/Vue/Svelteコンポーネント作成、自動テスト実装を担当。完了時は tmux send-keys -t $manager_pane '[Frontend] 完了: 内容' Enter で報告してください。CLAUDE.mdを参照して作業してください。" Enter
    
    echo "⚙️ Backend部門セットアップ中..."
    tmux send-keys -t $backend_pane "cc" Enter
    sleep 2
    tmux send-keys -t $backend_pane "あなたはBackend部門です。担当MCP: Supabase(DB・API), Stripe(決済処理), Context7(最新ライブラリ), LINE Bot(通知)。API開発、サーバーサイドロジック、認証システム、決済システム実装を担当。完了時は tmux send-keys -t $manager_pane '[Backend] 完了: 内容' Enter で報告してください。CLAUDE.mdを参照して作業してください。" Enter
    
    echo "🗄️ Database部門セットアップ中..."
    tmux send-keys -t $database_pane "cc" Enter
    sleep 2
    tmux send-keys -t $database_pane "あなたはDatabase部門です。担当MCP: Supabase(PostgreSQL), Obsidian(DB設計ドキュメント)。DB設計、マイグレーション、データモデリング、パフォーマンス最適化を担当。完了時は tmux send-keys -t $manager_pane '[Database] 完了: 内容' Enter で報告してください。CLAUDE.mdを参照して作業してください。" Enter
    
    echo "🚀 DevOps部門セットアップ中..."
    tmux send-keys -t $devops_pane "cc" Enter
    sleep 2
    tmux send-keys -t $devops_pane "あなたはDevOps部門です。担当MCP: Supabase(プロジェクト管理), Playwright(統合テスト), LINE Bot(デプロイ通知), Obsidian(インフラドキュメント)。CI/CD、Docker、デプロイ、インフラ管理、監視を担当。完了時は tmux send-keys -t $manager_pane '[DevOps] 完了: 内容' Enter で報告してください。CLAUDE.mdを参照して作業してください。" Enter
    
    echo "🧪 QA部門セットアップ中..."
    tmux send-keys -t $qa_pane "cc" Enter
    sleep 2
    tmux send-keys -t $qa_pane "あなたはQA部門です。担当MCP: Playwright(自動テスト), Obsidian(テストドキュメント), LINE Bot(テスト結果通知), Context7(テスト最新情報)。テスト作成、品質保証、バグ検証、テスト自動化を担当。完了時は tmux send-keys -t $manager_pane '[QA] 完了: 内容' Enter で報告してください。CLAUDE.mdを参照して作業してください。" Enter
    
    # Manager pane（親プロセス）の設定
    tmux select-pane -t $manager_pane
    tmux send-keys -t $manager_pane "clear" Enter
    tmux send-keys -t $manager_pane "echo '🏢 Claude Code Company with Full MCP Suite Ready!'" Enter
    tmux send-keys -t $manager_pane "echo '親プロセス（Manager）: 全体統括、要件定義、進捗管理、品質管理を担当'" Enter
    tmux send-keys -t $manager_pane "echo '利用可能MCP: Supabase, Playwright, Obsidian, Stripe, LINE Bot, Context7'" Enter
    tmux send-keys -t $manager_pane "echo ''" Enter
    tmux send-keys -t $manager_pane "echo 'コマンド: assign <部門> <タスク>, company_status, clear_workers, mcp_demo'" Enter
    tmux send-keys -t $manager_pane "echo '部門: frontend, backend, database, devops, qa'" Enter
    tmux send-keys -t $manager_pane "echo ''" Enter
    tmux send-keys -t $manager_pane "echo '🚀 例: assign frontend \"ログイン画面作成、Playwright E2Eテスト、use context7\"'" Enter
    
    echo "✅ 全部門MCP統合役割割り当て完了"
end

# MCP統合タスク割り当て関数
function assign
    if test (count $argv) -lt 2
        echo "❌ 使用法: assign <部門> <タスク内容>"
        echo "部門: frontend, backend, database, devops, qa"
        echo "例: assign frontend 'ログイン画面作成。Playwrightでテスト。use context7'"
        echo ""
        echo "🔧 利用可能MCP:"
        for desc in $MCP_DESCRIPTIONS
            set service_info (string split ":" $desc)
            printf "  %-12s: %s\n" $service_info[1] $service_info[2]
        end
        return 1
    end
    
    set department $argv[1]
    set task_content $argv[2..-1]
    
    # 現在のセッションがcompanyかチェック
    if not tmux has-session -t company 2>/dev/null
        echo "❌ companyセッションが見つかりません。company_init_with_mcpsを実行してください。"
        return 1
    end
    
    # 部門とpane indexのマッピング
    set pane_ids (tmux list-panes -t company -F "#{pane_id}")
    
    switch $department
        case frontend
            set target_pane $pane_ids[2]
            set dept_name "Frontend"
            set mcp_tools "Playwright, Obsidian, Context7, Stripe"
        case backend
            set target_pane $pane_ids[3]
            set dept_name "Backend"
            set mcp_tools "Supabase, Stripe, Context7, LINE Bot"
        case database
            set target_pane $pane_ids[4]
            set dept_name "Database"
            set mcp_tools "Supabase, Obsidian"
        case devops
            set target_pane $pane_ids[5]
            set dept_name "DevOps"
            set mcp_tools "Supabase, Playwright, LINE Bot, Obsidian"
        case qa
            set target_pane $pane_ids[6]
            set dept_name "QA"
            set mcp_tools "Playwright, Obsidian, LINE Bot, Context7"
        case '*'
            echo "❌ 不明な部門: $department"
            echo "有効な部門: frontend, backend, database, devops, qa"
            return 1
    end
    
    set manager_pane $pane_ids[1]
    
    # タスク割り当て（MCP情報付き）
    tmux send-keys -t $target_pane "新しいタスク: $task_content。担当MCP: $mcp_tools。CLAUDE.mdのワークフローに従って作業し、必要に応じてMCPを活用してください。完了時は tmux send-keys -t $manager_pane '[$dept_name] 完了: $task_content' Enter で報告してください。" Enter
    
    echo "✅ $dept_name部門にタスク割り当て完了"
    echo "📋 タスク: $task_content"
    echo "🔧 利用可能MCP: $mcp_tools"
end

# MCP統合デモワークフロー
function mcp_demo
    echo "🚀 Claude Code Company MCP統合ワークフロー デモ"
    echo "================================================"
    
    # 1. MCPサービス確認
    check_mcp_services
    
    # 2. サンプルプロジェクト提案
    echo ""
    echo "📋 ECサイト構築プロジェクト例:"
    echo "assign devops 'Supabaseプロジェクト作成、開発環境構築'"
    echo "assign database 'ユーザー・商品・注文テーブル設計。Supabase使用'"
    echo "assign backend 'Stripe決済API実装、Supabase認証システム。use context7'"
    echo "assign frontend '商品一覧・カート・決済画面作成。Playwright E2Eテスト'"
    echo "assign qa '全機能テスト自動化。Playwright使用、LINE Bot通知'"
    echo ""
    echo "📝 ドキュメント化:"
    echo "assign frontend 'Obsidianで仕様書・API一覧作成'"
    echo ""
    echo "📢 通知設定:"
    echo "assign devops 'LINE Botでデプロイ・エラー通知設定'"
    echo ""
    echo "🎯 高度な例:"
    echo "assign backend 'サブスクリプション機能。Stripe Billing API。use context7でStripe最新機能確認'"
end

# ステータス確認（MCP情報付き）
function company_status
    echo "📊 Claude Code Company Full MCP Status"
    echo "======================================="
    
    if not tmux has-session -t company 2>/dev/null
        echo "❌ companyセッションが見つかりません。"
        return 1
    end
    
    set pane_ids (tmux list-panes -t company -F "#{pane_id}")
    set departments "🏢Manager" "🎨Frontend" "⚙️Backend" "🗄️Database" "🚀DevOps" "🧪QA"
    set mcp_assignments \
        "全MCP統括" \
        "Playwright,Obsidian,Context7,Stripe" \
        "Supabase,Stripe,Context7,LINE Bot" \
        "Supabase,Obsidian" \
        "Supabase,Playwright,LINE Bot,Obsidian" \
        "Playwright,Obsidian,LINE Bot,Context7"
    
    for i in (seq 1 6)
        echo ""
        echo "=== $departments[$i] ==="
        echo "🔧 担当MCP: $mcp_assignments[$i]"
        echo "💬 最新出力:"
        tmux capture-pane -t $pane_ids[$i] -p | tail -5
    end
    echo ""
    echo "======================================="
end

# 全作業者クリア（MCP統合版）
function clear_workers
    echo "🧹 全作業者のコンテキストクリア中..."
    
    if not tmux has-session -t company 2>/dev/null
        echo "❌ companyセッションが見つかりません。"
        return 1
    end
    
    set pane_ids (tmux list-panes -t company -F "#{pane_id}")
    set departments "Frontend" "Backend" "Database" "DevOps" "QA"
    
    # Manager以外（子プロセス）をクリア
    for i in (seq 2 6)
        echo "🧹 $departments[(math $i - 1)]部門クリア中..."
        tmux send-keys -t $pane_ids[$i] "/clear" Enter
        sleep 0.3
    end
    
    echo "✅ 全作業者クリア完了"
    echo "ℹ️  MCPサーバーとの接続は維持されています"
end

# 緊急停止
function emergency_stop
    echo "🚨 緊急停止: 全プロセス終了中..."
    
    if tmux has-session -t company 2>/dev/null
        tmux kill-session -t company
        echo "✅ companyセッション終了"
    else
        echo "ℹ️  companyセッションは既に終了済み"
    end
end

# ヘルプ関数
function company_help
    echo "🏢 Claude Code Company Full MCP Suite"
    echo "====================================="
    echo ""
    echo "🚀 基本コマンド:"
    echo "company               : MCP統合Company環境初期化"
    echo "company_assign_mcp_roles : 各部門にMCP役割割り当て"
    echo "assign <部門> <タスク> : タスク割り当て"
    echo "company_status       : 全部門ステータス確認"
    echo "clear_workers        : 全作業者クリア"
    echo "emergency_stop       : 緊急全停止"
    echo ""
    echo "🔧 MCP関連:"
    echo "check_mcp_services   : 全MCPサービス確認"
    echo "mcp_demo             : MCPワークフロー例"
    echo ""
    echo "📊 利用可能MCP:"
    for desc in $MCP_DESCRIPTIONS
        set service_info (string split ":" $desc)
        printf "  %-12s: %s\n" $service_info[1] $service_info[2]
    end
    echo ""
    echo "🎯 部門: frontend, backend, database, devops, qa"
    echo ""
    echo "💡 例:"
    echo "company"
    echo "company_assign_mcp_roles"
    echo "assign frontend 'ログイン画面作成。Playwright E2Eテスト。use context7'"
    echo "assign backend 'Stripe決済API実装。Supabase認証統合'"
    echo "company_status"
end

# エイリアス設定
alias company='company_init_with_mcps'
alias roles='company_assign_mcp_roles'
alias help='company_help'
alias demo='mcp_demo'
alias mcp='check_mcp_services'

# 基本設定
set -g fish_greeting ""
set -gx PATH $PATH /usr/local/bin

# 基本エイリアス
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# 開発用エイリアス
alias dc='docker-compose'
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
alias dcl='docker-compose logs -f'

# Git エイリアス
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

echo "🏢 Claude Code Company Full MCP Suite loaded!"
echo "Type 'help' for commands or 'company' to start"
