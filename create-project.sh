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
    # スクリプトの場所から Claude-Project ディレクトリを特定
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CLAUDE_PROJECT_DIR="$SCRIPT_DIR"
    PROJECT_DIR="$CLAUDE_PROJECT_DIR/projects/$PROJECT_NAME"
    
    # Claude-Projectディレクトリが存在しない場合はエラー
    if [ ! -d "$CLAUDE_PROJECT_DIR" ]; then
        echo "エラー: Claude-Projectディレクトリが存在しません: $CLAUDE_PROJECT_DIR"
        echo "先にClaude-Projectのセットアップを完了してください"
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
            # 停止中のコンテナがあるか確認
            if docker ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
                echo "停止中のコンテナを検出しました。"
                echo "オプションを選択してください:"
                echo "1) 既存のコンテナを削除して新規作成"
                echo "2) 既存のコンテナを再起動"
                echo "3) キャンセル"
                read -p "選択 (1-3): " choice
                
                case $choice in
                    1)
                        echo "既存のコンテナを削除中..."
                        docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
                        # 新規作成フローへ
                        ;;
                    2)
                        echo "既存のコンテナを再起動中..."
                        cd "$PROJECT_DIR"
                        # Docker Composeで起動
                        docker compose -f "$CLAUDE_PROJECT_DIR/docker-compose-base.yml" --project-directory "$PROJECT_DIR" up -d
                        
                        # コンテナが起動するまで待機
                        echo "コンテナの起動を待機中..."
                        while ! docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; do
                            sleep 1
                        done
                        
                        echo "コンテナ '$CONTAINER_NAME' に接続中..."
                        docker exec -it -u developer "$CONTAINER_NAME" bash
                        return 0
                        ;;
                    3)
                        echo "キャンセルしました"
                        return 0
                        ;;
                    *)
                        echo "無効な選択です"
                        return 1
                        ;;
                esac
            fi
            
            echo "コンテナが起動していません。起動します..."
            cd "$PROJECT_DIR"
            
            # MCPプロキシサーバーの起動確認（常に必要）
            if ! nc -z localhost 9999 2>/dev/null; then
                echo "MCPプロキシサーバーを起動中..."
                cd "$CLAUDE_PROJECT_DIR/mcp-gateway"
                nohup bun run proxy > /dev/null 2>&1 &
                PROXY_PID=$!
                cd "$PROJECT_DIR"
                sleep 3
                echo "プロキシサーバー起動完了 (PID: $PROXY_PID)"
            fi
            
            # 必要なボリュームが存在するか確認し、なければ作成
            if ! docker volume ls -q | grep -q "^${PROJECT_NAME}_bash_history$"; then
                echo "ボリュームを作成中: ${PROJECT_NAME}_bash_history"
                docker volume create "${PROJECT_NAME}_bash_history"
            fi
            if ! docker volume ls -q | grep -q "^${PROJECT_NAME}_z$"; then
                echo "ボリュームを作成中: ${PROJECT_NAME}_z"
                docker volume create "${PROJECT_NAME}_z"
            fi
            
            # Docker Composeで起動
            docker compose -f "$CLAUDE_PROJECT_DIR/docker-compose-base.yml" --project-directory "$PROJECT_DIR" up -d
            
            # エラーチェック
            if [ $? -ne 0 ]; then
                echo ""
                echo "エラー: コンテナの起動に失敗しました"
                echo "考えられる原因:"
                echo "- ポートが既に使用されている"
                echo "- Dockerリソースが不足している"
                echo ""
                echo "以下のコマンドで既存のコンテナを確認してください:"
                echo "  docker ps -a | grep ${PROJECT_NAME}"
                return 1
            fi
            
            # コンテナが起動するまで待機
            echo "コンテナの起動を待機中..."
            local wait_count=0
            while ! docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; do
                sleep 1
                wait_count=$((wait_count + 1))
                if [ $wait_count -gt 30 ]; then
                    echo "エラー: コンテナの起動がタイムアウトしました"
                    echo "docker logs $CONTAINER_NAME で詳細を確認してください"
                    return 1
                fi
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
# Project Configuration (Required)
# ==============================================
PROJECT_NAME=$PROJECT_NAME
CLAUDE_PROJECT_DIR=$CLAUDE_PROJECT_DIR

# ==============================================
# Claude Authentication (Optional)
# ==============================================
# ANTHROPIC_API_KEYが設定されていない場合は、
# Claudeの認証が必要な際に手動でログインしてください
# ANTHROPIC_API_KEY=your-api-key-here

# ==============================================
# Project-specific Environment Variables
# ==============================================
# Add your project-specific environment variables below
# Example:
# DATABASE_URL=
# REDIS_URL=
# NEXT_PUBLIC_API_URL=
EOF
    
    # メインの.envから必要な環境変数をコピー
    if [ -f "$CLAUDE_PROJECT_DIR/.env" ]; then
        # ANTHROPIC_API_KEY
        ANTHROPIC_KEY=$(grep "^ANTHROPIC_API_KEY=" "$CLAUDE_PROJECT_DIR/.env" | cut -d'=' -f2-)
        if [ -n "$ANTHROPIC_KEY" ]; then
            echo "Claude API Keyを検出しました。プロジェクトの.envに追加します..."
            sed -i.bak "s|# ANTHROPIC_API_KEY=your-api-key-here|ANTHROPIC_API_KEY=$ANTHROPIC_KEY|" .env
            rm -f .env.bak
        fi
        
        # MCP Gateway関連の環境変数もコピー（もし設定されていれば）
        MCP_VARS=("GITHUB_TOKEN" "SUPABASE_ACCESS_TOKEN" "STRIPE_SEC_KEY" "CHANNEL_ACCESS_TOKEN" "DESTINATION_USER_ID" "OBSIDIAN_API_KEY" "MAGIC_API_KEY")
        for var in "${MCP_VARS[@]}"; do
            VALUE=$(grep "^${var}=" "$CLAUDE_PROJECT_DIR/.env" | cut -d'=' -f2-)
            if [ -n "$VALUE" ]; then
                echo "" >> .env
                echo "# Copied from main .env" >> .env
                echo "${var}=${VALUE}" >> .env
            fi
        done
    fi
    
    # .dockerignoreファイルは不要（docker-compose-base.ymlはCLAUDE_PROJECT_DIRから読み込むため）
    
    echo "6. Gitリポジトリ初期化の準備中..."

    # .gitの初期化と初回コミット
    echo "7. Gitリポジトリを初期化中..."
    git init
    git commit --allow-empty -m "Initial commit"
    
    # 必要なDockerボリュームを作成
    echo "8. Dockerボリュームを作成中..."
    docker volume create "${PROJECT_NAME}_bash_history" || true
    docker volume create "${PROJECT_NAME}_z" || true
    
    # Docker Composeを起動（ビルドログを表示）
    echo "9. Docker Composeを起動中..."
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
    
    # コンテナを起動（claude-codeとMCPゲートウェイ）
    docker compose -f "$CLAUDE_PROJECT_DIR/docker-compose-base.yml" --project-directory "$PROJECT_DIR" up -d
    
    echo ""
    echo "==============================================="
    
    # コンテナが起動するまで待機
    echo "10. コンテナの起動を待機中..."
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
    echo "11. コンテナに接続中..."
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