# tmux クイックリファレンス

## 🚨 よくある問題と解決方法

### Q: tmuxセッションから抜け出せない！
```bash
# 方法1: デタッチ（セッションは残る）
Ctrl+a → d

# 方法2: 終了（セッションも終了）
exit
# または
Ctrl+d
```

### Q: tmuxセッションを完全に削除したい
```bash
# 特定のセッションを削除
tmux kill-session -t claude-teams

# すべてのセッションを削除
tmux kill-server
```

### Q: コピペができない！
```bash
# Shiftキーを押しながら操作
Shift + マウス選択
Shift + Cmd+C (Mac) / Shift + Ctrl+C (Linux)
```

### Q: ペインが応答しない
```bash
# 該当ペインで
Ctrl+a → x → y    # 確認してペインを閉じる

# 別のペインから
tmux kill-pane -t ペイン番号
```

## 📌 必須コマンド TOP 10

1. **セッションから離れる**: `Ctrl+a → d`
2. **セッションに戻る**: `tmux a -t session-name`
3. **ペイン間移動**: `Ctrl+a → 矢印キー`
4. **ペイン分割**: `Ctrl+a → |` (縦) / `Ctrl+a → -` (横)
5. **ペインを閉じる**: `Ctrl+d` または `exit`
6. **ペイン最大化**: `Ctrl+a → z`
7. **セッション一覧**: `tmux ls`
8. **セッション削除**: `tmux kill-session -t name`
9. **コピーモード**: `Ctrl+a → [`
10. **ペースト**: `Ctrl+a → ]`

## 🎮 Master Claude Teams 専用

### 5チーム切り替え
```
0: Master   - Ctrl+a → 0
1: Frontend - Ctrl+a → 1  
2: Backend  - Ctrl+a → 2
3: Database - Ctrl+a → 3
4: DevOps   - Ctrl+a → 4
```

### ペイン番号を確認
```bash
Ctrl+a → q
```

### 全チームの状態を確認（別ターミナルで）
```bash
# 各ペインの最新10行を表示
for i in {0..4}; do
  echo "=== Pane $i ==="
  tmux capture-pane -t "claude-teams:Teams.$i" -p | tail -10
  echo ""
done
```

## 💡 プロのTips

### マウスモード一時切り替え
```bash
# tmuxコマンドモードで
Ctrl+a → :
set -g mouse off    # コピペしやすくなる
set -g mouse on     # 元に戻す
```

### セッション内検索
```bash
Ctrl+a → [    # コピーモード
Ctrl+s        # 前方検索
Ctrl+r        # 後方検索
```

### ペインの同期（全ペインに同じコマンド）
```bash
Ctrl+a → S    # ON/OFF切り替え
```

### 履歴をファイルに保存
```bash
# 現在のペインの履歴を保存
Ctrl+a → P
# ファイル名を入力
```

## 🔥 緊急リセット

```bash
# tmuxの外から実行
pkill -f tmux           # tmuxプロセスを終了
tmux kill-server        # サーバーを終了
rm -rf /tmp/tmux-*      # 一時ファイルを削除
```

---
**覚えておくべき最重要コマンド**: 
- 離脱: `Ctrl+a → d`
- 削除: `tmux kill-session -t name`
- コピペ: `Shift + マウス操作`