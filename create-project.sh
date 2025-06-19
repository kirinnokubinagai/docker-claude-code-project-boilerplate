#!/bin/bash

# プロジェクト作成スクリプト
# 使い方: sh create-project.sh プロジェクト名

create_project() {
    # 引数チェック
    if [ -z "$1" ]; then
        echo "エラー: プロジェクト名を指定してください"
        echo "使い方: create_project プロジェクト名"
        return 1
    fi
    
    PROJECT_NAME="$1"
    CLAUDE_PROJECT_DIR="$HOME/claude-project"
    PROJECT_DIR="$CLAUDE_PROJECT_DIR/projects/$PROJECT_NAME"
    
    # claude-projectディレクトリが存在しない場合はエラー
    if [ ! -d "$CLAUDE_PROJECT_DIR" ]; then
        echo "エラー: claude-projectディレクトリが存在しません"
        echo "先にclaude-projectのセットアップを完了してください"
        return 1
    fi
    
    # プロジェクトディレクトリが既に存在する場合の処理
    if [ -d "$PROJECT_DIR" ]; then
        echo "プロジェクトディレクトリが既に存在します: $PROJECT_DIR"
        echo "既存のコンテナに接続します..."
        
        # 環境変数を設定
        export PROJECT_NAME
        export CLAUDE_PROJECT_DIR
        
        # コンテナ名を設定
        CONTAINER_NAME="claude-code-${PROJECT_NAME}"
        
        # コンテナが起動しているか確認
        if docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
            echo "コンテナ '$CONTAINER_NAME' に接続中..."
            docker exec -it -u developer "$CONTAINER_NAME" bash
        else
            echo "コンテナが起動していません。起動します..."
            cd "$PROJECT_DIR"
            docker compose -f "$CLAUDE_PROJECT_DIR/docker-compose-base.yml" --project-directory "$PROJECT_DIR" up -d
            
            # コンテナが起動するまで待機
            echo "コンテナの起動を待機中..."
            while ! docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; do
                sleep 1
            done
            
            echo "コンテナ '$CONTAINER_NAME' に接続中..."
            docker exec -it -u developer "$CONTAINER_NAME" bash
        fi
        return 0
    fi
    
    echo "プロジェクト '$PROJECT_NAME' を作成中..."
    
    # projectsディレクトリが存在しない場合は作成
    if [ ! -d "$CLAUDE_PROJECT_DIR/projects" ]; then
        echo "1. projectsディレクトリを作成中..."
        mkdir -p "$CLAUDE_PROJECT_DIR/projects"
    fi
    
    # プロジェクトディレクトリを作成（空のディレクトリ）
    echo "2. プロジェクトディレクトリを作成中..."
    mkdir -p "$PROJECT_DIR"
    
    # プロジェクトディレクトリに移動
    echo "3. プロジェクトディレクトリに移動..."
    cd "$PROJECT_DIR"
    
    # PROJECT_NAMEを設定
    echo "4. 環境変数を設定中..."
    
    # .envファイルを作成（プロジェクト固有の設定のみ）
    echo "5. 環境変数ファイルを作成中..."
    cat > .env << EOF
# ==============================================
# Project Configuration
# ==============================================
PROJECT_NAME=$PROJECT_NAME
CLAUDE_PROJECT_DIR=$CLAUDE_PROJECT_DIR

# ==============================================
# Playwright MCP Port Configuration
# ==============================================
EOF
    
    # Playwright MCPポートを自動割り当て（8931から順番に空いているポートを探す）
    echo "Playwright MCPの利用可能なポートを検索中..."
    PLAYWRIGHT_PORT=8931
    while lsof -Pi :$PLAYWRIGHT_PORT -sTCP:LISTEN -t >/dev/null 2>&1; do
        PLAYWRIGHT_PORT=$((PLAYWRIGHT_PORT + 1))
    done
    echo "  → ポート $PLAYWRIGHT_PORT を使用します"
    echo "PLAYWRIGHT_MCP_PORT=$PLAYWRIGHT_PORT" >> .env
    
    # プロジェクト固有の環境変数用のセクションを追加
    cat >> .env << 'EOF'

# ==============================================
# Project-specific Environment Variables
# ==============================================
# Add your project-specific environment variables below
# Example:
# DATABASE_URL=
# REDIS_URL=
# NEXT_PUBLIC_API_URL=
EOF
    
    # .env.mcpファイルをコピー（MCPサービスの認証情報）
    if [ -f "$CLAUDE_PROJECT_DIR/.env" ]; then
        echo "MCPサービスの認証情報をコピー中..."
        cp "$CLAUDE_PROJECT_DIR/.env" .env.mcp
    fi
    
    # .dockerignoreファイルは不要（docker-compose-base.ymlはCLAUDE_PROJECT_DIRから読み込むため）
    echo "6. Gitリポジトリ初期化の準備中..."

    # .gitの初期化と初回コミット
    echo "7. Gitリポジトリを初期化中..."
    git init
    git commit --allow-empty -m "Initial commit"
    
    # Docker Composeを起動（ビルドログを表示）
    echo "8. Docker Composeを起動中..."
    echo "==============================================="
    echo "📦 Dockerイメージをビルド中..."
    echo "（初回は時間がかかる場合があります）"
    echo "==============================================="
    
    # ビルドのみ実行してログを表示
    export PROJECT_NAME
    export CLAUDE_PROJECT_DIR
    # プロジェクトディレクトリでdocker-composeを実行することで、.:/workspaceが正しく機能する
    docker compose -f "$CLAUDE_PROJECT_DIR/docker-compose-base.yml" --project-directory "$PROJECT_DIR" --progress=plain build
    
    echo "==============================================="
    echo "🚀 コンテナを起動中..."
    echo "==============================================="
    
    # claude-codeコンテナを先に起動
    docker compose -f "$CLAUDE_PROJECT_DIR/docker-compose-base.yml" --project-directory "$PROJECT_DIR" up -d claude-code
    
    echo ""
    echo "📦 Playwright MCPサーバーを起動中..."
    echo "（ARM64対応版をビルドします）"
    
    # Playwright MCPを後から起動
    docker compose -f "$CLAUDE_PROJECT_DIR/docker-compose-base.yml" --project-directory "$PROJECT_DIR" up -d playwright-mcp
    
    echo "==============================================="
    
    # コンテナが起動するまで待機
    echo "9. コンテナの起動を待機中..."
    CONTAINER_NAME="claude-code-${PROJECT_NAME}"
    
    local dot_count=0
    
    while true; do
        # コンテナが実際に稼働中かチェック
        if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "^${CONTAINER_NAME}\s.*Up"; then
            echo ""
            echo "✅ コンテナが起動しました！"
            break
        fi
        
        # コンテナの状態をチェック（デバッグ用）
        container_status=$(docker ps -a --format "table {{.Names}}\t{{.Status}}" | grep "^${CONTAINER_NAME}" || echo "Not found")
        if [[ "$container_status" == *"Exited"* ]]; then
            echo ""
            echo "❌ コンテナが終了しています："
            echo "$container_status"
            echo ""
            echo "ログを確認します："
            docker logs "$CONTAINER_NAME" --tail 20
            return 1
        fi
        
        # プログレス表示（3秒ごと）
        printf "."
        dot_count=$((dot_count + 1))
        
        # 15個のドットで改行
        if [ $dot_count -eq 15 ]; then
            echo ""
            echo "待機中"
            dot_count=0
        fi
        
        sleep 3
    done
    
    # developerユーザーでコンテナに入る
    echo "10. コンテナに接続中..."
    echo ""
    echo "==============================================="
    echo "プロジェクト '$PROJECT_NAME' の作成が完了しました！"
    echo "プロジェクトパス: $PROJECT_DIR"
    echo ""
    echo "今後このプロジェクトで作業する場合："
    echo "  cd $PROJECT_DIR"
    echo "  export PROJECT_NAME=$PROJECT_NAME"
    echo "  export CLAUDE_PROJECT_DIR=$CLAUDE_PROJECT_DIR"
    echo "  docker compose -f $CLAUDE_PROJECT_DIR/docker-compose-base.yml --project-directory . up -d"
    echo "  docker exec -it -u developer $CONTAINER_NAME bash"
    echo ""
    echo "コンテナ '$CONTAINER_NAME' にdeveloperユーザーで接続します..."
    echo "==============================================="
    echo ""
    
    docker exec -it -u developer "$CONTAINER_NAME" bash
}

# スクリプトが直接実行された場合は関数を呼び出す
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    create_project "$@"
fi