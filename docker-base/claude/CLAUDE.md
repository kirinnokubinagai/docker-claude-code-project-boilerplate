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
   - 要件整理とタイプ判定（web/mobile/ai/blockchain等）
   - **全機能を一発で実装する前提で機能洗い出し**
   - MVPやフェーズ分けはしない（完全版を作る）
   - 今後の展開やロードマップは作らない

2. **技術選定**
   - Web検索で最新トレンドを調査（直近半年）
   - Context7で最新バージョン確認
   - VibeCodingに適した技術スタック決定
   - **プロダクション完成形を想定した技術選定**
   - 現在実装できる最高の機能をすべて盛り込む

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
     - 例: `npx create-next-app@latest .` / `npm create vite@latest .` 等
   - package.jsonに必要なスクリプトを追加
     - `npm run dev` - 開発サーバー起動
     - `npm run build` - ビルド実行
     - `npm run test` - テスト実行
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
   - ESLint/Prettier等の開発ツールを設定
   - 開発サーバーを起動（`npm run dev`）してPlaywrightで動作確認
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
   git worktree add worktrees/team-frontend team/frontend
   git worktree add worktrees/team-backend team/backend
   git worktree add worktrees/team-database team/database
   git worktree add worktrees/team-devops team/devops
   
   # 確認
   git worktree list
   ```

8. **🛑 ここで必ず停止！**

### teams.json作成の具体例（厳守）

**重要: 以下のコマンドをそのままコピー＆ペーストして実行**

```bash
# 実際の作成コマンド例（Webアプリの場合）
# このコマンドを実行すると teams.json が作成されます
cat > documents/teams.json << 'EOF'
{
  "project_name": "YourProjectName",
  "project_type": "web-app",
  "teams": [
    {
      "id": "frontend",
      "name": "Frontend Team",
      "member_count": 4,
      "branch": "team/frontend"
    },
    {
      "id": "backend",
      "name": "Backend Team",
      "member_count": 4,
      "branch": "team/backend"
    },
    {
      "id": "database",
      "name": "Database Team",
      "member_count": 3,
      "branch": "team/database"
    },
    {
      "id": "devops",
      "name": "DevOps Team",
      "member_count": 3,
      "branch": "team/devops"
    }
  ]
}
EOF

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
   - Frontend Team: worktrees/team-frontend
   - Backend Team: worktrees/team-backend
   - Database Team: worktrees/team-database
   - DevOps Team: worktrees/team-devops
   
   # 各Bossが最初に実行
   cd /workspace/worktrees/team-frontend  # 自分のチームのworktreeに移動
   pwd  # 確認: /workspace/worktrees/team-frontend

