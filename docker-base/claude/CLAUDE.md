# Claude Code 開発ガイドライン

このファイルはClaude Codeが自動的に参照し、最高品質のコードを生み出すための指示書です。

## 🎯 基本原則

### 実行フロー判定

```
┌─────────────────────────────┐
│ ユーザーのリクエストを受信    │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│ 新規プロジェクト作成？        │
│ ・「作りたい」「作って」      │
│ ・「開発したい」「開発して」  │
│ ・「構築したい」「構築して」  │
│ ・「実装したい」「実装して」  │
│ ・「作成したい」「作成して」  │
│ ・「アプリ」「システム」      │
│ ・「サービス」「ツール」      │
│ ・「プロジェクト」「製品」    │
│ ・「要件定義」「設計」        │
│ ・新規開発・立ち上げの意図    │
└──────┬───────────┬──────────┘
       │YES        │NO
       ▼           ▼
┌──────────────┐ ┌───────────────┐
│ チーム構成    │ │ 通常の開発作業 │
│ フロー実行    │ │ ・バグ修正     │
│ → 停止！     │ │ ・機能追加     │
└──────────────┘ │ ・質問回答     │
                 │ ・単独ファイル  │
                 └───────────────┘
```

## 🚀 新規プロジェクト作成フロー

### 判定ロジック（重要）

新規プロジェクト作成フローは以下の条件で自動的に開始されます：

1. **動詞による判定**
   - 「作りたい」「作って」「作ろう」「作ってほしい」「作って欲しい」
   - 「開発したい」「開発して」「開発しよう」「開発してほしい」「開発して欲しい」
   - 「構築したい」「構築して」「構築しよう」「構築してほしい」「構築して欲しい」
   - 「実装したい」「実装して」「実装しよう」「実装してほしい」「実装して欲しい」
   - 「作成したい」「作成して」「作成しよう」「作成してほしい」「作成して欲しい」
   - 「立ち上げたい」「立ち上げて」「始めたい」「立ち上げてほしい」「始めてほしい」
   - 「制作したい」「制作して」「制作してほしい」「制作して欲しい」

2. **名詞による判定**（上記動詞と組み合わせ）
   - アプリ、アプリケーション
   - システム、サービス、ツール
   - プロジェクト、プロダクト、製品
   - サイト、ウェブサイト、Webサービス
   - プラットフォーム、ソリューション

3. **その他の判定条件**
   - 「要件定義から」「設計から」という言葉
   - teams.jsonやrequirements.mdの作成が必要と判断される場合
   - 完全に新しいものを0から作る意図が明確な場合

### 実行手順（自動実行）

1. **プロジェクト分析**
   - 要件整理とタイプ判定（web/mobile-app/ai/blockchain等）
   - **全機能を一発で実装する前提で機能洗い出し**
   - MVPやフェーズ分けはしない（完全版を作る）
   - 今後の展開やロードマップは作らない

2. **技術選定**
   - Web検索で最新トレンドを調査（直近3ヶ月の技術動向）
   - Context7で最新バージョンとベストプラクティス確認
   - **その時点で最も優れた技術スタックを選定**
   - プロダクション完成形を想定した技術選定
   - 現在実装できる最高の機能をすべて盛り込む
   - **動的技術選定ポリシー**:
     - 常に最新の安定版技術を調査・採用
     - 過去の選択に縛られず、その時点のベストを選択
     - 新技術が登場した場合は積極的に評価・採用
   - **例**: Webアプリ→その時点で最適なフレームワーク
   - **例**: モバイルアプリ→その時点で最適なクロスプラットフォーム技術

