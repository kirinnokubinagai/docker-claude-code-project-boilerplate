# Claude Code Company - プロジェクト設定（Full MCP版）

このファイルはClaude Codeが自動的に参照し、tmux環境での親子プロセス管理と**全MCPサーバー統合**によってプロジェクトのワークフローに従って作業を行うための指示書です。

## MCP統合組織構造

### 利用可能MCPサーバー（全プロセス共通）
1. **Supabase MCP** - データベース、認証、プロジェクト管理
2. **Playwright MCP** - ブラウザ自動化、E2Eテスト、スクリーンショット
3. **Obsidian MCP** - ドキュメント管理、ナレッジベース、セマンティック検索
4. **Stripe MCP** - 決済処理、サブスクリプション、顧客管理
5. **LINE Bot MCP** - メッセージ送信、通知、Flexメッセージ
6. **Context7 MCP** - 最新ライブラリドキュメント、API仕様

### 親プロセス（Manager）
- **役割**: プロジェクト全体統括、要件定義、進捗管理、品質管理
- **pane**: Main pane（通常pane 0）
- **責任**: 戦略決定、タスク分散、最終チェック、報告受領
- **利用MCP**: 全MCPサーバーにアクセス可能

### 子プロセス（Workers）- 各部門専用MCP付き

#### **Frontend部門** (pane 1)
- **担当**: UI/UX開発、コンポーネント作成、フロントエンドテスト
- **専用MCP**: 
  - Playwright: E2Eテスト、ブラウザ自動化
  - Obsidian: UIドキュメント、デザインシステム
  - Context7: React/Vue/Next.js最新情報
  - Stripe: 決済UI実装

#### **Backend部門** (pane 2)
- **担当**: API開発、サーバーサイドロジック、認証システム
- **専用MCP**:
  - Supabase: データベース操作、認証API
  - Stripe: 決済処理、Webhook処理
  - Context7: Node.js/Python/Go最新情報
  - LINE Bot: 通知システム

#### **Database部門** (pane 3)
- **担当**: DB設計、マイグレーション、データ管理、最適化
- **専用MCP**:
  - Supabase: PostgreSQL操作、マイグレーション
  - Obsidian: DB設計ドキュメント、ER図
  - LINE Bot: 通知システム

#### **DevOps部門** (pane 4)
- **担当**: CI/CD、デプロイ、インフラ管理、監視
- **専用MCP**:
  - Supabase: プロジェクト管理、環境設定
  - Playwright: 統合テスト、パフォーマンステスト
  - LINE Bot: デプロイ通知、アラート
  - Obsidian: インフラドキュメント

## 必須ワークフロー（MCP統合版）

### 1. 要件定義フェーズ（親プロセス主導）

親プロセスが新しいプロジェクトや機能の説明を受けたら：

1. **技術調査（Context7 MCP使用）**
   ```bash
   # プロンプトに必ず追加
   "最新の技術トレンドを調査してください。use context7"
   ```

2. **要件整理（Obsidian MCP使用）**
   - Context7で最新ライブラリ確認
   - Obsidianで要件定義ドキュメント作成
   - CLI/CI/CDでリリース可能な構成選定

3. **タスク分散（全MCPアクセス権限で）**
   ```bash
   # 各部門に専用MCPツールセット付きタスクを分散
   tmux send-keys -t %27 "あなたはFrontend部門です。担当MCP: Playwright, Obsidian, Context7, Stripe。[具体的なタスク内容]。完了時は tmux send-keys -t %22 '[Frontend] タスク完了: [内容]' Enter で報告。" Enter
   
   tmux send-keys -t %28 "あなたはBackend部門です。担当MCP: Supabase, Stripe, Context7, LINE Bot。[具体的なタスク内容]。完了時は tmux send-keys -t %22 '[Backend] タスク完了: [内容]' Enter で報告。" Enter
   ```

4. **初期設定（Supabase MCP使用）**
   - Supabase MCPでプロジェクト作成
   - git init、git commit
   - git worktreeによる細分化

### 2. 開発環境構築フェーズ（DevOps部門主導）

DevOps部門が以下を実行：
- **Supabase MCP**: プロジェクト・データベース設定
- **Playwright MCP**: テスト環境確認
- **LINE Bot MCP**: 構築完了通知
- **Obsidian MCP**: 環境構築ドキュメント作成

### 3. 実装フェーズ（各部門並列実行）

#### Frontend部門の実装例
```bash
# Context7で最新情報取得
"Next.js 15のapp router、Server Actionsを使った認証システム実装方法。use context7"

# Playwrightでテスト
"作成したコンポーネントのE2Eテストを実装"

# Obsidianでドキュメント化
"コンポーネント仕様をObsidianに記録"

# Stripe決済UI
"Stripe Elementsを使った決済フォーム実装"
```

#### Backend部門の実装例
```bash
# Supabaseで認証API
"Supabase Authを使った認証システム構築"

# StripeでWebhook処理
"Stripe Webhookハンドラー実装"

# Context7で最新情報
"Node.js Express最新のベストプラクティス。use context7"

# LINE Bot通知
"決済完了時のLINE通知システム"
```

#### Database部門の実装例
```bash
# Supabaseでテーブル設計
"ユーザー、商品、注文のリレーショナル設計"

# マイグレーション実行
"Supabase Migration実行・管理"

# Obsidianで設計書
"ER図とDB仕様書をObsidianで作成"
```

#### DevOps部門の実装例
```bash
# Supabaseプロジェクト管理
"開発・ステージング・本番環境設定"

# Playwright統合テスト
"CI/CDパイプラインでのE2Eテスト自動実行"

# LINE Bot通知
"デプロイ成功・失敗通知システム"

# Obsidianでインフラ文書
"デプロイ手順・トラブルシューティング文書"
```

