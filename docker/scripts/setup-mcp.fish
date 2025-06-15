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
echo $BLUE$BOLD"======================================"$NC
echo $BLUE$BOLD"    MCP Server Setup for Claude Code"$NC
echo $BLUE$BOLD"======================================"$NC
echo ""

# テンプレートファイルから設定を読み込む
set -l template_file "/workspace/docker/config/mcp-servers.json"

if not test -f $template_file
    echo $RED"[ERROR]"$NC" テンプレートファイルが見つかりません: $template_file"
    exit 1
end

# 既存のMCPサーバーを削除
echo $BLUE"[INFO]"$NC" 既存のMCPサーバーを削除中..."
for server in (claude mcp list -s user 2>/dev/null | grep -E '^[a-zA-Z0-9-]+:' | cut -d':' -f1)
    echo "  - $server を削除中..."
    claude mcp remove -s user $server >/dev/null 2>&1
end

# MCPサーバーを追加
echo $BLUE"[INFO]"$NC" MCPサーバーを追加中..."
echo ""

# jqを使ってサーバー情報を解析し、claude mcp addコマンドを実行
set -l servers (jq -r '.mcpServers | to_entries[] | .key' $template_file)

for server in $servers
    echo $YELLOW"[INFO]"$NC" $server を追加中..."
    
    # サーバー情報を取得（ハイフンを含む名前に対応）
    set -l command (jq -r ".mcpServers[\"$server\"].command" $template_file)
    set -l args (jq -r ".mcpServers[\"$server\"].args[]" $template_file)
    set -l env_vars (jq -r ".mcpServers[\"$server\"].env | to_entries[] | \"\(.key)=\(.value)\"" $template_file)
    
    # コマンドを構築
    set -l cmd "claude mcp add -s user"
    
    # サーバー名を追加
    set cmd $cmd $server
    
    # 環境変数を追加
    for env_var in $env_vars
        # キーと値を分離
        set -l key (echo $env_var | cut -d'=' -f1)
        set -l value (echo $env_var | cut -d'=' -f2-)
        
        # 環境変数の値を取得（デフォルト値の処理）
        if test "$key" = "OBSIDIAN_HOST"
            if test -z "$OBSIDIAN_HOST"
                set -l expanded_value "localhost:27123"
            else
                set -l expanded_value "$OBSIDIAN_HOST"
            end
            set cmd $cmd "-e" "$key=$expanded_value"
        else
            # 通常の環境変数展開
            set -l expanded_var (echo $env_var | envsubst)
            # デバッグ出力
            # echo "  環境変数: $env_var -> $expanded_var"
            
            # 環境変数の値を確認
            # key=value形式で、valueが$で始まる場合は未展開と判断
            set -l var_value (echo $expanded_var | cut -d'=' -f2-)
            if string match -q "\$*" $var_value
                # 環境変数名を取得
                set -l var_name (echo $var_value | sed 's/^\$//' | sed 's/{//' | sed 's/}//')
                # 実際の環境変数の値を確認
                if test -n "$$var_name"
                    # 環境変数が設定されている場合は追加
                    set cmd $cmd "-e" $expanded_var
                    # echo "  → 環境変数が設定されています"
                else
                    # echo "  → 環境変数が未設定です（スキップ）"
                end
            else
                # 展開済みの場合はそのまま追加
                set cmd $cmd "-e" $expanded_var
            end
        end
    end
    
    # -- を追加（コマンドとの区切り）
    set cmd $cmd "--"
    
    # コマンドと引数を追加
    set cmd $cmd $command $args
    
    # コマンドを実行
    # デバッグ: 実行するコマンドを表示
    # echo "実行コマンド: $cmd"
    eval $cmd
    
    if test $status -eq 0
        echo $GREEN"[SUCCESS]"$NC" $server を追加しました"
    else
        echo $RED"[ERROR]"$NC" $server の追加に失敗しました"
    end
    echo ""
end

# 環境変数の確認
echo $BLUE"[INFO]"$NC" 環境変数の設定状況:"
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

if test -n "$OBSIDIAN_API_KEY"
    echo "  ✅ OBSIDIAN_API_KEY: 設定済み"
else
    echo "  ⚠️  OBSIDIAN_API_KEY: 未設定（オプション）"
end

if test -n "$CHANNEL_ACCESS_TOKEN"
    echo "  ✅ CHANNEL_ACCESS_TOKEN: 設定済み"
else
    echo "  ⚠️  CHANNEL_ACCESS_TOKEN: 未設定（オプション）"
end

if test -n "$STRIPE_SECRET_KEY"
    echo "  ✅ STRIPE_SECRET_KEY: 設定済み"
else
    echo "  ⚠️  STRIPE_SECRET_KEY: 未設定（オプション）"
end

echo ""
echo $BLUE"[INFO]"$NC" 追加されたMCPサーバー:"
echo ""

# 追加されたサーバーを表示
for server in $servers
    switch $server
        case "filesystem"
            echo "  📁 filesystem  - ファイルシステムアクセス"
        case "github"
            echo "  🐙 github      - GitHub操作（要: GITHUB_TOKEN）"
        case "playwright"
            echo "  🎭 playwright  - ブラウザ自動化"
        case "everything"
            echo "  🌐 everything  - 統合サーバー"
        case "supabase"
            echo "  🗄️  supabase    - Supabase操作（要: SUPABASE_ACCESS_TOKEN）"
        case "context7"
            echo "  📚 context7    - ドキュメント検索"
        case "design-reference"
            echo "  🎨 design-ref  - デザインリファレンス"
        case "obsidian"
            echo "  📝 obsidian    - Obsidianノート操作（要: OBSIDIAN_API_KEY）"
        case "line-bot"
            echo "  💬 line-bot    - LINE Bot操作（要: CHANNEL_ACCESS_TOKEN）"
        case "stripe"
            echo "  💳 stripe      - Stripe決済操作（要: STRIPE_SECRET_KEY）"
    end
end
echo ""

# 無効化されているMCPサーバーの確認
echo $YELLOW"[INFO]"$NC" 利用可能な追加MCPサーバー（現在無効）:"

echo ""
echo $YELLOW"[TIP]"$NC" 追加のMCPサーバーを有効にするには:"
echo "  1. /workspace/docker/config/mcp-servers.json を編集"
echo "  2. setup-mcp を再実行"
echo ""

# 設定の確認
echo $BLUE"[INFO]"$NC" MCPサーバーの状態を確認するには:"
echo "  claude mcp list -s user"
echo "  または"
echo "  check_mcp"
echo ""

echo $GREEN"[SUCCESS]"$NC" MCP設定が完了しました！"
echo ""