3. **要件定義書とタスクファイル作成**
   ```bash
   # 必須: documentsディレクトリとtasksサブディレクトリを作成
   # worktreesではなく、必ずdocuments/tasks/に作成すること
   mkdir -p documents/tasks
   
   # documents/requirements.mdを作成（人間が確認する要件定義書）
   cat > documents/requirements.md << 'EOF'
   # プロジェクト要件定義
   
   ## 概要
   [プロジェクトの説明]
   
   ## 技術スタック
   - Frontend: [選定した技術]
   - Backend: [選定した技術]
   - Database: [選定した技術]
   
   ## 機能要件
   ### 認証システム
   - ユーザー登録・ログイン機能
   - ソーシャルログイン対応
   - 2段階認証
   - パスワードリセット機能
   
   ### ダッシュボード
   - リアルタイムデータ表示
   - カスタマイズ可能なウィジェット
   - レスポンシブデザイン
   
   ## 非機能要件
   - セキュリティ: JWT認証、HTTPS通信
   - パフォーマンス: 3秒以内のページロード
   - 可用性: 99.9%のアップタイム
   - スケーラビリティ: 水平スケーリング対応
   EOF
   
   # タスクファイルを個別に作成（Masterが参照）
   # 必ずdocuments/tasks/ディレクトリに作成すること
   # Frontend Tasks
   cat > documents/tasks/frontend_tasks.md << 'EOF'
   # Frontend Tasks
   
   ## 認証システム
   - [ ] ログイン画面のデザイン作成（Magic MCP使用）
   - [ ] ログインフォームコンポーネント実装（Magic MCP使用）
   - [ ] ログインフォームのE2Eテスト作成 (tests/e2e/login_test.spec.ts)
   - [ ] バリデーション処理実装
   - [ ] バリデーションのユニットテスト作成 (tests/unit/validation_test.ts)
   - [ ] エラーメッセージ表示機能（Magic MCP使用）
   - [ ] エラー表示のE2Eテスト作成 (tests/e2e/error_display_test.spec.ts)
   - [ ] パスワードリセット画面実装（Magic MCP使用）
   - [ ] 新規登録画面実装（Magic MCP使用）
   - [ ] メールアドレス確認フロー実装
   - [ ] ソーシャルログインボタン追加（Magic MCP使用）
   - [ ] Remember Me機能実装
   - [ ] 自動ログアウト機能実装
   
   ## ダッシュボード
   - [ ] ダッシュボードレイアウト設計（Magic MCP使用）
   - [ ] ヘッダーコンポーネント作成（Magic MCP使用）
   - [ ] サイドバーナビゲーション実装（Magic MCP使用）
   - [ ] ウィジェットコンポーネント作成（Magic MCP使用）
   - [ ] グラフ表示機能実装
   - [ ] リアルタイムデータ更新機能
   - [ ] フィルター機能実装
   - [ ] エクスポート機能追加
   
   ## レスポンシブ対応
   - [ ] モバイル用レイアウト作成（Magic MCP使用）
   - [ ] タブレット用レイアウト調整（Magic MCP使用）
   - [ ] ハンバーガーメニュー実装（Magic MCP使用）
   - [ ] タッチ操作対応
   - [ ] 画面回転対応
   EOF
   
   # Backend Tasks
   cat > documents/tasks/backend_tasks.md << 'EOF'
   # Backend Tasks
   
   ## API基盤
   - [ ] プロジェクト初期設定
   - [ ] ルーティング設定
   - [ ] ミドルウェア設定
   - [ ] エラーハンドリング実装
   - [ ] ロギングシステム構築
   - [ ] APIドキュメント自動生成設定
   
   ## 認証API
   - [ ] ユーザーモデル定義
   - [ ] JWT実装
   - [ ] JWTユニットテスト作成 (tests/backend/jwt_test.{拡張子})
   - [ ] ログインエンドポイント作成
   - [ ] ログインAPIテスト作成 (tests/backend/login_api_test.{拡張子})
   - [ ] ログアウトエンドポイント作成
   - [ ] ログアウトAPIテスト作成 (tests/backend/logout_api_test.{拡張子})
   - [ ] トークンリフレッシュ機能
   - [ ] パスワードハッシュ化実装
   - [ ] メール送信機能実装
   - [ ] 2段階認証対応
   
   ## データ処理
   - [ ] CRUD APIエンドポイント作成
   - [ ] バリデーション処理実装
   - [ ] ページネーション実装
   - [ ] ソート機能実装
   - [ ] 検索機能実装
   - [ ] バッチ処理機能
   EOF
   
   # Database Tasks
   cat > documents/tasks/database_tasks.md << 'EOF'
   # Database Tasks
   
   ## スキーマ設計
   - [ ] ER図作成
   - [ ] テーブル定義書作成
   - [ ] インデックス設計
   - [ ] 外部キー制約設定
   
   ## マイグレーション
   - [ ] 初期マイグレーションファイル作成
   - [ ] シードデータ作成
   - [ ] マイグレーションスクリプト作成
   EOF
   
   # DevOps Tasks
   cat > documents/tasks/devops_tasks.md << 'EOF'
   # DevOps Tasks
   
   ## 環境構築
   - [ ] Dockerfile作成
   - [ ] docker-compose.yml作成
   - [ ] 環境変数設定
   - [ ] 開発環境構築手順書作成
   
   ## CI/CD
   - [ ] GitHub Actions設定
   - [ ] 自動テスト設定
   - [ ] 自動デプロイ設定
   - [ ] コード品質チェック設定
   EOF
      ```

4. **Git初期化とリポジトリ作成**
   ```bash
   git init
   git add .
   git commit -m "feat: プロジェクト初期化"
   # GitHubリポジトリ作成（対話形式）
   ```

5. **開発環境構築**
   - 選定した技術スタックに基づいてプロジェクトを初期化
   - 基本的なディレクトリ構造を作成
     ```
     /workspace/
     ├── src/           # ソースコード
     ├── tests/         # テストコード
     │   ├── unit/      # ユニットテスト
     │   └── e2e/       # E2Eテスト（Playwright）
     ├── documents/     # ドキュメント（既存）
     └── worktrees/     # チーム別作業ディレクトリ（後で作成）
     ```
   - **デプロイツールの自動インストール**（技術選定後に実行）
     ```bash
     # プロジェクトタイプを検出して必要なツールをインストール
     /opt/claude-system/scripts/setup-deploy-tools.sh
     ```
   - ESLint/Prettier等の開発ツールを設定
   - 開発サーバーを起動（ポート番号を確認・記録）
   - git initとgit commitで初期状態を保存

6. **タスク分割とチーム編成**
   - documents/tasks/内のタスクファイルに基づいてタスクを詳細分割
   - 必要なチーム数とメンバー数を決定
   - **必須: teams.jsonをdocumentsディレクトリに作成**
   ```bash
   # documentsディレクトリに teams.json を作成
   cat > documents/teams.json << 'EOF'
   {
     "project_name": "実際のプロジェクト名に変更",
     "project_type": "web-app",
     "teams": [
       実際のチーム構成をここに記載
     ]
   }
   EOF
   
   # 作成確認（必須）
   ls -la documents/teams.json
   cat documents/teams.json
   ```

7. **git worktreeとブランチの準備**
   ```bash
   # teams.jsonに基づいてブランチとworktreeを作成
   # 例（teams.jsonの内容に応じて調整）:
   git branch team/frontend
   git branch team/backend
   git branch team/database
   git branch team/devops
   
   # worktreeディレクトリを作成
   mkdir -p worktrees
   git worktree add worktrees/frontend team/frontend
   git worktree add worktrees/backend team/backend
   git worktree add worktrees/database team/database
   git worktree add worktrees/devops team/devops
   
   # 確認
   git worktree list
   ```

8. **🛑 ここで必ず停止！**

### teams.json作成の具体例（厳守）

**重要: プロジェクトタイプと規模に応じてチーム構成を調整**

