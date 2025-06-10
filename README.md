# Master Claude Teams System

🎯 **最新技術** × 🧠 **5つの天才AI** × 🤝 **チーム間自動コラボ** × 📚 **自動ドキュメント化**

## 🌟 システムの特徴

- **5つのClaude Codeが並列作業** - フロントエンド、バックエンド、DB、DevOps、Master
- **チーム間リアルタイム通信** - 困った時に自動で相談しながら作業継続
- **自動ドキュメント化** - Obsidian + Playwright でスクリーンショット付きマニュアル自動生成
- **非同期タスク処理** - 作業を止めずに並列でコラボレーション

## 🚀 使い方（3ステップ）

### 1. セットアップ
```bash
git clone [repository-url] master-claude
cd master-claude
./init-project.sh my-project
cd my-project

# .env設定（必須）
ANTHROPIC_API_KEY=your_key

# オプション（追加MCP用）
GITHUB_TOKEN=your_github_token
POSTGRES_CONNECTION_STRING=your_pg_url
SLACK_BOT_TOKEN=your_slack_token
```

### 2. 起動
```bash
# 基本起動（5チーム並列）
./master-claude-teams.sh

# または別の起動方法
docker-compose up -d
docker-compose exec claude-code fish
./master-claude-teams.sh
```

### 3. 要件を伝える
```
ECサイトを作って
```

これだけ！あとは5チームが自動で協調しながら開発します。

## 🤖 自動実行される内容

### 開発フロー
1. **Master が要件定義** → 各チームにタスク分散
2. **5チーム並列開発** → 独立して作業開始
3. **自動チーム間通信** → 困った時に相談、作業は継続
4. **リアルタイム進捗記録** → Obsidianに自動記録
5. **実装完了時の自動化**:
   - Playwrightで画面キャプチャ
   - スクリーンショット付きドキュメント生成
   - Obsidianにマニュアル自動保存
6. **品質管理** → 15分ごとにチェック＆調整
7. **最終統合** → 全チームの成果物を統合

### チーム間通信の例
```bash
# Frontend → Backend: API仕様確認
send_team_message "frontend" "backend" "REQUEST" "認証APIの仕様を教えて"

# Backend → Database: パフォーマンス相談
send_team_message "backend" "database" "HELP" "クエリ最適化をお願いします"

# DevOps → 全体: デプロイ通知
broadcast_to_teams "devops" "NOTIFY" "本番デプロイを開始します"
```

## 🏢 5つの専門チーム

| チーム   | 専門分野       | 主要MCP                                    | チーム間通信機能     |
| -------- | -------------- | ------------------------------------------ | -------------------- |
| Master   | 全体設計・調整 | 全MCP統括、要件定義                        | 全チーム統括         |
| Frontend | UI/UX実装      | Context7, Obsidian, Playwright, LINE Bot  | ↔️ Backend, Database |
| Backend  | API開発        | Supabase, Obsidian, Postgres, LINE Bot    | ↔️ Frontend, Database |
| Database | DB設計         | Supabase, Obsidian, Postgres, LINE Bot    | ↔️ Backend, DevOps   |
| DevOps   | インフラ       | Playwright, Obsidian, LINE Bot, Sentry    | ↔️ 全チーム通知      |

## 📚 自動ドキュメント化機能

### 開発中の自動記録
- **進捗の自動記録**: 各チームの作業がリアルタイムでObsidianに記録
- **実装詳細の記録**: 重要な実装内容を自動でドキュメント化
- **チーム間通信ログ**: 相談内容と解決過程を記録

### 完成後の自動マニュアル生成
- **スクリーンショット自動撮影**: Playwrightで全画面キャプチャ
- **ビジュアルマニュアル**: 画像付きの使い方ガイド自動生成
- **技術ドキュメント**: API仕様書、DB設計書を自動作成
- **プロジェクト総括**: 成果物と技術的ハイライトをまとめ

### Obsidian構造
```
Projects/[プロジェクト名]/
├── README.md          # プロジェクト概要
├── docs/              # 実装ドキュメント
│   ├── 機能名_実装.md
│   └── 機能名_ビジュアルガイド.md
├── progress/          # 日次進捗
│   ├── 20241211_開発進捗.md
│   └── 20241211_チーム活動ログ.md
├── manual/            # ユーザーマニュアル
│   └── プロジェクト名_完全マニュアル.md
└── screenshots/       # 自動撮影画像
    ├── login_screen.png
    └── dashboard.png
```

## 💎 開発品質基準

全チーム共通のルール：
- 📝 **JSDoc必須** - 全関数に詳細ドキュメント
- 🚀 **早期リターン** - else/elseif禁止
- 🔄 **関数分割** - コメント不要な明確な設計
- 🌏 **日本人向け** - 分かりやすい実装
- ⚡ **最新技術** - 常に最新版を使用
- 🤝 **チーム協調** - 困った時は他チームに相談
- 📸 **ビジュアル記録** - 実装完了時にスクリーンショット撮影

## 📊 納品物の特徴

- ✅ **最新技術スタック** - 常に最先端
- ✅ **チーム協調開発** - 5チームの専門知識を融合
- ✅ **SEO完璧対応** - 検索上位＆AI検索対応
- ✅ **日本市場最適化** - 文化に合わせた設計
- ✅ **完全テスト済** - バグゼロ保証
- ✅ **セキュリティ万全** - OWASP Top 10対策
- ✅ **アクセシビリティ** - WCAG 2.1 AA準拠
- ✅ **ドキュメント完備** - スクリーンショット付きマニュアル
- ✅ **自動監視体制** - エラー追跡＆性能監視
- ✅ **開発プロセス記録** - 全作業がObsidianに自動記録

## 💡 便利コマンド

### システム管理
```bash
./master-claude-teams.sh        # 5チーム並列システム起動
check_mcp                       # MCP接続確認
```

### tmux操作
```bash
Ctrl-b q                        # ペイン番号表示
Ctrl-b 0-4                      # チーム切替（0:Master, 1:Frontend...）
tmux capture-pane -t "claude-teams:Teams.1" -p  # Frontend出力確認
```

### チーム間通信
```bash
# 個別チームへメッセージ送信
send_team_message "frontend" "backend" "REQUEST" "API仕様確認"

# 全チームへ通知
broadcast_to_teams "master" "NOTIFY" "要件変更のお知らせ"

# メッセージ確認
check_team_messages "frontend"
```

### ドキュメント生成
```bash
# 進捗記録
record_implementation_progress "frontend" "ログイン画面" "completed" "認証機能実装完了"

# スクリーンショット付きドキュメント
document_feature_with_screenshots "frontend" "ログイン画面" "http://localhost:3000/login" "ユーザー認証機能"

# 包括的マニュアル生成
generate_comprehensive_manual "ECサイト"
```

## 🛠️ システム要件

### 必須
- **Claude Code CLI** - 最新版
- **tmux** - セッション管理
- **Git** - バージョン管理
- **Node.js 20+** - 開発環境

### MCP要件
- **Obsidian MCP** - ドキュメント自動生成
- **Playwright MCP** - スクリーンショット撮影
- **Context7 MCP** - 最新技術情報
- **Supabase MCP** - データベース管理
- **LINE Bot MCP** - 通知機能

### オプション
- **GitHub MCP** - リポジトリ管理
- **Sentry MCP** - エラー監視

---

**要件を伝えるだけで、5つのAIチームが協調して最高品質のプロダクトを自動開発。全プロセスが自動でドキュメント化される革新的な開発システムです。**