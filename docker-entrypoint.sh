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

# Playwright MCPはコンテナ内での実行が複雑なため、
# 通常のPlaywrightテストコードを書くことを推奨

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


# 削除: プロジェクトファイルは直接マウントされるため、コピー処理は不要

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

# Claude Code用の設定ディレクトリ作成
mkdir -p /home/developer/.claude /workspace/.claude
chown -R developer:developer /home/developer/.claude /workspace/.claude

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
find /home/developer -type d -writable -exec chown developer:developer {} \; 2>/dev/null || true
find /home/developer -type f -writable -exec chown developer:developer {} \; 2>/dev/null || true

# 環境変数を設定
export HOME=/home/developer
export USER=developer

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

# MCP設定の自動実行
echo "MCPサーバーを設定中..."
# su -（ハイフン付き）は環境をリセットするので、su（ハイフンなし）を使用
su developer -c "/opt/claude-system/scripts/setup-mcp.sh" || {
    echo "[WARNING] MCP設定に失敗しましたが、続行します..."
}

# 最終段階でエラーハンドリングを再有効化
set -e

# Playwright環境変数とロケール設定、PATHをdeveloperユーザーに渡す
PLAYWRIGHT_ENV="PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=$PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD CI=$CI PLAYWRIGHT_BROWSERS_PATH=$PLAYWRIGHT_BROWSERS_PATH LANG=$LANG LC_ALL=$LC_ALL PNPM_HOME=$PNPM_HOME PATH=$PATH"

# Claude認証チェックスクリプトを作成
cat > /tmp/check_claude_auth.sh << 'EOF'
#!/bin/bash
# Claude Codeの認証状態をチェック
if ! claude --version >/dev/null 2>&1; then
    echo ""
    echo "========================================="
    echo "Claude Codeの初回認証が必要です"
    echo "========================================="
    echo ""
    claude login
fi
EOF
chmod +x /tmp/check_claude_auth.sh

# 引数があればそのコマンドを、なければbashシェルを起動
if [ $# -eq 0 ]; then
    # デフォルト: bashシェル起動時にClaude認証チェック
    exec su developer -c "cd /workspace && $PLAYWRIGHT_ENV /tmp/check_claude_auth.sh && exec bash"
else
    # 引数がある場合: そのコマンドを実行
    exec su developer -c "cd /workspace && $PLAYWRIGHT_ENV exec $*"
fi