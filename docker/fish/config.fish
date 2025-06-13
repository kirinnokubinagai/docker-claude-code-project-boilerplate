# Fish Shell Configuration for Master Claude Teams System

# PATH設定（重複を避ける）
set -g fish_user_paths /usr/local/bin $fish_user_paths
set -U fish_user_paths (printf '%s\n' $fish_user_paths | awk '!a[$0]++')

# setup_dynamic_teams関数の定義
function setup_dynamic_teams
    echo "📋 動的チーム構成を初期化しています..."
    # 動的チーム構成は master コマンドで処理される
end

# Claude API設定
if test -n "$ANTHROPIC_API_KEY"
    set -x ANTHROPIC_API_KEY $ANTHROPIC_API_KEY
end

# エイリアスとカスタムコマンド
alias ll='ls -la'
alias master='env -u TMUX /workspace/scripts/master-claude-teams-fixed.fish'
alias check_mcp='claude mcp list'
alias cc='claude --dangerously-skip-permissions'

# 実行可能ファイルの確認と権限付与
if test -f /workspace/scripts/master-claude-teams-fixed.fish
    chmod +x /workspace/scripts/master-claude-teams-fixed.fish 2>/dev/null
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
function tmux_help
    echo "🚀 Master Claude Teams System - ヘルプ"
    echo ""
    echo "基本コマンド:"
    echo "  master          - Master Claude Teamsシステムを起動"
    echo "  cc              - Claude CLIを直接使用"
    echo "  check_mcp       - MCPサーバーの状態確認"
    echo ""
    echo "ワークフロー:"
    echo "  1. cc            - アプリ要件を説明 → teams.json生成"
    echo "  2. master        - teams.jsonに基づいてチーム起動"
    echo "  3. tmux attach   - セッションに接続"
    echo ""
    echo "tmux操作:"
    echo "  接続:"
    echo "    tmux attach -t claude-teams  - セッションに接続"
    echo "    tmux list-sessions           - セッション一覧"
    echo "    tmux list-panes              - ペイン一覧"
    echo ""
    echo "  ペイン操作:"
    echo "    Ctrl+a → 矢印キー  - ペイン間移動"
    echo "    Ctrl+a → z         - ペイン最大化/復元"
    echo "    Ctrl+a → d         - デタッチ（終了せず切断）"
    echo "    Ctrl+a → x         - ペインを閉じる（確認あり）"
    echo ""
    echo "  スクロール:"
    echo "    Ctrl+a → [         - スクロールモード開始"
    echo "    矢印/PageUp/Down   - スクロール"
    echo "    q                  - スクロールモード終了"
    echo ""
    echo "  レイアウト:"
    echo "    Ctrl+a → スペース  - レイアウト切替"
    echo "    Ctrl+a → Alt+1~5   - プリセットレイアウト"
    echo ""
    echo "設定ファイル:"
    echo "  config/teams.json - チーム構成設定"
    echo "  .env              - 環境変数設定"
    echo ""
end

# 初回起動時の説明
if not test -f /home/developer/.claude_initialized
    echo ""
    echo "====================================="
    echo "🚀 Claude Code チームシステムへようこそ"
    echo "====================================="
    echo ""
    echo "📝 使い方："
    echo "  1. 'cc' でClaudeに作りたいアプリを説明"
    echo "  2. 'master' でチームを起動"
    echo "  3. チームがアプリを開発します"
    echo ""
    echo "====================================="
    echo ""
    touch /home/developer/.claude_initialized
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
    echo "  tmux_help  - 全コマンドとtmuxヘルプを表示"
    echo ""
    echo "🔧 tmux操作ガイド:"
    echo "  tmux attach -t claude-teams  - セッションに接続"
    echo "  Ctrl+a → 矢印キー           - ペイン間移動"
    echo "  Ctrl+a → z                   - ペイン最大化/復元"
    echo "  Ctrl+a → d                   - デタッチ（終了せず切断）"
    echo "  Ctrl+a → [                   - スクロールモード（qで終了）"
    echo "  Ctrl+a → スペース           - レイアウト変更"
    echo ""
    set -x CLAUDE_GREETING_SHOWN 1
end
