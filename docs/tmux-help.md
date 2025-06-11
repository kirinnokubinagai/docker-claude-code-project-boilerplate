# tmux ヘルプガイド

## 🚀 基本操作

### セッション管理
```bash
# 新しいセッションを作成
tmux new -s session-name

# セッション一覧を表示
tmux ls

# 既存のセッションにアタッチ
tmux attach -t session-name
tmux a -t session-name    # 短縮形

# セッションから離脱（セッションは残る）
Ctrl+a → d

# セッションを終了
tmux kill-session -t session-name

# すべてのセッションを終了
tmux kill-server

# 現在のセッションを終了
exit  # または Ctrl+d
```

### ペイン操作
```bash
# ペインを分割
Ctrl+a → |    # 縦分割
Ctrl+a → -    # 横分割

# ペイン間の移動
Ctrl+a → 矢印キー
Ctrl+a → h/j/k/l    # Vim風

# ペインを閉じる
Ctrl+d  # または exit

# ペインを強制終了
Ctrl+a → x    # 確認付き

# ペインのサイズ変更
Ctrl+a → H/J/K/L    # 5文字ずつ調整

# ペインを最大化/元に戻す
Ctrl+a → z
```

### ウィンドウ操作
```bash
# 新しいウィンドウを作成
Ctrl+a → c

# ウィンドウ間の移動
Ctrl+a → 数字    # 特定のウィンドウへ
Ctrl+a → n       # 次のウィンドウ
Ctrl+a → p       # 前のウィンドウ

# ウィンドウを閉じる
Ctrl+d  # または exit

# ウィンドウ一覧
Ctrl+a → w
```

## 🔧 トラブルシューティング

### tmuxセッションが応答しない場合
```bash
# 別のターミナルから
tmux ls                           # セッション確認
tmux kill-session -t session-name # 特定のセッションを終了
tmux kill-server                  # すべて終了
```

### ペインがフリーズした場合
```bash
# 該当ペインで
Ctrl+a → x    # ペインを閉じる（確認付き）

# または別のペインから
Ctrl+a → :    # コマンドモード
kill-pane -t .1    # ペイン番号を指定して終了
```

### プロセスが残っている場合
```bash
# tmux外から
ps aux | grep tmux
kill -9 <PID>    # 強制終了
```

## 📋 コピー＆ペースト

### 方法1: Shiftキーを使用（推奨）
- **コピー**: Shift + マウスで選択 → Shift + Cmd+C (Mac) / Shift + Ctrl+C (Linux)
- **ペースト**: Shift + Cmd+V (Mac) / Shift + Ctrl+V (Linux)

### 方法2: tmuxコピーモード
```bash
# コピーモードに入る
Ctrl+a → [

# 移動
矢印キー または h/j/k/l

# 選択
Space → 移動 → y

# ペースト
Ctrl+a → ]
```

### 方法3: マウスモード一時無効化
```bash
# 現在のセッションのみ
Ctrl+a → :
set -g mouse off    # 無効化
set -g mouse on     # 有効化
```

## 🎯 Master Claude Teams 専用コマンド

### チーム切り替えショートカット
```bash
Ctrl+a → M    # Master Architect
Ctrl+a → F    # Frontend Team
Ctrl+a → B    # Backend Team
Ctrl+a → D    # Database Team
Ctrl+a → O    # DevOps Team
```

### ペイン番号確認
```bash
Ctrl+a → q    # 番号を表示（3秒間）
```

### 全ペインに同じコマンドを送る
```bash
Ctrl+a → S    # 同期モードのON/OFF切り替え
```

### セッション内の出力を保存
```bash
Ctrl+a → P    # ファイル名を指定して保存
```

## 🆘 緊急時の対処

### すべてをリセットしたい場合
```bash
# tmuxの外から実行
tmux kill-server
rm -rf /tmp/tmux-*
```

### 設定ファイルをリロード
```bash
Ctrl+a → r    # .tmux.confを再読み込み
```

### デタッチされたセッションの確認
```bash
tmux ls
# セッション名: ウィンドウ数 (作成日時) (attached/detached)
```

## 💡 便利なTips

### セッション名を変更
```bash
Ctrl+a → $
```

### ウィンドウ名を変更
```bash
Ctrl+a → ,
```

### ペインのレイアウトを自動調整
```bash
Ctrl+a → Space    # レイアウトを順番に切り替え
```

### 直前のウィンドウに戻る
```bash
Ctrl+a → l
```

### ペインの入れ替え
```bash
Ctrl+a → {    # 前のペインと入れ替え
Ctrl+a → }    # 次のペインと入れ替え
```

### コマンドモード
```bash
Ctrl+a → :    # tmuxコマンドを直接実行
# 例:
# :new-window -n "test"
# :kill-pane -t 2
# :resize-pane -D 10
```

## 📝 設定ファイルの場所
- グローバル: `/etc/tmux.conf`
- ユーザー: `~/.tmux.conf`
- プロジェクト: `/workspace/docker/.tmux.conf`

## 🔍 状態確認コマンド
```bash
# tmuxのバージョン確認
tmux -V

# 現在の設定値を確認
tmux show -g | grep mouse    # マウス設定
tmux show -g | grep prefix   # プレフィックスキー

# アクティブなペインの情報
tmux display -p "#{pane_id} #{pane_index} #{pane_title}"
```

---

**注意**: このプロジェクトではプレフィックスキーが `Ctrl+a` に変更されています（デフォルトは `Ctrl+b`）。