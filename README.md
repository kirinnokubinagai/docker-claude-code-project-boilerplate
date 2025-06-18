# 🚀 Claude Code Docker Boilerplate

プロダクションレディな開発環境を即座に構築。Claude Code + Master Claude Teams System搭載。

## ✨ 特徴

- **🐳 完全Dockerized環境** - ローカル環境を汚さない
- **🤖 Claude Code統合** - 最新のAI開発支援
- **👥 Master Claude Teams** - 複数のClaudeが協調する革新的チーム開発
- **🔧 MCP (Model Context Protocol)** - 外部サービスとの連携
- **📦 プロジェクトテンプレート** - すぐに開発開始可能

## 📋 必要な環境

- Docker Desktop

## 🚀 クイックスタート

### 1. インストール（初回のみ）

```bash
# リポジトリをクローン
git clone https://github.com/yourusername/docker-claude-code-boilerplate.git ~/docker-claude-code-boiler-plate

# Fish shellユーザー
echo "alias create-project='sh ~/docker-claude-code-boiler-plate/create-project.sh'" >> ~/.config/fish/config.fish

# Bash/Zshユーザー  
echo "source ~/docker-claude-code-boiler-plate/create-project.sh" >> ~/.bashrc
```

### 2. プロジェクト作成

```bash
# 新規プロジェクトを作成（自動でDockerコンテナに接続）
create-project my-awesome-app
```

これだけで開発環境が整います！

### 3. アプリ開発開始

```bash
# コンテナ内で実行
ccd  # AIと対話しながら開発
```

## 🏗️ アーキテクチャ

```
my-project/
├── docker-base/          # システム設定（workspaceには表示されない）
│   ├── config/          # 実行時設定
│   ├── templates/       # チーム開発用テンプレート
│   └── scripts/         # 各種スクリプト
├── /workspace/          # プロジェクトファイル（クリーンな作業環境）
└── /opt/claude-system/  # システムファイル（分離されたシステム領域）
```

## 🛠️ 主要コマンド

| コマンド      | 説明                                         |
| ------------- | -------------------------------------------- |
| `cc`          | Claude CLIを起動（権限確認自動スキップなし） |
| `ccd`         | Claude CLIを起動（権限確認自動スキップ）     |
| `master`      | Master Claude Teamsを起動                    |
| `setup-mcp`   | MCPサーバーを設定/更新                       |
| `check_mcp`   | MCPサーバーの状態確認                        |
| `create-repo` | GitHubリポジトリを作成                       |
| `pcd`         | ディレクトリ選択（peco）                     |
| `pgb`         | Gitブランチ選択（peco）                      |
| `help`        | コマンド一覧とtmux操作ガイド                 |

## 👥 Master Claude Teams System

複数のClaude AIが協調して開発を進める革新的なシステム。

### 基本的な使い方

1. **要件定義**
   ```bash
   cc  # 「SNSアプリを作りたい」と伝える
   ```

2. **チーム起動**
   ```bash
   master  # 自動的にチーム構成に基づいてClaude達が起動
   ```

### メモリ最適化（16GBマシン向け）

```bash
# 段階的起動でメモリ負荷を分散
master --phased

# バックグラウンドで起動
master --no-attach
```

### 推奨チーム構成

| メモリ | チーム数    | 人数  | 起動方法          |
| ------ | ----------- | ----- | ----------------- |
| 8GB    | 1-2チーム   | 3-6人 | `master`          |
| 16GB   | 2-3チーム   | 6-9人 | `master`          |
| 16GB   | 4チーム     | 12人  | `master --phased` |
| 32GB+  | 5チーム以上 | 15人+ | `master --phased` |

## 🔌 MCP (Model Context Protocol)

事前設定済みのMCPサーバー：

- **GitHub** - リポジトリ操作、PR/Issue管理
- **Supabase** - データベース操作
- **Obsidian** - ドキュメント管理
- **LINE Bot** - 通知送信
- **Stripe** - 決済統合（要API Key）
- **Playwright** - ブラウザ自動操作
- **Magic MCP** - AI駆動UIコンポーネント生成（要API Key）
- その他多数...

### MCPサーバーの追加

```bash
# docker-base/config/mcp-servers.json を編集
setup-mcp  # 設定を反映
check_mcp  # 状態確認
```

## 🎯 開発フロー

1. **プロジェクト作成**
   ```bash
   create-project my-app
   ```

2. **要件定義**
   ```bash
   cc  # AIと対話しながら要件を定義
       # → 技術選定、開発環境構築、GitHubリポジトリ作成まで自動実行
   ```

3. **チーム開発**（オプション）
   ```bash
   master  # 複数のClaude AIによる並行開発
   ```

4. **デプロイ**
   ```bash
   # プロジェクトに応じた方法でデプロイ
   ```

## 📝 環境変数

`cp .env.example .env`で`.env`ファイルを作成：

