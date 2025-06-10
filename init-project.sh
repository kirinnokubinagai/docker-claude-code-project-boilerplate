#!/bin/bash

# Claude Code Docker Project Initializer
# Playwright専用：ホスト側開発 + コンテナ内テスト

set -e

PROJECT_NAME=""
NO_CREATE_DIR=""
PROJECT_PATH=""

# 引数解析
while [ $# -gt 0 ]; do
    case "$1" in
        --no-create-dir)
            NO_CREATE_DIR="--no-create-dir"
            shift
            ;;
        --path)
            if [ -z "$2" ] || [[ "$2" == --* ]]; then
                echo "❌ --path オプションにはパスを指定してください"
                exit 1
            fi
            PROJECT_PATH="$2"
            shift 2
            ;;
        *)
            if [ -z "$PROJECT_NAME" ]; then
                PROJECT_NAME="$1"
                shift
            else
                echo "❌ 不明な引数: $1"
                exit 1
            fi
            ;;
    esac
done

# 引数チェック
if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: $0 <project-name> [--path <directory>] [--no-create-dir]"
    echo "Example: $0 my-ecommerce"
    echo "Example: $0 my-ecommerce --path /var/www/projects"
    echo "Example: $0 my-ecommerce --no-create-dir"
    echo ""
    echo "プロジェクト名は必須です。"
    echo "オプション:"
    echo "  --path <directory>  プロジェクトを作成するディレクトリ（デフォルト: ~/Project）"
    echo "  --no-create-dir     現在のディレクトリで初期化"
    exit 1
fi

# プロジェクト名の検証
if [[ ! $PROJECT_NAME =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "❌ プロジェクト名は英数字、ハイフン、アンダースコアのみ使用可能です"
    exit 1
fi

echo "🚀 Claude Code Dockerプロジェクト初期化中..."
echo "プロジェクト名: $PROJECT_NAME"
echo "用途: Playwright E2Eテスト + ホスト側開発"

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
        echo "❌ ディレクトリ '$FULL_PROJECT_PATH' は既に存在します"
        exit 1
    fi
    
    # プロジェクトディレクトリ作成
    mkdir "$FULL_PROJECT_PATH"
    
    # 必要なファイルのみコピー（.gitは除外）
    echo "📋 必要なファイルをコピー中..."
    cp Dockerfile "$FULL_PROJECT_PATH/"
    cp docker-compose.yml "$FULL_PROJECT_PATH/"
    cp docker-entrypoint.sh "$FULL_PROJECT_PATH/"
    cp master-claude-teams.sh "$FULL_PROJECT_PATH/"
    cp -r lib "$FULL_PROJECT_PATH/"
    cp -r config "$FULL_PROJECT_PATH/"
    cp -r docker "$FULL_PROJECT_PATH/"
    if [ -f ".env.example" ]; then
        cp .env.example "$FULL_PROJECT_PATH/"
    fi
    if [ -f ".env" ]; then
        cp .env "$FULL_PROJECT_PATH/"
    fi
    cp .gitignore "$FULL_PROJECT_PATH/"
    
    # プロジェクトディレクトリに移動
    cd "$FULL_PROJECT_PATH"
    echo "✅ プロジェクトディレクトリ作成完了: $(pwd)"
    echo "ℹ️  Docker作業環境とホスト開発環境が分離されます"
    
    UPDATE_CLAUDE_MD=true
else
    echo "ℹ️  現在のディレクトリで初期化します"
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

# 必須: Claude Code API Key
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
    echo "⚠️  ANTHROPIC_API_KEYを設定してください"
else
    # 既存の.envファイルを更新
    echo "📝 既存の.envファイルを更新中..."
    
    # PROJECT_NAME を更新または追加
    if grep -q "^PROJECT_NAME=" "$ENV_FILE"; then
        sed -i.bak "s/^PROJECT_NAME=.*/PROJECT_NAME=$PROJECT_NAME/" "$ENV_FILE"
    else
        echo "PROJECT_NAME=$PROJECT_NAME" >> "$ENV_FILE"
    fi
    
    # バックアップファイルを削除
    rm -f "$ENV_FILE.bak"
    
    echo "✅ .envファイルが更新されました"
fi

# 必要なディレクトリ作成
echo "📁 必要なディレクトリを作成中..."
mkdir -p screenshots logs temp docs
touch screenshots/.gitkeep logs/.gitkeep temp/.gitkeep docs/.gitkeep

# docker-compose.ymlは既に環境変数対応済み
echo "✅ docker-compose.ymlは環境変数で動的に設定されます"

# CLAUDEプロジェクト設定ファイル更新（該当する場合のみ）
if [ "$UPDATE_CLAUDE_MD" = "true" ]; then
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
echo "📋 次の手順:"
echo "1. .envファイルでANTHROPIC_API_KEYを設定"
echo "2. 必要に応じてMCPサーバーの環境変数を設定"
echo "3. docker-compose up -d でコンテナ起動"
echo "4. docker-compose exec claude-code fish でシェルに接続"
echo "5. ./master-claude-teams.sh で5チーム並列システム起動"
echo ""
echo "🔧 よく使うコマンド:"
echo "docker-compose up -d                    # コンテナ起動"
echo "docker-compose exec claude-code fish    # シェル接続"
echo "./master-claude-teams.sh                # 5チーム並列システム"
echo "docker-compose down                     # コンテナ停止"
echo ""
echo "📚 詳しくはREADME.mdを参照してください"
