#!/bin/bash

# Claude with MCP wrapper
# MCPが設定されていることを確認してからClaudeを起動

# MCPサーバーが設定されているかチェック
if ! claude mcp list 2>/dev/null | grep -q "github:"; then
    # 未設定の場合は設定を実行
    echo "MCP設定を適用中..."
    /opt/claude-system/scripts/setup-mcp.sh >/dev/null 2>&1
fi

# Claudeを起動
exec claude --dangerously-skip-permissions "$@"