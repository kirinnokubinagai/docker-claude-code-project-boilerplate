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
    BOILERPLATE_DIR="$HOME/Project/docker-claude-code-boiler-plate"
    PROJECT_DIR="$HOME/Project/$PROJECT_NAME"
    
    # プロジェクトディレクトリが既に存在する場合はエラー
    if [ -d "$PROJECT_DIR" ]; then
        echo "エラー: プロジェクトディレクトリが既に存在します: $PROJECT_DIR"
        return 1
    fi
    
    echo "プロジェクト '$PROJECT_NAME' を作成中..."
    
    # boilerplateをコピー
    echo "1. Boilerplateをコピー中..."
    cp -r "$BOILERPLATE_DIR" "$PROJECT_DIR"
    
    # プロジェクトディレクトリに移動
    echo "2. プロジェクトディレクトリに移動..."
    cd "$PROJECT_DIR"
    
    # docker-compose.ymlを生成（プロジェクト名を反映）
    echo "3. docker-compose.ymlを生成中..."
    sed "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" docker-compose-base.yml > docker-compose.yml
    
    # Dockerfileを生成
    echo "4. Dockerfileを生成中..."
    cp DockerfileBase Dockerfile
    
    # Docker entrypointをコピー
    cp docker-entrypoint.sh .
    
    # docker-baseディレクトリをコピー
    cp -r docker-base .
    
    # .gitの初期化（必要に応じて）
    if [ -d .git ]; then
        rm -rf .git
    fi
    git init
    
    # Dockerボリュームを作成
    echo "5. Dockerボリュームを作成中..."
    docker volume create "${PROJECT_NAME}_bash_history"
    docker volume create "${PROJECT_NAME}_z_data"
    docker volume create "${PROJECT_NAME}_tmux_data"
    
    # Docker Composeを起動（ビルドログを表示）
    echo "6. Docker Composeを起動中..."
    echo "==============================================="
    echo "📦 Dockerイメージをビルド中..."
    echo "（初回は時間がかかる場合があります）"
    echo "==============================================="
    
    # ビルドのみ実行してログを表示
    docker compose build --progress=plain
    
    echo "==============================================="
    echo "🚀 コンテナを起動中..."
    echo "==============================================="
    
    # コンテナを起動
    docker compose up -d
    
    echo "==============================================="
    
    # コンテナが起動するまで待機
    echo "7. コンテナの起動を待機中..."
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
    echo "8. コンテナに接続中..."
    echo ""
    echo "==============================================="
    echo "プロジェクト '$PROJECT_NAME' の作成が完了しました！"
    echo "コンテナ '$CONTAINER_NAME' にdeveloperユーザーで接続します..."
    echo "==============================================="
    echo ""
    
    docker exec -it -u developer "$CONTAINER_NAME" bash
}

# スクリプトが直接実行された場合は関数を呼び出す
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    create_project "$@"
fi