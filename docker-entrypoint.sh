#!/bin/bash

# Docker Entrypoint Script
# Master Claude System環境準備

set -e

# 環境変数の設定
export WORKSPACE="/workspace"

# USER_UID/USER_GIDが環境変数で指定されている場合は、developerユーザーのUID/GIDを変更
if [ ! -z "$USER_UID" ] && [ ! -z "$USER_GID" ] && [ "$USER_UID" != "0" ]; then
    # 現在のdeveloperユーザーのUID/GIDを取得
    CURRENT_UID=$(id -u developer)
    CURRENT_GID=$(id -g developer)
    
    # 変更が必要な場合のみ実行
    if [ "$CURRENT_UID" != "$USER_UID" ] || [ "$CURRENT_GID" != "$USER_GID" ]; then
        # homeディレクトリの権限を一時的にrootに
        chown -R root:root /home/developer
        
        # UID/GIDを変更
        groupmod -g $USER_GID developer 2>/dev/null || true
        usermod -u $USER_UID developer 2>/dev/null || true
        
        # homeディレクトリの権限を戻す
        chown -R developer:developer /home/developer
    fi
fi

# workspaceディレクトリの権限設定（developerユーザーが書き込めるように）
# ただし、.gitディレクトリは除外（既存の権限を保持）
find /workspace -mindepth 1 -maxdepth 1 ! -name '.git' -exec chown -R developer:developer {} \; 2>/dev/null || true

# 新規ファイルのみ権限変更
find /workspace -user root -exec chown developer:developer {} \; 2>/dev/null || true

# Master Claudeスクリプトの実行権限
if [ -f "/workspace/master-claude-teams.sh" ]; then
    chmod +x /workspace/master-claude-teams.sh
fi

# libファイルの実行権限
if [ -d "/workspace/lib" ]; then
    chmod +x /workspace/lib/*.sh
fi

# tmux設定ファイルをコピー（権限を修正してから）
if [ -f "/workspace/docker/.tmux.conf" ]; then
    # 既存ファイルがある場合は削除
    rm -f /home/developer/.tmux.conf || true
    cp /workspace/docker/.tmux.conf /home/developer/.tmux.conf
    chown developer:developer /home/developer/.tmux.conf
fi

# Claude Code用の設定ディレクトリ作成
mkdir -p /home/developer/.anthropic /home/developer/.claude
chown -R developer:developer /home/developer/.anthropic /home/developer/.claude

# Dockerソケットの権限調整（developerユーザーが使えるように）
if [ -S /var/run/docker.sock ]; then
    chmod 666 /var/run/docker.sock || true
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

# 必要なディレクトリを作成（developerユーザー用）
mkdir -p /home/developer/.npm /home/developer/.local /home/developer/.config /home/developer/.cache
chown -R developer:developer /home/developer

# 環境変数を設定
export HOME=/home/developer
export USER=developer

# 引数があればそのコマンドを、なければfishシェルを起動
if [ $# -eq 0 ]; then
    # デフォルト: fishシェル
    exec su developer -c "cd /workspace && exec fish"
else
    # 引数がある場合: そのコマンドを実行
    exec su developer -c "cd /workspace && exec $*"
fi