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
   ```bash
   # 選定した技術スタックに基づいて開発環境を構築
   # 例: Next.js + Supabase + TypeScriptプロジェクトの場合
   npx create-next-app@latest . --typescript --tailwind --app --eslint
   
   # 基本的な依存関係のインストール
   npm install
   
   # ESLint + Prettierの設定
   npm install --save-dev prettier eslint-config-prettier eslint-plugin-prettier @typescript-eslint/eslint-plugin @typescript-eslint/parser
   
   # .eslintrc.json作成
   cat > .eslintrc.json << 'EOF'
   {
     "extends": [
       "next/core-web-vitals",
       "prettier"
     ],
     "plugins": ["prettier"],
     "rules": {
       "prettier/prettier": "error",
       "@typescript-eslint/no-unused-vars": "error",
       "@typescript-eslint/no-explicit-any": "warn"
     }
   }
   EOF
   
   # .prettierrc作成
   cat > .prettierrc << 'EOF'
   {
     "semi": true,
     "trailingComma": "es5",
     "singleQuote": true,
     "printWidth": 100,
     "tabWidth": 2,
     "useTabs": false
   }
   EOF
   
   # Supabaseのセットアップ
   npm install @supabase/supabase-js @supabase/ssr @supabase/auth-ui-react @supabase/auth-ui-shared
   
   # 環境変数ファイル作成
   cat > .env.local << 'EOF'
   NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
   EOF
   
   # Supabaseクライアント作成
   mkdir -p lib
   cat > lib/supabase.ts << 'EOF'
   import { createBrowserClient } from '@supabase/ssr'
   
   export function createClient() {
     return createBrowserClient(
       process.env.NEXT_PUBLIC_SUPABASE_URL!,
       process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
     )
   }
   EOF
   
   # その他の便利な開発ツール
   npm install --save-dev husky lint-staged
   npx husky init
   
   # pre-commitフック設定
   cat > .husky/pre-commit << 'EOF'
   #!/usr/bin/env sh
   . "$(dirname -- "$0")/_/husky.sh"
   
   npx lint-staged
   EOF
   chmod +x .husky/pre-commit
   
   # lint-staged設定をpackage.jsonに追加
   npm pkg set "lint-staged[*.{js,jsx,ts,tsx}]"="eslint --fix"
   npm pkg set "lint-staged[*.{js,jsx,ts,tsx,json,css,md}]"="prettier --write"
   
   # 開発サーバーの起動
   npm run dev
   
   # Playwrightで起動確認
   npm install --save-dev @playwright/test
   npx playwright install chromium --with-deps
   
   # 起動確認テスト
   mkdir -p tests/e2e
   cat > tests/e2e/startup.spec.ts << 'EOF'
   import { test, expect } from '@playwright/test';
   
   test('開発サーバーが正常に起動する', async ({ page }) => {
     await page.goto('http://localhost:3000');
     await expect(page).toHaveTitle(/.*Next.js.*/);
   });
   EOF
   
   # playwright.config.ts作成
   cat > playwright.config.ts << 'EOF'
   import { defineConfig, devices } from '@playwright/test';
   
   export default defineConfig({
     testDir: './tests/e2e',
     fullyParallel: true,
     forbidOnly: !!process.env.CI,
     retries: process.env.CI ? 2 : 0,
     workers: process.env.CI ? 1 : undefined,
     reporter: 'html',
     use: {
       baseURL: 'http://localhost:3000',
       trace: 'on-first-retry',
       headless: true,
     },
     projects: [
       {
         name: 'chromium',
         use: { ...devices['Desktop Chrome'] },
       },
     ],
     webServer: {
       command: 'npm run dev',
       port: 3000,
       reuseExistingServer: !process.env.CI,
     },
   });
   EOF
   
   # テスト実行
   npx playwright test --headed=false
   
   # 起動確認ができたら開発サーバーを停止
   # Ctrl+C または pkill -f "next dev"
   
   # VSCode設定（オプション）
   mkdir -p .vscode
   cat > .vscode/settings.json << 'EOF'
   {
     "editor.formatOnSave": true,
     "editor.defaultFormatter": "esbenp.prettier-vscode",
     "editor.codeActionsOnSave": {
       "source.fixAll.eslint": true
     }
   }
   EOF
   
   # 環境構築完了をコミット
   git add .
   git commit -m "feat: 開発環境構築完了"
   
   # LINE通知（オプション）
   echo "開発環境構築が完了しました" | claude mcp mcp__line-bot__push_text_message
   ```

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

