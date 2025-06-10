# Master Claude System - 動的親子プロセス管理

このファイルはClaude Codeが自動的に参照し、親プロセスとして子プロセスを動的に作成・管理する方法を定義します。

## 🎯 システム概要

**Master Claude System v2.0**は、親Claude（あなた）が要件に応じて子プロセスを動的に作成し、対話的に管理するシステムです。

### 特徴
- **動的作成**: 必要な時に必要なだけ子プロセスを作成
- **対話的管理**: 親子間でリアルタイムに通信
- **独立作業**: 各子プロセスがworktreeで独立して作業
- **MCP統合**: 各子プロセスが専門のMCPサーバーを活用

## 🚀 起動時の動作

Docker環境が起動したら、以下の手順で動作してください：

### 1. 初回起動時
```bash
# Master Claudeシステムを起動
/workspace/master-claude.sh
```

これにより：
- tmuxセッション「master」が作成されます
- あなたは「Master」ウィンドウで親プロセスとして起動します
- `/workspace/master-commands.md`にコマンドリファレンスが作成されます

### 2. 要件分析フェーズ

ユーザーから要件を受け取ったら：

1. **要件を分析**
   - 必要な機能を特定
   - 必要な子プロセスの数と役割を決定
   - 使用するMCPサーバーを選定

2. **プロジェクト初期化**
   ```bash
   git init
   echo "# プロジェクト名" > README.md
   git add README.md
   git commit -m "Initial commit"
   ```

### 3. 子プロセスの動的作成

要件に基づいて必要な子プロセスを作成：

```bash
# Frontend担当を作成
git worktree add /workspace/worktrees/frontend -b feature/frontend
tmux new-window -t master -n "Worker-frontend" "cd /workspace/worktrees/frontend && claude --dangerously-skip-permissions"
sleep 3
tmux send-keys -t "master:Worker-frontend" "あなたはFrontend担当です。以下のタスクを実行してください：[具体的なタスク]" Enter

# Backend担当を作成
git worktree add /workspace/worktrees/backend -b feature/backend
tmux new-window -t master -n "Worker-backend" "cd /workspace/worktrees/backend && claude --dangerously-skip-permissions"
sleep 3
tmux send-keys -t "master:Worker-backend" "あなたはBackend担当です。以下のタスクを実行してください：[具体的なタスク]" Enter
```

### 4. タスク管理と通信

#### 子プロセスへの指示
```bash
tmux send-keys -t "master:Worker-frontend" "Next.js 15でログイン画面を作成してください。use context7で最新情報を確認。" Enter
```

#### 進捗確認
```bash
# 特定の子プロセスの出力確認
tmux capture-pane -t "master:Worker-frontend" -p | tail -20

# 全子プロセスの状態確認
for w in $(tmux list-windows -t master -F "#{window_name}" | grep "Worker-"); do
    echo "=== $w ==="
    tmux capture-pane -t "master:$w" -p | tail -5
done
```

#### 子プロセスからの報告を促す
```bash
tmux send-keys -t "master:Worker-frontend" "完了したら以下のコマンドで報告してください：" Enter
tmux send-keys -t "master:Worker-frontend" "tmux send-keys -t 'master:Master' '[Frontend] 完了: ログイン画面作成' Enter" Enter
```

## 📋 実践的なワークフロー

```bash
# 1. 要件受領後、プロジェクト初期化
git init && git add . && git commit -m "Initial commit"

# 2. 必要な子プロセスを順次作成
# Frontend (UI/UX)
git worktree add /workspace/worktrees/frontend -b feature/frontend
tmux new-window -t master -n "Worker-frontend" "cd /workspace/worktrees/frontend && claude --dangerously-skip-permissions"
sleep 3
tmux send-keys -t "master:Worker-frontend" "Frontend担当：Next.js 15でECサイトのUI実装。MCP: Playwright, Context7, Stripe" Enter

# Backend (API)
git worktree add /workspace/worktrees/backend -b feature/backend
tmux new-window -t master -n "Worker-backend" "cd /workspace/worktrees/backend && claude --dangerously-skip-permissions"
sleep 3
tmux send-keys -t "master:Worker-backend" "Backend担当：Supabase APIとStripe決済実装。MCP: Supabase, Stripe, LINE Bot" Enter

# Database (設計)
git worktree add /workspace/worktrees/database -b feature/database
tmux new-window -t master -n "Worker-database" "cd /workspace/worktrees/database && claude --dangerously-skip-permissions"
sleep 3
tmux send-keys -t "master:Worker-database" "Database担当：商品・ユーザー・注文テーブル設計。MCP: Supabase, Obsidian" Enter

# 3. 並行作業の管理
# 定期的に進捗確認
for w in Worker-frontend Worker-backend Worker-database; do
    echo "確認: $w"
    tmux capture-pane -t "master:$w" -p | tail -10
done

# 4. 統合とテスト
# QA担当を追加
tmux new-window -t master -n "Worker-qa" "cd /workspace && claude --dangerously-skip-permissions"
tmux send-keys -t "master:Worker-qa" "QA担当：全機能のE2Eテスト作成。MCP: Playwright, Context7" Enter
```

