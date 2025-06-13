#!/bin/bash

# Claude Code Docker Project Initializer
# Playwright専用：ホスト側開発 + コンテナ内テスト

set -euo pipefail

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 変数の初期化
PROJECT_NAME=""
NO_CREATE_DIR=""
PROJECT_PATH=""

# ヘルプメッセージ表示
show_help() {
    cat << EOF
Usage: $(basename "$0") <project-name> [options]

Claude Code Dockerプロジェクトを初期化します。

引数:
  project-name         プロジェクト名（必須）

オプション:
  --path <directory>   プロジェクトを作成するディレクトリ
                       デフォルト: ~/Project
  --no-create-dir      現在のディレクトリで初期化
                       新しいディレクトリを作成しません
  --help, -h           このヘルプメッセージを表示

使用例:
  $(basename "$0") my-ecommerce
  $(basename "$0") my-ecommerce --path /var/www/projects
  $(basename "$0") my-ecommerce --no-create-dir

注意事項:
  - プロジェクト名は英数字、ハイフン、アンダースコアのみ使用可能
  - --no-create-dirを使用する場合、現在のディレクトリに必要なファイルがコピーされます
EOF
}

# エラーハンドリング
error_exit() {
    echo "❌ エラー: $1" >&2
    exit 1
}

# 引数解析
while [ $# -gt 0 ]; do
    case "$1" in
        --help|-h)
            show_help
            exit 0
            ;;
        --no-create-dir)
            NO_CREATE_DIR="--no-create-dir"
            shift
            ;;
        --path)
            if [ -z "${2:-}" ] || [[ "$2" == --* ]]; then
                error_exit "--path オプションにはパスを指定してください"
            fi
            PROJECT_PATH="$2"
            shift 2
            ;;
        -*)
            error_exit "不明なオプション: $1"
            ;;
        *)
            if [ -z "$PROJECT_NAME" ]; then
                PROJECT_NAME="$1"
                shift
            else
                error_exit "不明な引数: $1"
            fi
            ;;
    esac
done

# 引数チェック
if [ -z "$PROJECT_NAME" ]; then
    show_help
    exit 1
fi

# プロジェクト名の検証
if [[ ! $PROJECT_NAME =~ ^[a-zA-Z0-9_-]+$ ]]; then
    error_exit "プロジェクト名は英数字、ハイフン、アンダースコアのみ使用可能です"
fi

echo "🚀 Claude Code Dockerプロジェクト初期化中..."
echo "プロジェクト名: $PROJECT_NAME"
echo "用途: Playwright E2Eテスト + ホスト側開発"

# 必要なファイルの存在確認（ボイラープレートディレクトリ）
check_boilerplate_files() {
    local base_dir="$1"
    local required_files=(
        "Dockerfile"
        "docker-compose.yml"
        "docker-entrypoint.sh"
        "scripts"
        "lib"
        "config"
        "docker"
        "team-templates"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -e "$base_dir/$file" ]; then
            error_exit "必要なファイル/ディレクトリが見つかりません: $file"
        fi
    done
}