```bash
# teams.json作成コマンド
# 注意: チーム構成とメンバー数は実際のプロジェクト要件に合わせて調整すること
cat > documents/teams.json << 'EOF'
{
  "project_name": "実際のプロジェクト名",
  "project_type": "プロジェクトタイプ（web-app/mobile-app/ai/blockchain等）",
  "teams": [
    # ここに実際のチーム構成を記載
    # 例:
    # - Webアプリ: frontend(4), backend(4), database(3), devops(3)
    # - モバイルアプリ: mobile(4), backend(4), devops(3)
    # - AIプロダクト: ai(4), backend(4), frontend(4), data(4)
    # - シンプルなサイト: frontend(3), backend(2)
    # 
    # 各チームの形式:
    # {
    #   "id": "チームID（英小文字）",
    #   "name": "チーム表示名",
    #   "member_count": メンバー数（1-4）,
    #   "branch": "team/チームID"
    # }
  ]
}
EOF

# よく使われる構成例:

# 【Webアプリケーション（フルスタック）】
cat > documents/teams.json << 'EOF'
{
  "project_name": "プロジェクト名を入力",
  "project_type": "web-app",
  "teams": [
    {"id": "frontend", "name": "Frontend Team", "member_count": 4, "branch": "team/frontend"},
    {"id": "backend", "name": "Backend Team", "member_count": 4, "branch": "team/backend"},
    {"id": "database", "name": "Database Team", "member_count": 3, "branch": "team/database"},
    {"id": "devops", "name": "DevOps Team", "member_count": 3, "branch": "team/devops"}
  ]
}
EOF

# 【シンプルなWebサイト】
# cat > documents/teams.json << 'EOF'
# {
#   "project_name": "プロジェクト名を入力",
#   "project_type": "website",
#   "teams": [
#     {"id": "frontend", "name": "Frontend Team", "member_count": 3, "branch": "team/frontend"},
#     {"id": "backend", "name": "Backend Team", "member_count": 2, "branch": "team/backend"}
#   ]
# }
# EOF

# 【モバイルアプリ】
# cat > documents/teams.json << 'EOF'
# {
#   "project_name": "プロジェクト名を入力",
#   "project_type": "mobile-app",
#   "teams": [
#     {"id": "mobile", "name": "Mobile Team", "member_count": 4, "branch": "team/mobile"},
#     {"id": "backend", "name": "Backend Team", "member_count": 4, "branch": "team/backend"},
#     {"id": "devops", "name": "DevOps Team", "member_count": 3, "branch": "team/devops"}
#   ]
# }
# EOF

# 必ず実行: 作成確認
ls -la documents/teams.json
echo "teams.json created at: $(pwd)/documents/teams.json"
```

### teams.jsonの必須フィールド（厳密なフォーマット）

| フィールド   | 型     | 説明               | 例           |
| ------------ | ------ | ------------------ | ------------ |
| project_name | string | プロジェクト名     | "〇〇アプリ" |
| project_type | string | プロジェクトタイプ | "web-app"    |
| teams        | array  | チーム配列         | []           |

### teamsオブジェクトの必須フィールド（厳密なフォーマット）

| フィールド   | 型     | 説明                 | 例              |
| ------------ | ------ | -------------------- | --------------- |
| id           | string | チームID（英小文字） | "frontend"      |
| name         | string | チーム表示名         | "Frontend Team" |
| member_count | number | メンバー数（1-4）    | 4               |
| branch       | string | ブランチ名           | "team/frontend" |

**重要**: 上記4つのフィールドのみを含めること。他のフィールド（focus等）は追加しないこと。



### Master Claudeの動作フロー（指示待ちゼロシステム）

