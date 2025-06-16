#!/bin/bash

# Docker Entrypoint Script
# Master Claude System環境準備

# エラーハンドリング（読み取り専用マウントでの権限エラーを許可）
set -e
set +e  # 一時的にerrexitを無効化（権限関連エラーのため）

# 環境変数の設定
export WORKSPACE="/workspace"

# USER_UID/USER_GIDが環境変数で指定されている場合は、developerユーザーのUID/GIDを変更
if [ ! -z "$USER_UID" ] && [ ! -z "$USER_GID" ] && [ "$USER_UID" != "0" ]; then
    # 現在のdeveloperユーザーのUID/GIDを取得
    CURRENT_UID=$(id -u developer 2>/dev/null || echo "1001")
    CURRENT_GID=$(id -g developer 2>/dev/null || echo "1001")
    
    # 変更が必要な場合のみ実行
    if [ "$CURRENT_UID" != "$USER_UID" ] || [ "$CURRENT_GID" != "$USER_GID" ]; then
        # homeディレクトリの権限を一時的にrootに
        chown -R root:root /home/developer 2>/dev/null || true
        
        # UID/GIDを変更
        groupmod -g $USER_GID developer 2>/dev/null || true
        usermod -u $USER_UID developer 2>/dev/null || true
        
        # homeディレクトリの権限を戻す
        chown -R developer:developer /home/developer 2>/dev/null || true
    fi
fi


# workspaceディレクトリの権限設定（developerユーザーが書き込めるように）
# ただし、.gitディレクトリは除外（既存の権限を保持）
find /workspace -mindepth 1 -maxdepth 1 ! -name '.git' -exec chown -R developer:developer {} \; 2>/dev/null || true

# 新規ファイルのみ権限変更
find /workspace -user root -exec chown developer:developer {} \; 2>/dev/null || true

# scriptsファイルの実行権限
if [ -d "/opt/claude-system/scripts" ]; then
    chmod +x /opt/claude-system/scripts/*.sh
fi

# tmux設定ファイルをコピー（権限を修正してから）
if [ -f "/opt/claude-system/config/.tmux.conf" ]; then
    # rootユーザーとして実行されているので、直接操作
    if [ -f "/home/developer/.tmux.conf" ]; then
        rm -f /home/developer/.tmux.conf 2>/dev/null || true
    fi
    cp /opt/claude-system/config/.tmux.conf /home/developer/.tmux.conf 2>/dev/null || true
    chown developer:developer /home/developer/.tmux.conf 2>/dev/null || true
fi

# Claude Code用の設定ディレクトリ作成
mkdir -p /home/developer/.anthropic /home/developer/.claude
chown -R developer:developer /home/developer/.anthropic /home/developer/.claude

# Dockerソケットの権限調整（developerユーザーが使えるように）
if [ -S /var/run/docker.sock ]; then
    chmod 666 /var/run/docker.sock || true
fi

# 必要なディレクトリを作成（developerユーザー用）
mkdir -p /home/developer/.npm /home/developer/.local /home/developer/.config /home/developer/.cache

# 読み取り専用マウントを除いてchown実行
find /home/developer -type d -writable -exec chown developer:developer {} \; 2>/dev/null || true
find /home/developer -type f -writable -exec chown developer:developer {} \; 2>/dev/null || true

# 環境変数を設定
export HOME=/home/developer
export USER=developer

# MCP設定の自動実行
echo "MCPサーバーを設定中..."
# su -（ハイフン付き）は環境をリセットするので、su（ハイフンなし）を使用
su developer -c "/opt/claude-system/scripts/setup-mcp.sh" || {
    echo "[WARNING] MCP設定に失敗しましたが、続行します..."
}

# 最終段階でエラーハンドリングを再有効化
set -e

# 引数があればそのコマンドを、なければbashシェルを起動
if [ $# -eq 0 ]; then
    # デフォルト: bashシェル
    exec su developer -c "cd /workspace && exec bash"
else
    # 引数がある場合: そのコマンドを実行
    exec su developer -c "cd /workspace && exec $*"
fi