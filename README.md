# Master Claude System

親Claudeが5つの子Claude（Frontend/Backend/Database/DevOps/QA）を自動管理するシステム

## 🚀 使い方

### 1. セットアップ
```bash
# プロジェクト作成
git clone [repository-url] master-claude
cd master-claude
./init-project.sh my-project
cd my-project

# 環境変数設定（.env）
ANTHROPIC_API_KEY=your_key
# オプション（必要なものだけ）
LINE_CHANNEL_ACCESS_TOKEN=xxx
SUPABASE_ACCESS_TOKEN=xxx
STRIPE_SECRET_KEY=xxx
```

### 2. 起動
```bash
docker-compose up -d
docker-compose exec claude-code fish
master  # 親Claude起動（初回はMCP自動設定）
```

### 3. 開発開始
親Claudeに要件を伝えるだけ：
```
ECサイトを作って
```

## 🤖 自動で行われること

1. **要件定義作成** → `requirements.md`に整理
2. **5つのチーム起動** → Frontend/Backend/Database/DevOps/QA
3. **タスク自動配分** → 各チームが並列作業
4. **進捗管理** → 15分ごとに確認・調整
5. **成果物統合** → 完成したらマージ

## 📁 構成

```
my-project/
├── requirements.md         # 自動生成される要件定義
├── worktrees/             # 各チームの作業場所
│   ├── frontend/          # UI/UX担当
│   ├── backend/           # API担当
│   ├── database/          # DB設計担当
│   ├── devops/            # 環境構築担当
│   └── qa/                # テスト担当
└── docker/claude/CLAUDE.md # 親Claudeの動作定義
```

## 💡 コマンド

```bash
# MCP確認
check_mcp

# tmuxウィンドウ操作
Ctrl-b 1-6  # Master, Frontend, Backend, Database, DevOps, QA
Ctrl-b w    # ウィンドウ一覧

# 進捗確認（親Claudeが自動実行）
tmux capture-pane -t "master:Worker-frontend" -p | tail -20
```

## 🔧 MCPサーバー

初回起動時に自動設定：
- **Supabase** - DB/認証/Edge Functions
- **Playwright** - ブラウザ自動化/E2Eテスト
- **Obsidian** - ドキュメント管理
- **Stripe** - 決済処理
- **LINE Bot** - 通知
- **Context7** - 最新技術情報

## ⚠️ トラブルシューティング

```bash
# MCP再設定
rm ~/.mcp_setup_done && master

# tmux再接続
tmux attach -t master

# 手動MCP追加例
claude mcp add -s user line-bot \
  -e CHANNEL_ACCESS_TOKEN="$LINE_CHANNEL_ACCESS_TOKEN" \
  -e DESTINATION_USER_ID="$DESTINATION_USER_ID" \
  -- npx @line/line-bot-mcp-server
```

以上！要件を伝えれば、親Claudeが全て自動で進めます。