```
1. documents/teams.jsonを読み込んでtmuxセッションを起動
   - 各チームのペインを作成（1人目がBoss）
   - 全員でclaude --dangerously-skip-permissionsを起動

2. git worktreeの確認と移動（重要）
   各チームは必ず自分のworktreeで作業する：
   - Frontend Team: worktrees/frontend
   - Backend Team: worktrees/backend
   - Database Team: worktrees/database
   - DevOps Team: worktrees/devops
   
   # 各Bossが最初に実行
   cd /workspace/worktrees/frontend  # 自分のチームのworktreeに移動
   pwd  # 確認: /workspace/worktrees/frontend

3. documents/tasks/を参照してタスク管理
   ls documents/tasks/ でタスクファイル一覧を確認
   cat documents/tasks/*.md で各チームのタスクを確認

4. 未完了タスク（- [ ]）を抽出して優先順位付け
   依存関係を考慮して実行可能なタスクを選定

5. 各チームのBossに指示を出す（階層的指示システム）
   Master → Boss → メンバーの流れで指示が伝達される
   
   **重要な役割分担**：
   - **Master（pane 1）**: 全体統括、タスク配分、メインブランチへのマージ作業、完了マークの追加とコミットIDの追加、Bossへの指示のみ
   - **Boss（各チームの1人目）**: チーム内タスク管理、メインブランチをworktreeにマージ、レビュー及びMemberへの指示、コミットのみ
   - **Member（各チームの2-4人目）**: 実装作業とBossへの報告のみ

   **ペイン番号（重要）**：
   - ペイン1: Master（常に固定）
   - ペイン2以降: teams.jsonの順番通りに各チームが配置
     - 例: 最初のチームのBossがペイン2
     - 例: 最初のチームのメンバー2がペイン3
     - 以降、各チームのメンバーが順番に配置
   
   **禁止事項**：
   - BossやMemberがMasterの役割（他チームへの指示、マージ等）を行うこと
   - MemberがBossの役割（レビュー、コミット等）を行うこと
   - 各チームは自分のworktree内でのみ作業すること

### 📊 Master-Boss-Member ワークフロー

1. **Master**: documents/tasks/*.md から未完了タスクを抽出
2. **Master → Boss**: tmuxコマンドでタスク指示
3. **Boss → Members**: タスクを分配し、3秒ごとに監視
4. **Members**: 実装作業（アイドル時は即報告）
5. **Members → Boss**: 完了/質問/アイドル報告
6. **Boss**: レビュー & テスト & コミット
7. **Boss → Master**: チーム進捗報告
8. **Master**: マージ & タスクファイル更新
9. **ループ**: 全タスクが [x] になるまで継続

6. Masterは常にBossを監視（無限ループ処理）
   ```
   while true:
       for boss in all_bosses:
           # 各Bossの状態をチェック
           status = check_boss_status(boss)
           
           if status == "タスク完了":
               assign_next_task(boss)
           elif status == "指示待ち":
               assign_new_task(boss)
           elif status == "問題発生":
               provide_alternative_task(boss)
           elif status == "質問あり":
               answer_question(boss)
               
       # 5秒ごとに監視ループ
       sleep(5)
   ```
   - 各Bossの進捗を5秒ごとに確認
   - タスク完了を検知したらミリ秒で次のタスクを割り当て
   - 指示待ち状態を検知したら即座に新しいタスクを投入
   - 問題発生時は代替タスクを提供
   - Bossからの質問にリアルタイムで対応

7. Bossは部下を常に監視（無限ループ処理）
   ```
   while true:
       for member in team_members:
           # 各メンバーの状態をチェック
           status = check_member_status(member)
           
           if status == "タスク完了":
               assign_next_task(member)
           elif status == "アイドル" or status == "指示待ち":
               assign_new_task(member)
           elif status == "問題発生":
               provide_support(member)
           elif status == "質問あり":
               answer_question(member)
               
       # 3秒ごとに監視ループ
       sleep(3)
   ```
   - メンバーの作業状況を3秒ごとに継続的にチェック
   - タスク完了を検知したらミリ秒で次のタスクを割り当て
   - アイドル状態や指示待ちを検知したら即座に新しいタスクを投入
   - 全員が常に作業している状態を維持（指示待ちゼロ）
   - メンバーからの質問にリアルタイムで対応
   - 問題発生時は即座にサポートまたは代替タスクを提供

8. 確認フロー（重要）
   - メンバー → Boss: タスク完了報告、質問、レビュー依頼
   - **メンバー → Boss: アイドル状態になったら即座に報告（指示待ちゼロ）**
   - Boss → Master: チームタスク完了報告、方針確認、コミット準備
   - Master → Boss: マージ、次のタスク指示

9. テスト実施（必須）
   - 各タスク完了時に必ずテストを作成・実行
   - UIタスク: Playwright MCPを使用してE2Eテスト
     ```bash
     # 重要: 開発サーバーが起動していることを必ず確認
     # 開発サーバーのポートを確認（Next.js:3000, Vite:5173など）
     DEV_PORT=3000  # テスト対象アプリのポート番号
     
     # Playwright MCPサーバー経由でブラウザを操作
     # 注: Playwright MCPサーバーは各tmuxペインごとに30001-30999の範囲で自動割り当て済み
     # 以下のURLはテスト対象アプリケーションのアドレス
     claude mcp mcp__mcp-playwright__browser_navigate --url "http://host.docker.internal:${DEV_PORT}"
     claude mcp mcp__mcp-playwright__browser_snapshot
     claude mcp mcp__mcp-playwright__browser_click --element "Login button" --ref "button[type=submit]"
     claude mcp mcp__mcp-playwright__browser_take_screenshot --filename "login-test.png"
     
     # テストケースの自動生成も可能
     claude mcp mcp__mcp-playwright__browser_generate_playwright_test \
       --name "ログイン機能テスト" \
       --description "ユーザーがログインできることを確認" \
       --steps '["ログインページにアクセス", "メールアドレスを入力", "パスワードを入力", "ログインボタンをクリック", "ダッシュボードにリダイレクトされることを確認"]'
     ```
   - APIタスク: 言語に応じたユニットテスト (tests/backend/auth_test.拡張子)
   - ロジック: 言語に応じたユニットテスト (tests/unit/validation_test.拡張子)
   - テストが全て通過するまでコミット禁止

10. Bossがチームタスク完了後、自分のworktreeでコミット
   # 必ず自分のworktreeで作業していることを確認
   pwd  # 例: /workspace/worktrees/frontend
   
   # テスト実行（言語に応じたコマンド）
   npm test          # JavaScript/TypeScript
   pytest tests/     # Python
   go test ./...     # Go
   cargo test        # Rust
   
   # 全テスト通過後、活動ログを作成してからコミット
   # 1. 活動ログディレクトリを作成（プロジェクト内）
   mkdir -p /workspace/documents/activity_logs
   
   # 2. タイムスタンプを生成（形式: yyyy-mm-dd_HH-MM-SS）
   TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
   WORK_DESC="implement-auth-system"  # 作業内容を簡潔に記述（kebab-case）
   LOG_FILE="/workspace/documents/activity_logs/${TIMESTAMP}_${WORK_DESC}.md"
   
   # 3. 活動ログを作成
   cat > "$LOG_FILE" << 'EOF'
   # Activity Log: 認証システム実装
   
   **Date**: 2024-06-19 14:30:00
   **Author**: Claude Code (Frontend Team)
   **Commit Hash**: [後で追加]
   
   ## Summary
   認証システムの基本機能を実装しました。ログイン、ログアウト、パスワードリセット機能を含みます。
   
   ## Changes Made
   - ログインフォームコンポーネントの作成
   - バリデーション処理の実装
   - エラーメッセージ表示機能の追加
   - APIとの連携処理
   - テストコードの作成
   
   ## Files Modified
   - `src/components/auth/LoginForm.tsx` - ログインフォームUI
   - `src/utils/validation.ts` - バリデーションロジック
   - `src/api/auth.ts` - 認証API連携
   - `tests/e2e/login.spec.ts` - E2Eテスト
   - `tests/unit/validation.test.ts` - ユニットテスト
   
   ## Testing
   - 全ユニットテスト: PASS
   - E2Eテスト: PASS
   - カバレッジ: 85%
   
   ## Notes
   - パフォーマンス最適化は次回のスプリントで実施予定
   - アクセシビリティ対応完了
   EOF
   
   # 4. 活動ログを含めてコミット
   git add .
   git commit -m "feat: 認証システム実装
   
   📝 Activity log: documents/activity_logs/${TIMESTAMP}_${WORK_DESC}.md
   
   🤖 Generated with Claude Code
   Co-Authored-By: Claude <noreply@anthropic.com>"
   
   # 5. コミットハッシュを取得して活動ログを更新
   COMMIT_HASH=$(git log -1 --format="%H")
   sed -i "s/\[後で追加\]/$COMMIT_HASH/" "$LOG_FILE"
   git add "$LOG_FILE"
   git commit --amend --no-edit

11. MasterがBossからの報告を受けてマージ
    - テストの実行確認（テストなしのコミットは却下）
    - documents/tasks/内の該当タスクファイルを更新（完了: - [ ] を - [x] に変更）
    - 新規タスク発生: 適切な場所に追加
    - ブランチをメインにマージ
    - 即座に次のタスクセットをBossに割り当て

12. 全タスクが完了するまで4-10を繰り返す
    目標: documents/tasks/内の全タスクファイルの全項目が [x] になること

13. 12まで完了した時に`git push`を行いobsidianにメモを作成し、lineに通知を行う
```


