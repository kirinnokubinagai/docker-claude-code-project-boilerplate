#!/bin/bash

# Docker Entrypoint Script
# Master Claude System環境準備

# エラーハンドリング（読み取り専用マウントでの権限エラーを許可）
set -e
set +e  # 一時的にerrexitを無効化（権限関連エラーのため）

# 環境変数の設定
export WORKSPACE="/workspace"

# ロケール設定（日本語文字化け対策）
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

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

# tmux設定ファイルをコピー
if [ -f "/opt/claude-system/config/.tmux.conf" ]; then
    # rootユーザーとして実行されているので、直接操作
    # 両方の場所に配置（環境によって読み込み場所が異なるため）
    if [ -f "/home/developer/.tmux.conf" ]; then
        rm -f /home/developer/.tmux.conf 2>/dev/null || true
    fi
    cp /opt/claude-system/config/.tmux.conf /home/developer/.tmux.conf 2>/dev/null || true
    chown developer:developer /home/developer/.tmux.conf 2>/dev/null || true
    
    # ~/.tmux/.tmux.conf にも配置
    mkdir -p /home/developer/.tmux
    cp /opt/claude-system/config/.tmux.conf /home/developer/.tmux/.tmux.conf 2>/dev/null || true
    chown -R developer:developer /home/developer/.tmux 2>/dev/null || true
fi

# Claude Code用の設定ディレクトリ作成（workspaceのみ）
mkdir -p /workspace/.claude
chown -R developer:developer /workspace/.claude

# プロジェクト用CLAUDE.mdをworkspaceにコピー（ホストのCLAUDE.mdとは独立）
if [ -f "/opt/claude-system/claude/CLAUDE.md" ]; then
    cp /opt/claude-system/claude/CLAUDE.md /workspace/CLAUDE.md 2>/dev/null || true
    chown developer:developer /workspace/CLAUDE.md 2>/dev/null || true
fi

# .gitignoreをworkspaceにコピー（存在しない場合のみ）
if [ ! -f "/workspace/.gitignore" ] && [ -f "/opt/claude-system/templates/.gitignore" ]; then
    cp /opt/claude-system/templates/.gitignore /workspace/.gitignore 2>/dev/null || true
    chown developer:developer /workspace/.gitignore 2>/dev/null || true
fi

# Dockerソケットの権限調整（developerユーザーが使えるように）
if [ -S /var/run/docker.sock ]; then
    chmod 666 /var/run/docker.sock || true
fi

# 必要なディレクトリを作成（developerユーザー用）
mkdir -p /home/developer/.npm /home/developer/.local /home/developer/.config /home/developer/.cache

# 読み取り専用マウントを除いてchown実行
# .claude, .gitconfig, .ssh, .config/ghは除外（ホストからマウントされているため）
find /home/developer -type d -writable ! -path "/home/developer/.claude*" ! -path "/home/developer/.gitconfig" ! -path "/home/developer/.ssh*" ! -path "/home/developer/.config/gh*" -exec chown developer:developer {} \; 2>/dev/null || true
find /home/developer -type f -writable ! -path "/home/developer/.claude*" ! -path "/home/developer/.gitconfig" ! -path "/home/developer/.ssh*" ! -path "/home/developer/.config/gh*" -exec chown developer:developer {} \; 2>/dev/null || true

# 環境変数を設定
export HOME=/home/developer
export USER=developer
# HOST_CLAUDE_PROJECT_DIRはdocker-compose.ymlから渡される

# pnpmのグローバルディレクトリをPATHに追加（claudeコマンド用）
export PNPM_HOME=/usr/local/share/pnpm
export PATH="$PNPM_HOME:$PATH"

# すべてのシェルセッションで利用できるように/etc/profile.d/に追加
cat > /etc/profile.d/pnpm.sh << 'EOF'
export PNPM_HOME=/usr/local/share/pnpm
export PATH="$PNPM_HOME:$PATH"
EOF
chmod +x /etc/profile.d/pnpm.sh

# Playwright用の環境変数（developerユーザーに引き継がれるよう設定）
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=0
export CI=true
# ヘッドレスモードを強制
export PLAYWRIGHT_BROWSERS_PATH=/home/developer/.cache/ms-playwright

# Playwright MCPのポートはmasterコマンドが動的に割り当てるため
# ここでは設定しない

# MCP設定の自動実行
echo "MCPサーバーを設定中..."

# 環境変数を読み込む関数
load_env_files() {
    local env_vars=""
    
    # .envファイルが存在する場合は環境変数として読み込む
    if [ -f /workspace/.env ]; then
        echo "[INFO] .envファイルからプロジェクト設定を読み込みます..."
        env_vars="$env_vars $(grep -v '^#' /workspace/.env | xargs)"
    fi
    
    # .env.mcpファイルが存在する場合はMCPサービスの環境変数として読み込む
    if [ -f /workspace/.env.mcp ]; then
        echo "[INFO] .env.mcpファイルからMCPサービス設定を読み込みます..."
        env_vars="$env_vars $(grep -v '^#' /workspace/.env.mcp | xargs)"
    fi
    
    echo "$env_vars"
}

# 環境変数を読み込んでエクスポート
ENV_VARS=$(load_env_files)
if [ ! -z "$ENV_VARS" ]; then
    export $ENV_VARS
fi

# MCPサーバーを設定（developerユーザーとして実行）
echo "[INFO] MCPサーバーを設定中..."
su - developer -c "cd /workspace && /opt/claude-system/scripts/setup-mcp.sh" || {
    echo "[WARNING] MCP設定に失敗しましたが、続行します..."
}

# 最終段階でエラーハンドリングを再有効化
set -e

# 引数があればそのコマンドを、なければbashシェルを起動
if [ $# -eq 0 ]; then
    # デフォルト: bashシェル起動（-lオプションでログインシェルとして起動）
    exec su - developer -c "cd /workspace && exec bash"
else
    # 引数がある場合: そのコマンドを実行
    exec su - developer -c "cd /workspace && exec $*"
fi