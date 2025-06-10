#!/bin/bash

# Docker Entrypoint Script
# Master Claude System環境準備

set -e

# Master Claudeスクリプトの実行権限
if [ -f "/workspace/master-claude.sh" ]; then
    chmod +x /workspace/master-claude.sh
fi

# 初期化メッセージ
cat << 'WELCOME'
🚀 Master Claude System v2.0

動的親子プロセス管理システムへようこそ！

開始コマンド:
  master     - Master Claudeを起動（推奨）
  check_mcp  - MCPサーバーの状態確認

注意: 初回起動時は自動的にMCPサーバーが設定されます。

WELCOME

# developerユーザーとしてfishシェルを起動
exec su - developer -c "cd /workspace && exec fish"