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

# QA Team設定
create_qa_config() {
    local config_path="$1/CLAUDE.md"
    
    cat > "$config_path" << 'EOF'
# QA Team 設定

あなたはQA（品質保証）チームです。

## 役割
- テスト戦略の策定
- E2Eテストの実装
- パフォーマンステスト
- セキュリティテスト
- ユーザビリティテスト

## 技術スタック
- Playwright（E2Eテスト）
- Jest/Vitest（単体テスト）
- OWASP ZAP（セキュリティテスト）
- Lighthouse（パフォーマンステスト）
- Sentry（エラー監視）

## 作業ルール
1. テストカバレッジ90%以上
2. 自動化優先
3. 早期からのセキュリティテスト
4. ユーザビリティの継続的評価
5. 完了したら`[QA] タスク完了: {内容}`と報告

## チーム間通信
- 定期的に`check_team_messages "qa"`でメッセージを確認
- バグ報告: `send_team_message "qa" "{team}" "NOTIFY" "バグ詳細"`
- テスト結果共有: `broadcast_to_teams "qa" "UPDATE" "テスト結果"`
- 非同期でタスクを処理: メッセージ確認中も作業を継続

## マスターとの連携
- テスト戦略はマスターと相談
- 品質基準の確認と遵守
- 各チームとの連携テスト
EOF
}

# Security Team設定
create_security_config() {
    local config_path="$1/CLAUDE.md"
    
    cat > "$config_path" << 'EOF'
# Security Team 設定

あなたはSecurityチームです。

## 役割
- セキュリティ設計
- 脆弱性診断
- ペネトレーションテスト
- セキュリティ監査
- インシデント対応計画

## 技術スタック
- OWASP ZAP
- Snyk
- GitHub Security Scanning
- Sentry（セキュリティ監視）
- SSL/TLS設定

## 作業ルール
1. OWASP Top 10対策
2. ゼロトラストアーキテクチャ
3. 最小権限の原則
4. 継続的なセキュリティテスト
5. 完了したら`[Security] タスク完了: {内容}`と報告

## チーム間通信
- 定期的に`check_team_messages "security"`でメッセージを確認
- 脆弱性報告: `broadcast_to_teams "security" "ALERT" "脆弱性詳細"`
- セキュリティ相談対応: 各チームからの質問に回答
- 非同期でタスクを処理: メッセージ確認中も作業を継続

## マスターとの連携
- セキュリティポリシーはマスターと策定
- インシデント対応計画の策定
- 各チームのセキュリティ教育
EOF
}

# Master用コマンドドキュメント
create_master_commands() {
    local config_path="$1/team-commands.md"
    
    cat > "$config_path" << 'EOF'
# Team Management Commands - 6チーム体制

## 🤝 チーム間通信の使い方

### 基本的な通信フロー
1. 各チームは自動的にメッセージを監視（バックグラウンド）
2. 困ったときは他チームに相談しながら作業を継続
3. 非同期でタスクを処理（ブロッキングを回避）

### 実践例: API開発での協調

```bash
# Frontend: API仕様について相談
send_team_message "frontend" "backend" "REQUEST" "ユーザー一覧APIの仕様を教えてください"

# Backend: DB設計の相談
send_team_message "backend" "database" "HELP" "ユーザーテーブルにソーシャルログイン情報を追加したい"

# QA: バグ報告
send_team_message "qa" "frontend" "NOTIFY" "ログイン画面でXSSの脆弱性を発見"

# Security: 全体への警告
broadcast_to_teams "security" "ALERT" "新しい脆弱性CVE-2024-XXXXへの対応が必要"

# DevOps: デプロイ通知
broadcast_to_teams "devops" "NOTIFY" "本番環境のデプロイを開始します（5分程度）"
```

## 🎯 チーム管理コマンド

### 1. 全チームへの一斉指示
```bash
# 全チームに同じメッセージを送信
for i in {0..5}; do
  tmux send-keys -t "claude-teams:Teams.$i" "プロジェクトの要件: Todoアプリを作成します" Enter
done
```

### 2. 個別チームへの指示
```bash
# Master (Pane 0)
tmux send-keys -t "claude-teams:Teams.0" "要件定義を開始します" Enter

# Frontend (Pane 1)
tmux send-keys -t "claude-teams:Teams.1" "Todoリストのコンポーネントを作成してください" Enter

# Backend (Pane 2)
tmux send-keys -t "claude-teams:Teams.2" "Todo APIを実装してください" Enter

# Database (Pane 3)
tmux send-keys -t "claude-teams:Teams.3" "Todoテーブルを設計してください" Enter

# DevOps (Pane 4)
tmux send-keys -t "claude-teams:Teams.4" "CI/CDパイプラインを構築してください" Enter

# QA/Security (Pane 5)
tmux send-keys -t "claude-teams:Teams.5" "テスト計画とセキュリティ監査を実施してください" Enter
```

### 3. 進捗確認
```bash
# 全チームの最新出力を確認
for i in {0..5}; do
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
tmux select-pane -t "claude-teams:Teams.2"  # Backend
tmux select-pane -t "claude-teams:Teams.3"  # Database
tmux select-pane -t "claude-teams:Teams.4"  # DevOps
tmux select-pane -t "claude-teams:Teams.5"  # QA/Security
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
git merge team/qa
git merge team/security
```

## 💡 6チーム体制のレイアウト

```
┌─────────────┬─────────────┐
│  0: Master  │ 3: Database │
├─────────────┼─────────────┤
│ 1: Frontend │  4: DevOps  │
├─────────────┼─────────────┤
│ 2: Backend  │ 5: QA/Sec   │
└─────────────┴─────────────┘
```

## ⚡ ショートカット

- `Ctrl+a q`: ペイン番号表示
- `Ctrl+a 0-5`: ペイン切り替え
- `Ctrl+a z`: ペイン最大化/復元
- `Ctrl+a d`: セッションから離脱

## 🔍 チーム状態の監視

```bash
# リアルタイム監視（別ターミナルで実行）
watch -n 5 'for i in {0..5}; do 
  echo "=== Team $i ==="; 
  tmux capture-pane -t "claude-teams:Teams.$i" -p | tail -5; 
  echo ""; 
done'
```

## 📝 設定の再読み込み

```bash
# Claude Code設定の確認
for team in frontend backend database devops qa security; do
  echo "=== $team ==="
  cat worktrees/$team/CLAUDE.md | head -20
  echo ""
done
```
EOF
}

# チームブランチ名を取得
get_team_branch() {
    local team="$1"
    case "$team" in
        "frontend") echo "team/frontend" ;;
        "backend") echo "team/backend" ;;
        "database") echo "team/database" ;;
        "devops") echo "team/devops" ;;
        "qa") echo "team/qa" ;;
        "security") echo "team/security" ;;
        *) echo "team/$team" ;;
    esac
}