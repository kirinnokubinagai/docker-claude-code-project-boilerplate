#!/bin/bash

# Master Claude - 親Claude Codeが子プロセスを動的に管理するシステム
# tmuxを使った対話的なオーケストレーション

set -e

# 設定
SESSION_NAME="master"
WORKSPACE="/workspace"
WORKTREES_DIR="$WORKSPACE/worktrees"

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# メイン処理
main() {
    echo -e "${PURPLE}╔════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║       Master Claude System v2.0        ║${NC}"
    echo -e "${PURPLE}║  親が子を動的に作成・管理するシステム  ║${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    # 既存セッションをクリーンアップ
    tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true
    
    # マスターセッションを作成
    tmux new-session -d -s "$SESSION_NAME" -n "Master" -c "$WORKSPACE"
    
    # マスター用のヘルパー関数を作成
    create_master_helpers
    
    # Claude Codeを起動してマスターとして初期化
    tmux send-keys -t "$SESSION_NAME:Master" "claude --dangerously-skip-permissions" Enter
    sleep 3
    
    # マスターに指示を送信
    initialize_master
    
    # セッションにアタッチ
    echo -e "${GREEN}✓ Master Claude準備完了！${NC}"
    echo ""
    echo "セッションにアタッチします..."
    sleep 1
    
    tmux attach-session -t "$SESSION_NAME"
}

# マスター用ヘルパー関数を作成
create_master_helpers() {
    cat > "$WORKSPACE/master-commands.md" << 'COMMANDS'
# Master Claude Commands

## 🎯 基本的な使い方

私（親Claude）が子プロセスを動的に作成・管理します。以下のコマンドを使ってください：

### 1. 子プロセス作成
```bash
# 新しい子プロセスを作成
tmux new-window -t master -n "Worker-frontend" "cd /workspace && claude --dangerously-skip-permissions"

# worktree付きで作成
git worktree add /workspace/worktrees/frontend -b feature/frontend
tmux new-window -t master -n "Worker-frontend" "cd /workspace/worktrees/frontend && claude --dangerously-skip-permissions"
```

### 2. 子プロセスとの通信
```bash
# 子プロセスにタスクを送信
tmux send-keys -t "master:Worker-frontend" "ログイン画面を作成してください。完了したら報告してください。" Enter

# 子プロセスから親への報告
tmux send-keys -t "master:Master" "[Frontend] タスク完了: ログイン画面作成" Enter
```

### 3. 管理コマンド
```bash
# 全ウィンドウ確認
tmux list-windows -t master

# 子プロセスの出力確認
tmux capture-pane -t "master:Worker-frontend" -p | tail -20

# ウィンドウ切り替え
tmux select-window -t "master:Worker-frontend"

# 子プロセス終了
tmux kill-window -t "master:Worker-frontend"
```

### 4. 便利な一括操作
```bash
# 全子プロセスに一斉送信
for w in $(tmux list-windows -t master -F "#{window_name}" | grep "Worker-"); do
    tmux send-keys -t "master:$w" "進捗を報告してください" Enter
done

# 全子プロセスの状態確認
for w in $(tmux list-windows -t master -F "#{window_name}" | grep "Worker-"); do
    echo "=== $w ==="
    tmux capture-pane -t "master:$w" -p | tail -5
done
```

## 📋 実践例

### ECサイト開発の例
```bash
# 1. Gitリポジトリ初期化
git init
git add README.md
git commit -m "Initial commit"

# 2. Frontend担当を作成
git worktree add /workspace/worktrees/frontend -b feature/frontend
tmux new-window -t master -n "Worker-frontend" "cd /workspace/worktrees/frontend && claude --dangerously-skip-permissions"
sleep 3
tmux send-keys -t "master:Worker-frontend" "あなたはFrontend担当です。Next.js 15でECサイトのフロントエンドを作成してください。" Enter

# 3. Backend担当を作成
git worktree add /workspace/worktrees/backend -b feature/backend
tmux new-window -t master -n "Worker-backend" "cd /workspace/worktrees/backend && claude --dangerously-skip-permissions"
sleep 3
tmux send-keys -t "master:Worker-backend" "あなたはBackend担当です。Supabaseを使ってAPIを作成してください。" Enter

# 4. 進捗確認
tmux capture-pane -t "master:Worker-frontend" -p | tail -10
tmux capture-pane -t "master:Worker-backend" -p | tail -10
```

## 🔧 MCPサーバー活用

各子プロセスで異なるMCPサーバーを使う場合：

```bash
# Playwright専門の子プロセス
tmux send-keys -t "master:Worker-test" "Playwrightを使ってE2Eテストを作成してください" Enter

# Supabase専門の子プロセス
tmux send-keys -t "master:Worker-db" "Supabaseでデータベース設計をしてください" Enter
```

## 💡 Tips

1. **動的な子プロセス管理**: 必要に応じて子プロセスを作成・削除
2. **worktree活用**: 各子プロセスが独立したブランチで作業
3. **非同期実行**: 複数の子プロセスが並列で作業
4. **柔軟な通信**: 親子間、子同士での通信も可能

## ⌨️ ショートカット

- `Ctrl-b c`: 新しいウィンドウ作成
- `Ctrl-b n/p`: 次/前のウィンドウ
- `Ctrl-b 数字`: 特定のウィンドウへ
- `Ctrl-b w`: ウィンドウ一覧
- `Ctrl-b &`: 現在のウィンドウを閉じる
COMMANDS

    chmod +x "$WORKSPACE/master-commands.md"
}

