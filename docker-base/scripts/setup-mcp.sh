#!/bin/bash

# MCP Server Setup Script for Claude Code
# Docker内でMCPサーバーの設定を行うスクリプト


# カラー定義
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}${BOLD}======================================${NC}"
echo -e "${BLUE}${BOLD}    MCP Server Setup for Claude Code${NC}"
echo -e "${BLUE}${BOLD}======================================${NC}"
echo ""

# テンプレートファイルから設定を読み込む
template_file="/opt/claude-system/config/mcp-servers.json"

if [ ! -f "$template_file" ]; then
    echo -e "${RED}[ERROR]${NC} テンプレートファイルが見つかりません: $template_file"
    exit 1
fi

# 既存のMCPサーバーを削除
echo -e "${BLUE}[INFO]${NC} 既存のMCPサーバーを削除中..."
for server in $(claude mcp list 2>/dev/null | grep -E '^[a-zA-Z0-9-]+:' | cut -d':' -f1); do
    echo "  - $server を削除中..."
    claude mcp remove -s user "$server" >/dev/null 2>&1
done

# MCPサーバーを追加
echo -e "${BLUE}[INFO]${NC} MCPサーバーを追加中..."
echo ""

# jqを使ってサーバー情報を解析し、claude mcp addコマンドを実行
servers=$(jq -r '.mcpServers | to_entries[] | .key' "$template_file")

for server in $servers; do
    echo -e "${YELLOW}[INFO]${NC} $server を追加中..."
    
    # サーバー情報を取得（ハイフンを含む名前に対応）
    command=$(jq -r ".mcpServers[\"$server\"].command" "$template_file")
    args=$(jq -r ".mcpServers[\"$server\"].args[]" "$template_file" 2>/dev/null | tr '\n' ' ')
    
    # コマンドを構築
    cmd="claude mcp add -s user $server"
    
    # 環境変数を処理
    # jqで環境変数のキーを取得
    env_keys=$(jq -r ".mcpServers[\"$server\"].env | keys[]?" "$template_file" 2>/dev/null)
    
    for key in $env_keys; do
        # 環境変数の値を取得
        value=$(jq -r ".mcpServers[\"$server\"].env[\"$key\"]" "$template_file")
        
        # 環境変数の展開処理
        if [ "$key" = "OBSIDIAN_HOST" ]; then
            # OBSIDIAN_HOSTのデフォルト値処理
            if [ -z "$OBSIDIAN_HOST" ]; then
                expanded_value="localhost:27123"
            else
                expanded_value="$OBSIDIAN_HOST"
            fi
            cmd="$cmd -e \"$key=$expanded_value\""
        else
            # その他の環境変数
            # 値が${VARIABLE}形式の場合、環境変数を展開
            if echo "$value" | grep -q '^\${.*}$'; then
                var_name=$(echo "$value" | sed 's/^\${//' | sed 's/}$//')
                # 環境変数が設定されているか確認
                if [ -n "$(eval echo \$$var_name)" ]; then
                    expanded_value=$(eval echo \$$var_name)
                    cmd="$cmd -e \"$key=$expanded_value\""
                fi
            else
                # 通常の値の場合はそのまま使用
                cmd="$cmd -e \"$key=$value\""
            fi
        fi
    done
    
    # -- を追加（コマンドとの区切り）
    cmd="$cmd --"
    
    # コマンドと引数を追加
    cmd="$cmd $command $args"
    
    # コマンドを実行
    eval "$cmd"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} $server を追加しました"
    else
        echo -e "${RED}[ERROR]${NC} $server の追加に失敗しました"
    fi
    echo ""
done

# 環境変数の確認
echo -e "${BLUE}[INFO]${NC} 環境変数の設定状況:"
echo "  GITHUB_TOKEN: $([ -n "$GITHUB_TOKEN" ] && echo "設定済み" || echo "未設定")"
echo "  SUPABASE_ACCESS_TOKEN: $([ -n "$SUPABASE_ACCESS_TOKEN" ] && echo "設定済み" || echo "未設定")"
echo "  STRIPE_SEC_KEY: $([ -n "$STRIPE_SEC_KEY" ] && echo "設定済み" || echo "未設定")"
echo "  CHANNEL_ACCESS_TOKEN: $([ -n "$CHANNEL_ACCESS_TOKEN" ] && echo "設定済み" || echo "未設定")"
echo "  DESTINATION_USER_ID: $([ -n "$DESTINATION_USER_ID" ] && echo "設定済み" || echo "未設定")"
echo "  OBSIDIAN_API_KEY: $([ -n "$OBSIDIAN_API_KEY" ] && echo "設定済み" || echo "未設定")"
echo "  OBSIDIAN_HOST: $([ -n "$OBSIDIAN_HOST" ] && echo "$OBSIDIAN_HOST" || echo "localhost:27123 (デフォルト)")"
echo ""

# 設定完了の確認
echo -e "${BLUE}[INFO]${NC} 現在のMCPサーバー設定:"
claude mcp list

echo ""
echo -e "${GREEN}${BOLD}======================================${NC}"
echo -e "${GREEN}${BOLD}    MCP Server Setup Complete!${NC}"
echo -e "${GREEN}${BOLD}======================================${NC}"
echo ""