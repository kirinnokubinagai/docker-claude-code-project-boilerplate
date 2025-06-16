#!/bin/bash

# Claude初回実行時の設定を事前に行うスクリプト

echo "Claude設定を初期化中..."

# 必要な設定を事前に行う
claude config set -g autoUpdaterStatus "not_configured" 2>/dev/null || true
claude config set -g verbose false 2>/dev/null || true
claude config set -g preferredNotifChannel "terminal_bell" 2>/dev/null || true
claude config set -g shiftEnterKeyBindingInstalled true 2>/dev/null || true
claude config set -g editorMode "normal" 2>/dev/null || true
claude config set -g autoCompactEnabled true 2>/dev/null || true
claude config set -g diffTool "auto" 2>/dev/null || true
claude config set -g parallelTasksCount 1 2>/dev/null || true
claude config set -g todoFeatureEnabled true 2>/dev/null || true
claude config set -g messageIdleNotifThresholdMs 60000 2>/dev/null || true

# MCPサーバーの設定も確認
if [ ! -f "$HOME/.claude/config/mcp-servers.json" ]; then
    mkdir -p "$HOME/.claude/config"
    echo "{}" > "$HOME/.claude/config/mcp-servers.json"
fi

echo "Claude設定が完了しました"