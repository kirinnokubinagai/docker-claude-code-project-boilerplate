# Master Claude System

🤖 **動的親子プロセス管理** + 🎭 **Playwright E2Eテスト** + 🔧 **全MCP統合** の開発環境

## 🎯 コンセプト

- **動的管理**: 親Claude Codeが要件に応じて子プロセスを動的に作成・管理
- **MCP統合**: 全MCPサーバー（Supabase, Playwright, Obsidian, Stripe, LINE Bot, Context7）自動設定
- **並列開発**: tmux + git worktreeで複数の子プロセスが独立して並列作業
- **対話的**: 親子間でリアルタイムに通信しながら開発

## 🚀 使い方（超シンプル）

### デフォルト: 新しいディレクトリを自動作成（推奨）
```bash
cd /path/to/claude-code-docker-projects
./init-project.sh my-project
cd my-project
echo "ANTHROPIC_API_KEY=your_key" >> .env
```

### オプション: 現在ディレクトリで初期化
```bash
cd my-workspace
git clone /path/to/claude-code-docker-projects .
./init-project.sh my-project --no-create-dir
echo "ANTHROPIC_API_KEY=your_key" >> .env
```

### 起動
```bash
docker-compose up -d
docker-compose exec claude-code fish
```

### Master Claudeシステムを起動
```bash
# 親Claude Codeとして起動
master

# または直接実行
/workspace/master-claude.sh
```

## 💡 動的親子プロセスシステム

### 親Claude（Master）の役割
- 要件分析とタスク分割
- 子プロセスの動的作成・管理
- 進捗モニタリングと統合
- 全MCPサーバーへのアクセス

### 子プロセスの動的作成例
```bash
# Frontend担当を作成
git worktree add /workspace/worktrees/frontend -b feature/frontend
tmux new-window -t master -n "Worker-frontend" "cd /workspace/worktrees/frontend && claude --dangerously-skip-permissions"
tmux send-keys -t "master:Worker-frontend" "Frontend担当：Next.js 15でUIを実装してください" Enter

# Backend担当を作成
git worktree add /workspace/worktrees/backend -b feature/backend
tmux new-window -t master -n "Worker-backend" "cd /workspace/worktrees/backend && claude --dangerously-skip-permissions"
tmux send-keys -t "master:Worker-backend" "Backend担当：Supabase APIを実装してください" Enter
```

## 💡 典型的な開発フロー

### ステップ1: Master Claudeで要件分析
```bash
# Master Claudeを起動
master

# 要件を伝える
"ECサイトを作成してください。商品管理、カート、Stripe決済を含む"
```

### ステップ2: 親が子プロセスを動的作成
親Claude（あなた）が自動的に：
- Frontend担当（UI/UX）
- Backend担当（API）
- Database担当（DB設計）
- QA担当（テスト）
を必要に応じて作成

### ステップ3: 並列開発と統合
```bash
# 進捗確認
tmux list-windows -t master

# 子プロセスの出力確認
tmux capture-pane -t "master:Worker-frontend" -p | tail -20

# 成果物の統合
git merge feature/frontend
git merge feature/backend
```

## 📁 ディレクトリ構造

```
my-project/
├── .env                    # 環境変数（API Key等）
├── docker-compose.yml      # Docker設定（MCP自動設定付き）
├── docker-entrypoint.sh    # MCPサーバー自動設定
├── master-claude.sh        # Master Claudeシステム起動
├── docker/
│   ├── claude/
│   │   └── CLAUDE.md       # 動的親子プロセス管理設定
│   └── fish/
│       └── config.fish     # Fish shell設定（master関数付き）
├── worktrees/              # Git worktree（子プロセス作業場所）
│   ├── frontend/           # Frontend担当の作業ディレクトリ
│   ├── backend/            # Backend担当の作業ディレクトリ
│   └── database/           # Database担当の作業ディレクトリ
├── logs/                   # ログファイル
└── docs/                   # ドキュメント
```

## 🔧 利用可能なMCPサーバー（自動設定済み）

Docker起動時に以下のMCPサーバーが自動的にClaude Codeに追加されます：

- **Supabase** - データベース、認証
- **Playwright** - E2Eテスト、ブラウザ自動化
- **Obsidian** - ドキュメント管理
- **Stripe** - 決済処理
- **LINE Bot** - 通知システム
- **Context7** - 最新ライブラリ情報

## 🎯 Master Claude動的管理システム

| ウィンドウ | 役割 | 状態 |
|-----------|------|------|
| **Master** | 親プロセス（指揮者） | 常時起動 |
| **Worker-frontend** | Frontend開発 | 必要時に作成 |
| **Worker-backend** | Backend開発 | 必要時に作成 |
| **Worker-database** | DB設計 | 必要時に作成 |
| **Worker-qa** | テスト作成 | 必要時に作成 |
| **Worker-***  | その他専門タスク | 動的に追加/削除 |

## 💡 基本コマンド

```bash
# Master Claudeシステム
master                     # 親Claude起動（推奨）
/workspace/master-claude.sh # 直接起動

# 親Claude内で使うコマンド
tmux new-window -t master -n "Worker-[名前]" "cd /workspace && claude --dangerously-skip-permissions"
tmux send-keys -t "master:Worker-[名前]" "[メッセージ]" Enter
tmux list-windows -t master
tmux capture-pane -t "master:Worker-[名前]" -p | tail -20

# Docker
docker-compose up -d      # 起動（MCPサーバー自動設定）
docker-compose down       # 停止
docker-compose logs -f    # ログ確認
```

## 📝 実践例: ECサイト開発

```bash
# 1. Master Claude起動
master

# 2. 親Claudeで要件を伝える
"ECサイトを作成。商品管理、カート、Stripe決済、管理画面を含む"

# 3. 親Claudeが自動的に：
#    - Frontend担当作成 → UIコンポーネント開発
#    - Backend担当作成 → API実装
#    - Database担当作成 → テーブル設計
#    - QA担当作成 → E2Eテスト

# 4. 開発進行中の管理
#    - 各子プロセスの進捗確認
#    - 必要に応じて追加指示
#    - 成果物の統合
```

## ⚙️ 環境変数設定

最低限必要：
```bash
ANTHROPIC_API_KEY=your_key_here
```

MCPサーバー使用時（オプション）：
```bash
SUPABASE_ACCESS_TOKEN=your_token
STRIPE_SECRET_KEY=your_key
# など（.env.exampleを参照）
```

## 🔍 トラブルシューティング

### ポート競合
```bash
# 他のプロジェクトが同じポートを使用している場合
./init-project.sh my-project 3003 8083
```

### コンテナ名競合
```bash
# 自動的にプロジェクト名で区別されます
# claude-code-project1, claude-code-project2 など
```

### API Key未設定
```bash
# .envファイルでANTHROPIC_API_KEYを設定
echo "ANTHROPIC_API_KEY=your_key" >> .env
```

このテンプレートで複数のプロジェクトを簡単に作成・管理できます！
