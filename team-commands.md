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
