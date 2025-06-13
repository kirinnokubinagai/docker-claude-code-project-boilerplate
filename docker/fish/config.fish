# Fish Shell Configuration for Master Claude Teams System

# PATH設定（重複を避ける）
set -g fish_user_paths /usr/local/bin $fish_user_paths
set -U fish_user_paths (printf '%s\n' $fish_user_paths | awk '!a[$0]++')

# setup_dynamic_teams関数の定義（エラー回避のため）
function setup_dynamic_teams
    echo "📋 動的チーム構成を初期化しています..."
    if test -f /workspace/join-company.fish
        /workspace/join-company.fish --dynamic
    else
        echo "⚠️  join-company.fishが見つかりません"
    end
end

# Claude API設定
if test -n "$ANTHROPIC_API_KEY"
    set -x ANTHROPIC_API_KEY $ANTHROPIC_API_KEY
end

# エイリアスとカスタムコマンド
alias ll='ls -la'
alias master='/workspace/master-claude-teams.fish'
alias join-company='/workspace/join-company.fish'
alias check_mcp='claude mcp list'
alias cc='claude --dangerously-skip-permissions'

# 実行可能ファイルの確認と権限付与
if test -f /workspace/master-claude-teams.fish
    chmod +x /workspace/master-claude-teams.fish 2>/dev/null
end
if test -f /workspace/join-company.fish
    chmod +x /workspace/join-company.fish 2>/dev/null
end

# プロンプトカスタマイズ
function fish_prompt
    set -l last_status $status
    set -l user (whoami)
    set -l host (hostname)
    set -l pwd (pwd | sed -e "s|^$HOME|~|")
    
    # ユーザー名@ホスト名
    echo -n (set_color green)"$user"(set_color normal)"@"(set_color blue)"$host"(set_color normal)
    
    # 現在のディレクトリ
    echo -n " "(set_color yellow)"$pwd"(set_color normal)
    
    # プロンプト記号
    if test $last_status -eq 0
        echo -n (set_color green)"> "(set_color normal)
    else
        echo -n (set_color red)"> "(set_color normal)
    end
end

# グリーティングメッセージは無効化（動的チーム構成の後に表示）
set fish_greeting ""

# zはconf.d/z.fishで自動的に読み込まれる

# ヘルプメッセージ関数
function help
    echo "🚀 Master Claude Teams System - ヘルプ"
    echo ""
    echo "基本コマンド:"
    echo "  master          - Master Claude Teamsシステムを起動"
    echo "  cc              - Claude CLIを直接使用"
    echo "  claude mcp list - MCPサーバーの状態確認"
    echo ""
    echo "チーム管理:"
    echo "  join-company.fish <template>    - 手動でチーム追加"
    echo ""
    echo "ユーティリティ:"
    echo "  z <directory>   - ディレクトリ履歴から高速移動"
    echo "  ll              - 詳細なファイルリスト表示"
    echo ""
    echo "設定ファイル:"
    echo "  config/teams.json - チーム構成設定"
    echo "  .env              - 環境変数設定"
end

# 動的チーム構成の自動実行（初回のみ）
if test -f /workspace/config/teams.json
    set teams_count (jq -r '.teams | length' /workspace/config/teams.json 2>/dev/null || echo 0)
    if test "$teams_count" = "0"
        # 初回起動フラグファイルをチェック
        if not test -f /home/developer/.claude_initialized
            echo ""
            echo "====================================="
            echo "🚀 Claude Code 動的チーム構成の初期化"
            echo "====================================="
            echo ""
            echo "プロジェクトに最適なチーム構成を自動で作成します。"
            echo ""
            
            # join-company.fishが存在する場合のみ実行
            if test -f /workspace/join-company.fish
                # 動的チーム構成を実行
                /workspace/join-company.fish --dynamic
                
                # 初回起動フラグを作成
                touch /home/developer/.claude_initialized
                
                echo ""
                echo "✅ チーム構成が完了しました！"
                echo ""
                echo "📝 使い方："
                echo "  1. 'master' コマンドでtmuxセッションを開始"
                echo "  2. 各チームが自動的に専用ウィンドウで起動します"
                echo ""
                echo "====================================="
                echo ""
            else
                echo "⚠️  join-company.fishが見つかりません。手動でセットアップしてください。"
                echo ""
            end
        else
            echo ""
            echo "💡 プロジェクトのチーム構成がまだ設定されていません"
            echo ""
            echo "   1. 'cc'でClaude Codeを起動"
            echo "   2. 動的チーム構成でプロジェクトを開始することを伝える"
            echo "   3. 要件に基づいて最適なチーム構成が自動生成されます"
            echo ""
        end
    end
else
    # teams.jsonが存在しない場合
    if not test -f /home/developer/.claude_initialized
        echo ""
        echo "====================================="
        echo "🚀 Claude Code 動的チーム構成の初期化"
        echo "====================================="
        echo ""
        echo "プロジェクトに最適なチーム構成を自動で作成します。"
        echo ""
        
        if test -f /workspace/join-company.fish
            /workspace/join-company.fish --dynamic
            touch /home/developer/.claude_initialized
            echo ""
            echo "✅ チーム構成が完了しました！"
            echo ""
            echo "📝 使い方："
            echo "  1. 'master' コマンドでtmuxセッションを開始"
            echo "  2. 各チームが自動的に専用ウィンドウで起動します"
            echo ""
            echo "====================================="
            echo ""
        end
    end
end

# システム起動メッセージ（動的チーム構成の後に表示）
# インタラクティブシェルの場合のみ表示
if status is-interactive; and not set -q CLAUDE_GREETING_SHOWN
    echo ""
    echo "🚀 Master Claude Teams System"
    echo "📍 ユーザー: "(whoami)" | ホーム: "$HOME
    echo ""
    echo "📋 使用可能なコマンド:"
    echo "  cc         - 全権限claudeコマンド"
    echo "  master     - 並列システムを起動"
    echo "  check_mcp  - MCPサーバーの状態確認"
    echo "  help       - 全コマンドとヘルプを表示"
    echo ""
    set -x CLAUDE_GREETING_SHOWN 1
end
