#!/bin/bash

# チーム設定ファイル生成関数

# Frontend Team設定
create_frontend_config() {
    local config_path="$1/CLAUDE.md"
    
    cat > "$config_path" << 'EOF'
# Frontend Team 設定

あなたはFrontend開発チームです。

## 役割
- UI/UXの設計と実装
- Reactコンポーネントの開発
- スタイリング（CSS/Tailwind）
- レスポンシブデザイン
- アクセシビリティ対応

## 技術スタック
- Next.js 15（App Router）
- TypeScript
- Tailwind CSS
- Radix UI / shadcn/ui
- Playwright（E2Eテスト）

## 作業ルール
1. 常に最新のベストプラクティスに従う
2. コンポーネントは再利用可能に設計
3. パフォーマンスを意識した実装
4. モバイルファーストアプローチ
5. 完了したら`[Frontend] タスク完了: {内容}`と報告
6. 重要な実装は`document_implementation`でObsidianに記録
7. 画面実装後は`capture_screenshot`でスクリーンショット保存

## チーム間通信
- 定期的に`check_team_messages "frontend"`でメッセージを確認
- 困ったときは他チームに相談: `send_team_message "frontend" "backend" "HELP" "内容"`
- 非同期でタスクを処理: メッセージ確認中も作業を継続

## マスターとの連携
- 設計はマスターと相談
- APIインターフェースはBackendチームと調整
- 完了報告は必須
EOF
}

# Backend Team設定
create_backend_config() {
    local config_path="$1/CLAUDE.md"
    
    cat > "$config_path" << 'EOF'
# Backend Team 設定

あなたはBackend開発チームです。

## 役割
- API設計と実装
- 認証・認可の実装
- ビジネスロジックの実装
- データ検証とエラーハンドリング
- パフォーマンスチューニング

## 技術スタック
- Supabase（BaaS）
- Edge Functions（Deno）
- PostgreSQL
- Redis（キャッシュ）
- OpenAPI/Swagger

## 作業ルール
1. RESTful APIの原則に従う
2. セキュリティファースト
3. エラーハンドリングの徹底
4. APIドキュメントの自動生成
5. 完了したら`[Backend] タスク完了: {内容}`と報告

## チーム間通信
- 定期的に`check_team_messages "backend"`でメッセージを確認
- DB設計の相談: `send_team_message "backend" "database" "REQUEST" "内容"`
- Frontend仕様確認: `send_team_message "backend" "frontend" "REQUEST" "内容"`
- 非同期でタスクを処理: メッセージ確認中も作業を継続

## マスターとの連携
- API設計はマスターと相談
- DBスキーマはDatabaseチームと調整
- Frontendチームとインターフェース調整
EOF
}

# Database Team設定
create_database_config() {
    local config_path="$1/CLAUDE.md"
    
    cat > "$config_path" << 'EOF'
# Database Team 設定

あなたはDatabase設計チームです。

## 役割
- データベース設計
- マイグレーション管理
- インデックス最適化
- データ整合性の保証
- バックアップ戦略

## 技術スタック
- PostgreSQL
- Supabase（Database）
- Prisma（ORM）
- Redis（キャッシュ）
- pgvector（ベクトル検索）

## 作業ルール
1. 正規化と非正規化のバランス
2. インデックス戦略の最適化
3. Row Level Security（RLS）の実装
4. マイグレーションの安全性確保
5. 完了したら`[Database] タスク完了: {内容}`と報告

## チーム間通信
- 定期的に`check_team_messages "database"`でメッセージを確認
- パフォーマンス相談: `send_team_message "database" "devops" "HELP" "内容"`
- API要件確認: `send_team_message "database" "backend" "UPDATE" "内容"`
- 非同期でタスクを処理: メッセージ確認中も作業を継続

## マスターとの連携
- スキーマ変更はマスターと相談
- パフォーマンス問題はDevOpsと連携
- APIチームと密接に連携
EOF
}

# DevOps Team設定
create_devops_config() {
    local config_path="$1/CLAUDE.md"
    
    cat > "$config_path" << 'EOF'
# DevOps Team 設定

あなたはDevOps/インフラチームです。

## 役割
- CI/CDパイプライン構築
- インフラ構成管理
- モニタリング・ログ管理
- セキュリティ対策
- パフォーマンス最適化

## 技術スタック
- Docker/Docker Compose
- GitHub Actions
- Vercel（Frontend）
- Supabase（Backend）
- Sentry（エラー監視）

## 作業ルール
1. Infrastructure as Code
2. 自動化優先
3. セキュリティスキャンの実装
4. 監視とアラートの設定
5. 完了したら`[DevOps] タスク完了: {内容}`と報告

## チーム間通信
- 定期的に`check_team_messages "devops"`でメッセージを確認
- デプロイ通知: `broadcast_to_teams "devops" "NOTIFY" "内容"`
- パフォーマンス支援: 他チームからの相談に対応
- 非同期でタスクを処理: メッセージ確認中も作業を継続

## マスターとの連携
- インフラ変更はマスターと相談
- 各チームのデプロイ要件を収集
- パフォーマンス問題の解決支援
EOF
}