#### タスク管理のベストプラクティス
- **実現可能性重視**: 既存技術で確実に実装できるもののみ
- **完全実装主義**: MVP思考ではなく、完成品を一発で作る
- **動的タスク追加**: 開発中に必要なタスクは即座に追加
- **並列実行**: 依存関係のないタスクは同時進行
- **全員フル稼働**: 常に全メンバーがタスクを持つ状態を維持
- **指示待ちゼロ**: Master/Bossは常に監視し、即座に次のタスクを投入
- **完全ゼロアイドル**: メンバーはアイドル状態になったら即座にBossに報告
- **監視ループ必須**: Master→5秒ごと、Boss→3秒ごとに全員を監視
- **プロアクティブ管理**: タスク完了前に次のタスクを準備
- **確認体制徹底**: メンバー→Boss、Boss→Masterの確認フロー
- **テスト必須**: 各タスク完了時にテスト作成・実行が必須

## 🛠️ プロジェクトタイプ検出と動的ツールインストール

### 自動検出とツール選定

プロジェクトの種類を自動的に検出し、必要なデプロイツールを動的にインストールします。

#### Webプロジェクトの場合

```bash
# package.jsonから使用フレームワークを検出
if [ -f package.json ]; then
  # Next.js検出
  if grep -q "next" package.json; then
    echo "Next.jsプロジェクトを検出 → Vercel CLIをインストール"
    npm install -g vercel
    
    # デプロイコマンド例
    # vercel --prod
  fi
  
  # Remix検出
  if grep -q "@remix-run" package.json; then
    echo "Remixプロジェクトを検出 → Fly.io CLIをインストール"
    curl -L https://fly.io/install.sh | sh
    
    # デプロイコマンド例
    # fly deploy
  fi
  
  # Vite/Vue/React（静的サイト）検出
  if grep -q "vite\|vue\|react" package.json && ! grep -q "next\|remix" package.json; then
    echo "静的サイトを検出 → Netlify CLIをインストール"
    npm install -g netlify-cli
    
    # デプロイコマンド例
    # netlify deploy --prod
  fi
  
  # Nuxt検出
  if grep -q "nuxt" package.json; then
    echo "Nuxtプロジェクトを検出 → Vercel/Netlify CLIをインストール"
    npm install -g vercel netlify-cli
  fi
fi

# Python Webフレームワーク検出
if [ -f requirements.txt ] || [ -f pyproject.toml ]; then
  if grep -q "django\|flask\|fastapi" requirements.txt pyproject.toml 2>/dev/null; then
    echo "Python Webプロジェクトを検出 → Railway CLIをインストール"
    npm install -g @railway/cli
    
    # デプロイコマンド例
    # railway up
  fi
fi
```

#### モバイルアプリの場合

```bash
# React Native検出
if [ -f package.json ] && grep -q "react-native" package.json; then
  # Expo使用確認
  if grep -q "expo" package.json; then
    echo "React Native + Expoプロジェクトを検出"
    npm install -g expo-cli eas-cli
    echo "✅ Expo & EAS CLI installed"
  else
    echo "React Nativeプロジェクトを検出"
    # React Native CLIなど必要なツールをインストール
  fi
fi

# Flutter検出（将来的な対応のため）
if [ -f pubspec.yaml ]; then
  echo "Flutterプロジェクトを検出"
  # 必要なツールをインストール
fi
```

### プロジェクトタイプ別推奨ツール

#### Webプロジェクト

| フレームワーク | デプロイ先 | CLIツール | インストールコマンド |
|--------------|-----------|----------|------------------|
| Next.js | Vercel | vercel | `npm i -g vercel` |
| Remix | Fly.io | flyctl | `curl -L https://fly.io/install.sh \| sh` |
| Nuxt | Vercel/Netlify | vercel/netlify | `npm i -g vercel netlify-cli` |
| Vite/React/Vue | Netlify/Vercel | netlify/vercel | `npm i -g netlify-cli vercel` |
| SvelteKit | Vercel/Netlify | vercel/netlify | `npm i -g vercel netlify-cli` |
| Astro | Netlify/Vercel | netlify/vercel | `npm i -g netlify-cli vercel` |
| Django/Flask | Railway/Render | railway | `npm i -g @railway/cli` |
| Laravel | Forge/Vapor | vapor | `composer global require laravel/vapor-cli` |
| Rails | Heroku/Render | heroku | `curl https://cli-assets.heroku.com/install.sh \| sh` |

#### モバイルアプリ

| フレームワーク | ビルド/配信 | CLIツール | インストールコマンド |
|--------------|-----------|----------|------------------|
| React Native + Expo | EAS Build | expo-cli, eas-cli | `npm i -g expo-cli eas-cli` |
| React Native | React Native CLI | react-native | `npm i -g react-native` |
| Flutter | Flutter CLI | flutter | `適切なインストール方法` |

