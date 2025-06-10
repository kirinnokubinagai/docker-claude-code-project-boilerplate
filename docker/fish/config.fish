# ==============================================
# Master Claude System Fish設定
# ==============================================

# 環境変数の設定（Docker環境用）
set -gx WORKSPACE /workspace
set -gx HOME /home/developer
set -gx USER developer

# npmのグローバルパッケージをユーザーディレクトリにインストール
set -gx NPM_CONFIG_PREFIX $HOME/.npm
set -gx PATH $NPM_CONFIG_PREFIX/bin $PATH

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

# ==== Master Claude System v2.0 ====

# 初回起動時のMCPサーバー追加関数
function setup_mcp_servers
    echo "🔧 MCPサーバーを設定中..."
    
    # Supabase
    if test -n "$SUPABASE_ACCESS_TOKEN"
        echo "  追加中: Supabase"
        claude mcp add -s user supabase -e SUPABASE_ACCESS_TOKEN="$SUPABASE_ACCESS_TOKEN" -- npx @supabase/mcp-server-supabase@latest
    else
        echo "  ⚠️  Supabase: SUPABASE_ACCESS_TOKEN が設定されていません"
    end
    
    # Playwright
    echo "  追加中: Playwright"
    claude mcp add -s user playwright -e PLAYWRIGHT_HEADLESS="$PLAYWRIGHT_HEADLESS" -e PLAYWRIGHT_TIMEOUT="$PLAYWRIGHT_TIMEOUT" -- npx @playwright/mcp
    
    # Stripe
    if test -n "$STRIPE_SECRET_KEY"
        echo "  追加中: Stripe"
        claude mcp add -s user stripe -e STRIPE_SECRET_KEY="$STRIPE_SECRET_KEY" -e STRIPE_PUBLISHABLE_KEY="$STRIPE_PUBLISHABLE_KEY" -- npx @stripe/mcp
    else
        echo "  ⚠️  Stripe: STRIPE_SECRET_KEY が設定されていません"
    end
    
    # LINE Bot
    if test -n "$LINE_CHANNEL_ACCESS_TOKEN"
        echo "  追加中: LINE Bot"
        claude mcp add -s user line-bot -e CHANNEL_ACCESS_TOKEN="$LINE_CHANNEL_ACCESS_TOKEN" -e DESTINATION_USER_ID="$DESTINATION_USER_ID" -- npx @line/line-bot-mcp-server
    else
        echo "  ⚠️  LINE Bot: LINE_CHANNEL_ACCESS_TOKEN が設定されていません"
    end
    
    # Obsidian
    if test -d "/obsidian-vault"
        echo "  追加中: Obsidian"
        claude mcp add -s user obsidian -e OBSIDIAN_VAULT_PATH="/obsidian-vault" -- uvx mcp-obsidian
    else
        echo "  ⚠️  Obsidian: /obsidian-vault ディレクトリが見つかりません"
    end
    
    # Context7
    echo "  追加中: Context7"
    if test -n "$DEFAULT_MINIMUM_TOKENS"
        claude mcp add -s user context7 -e DEFAULT_MINIMUM_TOKENS="$DEFAULT_MINIMUM_TOKENS" -- npx @upstash/context7-mcp
    else
        claude mcp add -s user context7 -e DEFAULT_MINIMUM_TOKENS="6000" -- npx @upstash/context7-mcp
    end

    # Sentry
    echo " 追加中: Sentry"
    claude mcp add -s user sentry -- npx mcp-remote@latest https://mcp.sentry.dev/sse
    
    echo "✅ MCPサーバー設定完了"
    echo ""
    
    # 設定完了フラグを作成
    touch ~/.mcp_setup_done
end

# Master Claude 起動関数
function master
    echo "🎯 Master Claude Teams System を起動します..."
    
    # 環境変数の設定
    set -gx WORKSPACE /workspace
    
    # 初回起動時のみMCPサーバーを設定
    if not test -f ~/.mcp_setup_done
        setup_mcp_servers
    end
    
    # スクリプトが存在することを確認
    if test -f /workspace/master-claude-teams.sh
        bash /workspace/master-claude-teams.sh
    else
        echo "❌ master-claude-teams.sh が見つかりません"
        echo "📍 現在のディレクトリ: "(pwd)
        echo "📂 /workspace の内容:"
        ls -la /workspace/
    end
end

# MCP確認関数
function check_mcp
    echo "📊 利用可能なMCPサーバーを確認中..."
    
    # Claude CLIが利用可能か確認
    if not command -v claude >/dev/null 2>&1
        echo "❌ Claude CLIがインストールされていません"
        echo "📦 npm install -g @anthropic-ai/claude-code でインストールしてください"
        return 1
    end
    
    # MCPリストを表示
    if claude mcp list 2>/dev/null
        echo "✅ MCPサーバーの確認が完了しました"
    else
        echo "⚠️  MCPサーバーがまだ設定されていません"
        echo "💡 'master' コマンドを実行すると自動的に設定されます"
    end
end

# MCP手動セットアップ関数
function setup_mcp_manual
    setup_mcp_servers
end

# ヘルプ表示関数
function help_claude
    echo "🚀 Master Claude Teams System - ヘルプ"
    echo ""
    echo "📋 主要コマンド:"
    echo "  master         - 5チーム並列システムを起動"
    echo "  check_mcp      - MCPサーバーの状態確認"
    echo "  setup_mcp_manual - MCPサーバーを手動設定"
    echo "  help_claude    - このヘルプを表示"
    echo ""
    echo "🔧 エイリアス:"
    echo "  cc             - claude --dangerously-skip-permissions"
    echo "  ll, la, l      - ファイル一覧表示"
    echo "  dc, dcu, dcd   - docker-compose操作"
    echo "  gs, ga, gc, gp - Git操作"
    echo ""
    echo "💡 Tips:"
    echo "  初回起動時は 'master' を実行してMCPを設定してください"
    echo "  tmuxの操作は docs/tmux-cheatsheet.md を参照"
end

# ショートカット
alias help='help_claude'

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

# 起動時メッセージ
echo "🚀 Master Claude Teams System"
echo "📍 ユーザー: "(whoami)" | ホーム: $HOME"
echo ""
echo "📋 使用可能なコマンド:"
echo "  master     - 5チーム並列システムを起動"
echo "  check_mcp  - MCPサーバーの状態確認"
echo "  help       - 全コマンドとヘルプを表示"
echo ""

# 初回起動時の自動セットアップ
if not test -f ~/.mcp_setup_done
    echo "⚠️  初回起動を検出しました。"
    echo "👉 'master' コマンドを実行すると、MCPサーバーが自動設定されます。"
    echo ""
end