7. **🛑 ここで必ず停止！**

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

### teams.jsonの必須フィールド

| フィールド   | 型     | 説明               | 例           |
| ------------ | ------ | ------------------ | ------------ |
| project_name | string | プロジェクト名     | "〇〇アプリ" |
| project_type | string | プロジェクトタイプ | "web-app"    |
| teams        | array  | チーム配列         | []           |
****
### teamsオブジェクトの必須フィールド

| フィールド   | 型     | 説明                 | 例              |
| ------------ | ------ | -------------------- | --------------- |
| id           | string | チームID（英小文字） | "frontend"      |
| name         | string | チーム表示名         | "Frontend Team" |
| member_count | number | メンバー数（1-4）    | 4               |
| branch       | string | ブランチ名           | "team/frontend" |



### Master Claudeの動作フロー（指示待ちゼロシステム）

```
1. documents/teams.jsonを読み込んでtmuxセッションを起動
   - 各チームのペインを作成（1人目がBoss）
   - 全員でclaude --dangerously-skip-permissionsを起動

2. documents/tasks/を参照してタスク管理
   ls documents/tasks/ でタスクファイル一覧を確認
   cat documents/tasks/*.md で各チームのタスクを確認

3. 未完了タスク（- [ ]）を抽出して優先順位付け
   依存関係を考慮して実行可能なタスクを選定

4. 各チームのBossに指示を出す（階層的指示システム）
   Master → Boss → メンバーの流れで指示が伝達される
   例: 
   tmux send-keys -t claude-teams:1.2 "認証システムのタスクを進めてください"
   sleep 0.5
   
   tmux send-keys -t claude-teams:1.2 Enter

5. Masterは常にBossを監視（無限ループ処理）
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

9. Bossがチームタスク完了後、ブランチでコミット
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
4. **テスト実行コマンド（言語別）**
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

## 📝 タスクリスト作成例

### SNSアプリの場合（完全版・一発実装）
```markdown
### 🎨 Frontend Tasks (50-70タスク想定)
#### 認証システム完全版
- [ ] ログイン画面のワイヤーフレーム作成
- [ ] ログインフォームのHTML構造作成（Magic MCP使用）
- [ ] フォームのスタイリング（Magic MCP使用）
- [ ] メールアドレスのバリデーション実装
- [ ] パスワードの表示/非表示トグル実装（Magic MCP使用）
- [ ] ソーシャルログイン（Google）実装（Magic MCP使用）
- [ ] ソーシャルログイン（Twitter）実装（Magic MCP使用）
- [ ] 2段階認証UI実装（Magic MCP使用）
- [ ] パスワードリセット完全フロー（Magic MCP使用）
- [ ] メール認証フロー実装
- [ ] [新規追加] reCAPTCHA統合
- [ ] [新規追加] ログイン履歴表示機能（Magic MCP使用）

#### 完全なタイムライン機能
- [ ] タイムラインのレイアウト設計（Magic MCP使用）
- [ ] 投稿カードコンポーネント作成（Magic MCP使用）
- [ ] リアルタイム更新（WebSocket）
- [ ] 無限スクロール実装
- [ ] 画像アップロード機能（Magic MCP使用）
- [ ] 動画アップロード機能（Magic MCP使用）
- [ ] GIF対応
- [ ] 絵文字ピッカー実装（Magic MCP使用）
- [ ] メンション機能（@ユーザー名）
- [ ] ハッシュタグ機能
- [ ] 引用投稿機能（Magic MCP使用）
- [ ] [新規追加] 投稿の予約機能（Magic MCP使用）
- [ ] [新規追加] 下書き保存機能

### 開発中の動的タスク追加例
- [ ] [新規追加] エラーバウンダリ実装
- [ ] [新規追加] パフォーマンス最適化
- [ ] [新規追加] アクセシビリティ対応
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

---

**Mission**: 世界を変える完成品を、最高の品質で、一発で作っていこう！！

※ 「今後の展開」「ロードマップ」「将来的には」等の言葉は使わない。現在実装できる最高の完成品を作ろう！！