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
   - **バイブコーディング（AIによるプロジェクト作成）に適した技術を優先**:
     - **即座にビジュアルフィードバック**が得られる（HMR/ホットリロード必須）
     - **エラーメッセージが明確**で、AIが問題を特定しやすい
     - **型安全性**があり、コード補完が効く（TypeScript推奨）
     - **設定より規約**で、決まり切った設定が少ない
     - **統合開発環境**が充実している（Vite、Next.js等）
     - **ドキュメントが充実**し、AIが参照しやすい
   - **例**: Webアプリ→その時点で最適なフレームワーク
   - **例**: モバイルアプリ→その時点で最適なクロスプラットフォーム技術

3. **要件定義書とGitHub Issues作成**
   ```bash
   # 必須: documentsディレクトリを作成
   mkdir -p documents
   
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
   
   # GitHub Issuesでタスクを作成（チーム別にラベルを付けて管理）
   # Frontend Team Issues
   gh issue create --title "認証システム: ログイン画面のデザイン作成" \
     --body "Magic MCPを使用してログイン画面のデザインを作成する" \
     --label "team:frontend,priority:high,feature:auth"
   
   gh issue create --title "認証システム: ログインフォームコンポーネント実装" \
     --body "Magic MCPを使用してログインフォームコンポーネントを実装する\n- バリデーション処理を含む\n- E2Eテスト作成 (tests/e2e/login_test.spec.ts)" \
     --label "team:frontend,priority:high,feature:auth"
   
   # Backend Team Issues
   gh issue create --title "API基盤: プロジェクト初期設定" \
     --body "バックエンドプロジェクトの初期設定を行う\n- 依存関係のインストール\n- 基本構造の作成" \
     --label "team:backend,priority:high,feature:setup"
   
   gh issue create --title "認証API: JWT実装" \
     --body "JWT認証の実装\n- トークン生成・検証\n- ユニットテスト作成 (tests/backend/jwt_test.{拡張子})" \
     --label "team:backend,priority:high,feature:auth"
   
   # Database Team Issues
   gh issue create --title "スキーマ設計: ER図作成" \
     --body "データベースのER図を作成する" \
     --label "team:database,priority:high,feature:design"
   
   # DevOps Team Issues
   gh issue create --title "環境構築: Dockerfile作成" \
     --body "本番環境用のDockerfileを作成する" \
     --label "team:devops,priority:high,feature:infrastructure"
   
   # すべてのIssueを確認
   echo "作成されたIssue一覧:"
   gh issue list --label "team:frontend"
   gh issue list --label "team:backend"
   gh issue list --label "team:database"
   gh issue list --label "team:devops"
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

6. **チーム編成とGitHubラベル設定**
   - GitHub Issuesのラベルでチーム別にタスクを管理
   - **タスク量に基づいて各チームの人数を動的に決定**
   - **必須: teams.jsonをdocumentsディレクトリに作成（GitHubラベル情報含む）**
   
   ```bash
   # 各チームのタスク数をカウント
   FRONTEND_TASKS=$(gh issue list --label "team:frontend" --state open | wc -l)
   BACKEND_TASKS=$(gh issue list --label "team:backend" --state open | wc -l)
   DATABASE_TASKS=$(gh issue list --label "team:database" --state open | wc -l)
   DEVOPS_TASKS=$(gh issue list --label "team:devops" --state open | wc -l)
   
   echo "タスク数: Frontend=$FRONTEND_TASKS, Backend=$BACKEND_TASKS, Database=$DATABASE_TASKS, DevOps=$DEVOPS_TASKS"
   
   # タスク比率に基づいて15名（Master除く）を配分
   # 最小1名、最大7名の制約付き
   ```
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
   
   **重要**: 上記の作業（要件定義、技術選定、タスク作成、teams.json作成など）はすべて完了させるが、
   その後は必ず停止してmasterコマンドの起動を待つ。
   Masterロールに切り替わったら、自分では実装せず、各チームのBossに指示を出すだけ。

### teams.json作成の具体例（厳守）

**重要: プロジェクトタイプと規模に応じてチーム構成を調整**

```bash
# teams.json作成コマンド（タスク量に基づく動的配分）
# タスク数に基づいてチーム人数を自動計算
calculate_team_sizes() {
  # 各チームのタスク数を取得
  FRONTEND_TASKS=$(gh issue list --label "team:frontend" --state open | wc -l)
  BACKEND_TASKS=$(gh issue list --label "team:backend" --state open | wc -l)
  DATABASE_TASKS=$(gh issue list --label "team:database" --state open | wc -l)
  DEVOPS_TASKS=$(gh issue list --label "team:devops" --state open | wc -l)
  
  TOTAL_TASKS=$((FRONTEND_TASKS + BACKEND_TASKS + DATABASE_TASKS + DEVOPS_TASKS))
  
  # タスクがない場合はプロジェクトタイプに応じたデフォルト配分
  if [ $TOTAL_TASKS -eq 0 ]; then
    # プロジェクトタイプを確認
    PROJECT_TYPE=$(grep '"project_type"' documents/teams.json 2>/dev/null | cut -d'"' -f4)
    
    case "$PROJECT_TYPE" in
      "mobile-app")
        echo "6 5 2 2"  # Frontend(Mobile) Backend Database DevOps
        ;;
      "web-app"|*)
        echo "5 5 3 2"  # Frontend Backend Database DevOps
        ;;
    esac
    return
  fi
  
  # 15名（Master除く）をタスク比率で配分
  AVAILABLE_MEMBERS=15
  
  # 各チームの人数を計算（最小1名、最大7名）
  calc_members() {
    local tasks=$1
    local members=$((tasks * AVAILABLE_MEMBERS / TOTAL_TASKS))
    [ $members -lt 1 ] && members=1
    [ $members -gt 7 ] && members=7
    echo $members
  }
  
  FRONTEND_MEMBERS=$(calc_members $FRONTEND_TASKS)
  BACKEND_MEMBERS=$(calc_members $BACKEND_TASKS)
  DATABASE_MEMBERS=$(calc_members $DATABASE_TASKS)
  DEVOPS_MEMBERS=$(calc_members $DEVOPS_TASKS)
  
  # 合計が15名になるよう調整
  TOTAL_MEMBERS=$((FRONTEND_MEMBERS + BACKEND_MEMBERS + DATABASE_MEMBERS + DEVOPS_MEMBERS))
  if [ $TOTAL_MEMBERS -ne 15 ]; then
    # タスク数が最も多いチームで調整
    if [ $FRONTEND_TASKS -ge $BACKEND_TASKS ] && [ $FRONTEND_TASKS -ge $DATABASE_TASKS ] && [ $FRONTEND_TASKS -ge $DEVOPS_TASKS ]; then
      FRONTEND_MEMBERS=$((FRONTEND_MEMBERS + 15 - TOTAL_MEMBERS))
    elif [ $BACKEND_TASKS -ge $DATABASE_TASKS ] && [ $BACKEND_TASKS -ge $DEVOPS_TASKS ]; then
      BACKEND_MEMBERS=$((BACKEND_MEMBERS + 15 - TOTAL_MEMBERS))
    elif [ $DATABASE_TASKS -ge $DEVOPS_TASKS ]; then
      DATABASE_MEMBERS=$((DATABASE_MEMBERS + 15 - TOTAL_MEMBERS))
    else
      DEVOPS_MEMBERS=$((DEVOPS_MEMBERS + 15 - TOTAL_MEMBERS))
    fi
  fi
  
  echo "$FRONTEND_MEMBERS $BACKEND_MEMBERS $DATABASE_MEMBERS $DEVOPS_MEMBERS"
}

