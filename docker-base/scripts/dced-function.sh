#!/bin/bash

# Docker Claude Easy Developmentコマンド
# このファイルをホストの.bashrcや.bash_profileにsourceして使用

# プロジェクトコンテナに簡単に接続
dced() {
    if [ -z "$1" ]; then
        echo "使用方法: dced プロジェクト名"
        echo "例: dced beatlink"
        echo ""
        echo "利用可能なプロジェクト:"
        docker ps --format "table {{.Names}}\t{{.Status}}" | grep "claude-code-" | sed 's/claude-code-/  - /'
        return 1
    fi
    
    local project_name="$1"
    local container_name="claude-code-${project_name}"
    
    # コンテナが実行中か確認
    if ! docker ps --format "{{.Names}}" | grep -q "^${container_name}$"; then
        echo "エラー: コンテナ '${container_name}' が実行されていません"
        echo ""
        
        # 停止中のコンテナを確認
        if docker ps -a --format "{{.Names}}" | grep -q "^${container_name}$"; then
            echo "コンテナは停止中です。起動しますか？ [y/N]"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                echo "コンテナを起動中..."
                cd "$HOME/claude-project/projects/$project_name" 2>/dev/null || {
                    echo "プロジェクトディレクトリが見つかりません"
                    return 1
                }
                docker compose -f "$HOME/claude-project/docker-compose-base.yml" --project-directory . up -d
                sleep 3
                docker exec -it -u developer "${container_name}" bash
                return 0
            fi
        else
            echo "プロジェクト '$project_name' が見つかりません"
            echo ""
            echo "新規作成する場合: create-project $project_name"
        fi
        return 1
    fi
    
    # コンテナに接続
    echo "コンテナ '${container_name}' に接続中..."
    docker exec -it -u developer "${container_name}" bash
}

# プロジェクト一覧表示
dcls() {
    echo "🐳 Claude Code プロジェクト一覧:"
    echo ""
    echo "実行中:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep "claude-code-" | sed 's/claude-code-//'
    echo ""
    echo "停止中:"
    docker ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Status}}" | grep "claude-code-" | sed 's/claude-code-//'
}

# プロジェクトの停止
dcstop() {
    if [ -z "$1" ]; then
        echo "使用方法: dcstop プロジェクト名"
        return 1
    fi
    
    local project_name="$1"
    local project_dir="$HOME/claude-project/projects/$project_name"
    
    if [ ! -d "$project_dir" ]; then
        echo "プロジェクトディレクトリが見つかりません: $project_dir"
        return 1
    fi
    
    cd "$project_dir"
    docker compose -f "$HOME/claude-project/docker-compose-base.yml" --project-directory . down
}

# プロジェクトの再起動
dcrestart() {
    if [ -z "$1" ]; then
        echo "使用方法: dcrestart プロジェクト名"
        return 1
    fi
    
    dcstop "$1" && sleep 2
    
    local project_name="$1"
    local project_dir="$HOME/claude-project/projects/$project_name"
    
    cd "$project_dir"
    docker compose -f "$HOME/claude-project/docker-compose-base.yml" --project-directory . up -d
    sleep 3
    dced "$1"
}