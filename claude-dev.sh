#!/bin/bash
# Claude Code Developer Shell Wrapper
# developerユーザーとして自動的にコンテナに接続

# プロジェクト名を取得（docker-compose.ymlがあるディレクトリ名を使用）
PROJECT_DIR=$(basename "$(pwd)")

# コンテナ名を構築
CONTAINER_NAME="claude-code-${PROJECT_DIR}"

# docker-compose.ymlの存在確認
if [ ! -f "docker-compose.yml" ]; then
    echo "エラー: docker-compose.ymlが見つかりません"
    echo "プロジェクトディレクトリで実行してください"
    exit 1
fi

# コンテナが起動しているか確認
if ! docker ps --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "コンテナ '${CONTAINER_NAME}' が起動していません"
    echo "先に 'docker compose up -d' を実行してください"
    exit 1
fi

# developerユーザーとしてfishシェルに接続
echo "Connecting to ${CONTAINER_NAME} as developer..."
docker compose exec -u developer claude-code fish