### 自動セットアップスクリプト

プロジェクト作成時に自動的に実行されるセットアップ：

```bash
#!/bin/bash
# /opt/claude-system/scripts/setup-deploy-tools.sh

detect_and_install_tools() {
  echo "🔍 プロジェクトタイプを検出中..."
  
  # Web Framework Detection
  if [ -f package.json ]; then
    if grep -q '"next"' package.json; then
      echo "📦 Next.js detected → Installing Vercel CLI"
      npm install -g vercel
      echo "✅ Vercel CLI installed. Deploy with: vercel --prod"
    elif grep -q '"@remix-run"' package.json; then
      echo "📦 Remix detected → Installing Fly.io CLI"
      curl -L https://fly.io/install.sh | sh
      echo "✅ Fly CLI installed. Deploy with: fly deploy"
    elif grep -q '"nuxt"' package.json; then
      echo "📦 Nuxt detected → Installing deployment CLIs"
      npm install -g vercel netlify-cli
      echo "✅ Deploy with: vercel --prod or netlify deploy --prod"
    fi
  fi
  
  # Mobile Framework Detection
  if [ -f package.json ] && grep -q '"react-native"' package.json; then
    if grep -q '"expo"' package.json; then
      echo "📱 React Native + Expo detected → Installing Expo/EAS CLI"
      npm install -g expo-cli eas-cli
      echo "✅ Expo & EAS CLI installed"
      echo "   Development: expo start"
      echo "   Build: eas build --platform all"
      echo "   Submit: eas submit"
    else
      echo "📱 React Native detected → Installing React Native CLI"
      npm install -g react-native-cli
      echo "✅ React Native CLI installed"
    fi
  fi
  
  # Flutter Detection (for future support)
  if [ -f pubspec.yaml ]; then
    echo "📱 Flutter detected"
    # Flutter specific tools installation
  fi
}

# 実行
detect_and_install_tools
```

### 使用例

```bash
# プロジェクト作成後、自動的にツールがインストールされる
cd /workspace

# 手動で再検出・インストール
/opt/claude-system/scripts/setup-deploy-tools.sh

# デプロイ実行例（Next.js）
vercel --prod

# デプロイ実行例（React Native）
eas build --platform all
eas submit
```

### 注意事項

1. **認証情報**: 各CLIツールは初回使用時に認証が必要
2. **環境変数**: `.env`ファイルで以下を設定可能
   - `VERCEL_TOKEN`
   - `NETLIFY_AUTH_TOKEN`
   - `FLY_API_TOKEN`
   - `EXPO_TOKEN`

3. **自動デプロイ**: CI/CD設定は各プロジェクトで個別に行う

## 💻 開発原則

### コード品質

```javascript
/**
 * 関数には必ずJSDocを記載
 * @param {Type} param - パラメータの説明
 * @returns {Type} 戻り値の説明
 */
function exampleFunction(param) {
  // 早期リターンで可読性向上
  if (!param) return null;
  
  // ネストは浅く、処理は明確に
  return processValue(param);
}
```

### コーディングルール

- **関数Doc**: 必ず記載（引数・返り値の説明含む）
- **関数内コメント**: 禁止（必要なら関数を分割）
- **早期リターン**: 推奨（else/elseifは避ける）
- **ネスト**: 最大3階層まで
- **変数名**: 意味が明確で検索しやすい名前

### デザイン作成時の注意事項

**重要: UIコンポーネントやデザインを作成する際は、必ずMagic MCPを使用すること**

```bash
# デザイン作成時の基本フロー
1. Magic MCPを使用してUIコンポーネントを生成
2. 生成されたコンポーネントをプロジェクトに統合
3. 必要に応じてカスタマイズ
```

#### Magic MCP使用例
- ログインフォームのデザイン → Magic MCPで生成
- ダッシュボードレイアウト → Magic MCPで生成
- ボタンやカードコンポーネント → Magic MCPで生成
- レスポンシブナビゲーション → Magic MCPで生成


### テスト駆動開発

1. **タスク完了時に必ずテストを作成**
2. **テストの種類と配置**
   ```
   tests/
   ├── e2e/           # Playwright E2Eテスト
   │   ├── auth_test.spec.ts
   │   └── dashboard_test.spec.ts
   ├── backend/       # バックエンドユニットテスト
   │   ├── auth_test.{js|ts|py|go|rs}  # 言語に応じた拡張子
   │   └── api_test.{js|ts|py|go|rs}
   └── unit/          # フロントエンドユニットテスト
       ├── validation_test.{js|ts}
       └── utils_test.{js|ts}
   ```
3. **テスト命名規則**
   - E2E: `{機能名}_test.spec.ts`
   - Backend: `{機能名}_test.{言語拡張子}`
   - Unit: `{機能名}_test.{言語拡張子}`
   - 例: auth_test.js, auth_test.py, auth_test.go, auth_test.rs
4. **テストカバレッジ基準**
   - カバレッジ90%以上必須
   - ハードコード禁止
   - 各機能に対応するテスト必須
5. **テスト実行コマンド（言語別）**
   ```bash
   # Playwright MCP経由でE2Eテスト
   # 重要: 開発サーバーが起動していることを必ず確認
   # 1. 開発サーバー起動: npm run dev (別ペインで実行)
   # 2. ポート確認: 通常3000, Viteは5173, カスタムポートの場合は要確認
   # 3. Playwright MCPサーバー自体は30001-30999ポートで自動起動済み
   # 4. MCP経由でブラウザを操作してテスト対象アプリにアクセス:
   claude mcp mcp__mcp-playwright__browser_navigate --url "http://host.docker.internal:[DEV_PORT]"
   claude mcp mcp__mcp-playwright__browser_snapshot
   # 各テストステップをMCPコマンドで実行
   
   # JavaScript/TypeScript（ユニットテスト）
   npm test
   jest tests/
   vitest
   
   # Python
   pytest tests/
   python -m unittest discover
   
   # Go
   go test ./...
   go test ./tests/...
   
   # Rust
   cargo test
   
   # Java
   mvn test
   gradle test
   ```
