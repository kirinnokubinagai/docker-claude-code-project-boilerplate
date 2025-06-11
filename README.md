# Master Claude Teams System

🎯 **動的チーム管理** × 🧠 **階層的AI協調** × 🤝 **非同期コラボレーション** × 📚 **自動ドキュメント化**

## 🌟 システムの特徴

- **動的チーム構成** - Masterのみから始めて、必要に応じてチームを追加
- **階層的管理構造** - Master → Boss → チームメンバーの明確な指揮系統
- **非同期通信** - チーム間で作業を止めずに協調作業
- **自動ドキュメント化** - Obsidian + Playwright でスクリーンショット付きマニュアル自動生成
- **Git Worktree活用** - チームごとに独立したブランチで並列開発

## 🚀 クイックスタート

### 1. プロジェクト作成
```bash
git clone [repository-url]
./init-project.sh my-project
cd my-project
```

### 2. 環境設定
```bash
# .env設定（オプション）
ANTHROPIC_API_KEY=your_key

# オプション（追加MCP用）
GITHUB_TOKEN=your_github_token
LINE_USER_ID=your_line_user_id
```

### 3. 起動
```bash
# Dockerコンテナ起動
docker-compose up -d

# コンテナに入る
docker-compose exec -w /workspace claude-code developer-fish

# Masterのみで起動（デフォルト）
./master-claude-teams.sh
```

### 4. 開発開始
Masterペインで要件を入力：
```
ECサイトを作って
```

## 📋 teams.json - 動的チーム管理

### 基本構造
```json
{
  "teams": [
    {
      "id": "frontend",
      "name": "Frontend Team",
      "description": "UI/UX開発チーム",
      "active": true,
      "member_count": 4,
      "tech_stack": "Next.js 14, React 18, TypeScript"
    }
  ]
}
```

### よく使うチーム構成例

#### 5チーム構成（大規模プロジェクト）
```bash
cat > config/teams.json << 'EOF'
{
  "teams": [
    {"id": "frontend", "name": "Frontend Team", "active": true, "member_count": 4},
    {"id": "backend", "name": "Backend Team", "active": true, "member_count": 4},
    {"id": "database", "name": "Database Team", "active": true, "member_count": 4},
    {"id": "devops", "name": "DevOps Team", "active": true, "member_count": 4},
    {"id": "qa-security", "name": "QA/Security Team", "active": true, "member_count": 4}
  ]
}
EOF
```

#### 2チーム構成（小規模プロジェクト）
```bash
cat > config/teams.json << 'EOF'
{
  "teams": [
    {"id": "frontend", "name": "Frontend Team", "active": true, "member_count": 2},
    {"id": "backend", "name": "Backend Team", "active": true, "member_count": 2}
  ]
}
EOF
```

### チーム管理コマンド
```bash
# チーム追加後の再起動
tmux kill-session -t claude-teams
./master-claude-teams.sh

# アクティブなチーム確認
cat config/teams.json | jq '.teams[] | select(.active == true) | .name'
```

## 🎮 tmux操作ガイド

### 基本操作（プレフィックス: Ctrl+a）
```bash
# ウィンドウ切り替え
Ctrl+a → 0  # Master
Ctrl+a → 1  # Frontend Team（チームがある場合）
Ctrl+a → 2  # Backend Team（チームがある場合）

# ペイン操作
Ctrl+a → 矢印キー  # ペイン間移動
Ctrl+a → z         # ペイン最大化/元に戻す
Ctrl+a → d         # セッションから離脱

# セッション管理
tmux attach -t claude-teams     # セッションに再接続
tmux kill-session -t claude-teams  # セッション終了
```

### マウス操作（有効）
- クリックでペイン選択
- スクロールで履歴確認
- ドラッグでペインサイズ調整

## 🔄 コミュニケーション階層

```
Master
  ↕️ ↔️ ↕️
各チームBoss ←→ Boss同士の横連携
  ↕️ ↔️ ↕️
チームメンバー ←→ チーム間連携
```

### コミュニケーション関数

#### Master用
```bash
# Bossへの指示
master_to_boss "frontend" "認証UIを実装してください"

# Master会議
master_meeting "新機能の技術選定について"

# 全体通知
master_broadcast "プロジェクトを開始します"
```

#### Boss用
```bash
# Masterへの報告
boss_to_master "frontend" "UIの実装が完了しました"

# Boss間連携
boss_to_boss "frontend" "backend" "API仕様について相談"

# メンバーへの指示
boss_to_member "frontend" "pro1" "コンポーネント設計をお願いします"
```

#### メンバー用
```bash
# Bossへの報告
member_to_boss "frontend" "pro1" "タスクが完了しました"

# チーム内協力
member_to_member "frontend" "pro1" "pro2" "レビューをお願いします"

# 他チーム連携
cross_team_member_communication "frontend" "pro1" "backend" "pro1" "API使用方法を教えてください"
```

## 📚 自動ドキュメント化

### Obsidian構造
```
Projects/[プロジェクト名]/
├── README.md          # プロジェクト概要
├── docs/              # 実装ドキュメント
├── progress/          # 日次進捗
├── manual/            # ユーザーマニュアル
└── screenshots/       # 自動撮影画像
```

### ドキュメント生成コマンド
```bash
# 進捗記録
record_implementation_progress "frontend" "ログイン画面" "completed" "実装完了"

# スクリーンショット付きドキュメント
document_feature_with_screenshots "frontend" "ログイン画面" "http://localhost:3000/login"

# マニュアル生成
generate_comprehensive_manual "プロジェクト名"
```

## 💡 トラブルシューティング

### tmuxセッションエラー
```bash
tmux kill-session -t claude-teams
./master-claude-teams.sh
```

### コンテナ接続エラー
```bash
docker-compose down
docker-compose up -d
docker-compose exec claude-code developer-fish
```

### MCP設定確認
```bash
check_mcp  # MCP接続状態を確認
setup_mcp_manual  # 手動でMCP再設定
```

## 📌 tmux必須コマンド TOP 10

1. **セッションから離れる**: `Ctrl+a → d`
2. **セッションに戻る**: `tmux a -t claude-teams`
3. **ペイン間移動**: `Ctrl+a → 矢印キー`
4. **ペイン最大化**: `Ctrl+a → z`
5. **ウィンドウ切り替え**: `Ctrl+a → 0-5`
6. **セッション終了**: `tmux kill-session -t claude-teams`
7. **コピー**: `Shift + マウス選択`
8. **ペースト**: `Shift + Cmd+V (Mac) / Shift + Ctrl+V (Linux)`
9. **ペイン同期**: `Ctrl+a → S`（全ペインに同じコマンド）
10. **履歴スクロール**: マウスホイール

## 🛠️ システム要件

### 必須
- Docker & Docker Compose
- Git
- 4GB以上のRAM（チーム数に応じて増加）

### 自動設定されるMCP
- Obsidian MCP - ドキュメント管理
- Playwright MCP - スクリーンショット
- Context7 MCP - 最新技術情報
- Supabase MCP - データベース
- GitHub MCP - リポジトリ管理
- LINE Bot MCP - 通知機能

---

**Masterから始めて、必要に応じてチームを追加。動的で柔軟な開発体制を実現する次世代AI開発システム。**