# プロジェクトディレクトリ作成（デフォルト）
if [ "$NO_CREATE_DIR" != "--no-create-dir" ]; then
    # デフォルトパスまたは指定されたパスを使用
    if [ -z "$PROJECT_PATH" ]; then
        # デフォルトは ~/Project
        PROJECT_PATH="$HOME/Project"
    else
        # 相対パスを絶対パスに変換
        PROJECT_PATH=$(realpath "$PROJECT_PATH" 2>/dev/null || echo "$PROJECT_PATH")
    fi
    
    # 親ディレクトリが存在しない場合は作成
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "📁 親ディレクトリを作成: $PROJECT_PATH"
        mkdir -p "$PROJECT_PATH"
    fi
    
    FULL_PROJECT_PATH="$PROJECT_PATH/$PROJECT_NAME"
    echo "📁 プロジェクトディレクトリ作成: $FULL_PROJECT_PATH"
    
    if [ -d "$FULL_PROJECT_PATH" ]; then
        error_exit "ディレクトリ '$FULL_PROJECT_PATH' は既に存在します"
    fi
    
    # プロジェクトディレクトリ作成
    mkdir "$FULL_PROJECT_PATH"
    
    # ボイラープレートファイルの存在確認
    check_boilerplate_files "$SCRIPT_DIR"
    
    # 必要なファイルのみコピー（.gitは除外）
    echo "📋 必要なファイルをコピー中..."
    cp "$SCRIPT_DIR/Dockerfile" "$FULL_PROJECT_PATH/"
    cp "$SCRIPT_DIR/docker-compose.yml" "$FULL_PROJECT_PATH/"
    cp "$SCRIPT_DIR/docker-entrypoint.sh" "$FULL_PROJECT_PATH/"
    cp -r "$SCRIPT_DIR/scripts" "$FULL_PROJECT_PATH/"
    cp -P "$SCRIPT_DIR/master" "$FULL_PROJECT_PATH/" 2>/dev/null || true
    cp -r "$SCRIPT_DIR/lib" "$FULL_PROJECT_PATH/"
    cp -r "$SCRIPT_DIR/config" "$FULL_PROJECT_PATH/"
    cp -r "$SCRIPT_DIR/docker" "$FULL_PROJECT_PATH/"
    cp -r "$SCRIPT_DIR/team-templates" "$FULL_PROJECT_PATH/"
    
    # オプションファイルのコピー
    [ -f "$SCRIPT_DIR/.env.example" ] && cp "$SCRIPT_DIR/.env.example" "$FULL_PROJECT_PATH/"
    [ -f "$SCRIPT_DIR/.env" ] && cp "$SCRIPT_DIR/.env" "$FULL_PROJECT_PATH/"
    [ -f "$SCRIPT_DIR/.gitignore" ] && cp "$SCRIPT_DIR/.gitignore" "$FULL_PROJECT_PATH/"
    [ -f "$SCRIPT_DIR/README.md" ] && cp "$SCRIPT_DIR/README.md" "$FULL_PROJECT_PATH/"
    
    # プロジェクトディレクトリに移動
    cd "$FULL_PROJECT_PATH"
    echo "✅ プロジェクトディレクトリ作成完了: $(pwd)"
    echo "ℹ️  Docker作業環境とホスト開発環境が分離されます"
    
    UPDATE_CLAUDE_MD=true
else
    echo "ℹ️  現在のディレクトリで初期化します"
    
    # 現在のディレクトリでボイラープレートファイルの存在確認
    if [ "$SCRIPT_DIR" != "$(pwd)" ]; then
        # 別のディレクトリから実行されている場合、ファイルをコピー
        check_boilerplate_files "$SCRIPT_DIR"
        
        echo "📋 必要なファイルをコピー中..."
        # 既存ファイルの上書き確認
        for file in Dockerfile docker-compose.yml docker-entrypoint.sh; do
            if [ -f "$file" ]; then
                echo "⚠️  既存の $file を上書きします"
            fi
            cp "$SCRIPT_DIR/$file" .
        done
        
        # ディレクトリのコピー（既存の場合はマージ）
        cp -r "$SCRIPT_DIR/scripts" .
        cp -P "$SCRIPT_DIR/master" . 2>/dev/null || true
        cp -r "$SCRIPT_DIR/lib" .
        cp -r "$SCRIPT_DIR/config" .
        cp -r "$SCRIPT_DIR/docker" .
        cp -r "$SCRIPT_DIR/team-templates" .
        
        # オプションファイル
        [ -f "$SCRIPT_DIR/.env.example" ] && [ ! -f ".env.example" ] && cp "$SCRIPT_DIR/.env.example" .
        [ -f "$SCRIPT_DIR/.gitignore" ] && [ ! -f ".gitignore" ] && cp "$SCRIPT_DIR/.gitignore" .
        [ -f "$SCRIPT_DIR/README.md" ] && [ ! -f "README.md" ] && cp "$SCRIPT_DIR/README.md" .
    fi
    
    UPDATE_CLAUDE_MD=true
fi

echo ""

# .envファイル作成/更新
ENV_FILE=".env"
if [ ! -f "$ENV_FILE" ]; then
    echo "📝 .envファイルを作成中..."
    cat > "$ENV_FILE" << EOF
# プロジェクト設定
PROJECT_NAME=$PROJECT_NAME

# Claude Code API Key
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Optional: MCPサーバー設定（使用する場合のみ設定）
# SUPABASE_ACCESS_TOKEN=
# STRIPE_SECRET_KEY=
# STRIPE_PUBLISHABLE_KEY=
# LINE_CHANNEL_ACCESS_TOKEN=
# DESTINATION_USER_ID=
# OBSIDIAN_API_KEY=
# OBSIDIAN_HOST=

