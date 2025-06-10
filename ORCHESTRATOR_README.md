# Claude Code Orchestrator - 親子プロセス管理システム

親プロセスのClaude Codeが要件定義を分析し、子プロセスに自動的にタスクを配布するシステムです。

## 🎯 概要

- **親プロセス（Manager）**: 要件定義の分析、タスク分割、進捗管理
- **子プロセス（5部門）**: Frontend、Backend、Database、DevOps、QA
- **自動化**: Git worktree作成、tmux pane管理、タスク配布

## 🚀 セットアップ

### 1. Docker環境の準備

```bash
# プロジェクト初期化
./init-project.sh myproject

# .envファイルにAPI Key設定
echo "ANTHROPIC_API_KEY=your_key" >> .env

# Docker起動
docker-compose up -d
docker-compose exec claude-code fish
```

### 2. tmux環境の初期化

```bash
# tmuxセッション作成（6つのpane）
company

# 各部門にClaude Code起動
roles
```

### 3. Orchestratorの初期化

```bash
# worktree作成と子プロセス配置
./claude-orchestrator.sh init
```

## 📋 使い方

### 基本的なワークフロー

1. **要件定義を親プロセスに渡す**
```bash
./claude-orchestrator.sh analyze 'ECサイトを作成。ユーザー認証、商品管理、決済機能を含む'
```

2. **親プロセスが自動的に**:
   - 要件を分析
   - タスクに分割
   - 各部門に配布

3. **子プロセスが実行**:
   - 各worktreeで作業
   - MCPツールを活用
   - 完了したら親に報告

### クイックタスク配布

よくある機能を素早く配布:

```bash
# 認証機能
./claude-orchestrator.sh quick auth

# 決済機能
./claude-orchestrator.sh quick payment

# CRUD機能
./claude-orchestrator.sh quick crud
```

### ステータス確認

```bash
# 全部門の状態確認
./claude-orchestrator.sh status
```

## 🛠️ 高度な使い方

### 親プロセスから直接指示

親プロセス（Manager pane）で直接コマンドを実行:

```bash
# Frontend部門に指示
tmux send-keys -t %27 'ダッシュボード画面を作成してください' Enter

# Backend部門に指示  
tmux send-keys -t %28 'REST APIを実装してください' Enter

# 全部門に一斉指示
for pane in %27 %28 %29 %30 %31; do
  tmux send-keys -t $pane '最新のコードをgit pullしてください' Enter
done
```

### 通信ヘルパーの使用

```bash
# ヘルパー読み込み
source parent-child-comm.sh

# 特定部門にメッセージ送信
parent_to_child frontend "ログイン画面を作成してください"

# 全部門に緊急指示
emergency_command "全作業を一時停止してください"

# 進捗モニタリング
monitor_progress
```

## 📁 ディレクトリ構造

```
workspace/
├── worktrees/           # Git worktree
│   ├── frontend/       # Frontend部門の作業ディレクトリ
│   ├── backend/        # Backend部門の作業ディレクトリ
│   ├── database/       # Database部門の作業ディレクトリ
│   ├── devops/         # DevOps部門の作業ディレクトリ
│   └── qa/            # QA部門の作業ディレクトリ
├── logs/
│   └── communications/ # 親子プロセス間の通信ログ
└── requirements.md     # 要件定義ファイル
```

## 🔧 tmux pane構成

```
┌─────────────┬─────────────┬─────────────┐
│   Manager   │  Frontend   │   Backend   │
│  (親/pane0) │  (pane1)    │   (pane2)   │
├─────────────┼─────────────┼─────────────┤
│             │  Database   │   DevOps    │
│             │  (pane3)    │   (pane4)   │
│             ├─────────────┼─────────────┤
│             │     QA      │             │
│             │  (pane5)    │             │
└─────────────┴─────────────┴─────────────┘
```

## 💡 ベストプラクティス

1. **要件は具体的に記述**
   - NG: "Webアプリを作って"
   - OK: "ユーザー認証付きのタスク管理アプリ。Supabase認証、Stripe課金"

2. **MCPツールを活用**
   - Context7: 最新技術調査
   - Playwright: E2Eテスト
   - Supabase: DB・認証
   - Stripe: 決済
   - LINE Bot: 通知

3. **段階的に実装**
   - Phase 1: 設計・調査
   - Phase 2: 実装
   - Phase 3: テスト

## 🚨 トラブルシューティング

### tmuxセッションが見つからない
```bash
# セッション確認
tmux ls

# 再作成
company
roles
```

### worktreeエラー
```bash
# worktree一覧
git worktree list

# クリーンアップ
git worktree prune
```

### プロセスが応答しない
```bash
# 緊急停止
emergency_stop

# 再起動
company
roles
```

## 📝 カスタマイズ

`docker/claude/CLAUDE.md`を編集して:
- ワークフロー変更
- 部門の役割調整
- MCPツール設定

## 🎯 実践例

### ECサイト構築
```bash
./claude-orchestrator.sh analyze 'ECサイトを構築。商品カタログ、カート機能、Stripe決済、管理画面を含む。Next.js + Supabase使用'
```

### SaaSアプリケーション
```bash
./claude-orchestrator.sh analyze 'マルチテナントSaaS。ユーザー管理、サブスクリプション課金、ダッシュボード、API提供'
```

### モバイルアプリバックエンド
```bash
./claude-orchestrator.sh analyze 'モバイルアプリ用REST API。プッシュ通知、リアルタイムチャット、画像アップロード機能'
```

これで、親プロセスから子プロセスへの自動的なタスク配布システムが完成です！