6. **全テスト通過後にコミット**

## 🔧 技術選定基準

### 評価ポイント

1. **最新性**: 最新安定版を使用
2. **実績**: プロダクション実績
3. **DX**: 開発体験の良さ
4. **性能**: ベンチマーク結果
5. **保守性**: 長期的なメンテナンス

### 新技術への対応方針

1. **定期的な技術調査**
   - プロジェクト開始時に必ず最新技術を調査
   - 過去の選択にとらわれない

2. **評価基準**
   - 安定性（stable release）
   - コミュニティの活発さ
   - エコシステムの充実度
   - パフォーマンス指標
   - 開発者体験

3. **採用決定**
   - 新技術が既存技術を明確に上回る場合は採用
   - 「いつも使っているから」という理由での技術選定は禁止
   - その時点のベストプラクティスを採用


## 📊 プロジェクトタイプ別チーム構成

### Webアプリケーション
- Frontend Team（UI/UX）: 4名
- Backend Team（API）: 4名
- Database Team（データ）: 3名
- DevOps Team（インフラ）: 3名

### モバイルアプリ
- Mobile Team（アプリ）: 4名
- Backend Team（API）: 4名
- DevOps Team（配信）: 3名

### AIプロダクト
- AI Team（モデル）: 4名
- Backend Team（API）: 4名
- Frontend Team（UI）: 4名
- Data Team（データ）: 4名

## ⚡ クイックリファレンス

### コマンド早見表

```bash
# プロジェクト初期化
npm create vite@latest
npm create next-app@latest

# Git操作
git init && git add . && git commit -m "feat: 初期化"

# 開発サーバー
npm run dev
# 必ず終了: Ctrl+C

# Playwright MCPを使用したE2Eテスト
# 重要: 開発サーバーが起動していることを必ず確認
# 1. 開発サーバー起動（別ペイン）: npm run dev
# 2. 開発サーバーのポート確認（DEV_PORTはテスト対象アプリのポート）:
DEV_PORT=3000  # Next.js:3000, Vite:5173, その他フレームワークに応じて変更
# 3. Playwright MCPを使ってテスト対象アプリにアクセス:
claude mcp mcp__mcp-playwright__browser_navigate --url "http://host.docker.internal:${DEV_PORT}"
claude mcp mcp__mcp-playwright__browser_snapshot
claude mcp mcp__mcp-playwright__browser_type --element "Email input" --ref "input[name='email']" --text "test@example.com"
claude mcp mcp__mcp-playwright__browser_type --element "Password input" --ref "input[name='password']" --text "password"
claude mcp mcp__mcp-playwright__browser_click --element "Login button" --ref "button[type='submit']"
claude mcp mcp__mcp-playwright__browser_wait_for --text "Dashboard"
claude mcp mcp__mcp-playwright__browser_take_screenshot --filename "dashboard-after-login.png"
```

### よくあるミス

1. ❌ teams.jsonを表示だけ → ✅ ファイルに保存
2. ❌ 実装まで進める → ✅ チーム構成で停止
3. ❌ プロセス放置 → ✅ 必ず終了処理

## 📝 タスクリスト作成ガイドライン

### タスクの粒度と構成
タスクは機能単位で分割し、各タスクは1-4時間で完了できる粒度にする

### Frontend Tasks テンプレート
```markdown
#### 基本UI構築
- [ ] ワイヤーフレーム/モックアップ作成
- [ ] レイアウトコンポーネント作成（Magic MCP使用）
- [ ] ナビゲーション実装（Magic MCP使用）
- [ ] レスポンシブ対応

#### 機能実装
- [ ] フォーム作成（Magic MCP使用）
- [ ] バリデーション実装
- [ ] APIとの連携
- [ ] 状態管理実装
- [ ] エラーハンドリング

#### テスト
- [ ] ユニットテスト作成（tests/unit/）
- [ ] E2Eテスト作成（tests/e2e/）
```

### Backend Tasks テンプレート
```markdown
#### API実装
- [ ] エンドポイント設計
- [ ] ルーティング実装
- [ ] ミドルウェア作成
- [ ] 認証・認可実装

#### ビジネスロジック
- [ ] サービス層実装
- [ ] バリデーション処理
- [ ] エラーハンドリング

#### テスト
- [ ] APIテスト作成（tests/backend/）
- [ ] 統合テスト作成
```

## 📡 通信プロトコル（Master-Boss-Member）

### 階層的通信ルール
```
Master ↔️ Boss ↔️ Member
```

**重要**: 
- Memberは必ずBoss経由でMasterと通信
- Bossは必ずMaster経由で他チームと通信
- 直接的なクロスチーム通信は禁止

### 報告フォーマット

#### Member → Boss
```
【タスク完了報告】
タスク: [タスク名]
状態: 完了
テスト: 作成済み・実行済み
場所: tests/e2e/[ファイル名]
次タスク待機中

【質問・相談】
タスク: [タスク名]
内容: [具体的な質問]
提案: [自分の案がある場合]

【アイドル報告】※即座に報告
状態: アイドル
最終タスク: [直前のタスク名]
次タスク要求
```

#### Boss → Master
```
【チーム進捗報告】
チーム: [チーム名]
完了タスク: 
- [x] タスク1（テスト済み）
- [x] タスク2（テスト済み）
進行中: 
- [ ] タスク3（Member1）
- [ ] タスク4（Member2）
カバレッジ: 92%
コミット準備: OK

【問題エスカレーション】
チーム: [チーム名]
問題: [具体的な問題]
影響: [影響範囲]
提案: [解決案]
```

### ステータス確認方法

#### タスク進捗の可視化
```bash
# documents/tasks/[team]_tasks.mdファイルで管理
- [x] 完了タスク
- [ ] 未完了タスク
- [~] 進行中タスク（オプション）

# 定期的に更新
cat documents/tasks/frontend_tasks.md | grep -E "^\- \["
```

