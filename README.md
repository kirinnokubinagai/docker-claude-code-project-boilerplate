# Claude Code Docker Projects

🎭 **Playwright E2Eテスト専用** + 🖥️ **ホスト側開発** のハイブリッド環境

## 🎯 コンセプト

- **開発**: ホスト（Mac）側で通常通り `npm run dev`
- **テスト**: コンテナ内でPlaywright E2Eテスト
- **AI支援**: Claude Code + 全MCP統合でコード生成・テスト作成

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

### Claude Codeに丸投げ
```bash
cc "○○を作ってテストして"
```

## 🎯 環境分離のメリット

### Docker環境（Claude Code作業）
- Claude Code + Playwright + 全MCP統合
- 一時的な作業・テスト実行
- **Git管理対象外**

### ホスト環境（開発作業）
- `/workspace`にマウント
- 実際のアプリケーション開発
- **Git管理対象**（これが重要！）

## 💡 典型的な開発フロー

### ステップ1: ホスト側でアプリ開発
```bash
# Mac側で通常の開発
npx create-next-app@latest my-app
cd my-app
npm run dev  # localhost:3000で起動
```

### ステップ2: コンテナ内でPlaywright E2E
```bash
# claude-codeコンテナ内で
docker-compose exec claude-code fish

# Claude Codeでテスト作成
cc "localhost:3000のNext.jsアプリにPlaywright E2Eテストを作成。
ログイン機能、商品一覧、カート機能をテスト。"

# テスト実行
npx playwright test
```

### ステップ3: 開発とテストの反復
```bash
# Mac側: コード修正
# コンテナ内: テスト実行
# 繰り返し...
```

## 📁 ディレクトリ構造

```
my-project/
├── .env                    # 環境変数（API Key等）
├── .env.example           # 環境変数テンプレート
├── docker-compose.yml    # Docker設定（環境変数で動的制御）
├── Dockerfile             # コンテナ設定
├── init-project.sh       # プロジェクト初期化スクリプト
├── docker/
│   └── claude/
│       └── CLAUDE.md     # Claude Codeワークフロー設定
│   └── fish/
│       └── config.fish   # Fish shell設定（tmux + MCP統合）
├── screenshots/          # スクリーンショット出力
├── logs/                 # ログファイル
├── temp/                 # 一時ファイル
└── docs/                 # ドキュメント
```

## 🔧 利用可能なMCPサーバー

- **Supabase** - データベース、認証
- **Playwright** - E2Eテスト、ブラウザ自動化
- **Obsidian** - ドキュメント管理
- **Stripe** - 決済処理
- **LINE Bot** - 通知システム
- **Context7** - 最新ライブラリ情報

## 🎯 tmux組織構造

| 部門 | 役割 | 担当MCP |
|------|------|---------|
| **Manager** (親) | 全体統括、タスク分散 | 全MCP |
| **Frontend** | UI/UX開発 | Playwright, Context7, Stripe |
| **Backend** | API開発 | Supabase, Stripe, LINE Bot |
| **Database** | DB設計 | Supabase, Obsidian |
| **DevOps** | インフラ | Supabase, Playwright, LINE Bot |
| **QA** | テスト | Playwright, LINE Bot, Context7 |

## 💡 基本コマンド

```bash
# tmux環境
company                    # 組織構造作成
roles                      # 各部門に役割割り当て
assign frontend "タスク"   # 部門にタスク割り当て
status                     # 全部門状況確認
clear_workers             # 全作業者リセット

# Docker
docker-compose up -d      # 起動
docker-compose down       # 停止
docker-compose logs -f    # ログ確認
```

## 📝 複数プロジェクト作成例

```bash
# ECサイトプロジェクト
cp -r claude-code-docker-projects ecommerce-site
cd ecommerce-site
./init-project.sh ecommerce 3001 8081

# ブログプロジェクト  
cp -r claude-code-docker-projects blog-system
cd blog-system
./init-project.sh blog 3002 8082

# 両方同時起動可能（異なるポート番号なので競合しない）
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
