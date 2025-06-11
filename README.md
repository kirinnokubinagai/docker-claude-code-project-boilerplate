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

# 動的チーム構成を使用する場合
./join-company.sh --dynamic

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

### teams.jsonの役割
- **チーム構成の定義** - プロジェクトで稼働するチームをJSON形式で管理
- **動的チーム管理** - 必要に応じてチームの追加・削除・無効化が可能
- **メンバー数制御** - 各チームのメンバー数（1-4人）を設定
- **技術スタック定義** - チームごとの専門技術を明記

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

## 🏢 join-company.sh - テンプレートからチーム追加

### 概要
`join-company.sh`は、事前定義されたチームテンプレートを使用して、新しいチームをプロジェクトに追加するツールです。

### 使用方法
```bash
# 基本的な使い方
./join-company.sh <team-template.json>

# 例：フロントエンドチームを追加
./join-company.sh team-templates/frontend-team.json

# 例：新しいカスタムチームを追加
./join-company.sh team-templates/new-team.json
```

### 利用可能なテンプレート
```bash
# テンプレート一覧を確認
ls -la team-templates/

# 主なテンプレート:
- frontend-team.json    # UI/UX開発チーム
- backend-team.json     # API/サーバー開発チーム
- database-team.json    # データベース設計チーム
- devops-team.json      # インフラ/CI/CDチーム
- qa-security-team.json # 品質保証/セキュリティチーム
- mobile-team.json      # モバイルアプリ開発チーム
- ai-team.json          # AI/機械学習チーム
- small-team.json       # 小規模プロジェクト用（2人構成）
- large-team.json       # 大規模プロジェクト用（4人構成）
- new-team.json         # カスタムチーム用テンプレート
```

### チームテンプレートの構造
```json
{
  "id": "frontend",
  "name": "Frontend Team",
  "description": "UI/UX開発チーム",
  "tech_stack": "Next.js, React, TypeScript",
  "member_count": 4,
  "branch": "team/frontend",
  "roles": {
    "boss": {
      "title": "Frontend Boss",
      "responsibilities": "チーム管理、技術選定"
    },
    "pro1": {
      "title": "UI/UX Architect",
      "responsibilities": "デザインシステム構築"
    },
    "pro2": {
      "title": "Performance Engineer",
      "responsibilities": "パフォーマンス最適化"
    },
    "pro3": {
      "title": "Quality Engineer",
      "responsibilities": "テスト実装、品質管理"
    }
  },
  "initial_tasks": [
    "デザインシステムの構築",
    "コンポーネントライブラリの整備"
  ]
}
```

### join-company.shの動作
1. **テンプレート検証** - JSONファイルの構造を確認
2. **チーム情報読み込み** - ID、名前、技術スタックなどを取得
3. **既存チーム確認** - 同じIDのチームが存在しないか確認
4. **Git worktree作成** - チーム専用のブランチを作成
5. **設定ファイル生成** - チーム固有のCLAUDE.mdや初期タスクを生成
6. **teams.json更新** - 新しいチームを追加してアクティブ化

### カスタムチームの作成
```bash
# new-team.jsonをコピーして編集
cp team-templates/new-team.json team-templates/my-custom-team.json

# 必要な項目を編集:
# - id: チームの一意識別子
# - name: チーム表示名
# - description: チームの説明
# - tech_stack: 使用技術
# - roles: 各メンバーの役割
# - initial_tasks: 初期タスク

# カスタムチームを追加
./join-company.sh team-templates/my-custom-team.json
```

## 🎮 tmux操作ガイド

### 基本操作（プレフィックス: Ctrl+a）
```bash
# ウィンドウ切り替え
Ctrl+a → 0  # Master
Ctrl+a → 1  # Team 1（チームがある場合）
Ctrl+a → 2  # Team 2（チームがある場合）
Ctrl+a → N  # Team N（チームがある場合）

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