```bash
# 必須
ANTHROPIC_API_KEY=your_api_key_here

# オプション（MCP用）
GITHUB_TOKEN=
SUPABASE_ACCESS_TOKEN=
STRIPE_SEC_KEY=
CHANNEL_ACCESS_TOKEN=
DESTINATION_USER_ID=
OBSIDIAN_API_KEY=
MAGIC_API_KEY=
# ... その他のAPI Keys
```

### 各MCPサーバーの詳細説明

#### GitHub MCP
GitHubリポジトリの操作を自動化：
- **リポジトリ管理** - 作成、フォーク、ブランチ操作
- **PR/Issue管理** - 作成、更新、レビュー、マージ
- **コード検索** - リポジトリ内のコード検索
- **ファイル操作** - ファイルの作成、更新、削除

#### Supabase MCP
Supabaseプロジェクトの完全な管理：
- **プロジェクト管理** - 作成、一時停止、復元
- **データベース操作** - テーブル作成、SQL実行、マイグレーション
- **Edge Functions** - サーバーレス関数のデプロイ
- **セキュリティ監査** - RLSポリシーチェック、パフォーマンス最適化提案

#### Obsidian MCP
ナレッジベースとドキュメント管理：
- **ノート操作** - 作成、読み取り、更新、削除
- **検索機能** - セマンティック検索、Dataview/JsonLogic検索
- **テンプレート実行** - Templaterテンプレートの実行
- **リアルタイム同期** - Obsidian UIとの双方向同期

#### LINE Bot MCP
LINE通知とメッセージング：
- **メッセージ送信** - テキスト、Flexメッセージ
- **ブロードキャスト** - 全フォロワーへの一斉送信
- **プロフィール取得** - ユーザー情報の取得
- **配信状況確認** - メッセージ配信枠の確認

#### Stripe MCP
決済システムの統合：
- **顧客管理** - 顧客の作成、更新、検索
- **支払い処理** - 請求書、サブスクリプション管理
- **製品管理** - 製品・価格の作成と管理
- **レポート** - 売上分析、決済履歴

#### Playwright MCP
ブラウザ自動操作とテスト：
- **ブラウザ操作** - ナビゲーション、クリック、入力
- **スクリーンショット** - ページ全体、要素単位の撮影
- **テスト生成** - 操作を記録してテストコード生成
- **ネットワーク監視** - リクエスト/レスポンスの監視

#### Context7 MCP
ライブラリドキュメントの検索：
- **最新ドキュメント取得** - npm/pip等のパッケージドキュメント
- **バージョン指定** - 特定バージョンのドキュメント取得
- **トピック検索** - 関数、クラス、概念の検索
- **コード例** - 実装例とベストプラクティス

#### Magic MCP
AI駆動UIコンポーネント生成：
- **自然言語でUIコンポーネント生成** - 「ログインボタンを作って」など
- **TypeScript対応** - 型安全なコンポーネント生成
- **リアルタイムプレビュー** - 生成したコンポーネントをすぐに確認
- **プロジェクト統合** - 既存のコードスタイルに合わせて生成

### API Key取得方法まとめ

| サービス  | 取得方法                | URL                                  |
| --------- | ----------------------- | ------------------------------------ |
| GitHub    | Personal Access Tokens  | https://github.com/settings/tokens   |
| Supabase  | Project Settings > API  | https://supabase.com/dashboard       |
| Stripe    | Dashboard > API Keys    | https://dashboard.stripe.com/apikeys |
| LINE      | LINE Developers Console | https://developers.line.biz/         |
| Obsidian  | Local REST API plugin   | Obsidian内で設定                     |
| Magic MCP | 21st.dev Console        | https://21st.dev/magic/console       |

## 🐛 トラブルシューティング

### メモリ不足

```bash
# Docker Desktopでメモリを増やす
# Mac: Preferences → Resources → Memory
# Windows: Settings → Resources → Memory

# または段階的起動を使用
master --phased
```

### コンテナが起動しない

```bash
# ログを確認
docker compose logs

# 再ビルド
docker compose down
docker compose up -d --build
```

### Claude CLIエラー

```bash
# API Keyを確認
echo $ANTHROPIC_API_KEY

# MCPサーバーをリセット
setup-mcp
```

## 🤝 コントリビューション

1. このリポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📄 ライセンス

MIT License - 詳細は[LICENSE](LICENSE)ファイルを参照

## 🙏 謝辞

- [Anthropic](https://anthropic.com) - Claude AI
- [Model Context Protocol](https://github.com/anthropics/mcp) - MCP仕様
- すべてのコントリビューター

---

<p align="center">
  Made with ❤️ by the Claude Code Community
</p>

<p align="center">
  <a href="https://github.com/yourusername/docker-claude-code-boilerplate/issues">Issues</a> •
  <a href="https://github.com/yourusername/docker-claude-code-boilerplate/discussions">Discussions</a> •
  <a href="https://claude.ai">Claude AI</a>
</p>