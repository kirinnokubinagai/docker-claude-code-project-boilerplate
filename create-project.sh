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
    
    local wait_count=0
    local dot_count=0
    
    while true; do
        if docker ps | grep -q "$CONTAINER_NAME"; then
            echo ""
            echo "✅ コンテナが起動しました！（${wait_count}秒）"
            break
        fi
        
        # プログレス表示
        if [ $((wait_count % 5)) -eq 0 ]; then
            printf "."
            dot_count=$((dot_count + 1))
            
            # 60秒ごとに経過時間を表示
            if [ $((wait_count % 60)) -eq 0 ] && [ $wait_count -gt 0 ]; then
                printf " [${wait_count}秒経過]"
            fi
            
            # 20個のドットで改行
            if [ $dot_count -eq 20 ]; then
                echo ""
                echo "                      "
                dot_count=0
            fi
        fi
        
        # 初回のイメージダウンロードの可能性を通知
        if [ $wait_count -eq 30 ]; then
            echo ""
            echo "ℹ️  初回実行時はDockerイメージのダウンロードに時間がかかる場合があります"
            echo "   継続して待機中"
        fi
        
        sleep 1
        wait_count=$((wait_count + 1))
        
        # 5分以上かかっている場合は警告
        if [ $wait_count -eq 300 ]; then
            echo ""
            echo "⚠️  警告: 5分以上経過しています。別のターミナルで以下を確認してください："
            echo "   docker compose logs -f"
            echo "   待機を継続中"
        fi
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