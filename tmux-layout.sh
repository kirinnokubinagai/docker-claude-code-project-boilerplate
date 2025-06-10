#!/bin/bash

# tmuxセッション名
SESSION_NAME="claude-dev"

# 既存のセッションがあれば削除
tmux kill-session -t $SESSION_NAME 2>/dev/null

# 新しいセッションを作成（デタッチモードで）
tmux new-session -d -s $SESSION_NAME

# メインウィンドウのレイアウト設定
# 最初に垂直分割（左33%、右67%）
tmux split-window -h -p 67

# 右側のペインを選択
tmux select-pane -t 1

# 右側を水平分割（上下に分ける）
tmux split-window -v -p 50

# 右上のペインを選択
tmux select-pane -t 1

# 右上を垂直分割（左右に分ける）
tmux split-window -h -p 50

# 右下のペインを選択
tmux select-pane -t 3

# 右下を垂直分割（左右に分ける）
tmux split-window -h -p 50

# 各ペインにコマンドを送信（必要に応じて）
# 左側（親プロセス）
tmux select-pane -t 0
tmux send-keys -t $SESSION_NAME:0.0 "echo '親プロセス（メイン）'" C-m

# 右上左
tmux select-pane -t 1
tmux send-keys -t $SESSION_NAME:0.1 "echo 'サブプロセス1'" C-m

# 右上右
tmux select-pane -t 2
tmux send-keys -t $SESSION_NAME:0.2 "echo 'サブプロセス2'" C-m

# 右下左
tmux select-pane -t 3
tmux send-keys -t $SESSION_NAME:0.3 "echo 'サブプロセス3'" C-m

# 右下右
tmux select-pane -t 4
tmux send-keys -t $SESSION_NAME:0.4 "echo 'サブプロセス4'" C-m

# 最初のペインにフォーカス
tmux select-pane -t 0

# セッションにアタッチ
tmux attach-session -t $SESSION_NAME