# チーム人数を計算
read FRONTEND_COUNT BACKEND_COUNT DATABASE_COUNT DEVOPS_COUNT <<< $(calculate_team_sizes)

echo "チーム編成（タスク数に基づく）:"
echo "- Frontend: ${FRONTEND_COUNT}名"
echo "- Backend: ${BACKEND_COUNT}名"
echo "- Database: ${DATABASE_COUNT}名"
echo "- DevOps: ${DEVOPS_COUNT}名"
echo "- 合計: 16名（Master1名 + 開発15名）"

# プロジェクトタイプを確認（デフォルトはweb-app）
PROJECT_TYPE="${PROJECT_TYPE:-web-app}"

# teams.jsonを生成（プロジェクトタイプに関わらず同じチーム名を使用）
cat > documents/teams.json << EOF
{
  "project_name": "プロジェクト名を入力",
  "project_type": "${PROJECT_TYPE}",
  "teams": [
    {"id": "frontend", "name": "Frontend Team", "member_count": ${FRONTEND_COUNT}, "branch": "team/frontend", "github_label": "team:frontend", "playwright_required": true},
    {"id": "backend", "name": "Backend Team", "member_count": ${BACKEND_COUNT}, "branch": "team/backend", "github_label": "team:backend"},
    {"id": "database", "name": "Database Team", "member_count": ${DATABASE_COUNT}, "branch": "team/database", "github_label": "team:database"},
    {"id": "devops", "name": "DevOps Team", "member_count": ${DEVOPS_COUNT}, "branch": "team/devops", "github_label": "team:devops"}
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

| フィールド   | 型     | 説明                 | 例              | 必須 |
| ------------ | ------ | -------------------- | --------------- | ---- |
| id           | string | チームID（英小文字） | "frontend"      | ✅   |
| name         | string | チーム表示名         | "Frontend Team" | ✅   |
| member_count | number | メンバー数（1-4）    | 4               | ✅   |
| branch       | string | ブランチ名           | "team/frontend" | ✅   |
| github_label | string | GitHubラベル名       | "team:frontend" | ✅   |

### teamsオブジェクトのオプションフィールド

| フィールド         | 型      | 説明                           | 例                              | 必須 |
| ------------------ | ------- | ------------------------------ | ------------------------------- | ---- |
| playwright_required | boolean | Playwright MCPの要否           | true                            | ❌   |
| description        | string  | チームの責務説明               | "UI/UX development and testing" | ❌   |

**GitHubラベル設定のガイドライン**:
- **チームラベル**: `team:frontend`, `team:backend`, `team:database`, `team:devops`
- **優先度ラベル**: `priority:high`, `priority:medium`, `priority:low`
- **機能ラベル**: `feature:auth`, `feature:dashboard`, `feature:api`
- **ステータスラベル**: `status:in-progress`, `status:blocked`, `status:review`

**Playwright MCP設定のガイドライン**:
- **Frontend/QA Team**: `playwright_required: true` （UI/E2Eテスト用）
- **Backend/Database/DevOps Team**: `playwright_required: false` または省略（不要）
- 未設定の場合はデフォルトで `false`

**重要**: 上記7つのフィールドのみを含めること。他のフィールド（focus等）は追加しないこと。



### Master Claudeの動作フロー（指示待ちゼロシステム）

```
1. Masterの初期設定（重要）
   **Master（ペイン1）は実装作業を一切行わない。指示と管理のみ。**
   
   初回メッセージ例：
   「私はMaster Claudeです。GitHub Issuesから各チームのタスクを管理します。
   5秒ごとに全Bossを監視し、タスク完了や問題を検知したら即座に対応します。
   
   チーム構成はGitHub Issuesのタスク数に基づいて動的に決定します。
   合計16名（Master1名 + 開発15名）をタスク量に応じて配分します。」

2. タスク管理の準備
   - GitHub Issuesからチーム別のタスクを取得
   - 各チームのBoss（ペイン番号）を確認
   - 依存関係を考慮してタスク実行順序を決定
   
   ```bash
   # チーム別のIssue取得
   gh issue list --label "team:frontend" --state open --json number,title,labels
   gh issue list --label "team:backend" --state open --json number,title,labels
   gh issue list --label "team:database" --state open --json number,title,labels
   gh issue list --label "team:devops" --state open --json number,title,labels
   ```

3. 各チームのBossに初期指示を出す
   例：Frontend Boss（ペイン2）への初期指示
   tmux send-keys -t claude-teams.2 "Frontend Boss、あなたはFrontend Teamのリーダーです。
   worktrees/frontendに移動して、GitHub IssueのラベルがTeam:frontendのタスクから実装を開始してください。
   gh issue list --label 'team:frontend' --state open でタスクを確認し、メンバーに割り振ってください。"
   sleep 0.5
   tmux send-keys -t claude-teams.2 Enter

4. 無限監視ループを開始
   - 5秒ごとに全Bossの状態を確認
   - タスク完了、質問、問題、アイドル状態を検知
   - 即座に次のタスクを割り当て
   
   **重要な役割分担**：
   - **Master（pane 1）**: 
     - 全体統括とBossへの指示のみ
     - GitHub Issuesの更新（完了したらclose、新規タスクはcreate）
     - メインブランチへのマージ作業
     - **実装作業は一切行わない**
     - **開発環境の構築も行わない**
     - **技術調査や要件定義も直接行わない（Bossに指示）**
   - **Boss（各チームの1人目）**: チーム内タスク管理、メインブランチをworktreeにマージ、レビュー及びMemberへの指示、コミットのみ、Issue番号の管理
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
   - **tmuxのペイン名を変更すること（絶対禁止）**
   - **tmux select-pane -T コマンドの使用（絶対禁止）**
   - **tmux rename-window コマンドの使用（絶対禁止）**

### 📊 Master-Boss-Member ワークフロー

1. **Master**: GitHub Issuesから未完了タスクを取得
   ```bash
   # 各チームの未完了タスクを確認
   gh issue list --label "team:frontend" --state open
   gh issue list --label "team:backend" --state open
   ```
2. **Master → Boss**: tmuxコマンドでタスク指示（Issue番号を含む）
   ```bash
   # MasterからFrontend Boss（ペイン2）への指示例
   tmux send-keys -t claude-teams.2 "Frontend Boss、Issue #23の認証システムの実装を開始してください。詳細は gh issue view 23 で確認し、メンバーに割り振ってください。"
   sleep 0.5
   tmux send-keys -t claude-teams.2 Enter
   ```
3. **Boss → Members**: タスクを分配し、3秒ごとに監視
   ```bash
   # Frontend Boss（ペイン2）からMember 2（ペイン3）への指示例
   tmux send-keys -t claude-teams.3 "Member 2、Issue #23のログインフォームコンポーネントを作成してください。src/components/auth/LoginForm.tsxに実装し、バリデーション処理も含めてください。完了したらテストを作成して報告してください。"
   sleep 0.5
   tmux send-keys -t claude-teams.3 Enter
   ```
4. **Members**: 実装作業（アイドル時は即報告）
5. **Members → Boss**: 完了/質問/アイドル報告
6. **Boss**: レビュー & テスト & コミット（Issue番号をコミットメッセージに含める）
7. **Boss → Master**: チーム進捗報告（Issue番号含む）
8. **Master**: マージ & GitHub Issue更新
   ```bash
   # Issueを閉じる
   gh issue close 23 --comment "実装完了しました。コミット: abc123"
   ```
9. **ループ**: 全Issueがcloseされるまで継続

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
   
   # 全テスト通過後、活動ログを作成してからコミット（Issue番号含む）
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
   
   # 4. 活動ログを含めてコミット（Issue番号を含める）
   git add .
   git commit -m "feat: 認証システム実装 (#23)
   
   Closes #23
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
    - GitHub Issueをクローズ
      ```bash
      gh issue close 23 --comment "実装完了: ${COMMIT_HASH}"
      ```
    - 新規タスク発生時: GitHub Issueを作成
      ```bash
      gh issue create --title "新規タスク名" --body "詳細説明" --label "team:frontend,priority:medium"
      ```
    - ブランチをメインにマージ
    - 即座に次のタスクセットをBossに割り当て

12. 全タスクが完了するまで4-10を繰り返す
    目標: 全GitHub Issueがクローズされること
    ```bash
    # 完了確認
    gh issue list --state open | wc -l  # 0になればすべて完了
    ```

13. 12まで完了した時に`git push`を行いobsidianにメモを作成し、lineに通知を行う
```


#### タスク管理のベストプラクティス
- **GitHub Issues中心**: すべてのタスクはGitHub Issuesで管理
- **ラベル活用**: team:*, priority:*, feature:*, status:* ラベルで整理
- **Issue番号追跡**: コミットメッセージに必ずIssue番号を含める
- **実現可能性重視**: 既存技術で確実に実装できるもののみ
- **完全実装主義**: MVP思考ではなく、完成品を一発で作る
- **動的タスク追加**: 開発中に必要なタスクは即座にIssue作成
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


## 📊 動的チーム構成（タスク量ベース）

### チーム人数の動的配分
- **Master**: 1名（全体統括・指示のみ）
- **開発チーム**: 15名（タスク量に応じて配分）
  - Frontend Team: 1-7名
  - Backend Team: 1-7名
  - Database Team: 1-7名
  - DevOps Team: 1-7名

**合計**: 16名（Master1名 + 開発15名）

### 配分アルゴリズム
1. **GitHub Issuesのタスク数をカウント**
   - 各チームラベルごとのオープンIssue数を集計
2. **タスク比率で人数を配分**
   - タスク数の比率に応じて15名を配分
   - 最小1名、最大7名の制約付き
3. **自動調整**
   - 合計が15名になるよう最もタスクが多いチームで調整
4. **プロジェクトタイプ別デフォルト配分**（タスクがない場合）
   - **Webアプリ**: Frontend5名、Backend5名、Database3名、DevOps2名
   - **スマホアプリ**: Frontend(Mobile)6名、Backend5名、Database2名、DevOps2名
   
### スマホアプリ開発時の特徴
- **Frontend Team = Mobile Team**: iOS/Android開発に特化
- **人数を多めに配分**: UI/UX、端末対応、OS対応など作業量が多い
- **Database**: モバイル向けに最適化されたAPIのため少人数
- **DevOps**: アプリストア配信中心のため少人数

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

## 📝 GitHub Issue作成ガイドライン

### Issueの粒度と構成
タスクは機能単位で分割し、各タスクは1-4時間で完了できる粒度にする

### Issue作成例

#### Frontend Team Issues
```bash
# 基本UI構築
gh issue create --title "基本レイアウト: ワイヤーフレーム作成" \
  --body "プロジェクト全体のワイヤーフレームを作成する" \
  --label "team:frontend,priority:high,feature:ui"

gh issue create --title "基本レイアウト: レイアウトコンポーネント実装" \
  --body "Magic MCPを使用してレイアウトコンポーネントを作成する\n- ヘッダー\n- フッター\n- サイドバー" \
  --label "team:frontend,priority:high,feature:ui"

# 機能実装
gh issue create --title "フォーム: ユーザー登録フォーム実装" \
  --body "Magic MCPを使用してユーザー登録フォームを作成\n- バリデーション処理\n- エラーハンドリング\n- テスト作成" \
  --label "team:frontend,priority:high,feature:auth"
```

#### Backend Team Issues  
```bash
# API実装
gh issue create --title "API: エンドポイント設計" \
  --body "RESTful APIのエンドポイント設計\n- ルーティング構成\n- バージョニング戦略" \
  --label "team:backend,priority:high,feature:api"

gh issue create --title "API: 認証ミドルウェア実装" \
  --body "JWT認証ミドルウェアの実装\n- トークン検証\n- エラーハンドリング\n- テスト作成" \
  --label "team:backend,priority:high,feature:auth"
```

### ラベル管理
```bash
# 必須ラベルの作成
gh label create "team:frontend" --color "0052CC" --description "Frontend team tasks"
gh label create "team:backend" --color "5319E7" --description "Backend team tasks"
gh label create "team:database" --color "006B75" --description "Database team tasks"
gh label create "team:devops" --color "E99695" --description "DevOps team tasks"

gh label create "priority:high" --color "D93F0B" --description "High priority"
gh label create "priority:medium" --color "FBCA04" --description "Medium priority"
gh label create "priority:low" --color "0E8A16" --description "Low priority"

gh label create "status:in-progress" --color "1D76DB" --description "Work in progress"
gh label create "status:blocked" --color "B60205" --description "Blocked by dependency"
gh label create "status:review" --color "C2E0C6" --description "Ready for review"
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
Issue: #23
タスク: [タスク名]
状態: 完了
テスト: 作成済み・実行済み
場所: tests/e2e/[ファイル名]
次タスク待機中

【質問・相談】
Issue: #23
タスク: [タスク名]
内容: [具体的な質問]
提案: [自分の案がある場合]

【アイドル報告】※即座に報告
状態: アイドル
最終Issue: #23
次タスク要求
```

#### Boss → Master
```
【チーム進捗報告】
チーム: [チーム名]
完了Issue: 
- #23 認証システム実装（テスト済み）
- #24 ダッシュボード実装（テスト済み）
進行中: 
- #25 API実装（Member1）
- #26 DB設計（Member2）
カバレッジ: 92%
コミット準備: OK

【問題エスカレーション】
チーム: [チーム名]
Issue: #23
問題: [具体的な問題]
影響: [影響範囲]
提案: [解決案]
```

### ステータス確認方法

#### タスク進捗の可視化
```bash
# GitHub Issuesで管理
# チーム別の進捗確認
gh issue list --label "team:frontend" --json number,title,state,labels
gh issue list --label "team:backend" --json number,title,state,labels

# ステータス別の確認
gh issue list --label "status:in-progress" --json number,title,assignees
gh issue list --label "status:blocked" --json number,title,body

# 完了タスクの確認
gh issue list --state closed --label "team:frontend" --limit 10
```

#### 監視ループの実装
```
# Master監視ループ（5秒間隔）
while true; do
  for team in frontend backend database devops; do
    # 各チームの未完了Issue確認
    OPEN_ISSUES=$(gh issue list --label "team:${team}" --state open --json number)
    
    # 進行中Issue確認
    IN_PROGRESS=$(gh issue list --label "team:${team},status:in-progress" --state open --json number)
    
    # アイドル検知と即座のタスク割り当て
    if [ -z "$IN_PROGRESS" ] && [ -n "$OPEN_ISSUES" ]; then
      # Bossに新しいタスクを割り当て
      assign_new_task_to_boss $team
    fi
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

### tmux send-keys ベストプラクティス（重要）

**指示送信時の必須ルール**：

1. **テキスト入力とEnter実行を分離**
   ```bash
   # ◎ 正しい例
   tmux send-keys -t claude-teams.2 "認証機能を実装してください"
   sleep 0.5  # テキスト入力完了を待つ
   tmux send-keys -t claude-teams.2 Enter
   
   # × 悪い例（改行や長いテキストで失敗する可能性）
   tmux send-keys -t claude-teams.2 "認証機能を実装してください" && sleep 0.1 && tmux send-keys -t claude-teams.2 Enter
   ```

2. **送信確認を実施**
   ```bash
   # 指示送信後に確認
   sleep 2
   PANE_CONTENT=$(tmux capture-pane -t claude-teams.2 -p | tail -20)
   if echo "$PANE_CONTENT" | grep -q "Human:"; then
     echo "✓ 指示が正常に送信されました"
   else
     echo "✗ 指示送信に失敗。再度Enterを送信します"
     tmux send-keys -t claude-teams.2 Enter
   fi
   ```

3. **リトライ処理を実装**
   - 最大3回まで自動リトライ
   - 各リトライで2秒待機
   - 失敗時はEnterのみ再送信

4. **長いタスクの場合**
   ```bash
   # タスクの最初の20文字を保存（確認用）
   TASK_PREFIX=$(echo "$TASK" | head -c 20)
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
# 全Issueの完了確認
echo "=== 未完了Issue確認 ==="
OPEN_ISSUES=$(gh issue list --state open | wc -l)
if [ "$OPEN_ISSUES" -eq 0 ]; then
  echo "全Issue完了！"
else
  echo "未完了Issue: $OPEN_ISSUES 件"
  gh issue list --state open
fi

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
tmux send-keys -t claude-teams.1 "echo '開発完了！セッションを終了します。'"
sleep 0.5  # テキスト入力完了を待つ
tmux send-keys -t claude-teams.1 Enter

# 全ペインにexit送信（Claude Codeセッションを正常終了）
for pane in $(tmux list-panes -t claude-teams -F '#{pane_index}'); do
  tmux send-keys -t claude-teams.$pane "exit"
  sleep 0.5  # テキスト入力完了を待つ
  tmux send-keys -t claude-teams.$pane Enter
  sleep 0.1  # 次のペインへ移る前の小休止
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
   
   # ログ内容を記述（Issue番号含む）
   cat > "$LOG_FILE" << 'EOF'
   [活動ログテンプレートに従って記述]
   関連Issue: #23, #24
   EOF
   
   # コミット実行（Issue番号を含める）
   git add .
   git commit -m "feat: [説明] (#23, #24)
   
   Closes #23, #24
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
3. **documents/requirements.mdは人間用要件定義、GitHub Issuesで詳細タスク管理**
4. **フェーズ分けせず一発で全機能実装**
5. **開発中に必要なタスクは随時GitHub Issue作成**
6. **「今後の展開」「ロードマップ」等は作成しない（完成品を一発で作る）**
7. **teams.jsonは必ずdocumentsディレクトリに保存（GitHubラベル情報含む）**
8. **生成後は必ず停止（Masterがtmuxで指示を出す）**
9. **UIデザイン作成時は必ずMagic MCPを使用**
10. **通信は必ず階層構造を守る（Master ↔️ Boss ↔️ Member）**
11. **アイドル状態は即座に報告・即座に対応**
12. **テストカバレッジ90%以上、ハードコード禁止**
13. **すべてのコミットに活動ログとIssue番号を含める**
14. **タスク管理はすべてGitHub Issuesで行う**