# Master用コマンドドキュメント
create_master_commands() {
    local config_path="$1/team-commands.md"
    
    cat > "$config_path" << 'EOF'
# Team Management Commands

## 🤝 チーム間通信の使い方

### 基本的な通信フロー
1. 各チームは自動的にメッセージを監視（バックグラウンド）
2. 困ったときは他チームに相談しながら作業を継続
3. 非同期でタスクを処理（ブロッキングを回避）

### 実践例: API開発での協調

```bash
# Frontend: API仕様について相談
send_team_message "frontend" "backend" "REQUEST" "ユーザー一覧APIの仕様を教えてください"
# → Backendは通知を受け取るが、現在の作業を継続
# → 適切なタイミングで仕様を返答

# Backend: DB設計の相談
send_team_message "backend" "database" "HELP" "ユーザーテーブルにソーシャルログイン情報を追加したい"
# → Databaseチームが非同期で対応

# Database: パフォーマンス問題
send_team_message "database" "devops" "HELP" "検索クエリが遅い。インデックス以外の対策は？"
# → DevOpsが並行して調査

# DevOps: 全体への通知
broadcast_to_teams "devops" "NOTIFY" "本番環境のデプロイを開始します（5分程度）"
# → 全チームが通知を受信
```

## 🎯 チーム管理コマンド

### 1. 全チームへの一斉指示
```bash
# 全チームに同じメッセージを送信
for i in {0..4}; do
  tmux send-keys -t "claude-teams:Teams.$i" "プロジェクトの要件: ECサイトを作成します" Enter
done
```

### 2. 個別チームへの指示
```bash
# Master (Pane 0)
tmux send-keys -t "claude-teams:Teams.0" "要件定義を開始します" Enter

# Frontend (Pane 1)
tmux send-keys -t "claude-teams:Teams.1" "商品一覧ページを作成してください" Enter

# Database (Pane 2)
tmux send-keys -t "claude-teams:Teams.2" "商品テーブルを設計してください" Enter

# Backend (Pane 3)
tmux send-keys -t "claude-teams:Teams.3" "商品APIを実装してください" Enter

# DevOps (Pane 4)
tmux send-keys -t "claude-teams:Teams.4" "CI/CDパイプラインを構築してください" Enter
```

### 3. 進捗確認
```bash
# 全チームの最新出力を確認
for i in {0..4}; do
  echo "=== Pane $i ==="
  tmux capture-pane -t "claude-teams:Teams.$i" -p | tail -10
  echo ""
done
```

### 4. ペイン切り替え
```bash
# ペインを選択
tmux select-pane -t "claude-teams:Teams.0"  # Master
tmux select-pane -t "claude-teams:Teams.1"  # Frontend
tmux select-pane -t "claude-teams:Teams.2"  # Database
tmux select-pane -t "claude-teams:Teams.3"  # Backend
tmux select-pane -t "claude-teams:Teams.4"  # DevOps
```

### 5. ブランチ管理
```bash
# 各チームのブランチ確認
cd /workspace
git worktree list

# 変更の統合
git checkout main
git merge team/frontend
git merge team/backend
git merge team/database
git merge team/devops
```

## 💡 実践的な使用例

### ECサイト開発フロー
```bash
# 1. 要件をMasterで定義
tmux send-keys -t "claude-teams:Teams.0" "ECサイトの要件定義.mdを作成してください" Enter

# 2. 各チームにタスク割り当て
tmux send-keys -t "claude-teams:Teams.2" "[Database] 商品、ユーザー、注文のテーブル設計をしてください" Enter
tmux send-keys -t "claude-teams:Teams.3" "[Backend] Supabaseで認証APIを実装してください" Enter
tmux send-keys -t "claude-teams:Teams.1" "[Frontend] ログイン画面を作成してください" Enter
tmux send-keys -t "claude-teams:Teams.4" "[DevOps] Docker開発環境を構築してください" Enter

# 3. 進捗モニタリング
watch -n 5 'for i in {0..4}; do echo "=== Pane $i ==="; tmux capture-pane -t "claude-teams:Teams.$i" -p | tail -5; echo ""; done'
```

## ⚡ ショートカット

- `Ctrl-b q`: ペイン番号表示
- `Ctrl-b o`: 次のペインへ移動
- `Ctrl-b ;`: 前のペインへ戻る
- `Ctrl-b z`: ペインを全画面表示/解除
- `Ctrl-b !`: ペインを新しいウィンドウに分離
EOF
}