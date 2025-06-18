#!/bin/bash

# Quick MCP Setup Script
# tmux内で高速にMCP設定を適用するスクリプト

# 環境変数を読み込む（.bashrcで既に読み込まれているはずだが念のため）
if [ -f /workspace/.env ]; then
    export $(grep -v '^#' /workspace/.env 2>/dev/null | xargs) 2>/dev/null
fi
if [ -f /workspace/.env.mcp ]; then
    export $(grep -v '^#' /workspace/.env.mcp 2>/dev/null | xargs) 2>/dev/null
fi

# MCPサーバーが既に設定されているかチェック
if claude mcp list 2>/dev/null | grep -q "github:"; then
    # 既に設定済みの場合はスキップ
    exit 0
fi

# 設定ファイルの場所を決定
if [ -f "/workspace/mcp-servers.json" ]; then
    template_file="/workspace/mcp-servers.json"
else
    template_file="/opt/claude-system/config/mcp-servers.json"
fi

# 環境変数を使用してMCPサーバーを直接追加（高速化のため）
# GitHub
if [ ! -z "$GITHUB_TOKEN" ]; then
    claude mcp add -s user -c npx -a "-y" -a "@modelcontextprotocol/server-github" --env "GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_TOKEN" github >/dev/null 2>&1 &
fi

# Supabase
if [ ! -z "$SUPABASE_ACCESS_TOKEN" ]; then
    claude mcp add -s user -c npx -a "-y" -a "@modelcontextprotocol/server-supabase" --env "SUPABASE_ACCESS_TOKEN=$SUPABASE_ACCESS_TOKEN" supabase >/dev/null 2>&1 &
fi

# Obsidian
if [ ! -z "$OBSIDIAN_API_KEY" ]; then
    claude mcp add -s user -c npx -a "-y" -a "mcp-obsidian" --env "OBSIDIAN_API_KEY=$OBSIDIAN_API_KEY" --env "OBSIDIAN_HOST=${OBSIDIAN_HOST:-localhost:27123}" obsidian >/dev/null 2>&1 &
fi

# 他の必須サーバー（環境変数不要）を追加
claude mcp add -s user -c npx -a "-y" -a "@modelcontextprotocol/server-playwright" --env "PLAYWRIGHT_MCP_PORT=${PLAYWRIGHT_MCP_PORT:-8931}" mcp-playwright >/dev/null 2>&1 &
claude mcp add -s user -c npx -a "-y" -a "@context7/mcp-server" context7 >/dev/null 2>&1 &

# バックグラウンドジョブを待つ（最大5秒）
wait_time=0
while [ $wait_time -lt 5 ] && jobs -r | grep -q .; do
    sleep 0.5
    wait_time=$((wait_time + 1))
done