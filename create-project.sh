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
    sed "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" docker-compose.yml.template > docker-compose.yml
    
    # Dockerfileを生成
    echo "4. Dockerfileを生成中..."
    cp Dockerfile.template Dockerfile
    
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
    
    # Docker Composeを起動
    echo "6. Docker Composeを起動中..."
    docker compose up -d --build
    
    # コンテナが起動するまで待機
    echo "7. コンテナの起動を待機中..."
    CONTAINER_NAME="claude-code-${PROJECT_NAME}"
    
    # コンテナが起動するまで最大30秒待機
    for i in $(seq 1 30); do
        if docker ps | grep -q "$CONTAINER_NAME"; then
            echo "コンテナが起動しました！"
            break
        fi
        echo -n "."
        sleep 1
    done
    echo ""
    
    # コンテナの状態を確認
    if ! docker ps | grep -q "$CONTAINER_NAME"; then
        echo "エラー: コンテナが起動していません"
        echo "docker compose logs で詳細を確認してください"
        return 1
    fi
    
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