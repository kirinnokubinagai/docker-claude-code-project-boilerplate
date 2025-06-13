#!/bin/bash

# Generate Team Tasks
# プロジェクトタイプに基づいて動的にタスクを生成

PROJECT_TYPE="${1:-web}"  # web, mobile, api, cli など
PROJECT_NAME="${2:-MyProject}"

# タスクファイルのパス
TASKS_FILE="/workspace/config/team-tasks.json"

# プロジェクトタイプに応じたタスク生成
generate_tasks() {
    case "$PROJECT_TYPE" in
        "web")
            cat > "$TASKS_FILE" << EOF
{
  "master": {
    "initial_prompt": "私はMaster Claudeです。${PROJECT_NAME}のWeb開発プロジェクトを統括します。\\n\\n現在の目標：\\n1. プロジェクトの技術スタックを確定\\n2. 各チームのタスクを割り振り\\n3. 進捗管理とコードレビュー"
  },
  "frontend": {
    "member_tasks": [
      {
        "member_id": 1,
        "role": "Frontend Lead",
        "initial_prompt": "私はFrontend Leadです。${PROJECT_NAME}のフロントエンド開発をリードします。\\n\\n担当タスク：\\n1. Next.js 14でのプロジェクトセットアップ\\n2. UIコンポーネントライブラリの選定（shadcn/ui推奨）\\n3. 状態管理の設計（Zustand or Jotai）\\n4. ルーティング構造の設計"
      },
      {
        "member_id": 2,
        "role": "UI/UX Developer",
        "initial_prompt": "私はUI/UX Developerです。${PROJECT_NAME}のユーザー体験を設計します。\\n\\n担当タスク：\\n1. デザインシステムの構築\\n2. レスポンシブデザインの実装\\n3. アクセシビリティ対応（WCAG 2.1 AA準拠）\\n4. パフォーマンス最適化（Core Web Vitals）"
      }
    ]
  },
  "backend": {
    "member_tasks": [
      {
        "member_id": 1,
        "role": "Backend Lead",
        "initial_prompt": "私はBackend Leadです。${PROJECT_NAME}のバックエンド開発をリードします。\\n\\n担当タスク：\\n1. Node.js + TypeScriptでのAPIサーバー構築\\n2. PostgreSQLデータベース設計\\n3. 認証・認可システムの実装（JWT + OAuth2）\\n4. APIドキュメント自動生成（OpenAPI）"
      },
      {
        "member_id": 2,
        "role": "DevOps Engineer",
        "initial_prompt": "私はDevOps Engineerです。${PROJECT_NAME}のインフラと運用を担当します。\\n\\n担当タスク：\\n1. Docker環境の構築\\n2. CI/CDパイプラインの設定（GitHub Actions）\\n3. 本番環境のデプロイ設定（Vercel + Railway）\\n4. モニタリングとログ管理"
      }
    ]
  }
}
EOF
            ;;
        "mobile")
            cat > "$TASKS_FILE" << EOF
{
  "master": {
    "initial_prompt": "私はMaster Claudeです。${PROJECT_NAME}のモバイルアプリ開発プロジェクトを統括します。\\n\\n現在の目標：\\n1. React Native vs Flutter の技術選定\\n2. iOS/Android同時開発の戦略\\n3. バックエンドAPIとの連携設計"
  },
  "mobile": {
    "member_tasks": [
      {
        "member_id": 1,
        "role": "Mobile Lead",
        "initial_prompt": "私はMobile Leadです。${PROJECT_NAME}のモバイルアプリ開発をリードします。\\n\\n担当タスク：\\n1. React Native + Expoでのプロジェクトセットアップ\\n2. ナビゲーション構造の設計\\n3. プッシュ通知の実装\\n4. オフライン対応の設計"
      },
      {
        "member_id": 2,
        "role": "Mobile UI Developer",
        "initial_prompt": "私はMobile UI Developerです。${PROJECT_NAME}のモバイルUIを実装します。\\n\\n担当タスク：\\n1. UIコンポーネントライブラリの実装\\n2. アニメーションとトランジション\\n3. ダークモード対応\\n4. 各種画面サイズへの対応"
      }
    ]
  },
  "backend": {
    "member_tasks": [
      {
        "member_id": 1,
        "role": "API Developer",
        "initial_prompt": "私はAPI Developerです。${PROJECT_NAME}のモバイルアプリ向けAPIを開発します。\\n\\n担当タスク：\\n1. RESTful APIの設計と実装\\n2. リアルタイム通信（WebSocket）\\n3. ファイルアップロード機能\\n4. プッシュ通知サーバーの実装"
      }
    ]
  }
}
EOF
            ;;
        "api")
            cat > "$TASKS_FILE" << EOF
{
  "master": {
    "initial_prompt": "私はMaster Claudeです。${PROJECT_NAME}のAPI開発プロジェクトを統括します。\\n\\n現在の目標：\\n1. マイクロサービスアーキテクチャの設計\\n2. API仕様の策定\\n3. セキュリティとパフォーマンスの最適化"
  },
  "backend": {
    "member_tasks": [
      {
        "member_id": 1,
        "role": "API Architect",
        "initial_prompt": "私はAPI Architectです。${PROJECT_NAME}のAPI設計を担当します。\\n\\n担当タスク：\\n1. マイクロサービス構成の設計\\n2. API Gateway の実装\\n3. 認証・認可サービスの構築\\n4. イベント駆動アーキテクチャの設計"
      },
      {
        "member_id": 2,
        "role": "Backend Developer",
        "initial_prompt": "私はBackend Developerです。${PROJECT_NAME}のAPIを実装します。\\n\\n担当タスク：\\n1. 各マイクロサービスの実装\\n2. データベース設計と最適化\\n3. キャッシング戦略の実装\\n4. 単体テストと統合テスト"
      },
      {
        "member_id": 3,
        "role": "Infrastructure Engineer",
        "initial_prompt": "私はInfrastructure Engineerです。${PROJECT_NAME}のインフラを構築します。\\n\\n担当タスク：\\n1. Kubernetes環境の構築\\n2. サービスメッシュの実装\\n3. 監視とロギングシステム\\n4. 自動スケーリングの設定"
      }
    ]
  }
}
EOF
            ;;
        *)
            # デフォルトのタスク
            echo "Unknown project type: $PROJECT_TYPE. Using default tasks."
            ;;
    esac
}

# メイン処理
echo "Generating tasks for $PROJECT_TYPE project: $PROJECT_NAME"
generate_tasks
echo "Tasks generated successfully at: $TASKS_FILE"