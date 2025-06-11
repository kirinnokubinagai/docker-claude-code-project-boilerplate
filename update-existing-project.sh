#!/bin/bash

# 既存プロジェクトを最新版に更新するスクリプト

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 色付きログ出力
log_info() {
    echo -e "\033[0;36m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
}

# 使用方法の表示
show_usage() {
    echo "使用方法: $0 <プロジェクトディレクトリ>"
    echo ""
    echo "例: $0 ../my-project"
    echo ""
    echo "このスクリプトは既存のプロジェクトを最新版に更新します。"
    exit 1
}

# 引数チェック
if [ $# -ne 1 ]; then
    show_usage
fi

PROJECT_DIR="$1"

# プロジェクトディレクトリの存在確認
if [ ! -d "$PROJECT_DIR" ]; then
    log_error "プロジェクトディレクトリが見つかりません: $PROJECT_DIR"
    exit 1
fi

# docker-compose.ymlの存在確認
if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
    log_error "docker-compose.ymlが見つかりません。正しいプロジェクトディレクトリを指定してください。"
    exit 1
fi

log_info "プロジェクトを更新します: $PROJECT_DIR"

# 更新前にバックアップ
log_info "現在の設定をバックアップ中..."
BACKUP_DIR="$PROJECT_DIR/.backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r "$PROJECT_DIR/lib" "$BACKUP_DIR/" 2>/dev/null || true
cp -r "$PROJECT_DIR/config" "$BACKUP_DIR/" 2>/dev/null || true
cp "$PROJECT_DIR/master-claude-teams.sh" "$BACKUP_DIR/" 2>/dev/null || true
cp "$PROJECT_DIR/docker/fish/config.fish" "$BACKUP_DIR/" 2>/dev/null || true
cp "$PROJECT_DIR/Dockerfile" "$BACKUP_DIR/" 2>/dev/null || true

# ファイルのコピー
log_info "最新ファイルをコピー中..."

# 必要なディレクトリを作成
mkdir -p "$PROJECT_DIR/lib"
mkdir -p "$PROJECT_DIR/config"
mkdir -p "$PROJECT_DIR/docker/fish"

# ファイルをコピー
cp "$SCRIPT_DIR/master-claude-teams.sh" "$PROJECT_DIR/"
cp -r "$SCRIPT_DIR/lib/"* "$PROJECT_DIR/lib/"
cp -r "$SCRIPT_DIR/config/"* "$PROJECT_DIR/config/"
cp "$SCRIPT_DIR/docker/fish/config.fish" "$PROJECT_DIR/docker/fish/"
cp "$SCRIPT_DIR/docker/developer-entrypoint.sh" "$PROJECT_DIR/docker/"
cp "$SCRIPT_DIR/docker-entrypoint.sh" "$PROJECT_DIR/"
cp "$SCRIPT_DIR/Dockerfile" "$PROJECT_DIR/"
cp "$SCRIPT_DIR/docker-compose.yml" "$PROJECT_DIR/"

# 実行権限を付与
chmod +x "$PROJECT_DIR/master-claude-teams.sh"
chmod +x "$PROJECT_DIR/docker-entrypoint.sh"
chmod +x "$PROJECT_DIR/docker/developer-entrypoint.sh"

log_success "ファイルの更新が完了しました"

# Dockerの再ビルドを提案
echo ""
log_info "次のコマンドでDockerイメージを再ビルドしてください："
echo ""
echo "  cd $PROJECT_DIR"
echo "  docker-compose down"
echo "  docker-compose build --no-cache"
echo "  docker-compose up -d"
echo "  docker-compose exec -w /workspace claude-code developer-fish"
echo ""
echo "その後、fishシェル内で以下を実行："
echo "  setup_mcp_manual  # MCPサーバーを再設定"
echo "  master           # 5チーム並列システムを起動"
echo ""
log_success "更新完了！バックアップは $BACKUP_DIR に保存されています。"