# Playwright設定
PLAYWRIGHT_HEADLESS=true
PLAYWRIGHT_TIMEOUT=30000

# Context7設定
DEFAULT_MINIMUM_TOKENS=6000
EOF
    echo "✅ .envファイルが作成されました"
    echo "⚠️  環境変数を設定してください"
else
    # 既存の.envファイルを更新
    echo "📝 既存の.envファイルを更新中..."
    
    # PROJECT_NAME を更新または追加
    if grep -q "^PROJECT_NAME=" "$ENV_FILE"; then
        # macOSとLinuxの両方で動作するように
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/^PROJECT_NAME=.*/PROJECT_NAME=$PROJECT_NAME/" "$ENV_FILE"
        else
            sed -i "s/^PROJECT_NAME=.*/PROJECT_NAME=$PROJECT_NAME/" "$ENV_FILE"
        fi
    else
        echo "PROJECT_NAME=$PROJECT_NAME" >> "$ENV_FILE"
    fi
    
    echo "✅ .envファイルが更新されました"
fi

# 必要なディレクトリ作成
echo "📁 必要なディレクトリを作成中..."
mkdir -p screenshots logs temp docs
touch screenshots/.gitkeep logs/.gitkeep temp/.gitkeep docs/.gitkeep

# docker-compose.ymlは既に環境変数対応済み
echo "✅ docker-compose.ymlは環境変数で動的に設定されます"

# CLAUDEプロジェクト設定ファイル更新（該当する場合のみ）
if [ "$UPDATE_CLAUDE_MD" = "true" ] && [ -f "docker/claude/CLAUDE.md" ]; then
    echo "📋 CLAUDE.mdを更新中..."
    # macOSとLinuxの両方で動作するようにsedを実行
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/Claude Code Company プロジェクト設定/Claude Code Company - $PROJECT_NAME プロジェクト設定/" docker/claude/CLAUDE.md
    else
        # Linux
        sed -i "s/Claude Code Company プロジェクト設定/Claude Code Company - $PROJECT_NAME プロジェクト設定/" docker/claude/CLAUDE.md
    fi
    echo "✅ CLAUDE.md更新完了"
fi

# Docker Volumeを事前に作成
echo "🐳 Docker Volumeを作成中..."
docker volume create "${PROJECT_NAME}_fish_history" > /dev/null 2>&1 || true
docker volume create "${PROJECT_NAME}_z_data" > /dev/null 2>&1 || true
docker volume create "${PROJECT_NAME}_tmux_data" > /dev/null 2>&1 || true
echo "✅ Docker Volume作成完了"

echo ""
echo "🎉 プロジェクト初期化完了!"
echo ""
if [ "$NO_CREATE_DIR" != "--no-create-dir" ]; then
    echo "📁 プロジェクトディレクトリ: $(pwd)"
    echo "🔄 Master Claude System:"
    echo "   - 親Claude Codeが子プロセスを動的に管理"
    echo "   - MCPサーバー自動設定"
    echo "   - Git worktreeで並列開発"
    echo ""
fi

# docker compose を自動起動
echo "📋 次のステップ"
echo "1. cd $FULL_PROJECT_PATH"
echo "2. 必要に応じて.envファイルを編集"
echo "3. 必要に応じてMCPサーバーの環境変数を設定"
echo "4. docker compose up -d でコンテナ起動"
echo "5. docker compose exec -w /workspace claude-code developer-fish でdeveloperとしてシェルに接続 # root権限だとclaude codeを--dangerously-skipで実行できない"
echo "6. cc を実行してClaude Codeを起動（「〇〇を作りたい」でチーム自動構成）"
echo "7. master を実行してMasterとして起動"
echo ""
echo "🔧 よく使うコマンド:"
echo "docker compose up -d                    # コンテナ起動"
echo "docker compose exec claude-code fish    # シェル接続"
echo "cc                                     # Claude Code起動（動的チーム構成）"
echo "./join-company.sh <team-template>       # テンプレートからチーム追加"
echo "docker compose down                     # コンテナ停止"
echo ""
echo "📚 動的チーム構成（推奨）:"
echo "cc  # Claude Codeを起動して「〇〇を作りたい」で自動チーム構成"
echo ""
echo "📚 手動チーム追加例:"
echo "./join-company.sh team-templates/frontend-team.json   # フロントエンドチーム追加"
echo "./join-company.sh team-templates/backend-team.json    # バックエンドチーム追加"