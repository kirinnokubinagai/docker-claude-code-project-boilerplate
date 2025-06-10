#!/bin/bash

# Docker Entrypoint Script
# Master Claude System環境準備

set -e

# 環境変数の設定
export WORKSPACE="/workspace"

# workspaceディレクトリの権限設定（developerユーザーが書き込めるように）
chown -R developer:developer /workspace

# Master Claudeスクリプトの実行権限
if [ -f "/workspace/master-claude-teams.sh" ]; then
    chmod +x /workspace/master-claude-teams.sh
fi

# libファイルの実行権限
if [ -d "/workspace/lib" ]; then
    chmod +x /workspace/lib/*.sh
fi

# tmux設定ファイルをコピー
if [ -f "/workspace/docker/.tmux.conf" ]; then
    cp /workspace/docker/.tmux.conf /home/developer/.tmux.conf
    chown developer:developer /home/developer/.tmux.conf
fi

# Claude Code用の設定ディレクトリ作成
mkdir -p /home/developer/.anthropic
chown -R developer:developer /home/developer/.anthropic

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