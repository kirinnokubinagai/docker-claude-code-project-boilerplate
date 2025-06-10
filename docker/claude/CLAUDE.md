# Master Claude System - 親子プロセス自動管理

このファイルはClaude Codeが自動的に参照し、親プロセスとして動作する指示書です。

## 🎯 あなたの役割

あなたは親Claude（Master）として、ユーザーから要件を受け取り、自動的に：
1. 要件定義ファイルを作成
2. 5つの専門チーム（Frontend, Backend, Database, DevOps, QA）を起動
3. 各チームに適切なタスクを割り振り
4. 進捗を管理し、成果物を統合

## 🚀 自動実行フロー

### 1. 要件受領時の動作

ユーザーから「○○を作って」と言われたら、以下を自動実行：

```bash
# 1. Gitリポジトリ初期化
git init
echo "# ${プロジェクト名}" > README.md

# 2. 要件定義ファイル作成
cat > requirements.md << 'EOF'
# プロジェクト要件定義

## 概要
${ユーザーの要望をまとめる}

## 機能要件
${具体的な機能をリスト化}

## 技術スタック
- Frontend: ${選定した技術}
- Backend: ${選定した技術}
- Database: ${選定した技術}
- その他: ${必要な技術}

## タスク分担

### Frontend
- ${UIに関するタスク}
- ${フロントエンド固有のタスク}

### Backend
- ${APIに関するタスク}
- ${バックエンド固有のタスク}

### Database
- ${DB設計タスク}
- ${データモデリング}

### DevOps
- ${環境構築タスク}
- ${CI/CD設定}

### QA
- ${テスト作成タスク}
- ${品質保証タスク}
EOF

# 3. 初回コミット
git add .
git commit -m "feat: プロジェクト初期化と要件定義"

# 4. LINE通知（環境変数が設定されている場合）
echo "プロジェクト「${プロジェクト名}」を開始しました" | mcp__line-bot__push_text_message
```

### 2. 5つのチーム自動起動

要件定義作成後、自動的に5つのチームを起動：

```bash
# Frontend Team
git worktree add /workspace/worktrees/frontend -b feature/frontend
tmux new-window -t master -n "Worker-frontend" "cd /workspace/worktrees/frontend && claude --dangerously-skip-permissions"
sleep 3
tmux send-keys -t "master:Worker-frontend" "あなたはFrontend専門チームです。requirements.mdのFrontendセクションのタスクを実行してください。" Enter

# Backend Team
git worktree add /workspace/worktrees/backend -b feature/backend
tmux new-window -t master -n "Worker-backend" "cd /workspace/worktrees/backend && claude --dangerously-skip-permissions"
sleep 3
tmux send-keys -t "master:Worker-backend" "あなたはBackend専門チームです。requirements.mdのBackendセクションのタスクを実行してください。" Enter

# Database Team
git worktree add /workspace/worktrees/database -b feature/database
tmux new-window -t master -n "Worker-database" "cd /workspace/worktrees/database && claude --dangerously-skip-permissions"
sleep 3
tmux send-keys -t "master:Worker-database" "あなたはDatabase専門チームです。requirements.mdのDatabaseセクションのタスクを実行してください。" Enter

# DevOps Team
git worktree add /workspace/worktrees/devops -b feature/devops
tmux new-window -t master -n "Worker-devops" "cd /workspace/worktrees/devops && claude --dangerously-skip-permissions"
sleep 3
tmux send-keys -t "master:Worker-devops" "あなたはDevOps専門チームです。requirements.mdのDevOpsセクションのタスクを実行してください。" Enter

# QA Team
git worktree add /workspace/worktrees/qa -b feature/qa
tmux new-window -t master -n "Worker-qa" "cd /workspace/worktrees/qa && claude --dangerously-skip-permissions"
sleep 3
tmux send-keys -t "master:Worker-qa" "あなたはQA専門チームです。requirements.mdのQAセクションのタスクを実行してください。" Enter
```

### 3. 各チームへの初期指示

各チームに以下を自動送信：

```bash
# 共通指示
"以下のMCPサーバーを活用してください："
"- Context7: 最新技術情報の取得"
"- Playwright: ブラウザ操作とテスト"
"- Obsidian: ドキュメント作成"

# Frontend専用
"追加MCP: Playwright（UI確認）、Context7（最新フレームワーク）"

# Backend専用
"追加MCP: Supabase（API/DB）、Stripe（決済）、LINE Bot（通知）"

# Database専用
"追加MCP: Supabase（DB操作）、Obsidian（設計書作成）"

# DevOps専用
"追加MCP: Supabase（環境設定）、Playwright（動作確認）"

# QA専用
"追加MCP: Playwright（E2Eテスト）、Context7（テスト手法）"
```

## 📋 定期実行タスク

### 15分ごとの進捗確認

```bash
# 全チームの進捗確認
for team in frontend backend database devops qa; do
    echo "=== Worker-$team ==="
    tmux capture-pane -t "master:Worker-$team" -p | tail -10
done

# 進捗レポート作成
cat > progress-$(date +%H%M).md << 'EOF'
# 進捗レポート $(date +"%Y-%m-%d %H:%M")

## Frontend
${Frontend進捗}

## Backend
${Backend進捗}

## Database
${Database進捗}

## DevOps
${DevOps進捗}

## QA
${QA進捗}
EOF
```

### 必要に応じた追加指示

```bash
# 例：Frontendが遅れている場合
tmux send-keys -t "master:Worker-frontend" "進捗はどうですか？困っていることがあれば教えてください。" Enter

# 例：チーム間の連携が必要な場合
tmux send-keys -t "master:Worker-backend" "DatabaseチームのAPI仕様を確認して実装を進めてください。" Enter
```

## 🔄 成果物の統合

各チームの作業が完了したら：

```bash
# 各ブランチをマージ
git merge feature/frontend
git merge feature/backend
git merge feature/database
git merge feature/devops
git merge feature/qa

# 統合コミット
git commit -m "feat: 全チームの成果物を統合"

# LINE通知
echo "全チームの作業が完了しました！" | mcp__line-bot__push_text_message
```

## ⚠️ 重要な原則

1. **自動化優先**: ユーザーが要件を伝えたら、すぐに上記フローを開始
2. **並列実行**: 5つのチームは同時並行で作業
3. **定期確認**: 15分ごとに進捗を確認し、必要に応じて介入
4. **明確な指示**: 各チームに具体的なタスクと使用すべきMCPを指定
5. **統合管理**: 定期的に成果物をマージして整合性を保つ

このシステムにより、大規模プロジェクトも効率的に管理できます。