#!/bin/bash

# Docker Entrypoint Script
# Claude Code起動時にMCPサーバーを自動設定

set -e

# MCPサーバー設定ファイルのパス
MCP_CONFIG_DIR="/home/developer/.config/claude"
MCP_CONFIG_FILE="$MCP_CONFIG_DIR/mcp_servers.json"

# ディレクトリ作成
mkdir -p "$MCP_CONFIG_DIR"

# MCPサーバー設定を生成
cat > "$MCP_CONFIG_FILE" << 'EOF'
{
  "servers": {
    "supabase": {
      "command": "npx",
      "args": ["@supabase/mcp-server-supabase"],
      "env": {
        "SUPABASE_ACCESS_TOKEN": "${SUPABASE_ACCESS_TOKEN}"
      },
      "description": "Supabase database and authentication"
    },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp"],
      "env": {
        "PLAYWRIGHT_HEADLESS": "${PLAYWRIGHT_HEADLESS}",
        "PLAYWRIGHT_TIMEOUT": "${PLAYWRIGHT_TIMEOUT}"
      },
      "description": "Browser automation and E2E testing"
    },
    "obsidian": {
      "command": "python",
      "args": ["-m", "mcp_obsidian"],
      "env": {
        "OBSIDIAN_VAULT_PATH": "/obsidian-vault"
      },
      "description": "Knowledge management and documentation"
    },
    "stripe": {
      "command": "npx",
      "args": ["@stripe/mcp"],
      "env": {
        "STRIPE_SECRET_KEY": "${STRIPE_SECRET_KEY}",
        "STRIPE_PUBLISHABLE_KEY": "${STRIPE_PUBLISHABLE_KEY}"
      },
      "description": "Payment processing and subscriptions"
    },
    "linebot": {
      "command": "npx",
      "args": ["@line/line-bot-mcp-server"],
      "env": {
        "LINE_CHANNEL_ACCESS_TOKEN": "${LINE_CHANNEL_ACCESS_TOKEN}",
        "DESTINATION_USER_ID": "${DESTINATION_USER_ID}"
      },
      "description": "LINE messaging and notifications"
    },
    "context7": {
      "command": "npx",
      "args": ["@upstash/context7-mcp"],
      "env": {
        "DEFAULT_MINIMUM_TOKENS": "${DEFAULT_MINIMUM_TOKENS}"
      },
      "description": "Latest library documentation and APIs"
    }
  }
}
EOF

# 環境変数を展開
envsubst < "$MCP_CONFIG_FILE" > "$MCP_CONFIG_FILE.tmp"
mv "$MCP_CONFIG_FILE.tmp" "$MCP_CONFIG_FILE"

# Claude Code設定ディレクトリの権限設定
chown -R developer:developer "$MCP_CONFIG_DIR"

# オーケストレーションスクリプトの実行権限
if [ -f "/workspace/claude-orchestrator.sh" ]; then
    chmod +x /workspace/claude-orchestrator.sh
fi

if [ -f "/workspace/parent-child-comm.sh" ]; then
    chmod +x /workspace/parent-child-comm.sh
fi

# Claude Codeの初期化メッセージ
cat << 'WELCOME'
🚀 Claude Code Company - Full MCP Integration Ready!

利用可能なMCPサーバー:
  - Supabase: データベース、認証
  - Playwright: E2Eテスト、ブラウザ自動化
  - Obsidian: ドキュメント管理
  - Stripe: 決済処理
  - LINE Bot: 通知システム
  - Context7: 最新ライブラリ情報

開始コマンド:
  company  - tmux環境を起動
  roles    - 各部門にClaude Code割り当て
  /workspace/claude-orchestrator.sh init - オーケストレーター初期化

WELCOME

# developerユーザーとしてfishシェルを起動
exec su - developer -c "cd /workspace && exec fish"