# マスターを初期化
initialize_master() {
    # 初期メッセージ
    tmux send-keys -t "$SESSION_NAME:Master" "# 🎯 Master Claude System v2.0" Enter
    tmux send-keys -t "$SESSION_NAME:Master" "" Enter
    tmux send-keys -t "$SESSION_NAME:Master" "私は親プロセス（Master）として、子プロセスを動的に作成・管理します。" Enter
    tmux send-keys -t "$SESSION_NAME:Master" "" Enter
    tmux send-keys -t "$SESSION_NAME:Master" "## 使い方" Enter
    tmux send-keys -t "$SESSION_NAME:Master" "1. まず要件を教えてください" Enter
    tmux send-keys -t "$SESSION_NAME:Master" "2. 必要に応じて子プロセスを作成します" Enter
    tmux send-keys -t "$SESSION_NAME:Master" "3. 各子プロセスにタスクを割り当てます" Enter
    tmux send-keys -t "$SESSION_NAME:Master" "4. 進捗を管理し、統合します" Enter
    tmux send-keys -t "$SESSION_NAME:Master" "" Enter
    tmux send-keys -t "$SESSION_NAME:Master" "詳細なコマンドは /workspace/master-commands.md を参照してください。" Enter
    tmux send-keys -t "$SESSION_NAME:Master" "" Enter
    tmux send-keys -t "$SESSION_NAME:Master" "準備ができました。プロジェクトの要件を教えてください。" Enter
}

# tmux設定を最適化
setup_tmux_config() {
    cat > "$HOME/.tmux.conf" << 'TMUX_CONFIG'
# マウスサポート
set -g mouse on

# ウィンドウ番号を1から開始
set -g base-index 1
setw -g pane-base-index 1

# ステータスバーをカスタマイズ
set -g status-bg colour235
set -g status-fg colour136
set -g status-left '#[fg=colour226]Master Claude '
set -g status-right '#[fg=colour226]%H:%M:%S'
set -g status-interval 1

# アクティブウィンドウを強調
setw -g window-status-current-style fg=colour226,bg=colour238,bold

# ペイン境界線
set -g pane-border-style fg=colour238
set -g pane-active-border-style fg=colour226

# コピーモード
setw -g mode-keys vi
TMUX_CONFIG
}

# 実行前チェック
if ! command -v tmux >/dev/null 2>&1; then
    echo -e "${RED}エラー: tmuxがインストールされていません${NC}"
    exit 1
fi

if ! command -v claude >/dev/null 2>&1; then
    echo -e "${RED}エラー: Claude Codeがインストールされていません${NC}"
    exit 1
fi

# tmux設定
setup_tmux_config

# メイン実行
main "$@"