#### 監視ループの実装
```
# Master監視ループ（5秒間隔）
while true; do
  for boss in all_bosses; do
    # 各Bossのステータス確認
    # タスクファイルのチェックカウント
    # アイドル検知と即座のタスク割り当て
  done
  sleep 5
done

# Boss監視ループ（3秒間隔）
while true; do
  for member in team_members; do
    # 各メンバーのステータス確認
    # タスク完了検知
    # アイドル状態の即座検知
    # 次タスクの自動割り当て
  done
  sleep 3
done
```

### エスカレーションルール

1. **Member → Boss**
   - 技術的な質問・相談
   - タスク完了報告
   - アイドル状態報告（最優先）

2. **Boss → Master**
   - チーム間調整が必要な事項
   - アーキテクチャ決定
   - マージタイミング調整
   - リソース不足

3. **緊急エスカレーション**
   - ビルドが壊れた
   - テストが大量に失敗
   - 依存関係の問題
   - セキュリティ問題発見

## 🏁 プロジェクト完了手順

### 1. 全タスク完了確認
```bash
# 全タスクファイルの完了確認
for file in documents/tasks/*.md; do
  echo "=== $file ==="
  grep -E "^\- \[ \]" "$file" || echo "全タスク完了！"
done

# カバレッジ確認
npm run test:coverage  # または適切なコマンド
```

### 2. 最終マージとプッシュ
```bash
# Masterが実行
cd /workspace
git checkout main
git merge --no-ff team/frontend
git merge --no-ff team/backend
git merge --no-ff team/database
git merge --no-ff team/devops

# 最終テスト実行
npm test  # または適切なテストコマンド

# GitHubへプッシュ
git push origin main
```

### 3. 成果物の記録
```bash
# Obsidianへの記録（MCP経由）
claude mcp mcp__obsidian__create_vault_file \
  --filename "projects/$(date +%Y%m%d)_${PROJECT_NAME}.md" \
  --content "# ${PROJECT_NAME} 開発完了レポート..."

# LINE通知（MCP経由）
claude mcp mcp__line-bot__push_text_message \
  --message "🎉 ${PROJECT_NAME} の開発が完了しました！全テスト通過、カバレッジ95%"
```

### 4. tmuxセッション終了
```bash
# Masterペインに終了通知（ペイン1は必ずMaster）
tmux send-keys -t claude-teams.1 "echo '開発完了！セッションを終了します。'" && sleep 2 && tmux send-keys -t claude-teams.1 Enter

# 全ペインにexit送信（Claude Codeセッションを正常終了）
for pane in $(tmux list-panes -t claude-teams -F '#{pane_index}'); do
  tmux send-keys -t claude-teams.$pane "exit" && sleep 0.1 && tmux send-keys -t claude-teams.$pane Enter
done

# セッション終了
sleep 2
tmux kill-session -t claude-teams
```

### 5. クリーンアップ（オプション）
```bash
# worktreeの削除
git worktree remove worktrees/frontend
git worktree remove worktrees/backend
git worktree remove worktrees/database
git worktree remove worktrees/devops

# ブランチの削除
git branch -d team/frontend
git branch -d team/backend
git branch -d team/database
git branch -d team/devops

# 一時ファイルの削除
rm -rf .tmp/ .cache/
```

## 📝 活動ログの作成ルール

### 重要: すべてのコミット時に活動ログを必ず作成

1. **ファイル名形式**: `yyyy-mm-dd_HH-MM-SS_work-description.md`
   - 例: `2024-06-19_14-30-00_add-authentication.md`
   - work-descriptionはkebab-case、最大50文字

2. **保存場所**: `documents/activity_logs/`

3. **作成タイミング**: コミット実行前（必須）

4. **活動ログの内容**:
   - 作業内容の要約
   - 変更したファイルのリスト
   - テスト結果
   - コミットハッシュ（後で追加）

5. **コミット手順**:
   ```bash
   # 活動ログを作成
   mkdir -p documents/activity_logs
   TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
   WORK_DESC="brief-description"
   LOG_FILE="documents/activity_logs/${TIMESTAMP}_${WORK_DESC}.md"
   
   # ログ内容を記述
   cat > "$LOG_FILE" << 'EOF'
   [活動ログテンプレートに従って記述]
   EOF
   
   # コミット実行
   git add .
   git commit -m "feat: [説明]
   
   📝 Activity log: documents/activity_logs/${TIMESTAMP}_${WORK_DESC}.md
   
   🤖 Generated with Claude Code
   Co-Authored-By: Claude <noreply@anthropic.com>"
   
   # コミットハッシュで更新
   COMMIT_HASH=$(git log -1 --format="%H")
   sed -i "s/\[後で追加\]/$COMMIT_HASH/" "$LOG_FILE"
   git add "$LOG_FILE"
   git commit --amend --no-edit
   ```

## 🎯 最重要ポイント

1. **新規プロジェクト = チーム構成のみ**
2. **既存プロジェクト = 通常作業**
3. **documents/requirements.mdは人間用要件定義、documents/tasks/は詳細タスクリスト**
4. **フェーズ分けせず一発で全機能実装**
5. **開発中に必要なタスクは随時追加**
6. **「今後の展開」「ロードマップ」等は作成しない（完成品を一発で作る）**
7. **teams.jsonは必ずdocumentsディレクトリに保存（catコマンド使用）**
8. **生成後は必ず停止（Masterがtmuxで指示を出す）**
9. **UIデザイン作成時は必ずMagic MCPを使用**
10. **通信は必ず階層構造を守る（Master ↔️ Boss ↔️ Member）**
11. **アイドル状態は即座に報告・即座に対応**
12. **テストカバレッジ90%以上、ハードコード禁止**
13. **すべてのコミットに活動ログを作成（documents/activity_logs/）**
