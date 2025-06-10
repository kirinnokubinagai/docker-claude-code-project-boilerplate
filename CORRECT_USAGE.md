# Master Claude System - 正しい使用手順

## 📋 完全な手順ガイド

### 1. プロジェクト作成

```bash
# リポジトリをクローン
git clone [repository-url] claude-master-system
cd claude-master-system

# 新しいプロジェクトを初期化
./init-project.sh myproject
cd myproject

# API Keyを設定（必須）
echo "ANTHROPIC_API_KEY=your_api_key_here" >> .env
```

### 2. Docker環境起動

```bash
# Dockerコンテナを起動
docker-compose up -d

# コンテナ内に入る
docker-compose exec claude-code fish
```

### 3. Master Claude起動（初回）

```bash
# コンテナ内で実行
master
```

初回起動時の動作：
1. 環境変数に基づいてMCPサーバーが自動的に追加される
   - 例: `claude mcp add -s user line-bot -e CHANNEL_ACCESS_TOKEN="xxx" -e DESTINATION_USER_ID="xxx" -- npx @line/line-bot-mcp-server`
2. tmuxセッション「master」が作成される
3. 親Claude Codeが「Master」ウィンドウで起動する

### 4. 要件を伝える

親Claudeウィンドウで要件を入力：
```
ECサイトを作成してください。以下の機能を含む：
- ユーザー認証（メール/パスワード、ソーシャルログイン）
- 商品カタログ（検索、フィルタリング付き）
- ショッピングカート
- Stripe決済
- 管理画面
```

### 5. 親Claudeが子プロセスを作成

親Claude（あなた）が以下のようなコマンドを実行：

```bash
# Gitリポジトリ初期化
git init
echo "# ECサイト" > README.md
git add . && git commit -m "Initial commit"

# Frontend担当を作成
git worktree add /workspace/worktrees/frontend -b feature/frontend
tmux new-window -t master -n "Worker-frontend" "cd /workspace/worktrees/frontend && claude --dangerously-skip-permissions"
sleep 3
tmux send-keys -t "master:Worker-frontend" "あなたはFrontend担当です。Next.js 15でECサイトのUIを実装してください。商品一覧、カート、決済画面を作成。" Enter

# Backend担当を作成
git worktree add /workspace/worktrees/backend -b feature/backend
tmux new-window -t master -n "Worker-backend" "cd /workspace/worktrees/backend && claude --dangerously-skip-permissions"
sleep 3
tmux send-keys -t "master:Worker-backend" "あなたはBackend担当です。Supabase認証、商品API、Stripe決済処理を実装してください。" Enter

# Database担当を作成
git worktree add /workspace/worktrees/database -b feature/database
tmux new-window -t master -n "Worker-database" "cd /workspace/worktrees/database && claude --dangerously-skip-permissions"
sleep 3
tmux send-keys -t "master:Worker-database" "あなたはDatabase担当です。ユーザー、商品、注文、カートのテーブル設計をしてください。" Enter
```

### 6. 開発管理コマンド

```bash
# ウィンドウ一覧確認
tmux list-windows -t master

# ウィンドウ切り替え（キーボードショートカット）
Ctrl-b 1  # Master
Ctrl-b 2  # Worker-frontend
Ctrl-b 3  # Worker-backend
Ctrl-b 4  # Worker-database

# 子プロセスの出力確認（親ウィンドウから）
tmux capture-pane -t "master:Worker-frontend" -p | tail -30

# 追加指示
tmux send-keys -t "master:Worker-frontend" "レスポンシブデザインにも対応してください" Enter

# 進捗確認（全子プロセス）
for w in $(tmux list-windows -t master -F "#{window_name}" | grep "Worker-"); do
    echo "=== $w ==="
    tmux capture-pane -t "master:$w" -p | tail -5
done
```

### 7. 成果物の統合

```bash
# worktree状態確認
git worktree list

# 各ブランチの変更確認
cd /workspace
git log --oneline --graph --all

# マージ
git merge feature/frontend
git merge feature/backend
git merge feature/database
```

### 8. 子プロセスの終了

```bash
# 不要になった子プロセスを終了
tmux kill-window -t "master:Worker-frontend"

# worktreeも削除
git worktree remove /workspace/worktrees/frontend
```

## ⚠️ 重要な注意点

### MCP関連

1. **Claude CodeのMCP**
   - `mcp add`コマンドで追加（自動化済み）
   - `mcp list`で確認
   - 各子プロセスも同じMCPサーバーを利用可能

2. **MCPサーバーが追加されない場合**
   ```bash
   # 手動で追加（環境変数を使う例）
   claude mcp add -s user line-bot -e CHANNEL_ACCESS_TOKEN="$LINE_CHANNEL_ACCESS_TOKEN" -e DESTINATION_USER_ID="$DESTINATION_USER_ID" -- npx @line/line-bot-mcp-server
   
   # または、再セットアップ
   setup_mcp_manual
   ```

### tmux操作

1. **基本キー操作**
   - `Ctrl-b c`: 新しいウィンドウ
   - `Ctrl-b n/p`: 次/前のウィンドウ
   - `Ctrl-b 数字`: 特定ウィンドウへ
   - `Ctrl-b w`: ウィンドウ一覧
   - `Ctrl-b d`: デタッチ（切断）

2. **セッション再接続**
   ```bash
   tmux attach -t master
   ```

### Git worktree

1. **ブランチ作成エラー**
   ```bash
   # ブランチが既に存在する場合
   git branch -D feature/frontend
   git worktree add /workspace/worktrees/frontend -b feature/frontend
   ```

2. **worktreeクリーンアップ**
   ```bash
   git worktree prune
   ```

## 💡 ベストプラクティス

1. **段階的開発**
   - 最初から全子プロセスを作らない
   - 必要に応じて追加

2. **明確な指示**
   - 各子プロセスに具体的なタスクを与える
   - 使用技術、MCPサーバーを明示

3. **定期的な統合**
   - こまめにマージして競合を避ける
   - 各子プロセスの成果を確認

4. **リソース管理**
   - 使わない子プロセスは終了
   - worktreeも適切に削除

## 🆘 トラブルシューティング

### MCPが使えない
```bash
# MCPサーバーの再追加
mcp add supabase
mcp list
```

### tmuxセッションが消えた
```bash
# 再作成
master
```

### 子プロセスが応答しない
```bash
# 強制終了して再作成
tmux kill-window -t "master:Worker-frontend"
```