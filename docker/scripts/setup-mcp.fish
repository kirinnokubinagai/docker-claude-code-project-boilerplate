#!/usr/bin/env fish

# MCP Server Setup Script for Claude Code
# Docker内でMCPサーバーの設定を行うスクリプト

set -g BLUE (set_color blue 2>/dev/null; or echo "")
set -g GREEN (set_color green 2>/dev/null; or echo "")
set -g YELLOW (set_color yellow 2>/dev/null; or echo "")
set -g RED (set_color red 2>/dev/null; or echo "")
set -g BOLD (set_color --bold 2>/dev/null; or echo "")
set -g NC (set_color normal 2>/dev/null; or echo "")

echo ""
echo "$BLUE$BOLD======================================$NC"
echo "$BLUE$BOLD    MCP Server Setup for Claude Code$NC"
echo "$BLUE$BOLD======================================$NC"
echo ""

# Claude Code設定ディレクトリ
set -l config_dir "$HOME/.claude"
set -l config_file "$config_dir/claude_desktop_config.json"

# 設定ディレクトリ作成
mkdir -p $config_dir

# 既存の設定をバックアップ
if test -f $config_file
    echo "$YELLOW[INFO]$NC 既存の設定をバックアップ中..."
    cp $config_file "$config_file.backup"(date +%Y%m%d%H%M%S)
end

# MCP設定を生成
echo "$BLUE[INFO]$NC MCP設定ファイルを生成中..."

# テンプレートファイルから設定を読み込み、無効化されていないサーバーのみをフィルタ
set -l template_file "/workspace/docker/config/mcp-servers.json"

if test -f $template_file
    # jqを使って無効化されていないサーバーのみを抽出し、環境変数を展開
    jq 'del(.mcpServers | to_entries[] | select(.value.disabled == true))' $template_file | \
    envsubst > $config_file
    
    echo "$GREEN[SUCCESS]$NC テンプレートから設定を生成しました"
else
    echo "$RED[ERROR]$NC テンプレートファイルが見つかりません: $template_file"
    exit 1
end

echo "$GREEN[SUCCESS]$NC MCP設定ファイルを作成しました: $config_file"
echo ""

# 環境変数の確認
echo "$BLUE[INFO]$NC 環境変数の設定状況:"
echo ""

if test -n "$GITHUB_TOKEN"
    echo "  ✅ GITHUB_TOKEN: 設定済み"
else
    echo "  ❌ GITHUB_TOKEN: 未設定"
    echo "     → GitHub MCPを使用するには設定が必要です"
end

if test -n "$SUPABASE_ACCESS_TOKEN"
    echo "  ✅ SUPABASE_ACCESS_TOKEN: 設定済み"
else
    echo "  ⚠️  SUPABASE_ACCESS_TOKEN: 未設定（オプション）"
end

echo ""
echo "$BLUE[INFO]$NC 利用可能なMCPサーバー:"
echo ""
echo "  📁 filesystem  - ファイルシステムアクセス"
echo "  🐙 github      - GitHub操作（要: GITHUB_TOKEN）"
echo "  🎭 playwright  - ブラウザ自動化"
echo "  🌐 everything  - 統合サーバー"
echo ""

# 無効化されているMCPサーバーの確認
echo "$YELLOW[INFO]$NC 利用可能な追加MCPサーバー（現在無効）:"
echo ""

# テンプレートから無効化されているサーバーを表示
set -l disabled_servers (jq -r '.mcpServers | to_entries[] | select(.value.disabled == true) | .key' $template_file)

for server in $disabled_servers
    switch $server
        case "supabase"
            echo "  🗄️  supabase    - Supabase操作（要: SUPABASE_ACCESS_TOKEN）"
        case "context7"
            echo "  📚 context7    - ドキュメント検索"
        case "design-reference"
            echo "  🎨 design-ref  - デザインリファレンス"
        case "obsidian"
            echo "  📝 obsidian    - Obsidianノート操作（要: OBSIDIAN_API_KEY）"
        case "line-bot"
            echo "  💬 line-bot    - LINE Bot操作（要: LINE_CHANNEL_ACCESS_TOKEN）"
    end
end

echo ""
echo "$YELLOW[TIP]$NC 追加のMCPサーバーを有効にするには:"
echo "  1. /workspace/docker/config/mcp-servers.json を編集"
echo "  2. 使いたいサーバーの 'disabled: true' を削除"
echo "  3. setup-mcp を再実行"
echo ""

# 設定の確認
echo "$BLUE[INFO]$NC MCP設定を確認するには:"
echo "  cat $config_file | jq ."
echo ""
echo "$BLUE[INFO]$NC MCPサーバーの状態を確認するには:"
echo "  claude mcp list"
echo "  または"
echo "  check_mcp"
echo ""

echo "$GREEN[SUCCESS]$NC MCP設定が完了しました！"
echo ""
echo "⚠️  注意: Claude Codeを再起動して設定を反映してください"
echo ""