#### QA部門の実装例
```bash
# Playwrightテスト自動化
"全機能の回帰テスト自動化"

# Context7でテスト情報
"Jest/Playwrightベストプラクティス。use context7"

# LINE Bot結果通知
"テスト結果の自動通知"

# Obsidianでテスト文書
"テストケース・バグレポート管理"
```

### 4. 品質管理フェーズ（QA部門＋親プロセス）

各タスクの実装時は必ず以下を実行：
- **Playwright MCP**: 機能テスト実施
- **LINE Bot MCP**: テスト結果通知
- **Obsidian MCP**: バグレポート・修正履歴管理
- **Context7 MCP**: 最新のテスト手法確認

### 5. ドキュメント作成フェーズ（Frontend部門＋全部門）

タスク完了後：
- **Playwright MCP**: スクリーンショット撮影
- **Obsidian MCP**: 画像付きドキュメント作成
- **Context7 MCP**: 最新ドキュメント手法確認
- **LINE Bot MCP**: ドキュメント完成通知

### 6. 進捗報告システム

#### 子プロセスから親プロセスへの報告形式
```bash
# 標準報告フォーマット（MCP使用状況含む）
tmux send-keys -t %22 '[部門名] ステータス: 内容 (使用MCP: tool1,tool2)' Enter

# 例
tmux send-keys -t %22 '[Frontend] 完了: ログイン画面作成 (使用MCP: Context7,Playwright,Obsidian)' Enter
tmux send-keys -t %22 '[Backend] エラー: Stripe Webhook処理で500エラー (使用MCP: Stripe,Context7)' Enter
```

## 開発原則（全部門共通）

### MCPサーバー活用ルール
1. **Context7**: 最新情報が必要な場合は必ず`use context7`を付加
2. **Playwright**: テストコード作成・実行時は必須
3. **Obsidian**: ドキュメント作成・検索時は必須
4. **Stripe**: 決済関連実装時は必須
5. **LINE Bot**: 通知・アラート実装時は必須
6. **Supabase**: データベース・認証操作時は必須

### コーディング（全部門共通）
あなたは天才エンジニアです。以下を厳守してください：
- **Context7 MCP**: 最新の技術トレンドを必ず調査（`use context7`）
- **Supabase MCP**: データベース操作は全てSupabase経由
- **Playwright MCP**: 作成したコードは必ずテスト実装
- バグゼロを前提とした高品質なコード
- 全ての関数にJSDocコメント記載
- 日本人に分かりやすい言葉で説明

### デザイン（Frontend部門）
- **Context7 MCP**: 最新UIフレームワーク調査
- **Obsidian MCP**: デザインシステム文書化
- **Playwright MCP**: UIテスト自動化
- モダンで直感的なUI/UX
- アクセシビリティ考慮

### 決済システム（Backend部門）
- **Stripe MCP**: 決済処理実装
- **Supabase MCP**: 決済データ管理
- **LINE Bot MCP**: 決済完了通知
- セキュリティ最優先

## MCP統合管理コマンド

### 基本コマンド（親プロセス用）
```bash
# 全部門MCP状況確認
for pane in %27 %28 %29 %30 %31; do
  echo "=== $pane MCP Status ==="
  tmux capture-pane -t $pane -p | tail -5
done

# 全部門一斉クリア
tmux send-keys -t %27 "/clear" Enter & \
tmux send-keys -t %28 "/clear" Enter & \
tmux send-keys -t %29 "/clear" Enter & \
tmux send-keys -t %30 "/clear" Enter & \
tmux send-keys -t %31 "/clear" Enter & \
wait

# MCP統合タスク配布
tmux send-keys -t %27 "Frontend: [タスク内容] 担当MCP: Playwright,Context7,Obsidian,Stripe" Enter & \
tmux send-keys -t %28 "Backend: [タスク内容] 担当MCP: Supabase,Stripe,Context7,LINE Bot" Enter & \
tmux send-keys -t %29 "Database: [タスク内容] 担当MCP: Supabase,Obsidian" Enter & \
tmux send-keys -t %30 "DevOps: [タスク内容] 担当MCP: Supabase,Playwright,LINE Bot,Obsidian" Enter & \
tmux send-keys -t %31 "QA: [タスク内容] 担当MCP: Playwright,Obsidian,LINE Bot,Context7" Enter & \
wait
```

## Git Worktree 命名規則
```
worktrees/
├── feature/[機能名]
├── mcp-integration/[MCP名]
├── frontend-mcp/[Frontend+MCP作業]
├── backend-mcp/[Backend+MCP作業]
├── database-mcp/[Database+MCP作業]
├── devops-mcp/[DevOps+MCP作業]
└── qa-mcp/[QA+MCP作業]
```

## 重要な注意事項

### MCP統合ルール
- **全プロセスで全MCPアクセス可能**: 必要に応じて部門外MCPも使用可
- **Context7は必須**: 最新情報が必要な場合は必ず`use context7`
- **テストは必須**: Playwright MCPでテスト自動化
- **ドキュメント化必須**: Obsidian MCPで記録
- **通知システム**: LINE Bot MCPで進捗・エラー通知

### プロセス管理
- **テストが通過するまで絶対にコミットしない**
- **各フェーズを省略せず必ず実行する**
- **MCPサーバーとの連携を最大限活用**

### 報連相ルール
- **子プロセスは必ず親プロセスに報告**
- **使用MCPツールを報告に含める**
- **エラー発生時は即座に報告**
- **不明な点があれば実装前に親プロセスに確認**

この組織構造により、**全MCPサーバーを活用した効率的な並列開発と品質管理**を実現します。