## 🔧 MCPサーバー活用戦略

各子プロセスに特化したMCPサーバーを割り当て：

| 子プロセス | 主要MCP                        | 用途                               |
| ---------- | ------------------------------ | ---------------------------------- |
| Frontend   | Playwright, Context7, Obsidian | UI開発、最新技術調査、ドキュメント |
| Backend    | Supabase, Stripe, LINE Bot     | API、決済、通知                    |
| Database   | Supabase, Obsidian             | DB設計、ドキュメント               |
| DevOps     | Supabase, Playwright, LINE Bot | 環境構築、CI/CD、通知              |
| QA         | Playwright, Context7, Obsidian | テスト自動化、最新手法、レポート   |

## 💡 ベストプラクティス

### 1. 段階的な子プロセス作成
- 最初から全部作らない
- 必要に応じて追加
- 完了したら終了

### 2. 明確なタスク定義
```bash
tmux send-keys -t "master:Worker-frontend" "タスク: ログイン画面作成" Enter
tmux send-keys -t "master:Worker-frontend" "要件: メールとパスワード、ソーシャルログイン対応" Enter
tmux send-keys -t "master:Worker-frontend" "技術: Next.js 15 App Router, Supabase Auth" Enter
tmux send-keys -t "master:Worker-frontend" "完了条件: Playwrightテスト付き" Enter
```

### 3. 定期的な統合
```bash
# 各worktreeの変更を確認
for dir in /workspace/worktrees/*; do
    echo "=== $(basename $dir) ==="
    cd $dir && git status
done

# メインブランチに統合
cd /workspace
git merge feature/frontend
git merge feature/backend
```

### 4. 動的なリソース管理
```bash
# 不要になった子プロセスは終了
tmux kill-window -t "master:Worker-frontend"

# worktreeもクリーンアップ
git worktree remove /workspace/worktrees/frontend
```

## 🚨 トラブルシューティング

### 子プロセスが応答しない
```bash
# プロセスの状態確認
tmux list-windows -t master

# 強制終了して再作成
tmux kill-window -t "master:Worker-frontend"
# 再度作成...
```

### worktreeエラー
```bash
# worktree一覧確認
git worktree list

# 壊れたworktreeを修復
git worktree prune
```

## 📊 モニタリングコマンド

```bash
# リアルタイムモニタリング（親プロセスで実行）
watch -n 2 'for w in $(tmux list-windows -t master -F "#{window_name}" | grep "Worker-"); do echo "=== $w ==="; tmux capture-pane -t "master:$w" -p | tail -3; echo; done'

# 全体の進捗レポート生成
for w in $(tmux list-windows -t master -F "#{window_name}" | grep "Worker-"); do
    echo "## $w"
    echo '```'
    tmux capture-pane -t "master:$w" -p | grep -E "(完了|エラー|進行中)" | tail -5
    echo '```'
    echo
done > progress-report.md
```

## 🎯 重要な原則

1. **親は指揮者**: 全体を把握し、適切に指示を出す
2. **子は専門家**: 与えられたタスクに集中
3. **動的管理**: 必要な時に作成、不要になったら削除
4. **非同期実行**: 子プロセスは並列で独立して作業
5. **定期的な統合**: 各子の成果を適切にマージ

この動的システムにより、プロジェクトの規模や複雑さに応じて柔軟に対応できます。