3. documents/tasks/を参照してタスク管理
   ls documents/tasks/ でタスクファイル一覧を確認
   cat documents/tasks/*.md で各チームのタスクを確認

4. 未完了タスク（- [ ]）を抽出して優先順位付け
   依存関係を考慮して実行可能なタスクを選定

5. 各チームのBossに指示を出す（階層的指示システム）
   Master → Boss → メンバーの流れで指示が伝達される
   
   **重要な役割分担**：
   - **Master（pane 0）**: 全体統括、タスク配分、マージ作業のみ
   - **Boss（各チームの1人目）**: チーム内タスク管理、レビュー、コミットのみ
   - **Member（各チームの2-4人目）**: 実装作業のみ
   
   **禁止事項**：
   - BossやMemberがMasterの役割（他チームへの指示、マージ等）を行うこと
   - MemberがBossの役割（レビュー、コミット等）を行うこと
   - 各チームは自分のworktree内でのみ作業すること
   
   例: 
   tmux send-keys -t claude-teams:1.2 "認証システムのタスクを進めてください"
   sleep 0.5
   
   tmux send-keys -t claude-teams:1.2 Enter

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

6. Bossは部下を常に監視（無限ループ処理）
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

7. 確認フロー（重要）
   - メンバー → Boss: タスク完了報告、質問、レビュー依頼
   - **メンバー → Boss: アイドル状態になったら即座に報告（指示待ちゼロ）**
   - Boss → Master: チームタスク完了報告、方針確認、コミット準備
   - Master → Boss: マージ、次のタスク指示

8. テスト実施（必須）
   - 各タスク完了時に必ずテストを作成・実行
   - UIタスク: Playwright MCPを使用してE2Eテスト (tests/e2e/auth_test.spec.ts)
     ```bash
     # オプション1: Playwright MCPサーバー経由（Chromium不要）
     # MCPコマンドで直接ブラウザを操作
     claude mcp mcp__mcp-playwright__browser_navigate --url "http://localhost:3000"
     claude mcp mcp__mcp-playwright__browser_snapshot
     claude mcp mcp__mcp-playwright__browser_click --element "Login button" --ref "button[type=submit]"
     ```
   - APIタスク: 言語に応じたユニットテスト (tests/backend/auth_test.拡張子)
   - ロジック: 言語に応じたユニットテスト (tests/unit/validation_test.拡張子)
   - テストが全て通過するまでコミット禁止

9. Bossがチームタスク完了後、自分のworktreeでコミット
   # 必ず自分のworktreeで作業していることを確認
   pwd  # 例: /workspace/worktrees/team-frontend
   
   # テスト実行（言語に応じたコマンド）
   npm test          # JavaScript/TypeScript
   pytest tests/     # Python
   go test ./...     # Go
   cargo test        # Rust
   
   # 全テスト通過後
   git add . && git commit -m "feat: 認証システム実装"

10. MasterがBossからの報告を受けてマージ
    - テストの実行確認（テストなしのコミットは却下）
    - documents/tasks/内の該当タスクファイルを更新（完了: - [ ] を - [x] に変更）
    - 新規タスク発生: 適切な場所に追加
    - ブランチをメインにマージ
    - 即座に次のタスクセットをBossに割り当て

11. 全タスクが完了するまで4-10を繰り返す
    目標: documents/tasks/内の全タスクファイルの全項目が [x] になること

12. 11まで完了した時に`git push`を行いobsidianにメモを作成し、lineに通知を行う
```

#### コミュニケーションフローの例

```
Master: "Frontend Teamのboss、認証システムの実装を開始してください"
（Masterは監視ループ継続中...）
↓
Frontend Boss: "了解しました。メンバーにタスクを割り当てます"

Master: （監視中 - 5秒後） "Frontend Bossのステータス: タスク割り当て中。問題なし。"
↓
Frontend Boss → Member1: "ログインフォームのUI実装をお願いします"
Frontend Boss → Member2: "バリデーション処理を実装してください"
Frontend Boss → Member3: "エラーメッセージ表示機能を実装してください"

Boss: （監視ループ - 3秒後） "全メンバーのステータス確認中..."
↓
Member1 → Boss: "ログインフォーム完成しました。テストも作成済みです。レビューお願いします"

Boss: （監視ループで即検知） "Member1のタスク完了を検知。次のタスクを即座に割り当て"
Boss: "テストを実行して確認します... （プロジェクトのテストコマンドを実行）"
Boss: "テスト通過確認。次はパスワードリセット画面を実装してください"
（指示待ちゼロ、Member1に即座に次タスク）

Member2 → Boss: "質問があります。バリデーションのエラーメッセージはどのように表示しますか？"
Boss: （監視ループで即検知） "エラーメッセージはトースト通知で表示してください"

Member3 → Boss: "アイドル状態になりました。次のタスクをください"
Boss: （監視ループで即検知） "メール認証フロー実装をお願いします"

Master: （監視中 - 即検知） "Frontend Bossの活発な管理を確認。問題なし。"
↓
Frontend Boss → Master: "認証システムの基本機能完了しました。全テスト通過確認済み。コミット準備OKです"

Master: （監視ループで即検知） "報告受領。コミット許可。次のタスクセットを準備済みです"
Master: "テストカバレッジを確認... 了解。コミットしてください"
↓
Frontend Boss: 
"（プロジェクトのテストコマンドを実行） # npm test / pytest / go test 等"
"git add ."
"git commit -m 'feat: 認証システムのUI実装完了（テスト含む）'"
↓
Master: "テストカバレッジ確認。メインブランチにマージします"
Master: "次はダッシュボード機能を実装してください"
（Masterは監視ループを継続し、各Bossの状態を5秒ごとにチェック）
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
   # Playwright E2E (ヘッドレスモード)
   npx playwright test tests/e2e/ --headed=false
   # またはプロジェクトでの設定
   npm install --save-dev @playwright/test
   npx playwright install chromium --with-deps
   
   # JavaScript/TypeScript
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
5. **全テスト通過後にコミット**

## 🔧 技術選定基準

### 評価ポイント

1. **最新性**: 最新安定版を使用
2. **実績**: プロダクション実績
3. **DX**: 開発体験の良さ
4. **性能**: ベンチマーク結果
5. **保守性**: 長期的なメンテナンス


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

# Playwrightテスト実行（ヘッドレス）
# プロジェクトディレクトリで:
npm install --save-dev @playwright/test
npx playwright install chromium --with-deps
npx playwright test --headed=false

# テストコード例:
# tests/e2e/example.spec.ts
import { test, expect } from '@playwright/test';

test('ログイン機能', async ({ page }) => {
  await page.goto('http://localhost:3000');
  await page.fill('input[name="email"]', 'test@example.com');
  await page.fill('input[name="password"]', 'password');
  await page.click('button[type="submit"]');
  await expect(page).toHaveURL('/dashboard');
});
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
# 全ペインに終了通知
tmux send-keys -t claude-teams:0 "echo '開発完了！セッションを終了します。'" Enter
sleep 2

# セッション終了
tmux kill-session -t claude-teams
```

### 5. クリーンアップ（オプション）
```bash
# worktreeの削除
git worktree remove worktrees/team-frontend
git worktree remove worktrees/team-backend
git worktree remove worktrees/team-database
git worktree remove worktrees/team-devops

# ブランチの削除
git branch -d team/frontend
git branch -d team/backend
git branch -d team/database
git branch -d team/devops

# 一時ファイルの削除
rm -rf .tmp/ .cache/
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
