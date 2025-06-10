#!/bin/bash

# 自動ドキュメント化ライブラリ（Obsidian MCP & Playwright MCP使用）

# プロジェクト初期化時のドキュメント作成
create_project_documentation() {
    local project_name="$1"
    local description="$2"
    
    log_info "プロジェクトドキュメントを作成中..."
    
    # プロジェクト概要をObsidianに作成
    mcp__mcp-obsidian__obsidian_append_content \
        "$OBSIDIAN_PROJECT_DIR/README.md" \
        "# $project_name

## プロジェクト概要
$description

## 開始日時
$(date +'%Y-%m-%d %H:%M:%S')

## チーム構成
- Master Architect: 全体設計・調整
- Frontend Team: UI/UX開発
- Backend Team: API・サーバー開発  
- Database Team: DB設計・最適化
- DevOps Team: CI/CD・インフラ

## 開発フロー
1. 要件定義
2. 各チーム並列開発
3. 統合テスト
4. デプロイ

---
このドキュメントは自動生成されました。
"
    
    log_success "プロジェクトドキュメントを作成しました"
}

# 実装進捗のリアルタイム記録
record_implementation_progress() {
    local team="$1"
    local task="$2"
    local status="$3"  # started, in_progress, completed
    local details="$4"
    
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    local progress_entry="## $timestamp - $team

### タスク: $task
**ステータス**: $status

$details

---
"
    
    # Obsidianに進捗を記録
    mcp__mcp-obsidian__obsidian_append_content \
        "$OBSIDIAN_PROGRESS_DIR/$(date +'%Y%m%d')_開発進捗.md" \
        "$progress_entry"
    
    log_info "[$team] 進捗を記録: $task ($status)"
}

# 機能実装完了時のスクリーンショット撮影とドキュメント化
document_feature_with_screenshots() {
    local team="$1"
    local feature_name="$2"
    local url="$3"
    local description="$4"
    
    log_info "[$team] $feature_name のビジュアルドキュメントを作成中..."
    
    # 1. Playwrightでブラウザを起動
    mcp__mcp-playwright__browser_navigate "$url"
    
    # 2. ページの読み込み待機
    sleep 3
    
    # 3. スクリーンショットを撮影
    local screenshot_filename="${team}_${feature_name}_$(date +'%Y%m%d_%H%M%S').png"
    mcp__mcp-playwright__browser_take_screenshot "$screenshot_filename"
    
    # 4. ブラウザを閉じる
    mcp__mcp-playwright__browser_close
    
    # 5. ドキュメントを作成
    local doc_content="# $feature_name

## 担当チーム
$team

## 概要
$description

## スクリーンショット
![[screenshots/$screenshot_filename]]

## URL
$url

## 実装日時
$(date +'%Y-%m-%d %H:%M:%S')

## 機能詳細
- 機能の詳細説明
- 使用技術
- 特記事項

---
"
    
    # Obsidianに保存
    mcp__mcp-obsidian__obsidian_append_content \
        "$OBSIDIAN_DOCS_DIR/${feature_name}_実装ドキュメント.md" \
        "$doc_content"
    
    log_success "[$team] $feature_name のドキュメントを作成しました"
}

# 完成したシステムの包括的マニュアル生成
generate_comprehensive_manual() {
    local project_name="$1"
    
    log_info "包括的マニュアルを生成中..."
    
    # 1. 全機能のスクリーンショットを撮影
    local urls=(
        "http://localhost:3000"
        "http://localhost:3000/login"
        "http://localhost:3000/dashboard"
        "http://localhost:3000/users"
        "http://localhost:3000/settings"
    )
    
    local manual_content="# $project_name 完全マニュアル

作成日: $(date +'%Y年%m月%d日')
バージョン: 1.0.0

## 目次

1. [システム概要](#システム概要)
2. [セットアップガイド](#セットアップガイド)
3. [機能一覧](#機能一覧)
4. [画面ガイド](#画面ガイド)
5. [API仕様](#API仕様)
6. [トラブルシューティング](#トラブルシューティング)

---

## システム概要

$project_name は、Claude Code チームによって開発された次世代Webアプリケーションです。

### アーキテクチャ

"
    
    # メイン画面のスクリーンショット
    mcp__mcp-playwright__browser_navigate "http://localhost:3000"
    sleep 3
    mcp__mcp-playwright__browser_take_screenshot "manual_main_$(date +'%Y%m%d').png"
    
    manual_content+="![[screenshots/manual_main_$(date +'%Y%m%d').png]]

### 技術スタック

**Frontend**
- Next.js 15 (App Router)
- TypeScript
- Tailwind CSS
- Radix UI

**Backend**
- Supabase
- Edge Functions
- PostgreSQL

**DevOps**
- Docker
- GitHub Actions
- Vercel

## セットアップガイド

### 必要な環境

\`\`\`bash
# Node.js 20以上
node --version

# Docker
docker --version

# Git
git --version
\`\`\`

### インストール手順

1. **リポジトリのクローン**

\`\`\`bash
git clone [repository_url]
cd $project_name
\`\`\`

2. **依存関係のインストール**

\`\`\`bash
npm install
\`\`\`

3. **環境変数の設定**

\`\`\`bash
cp .env.example .env
# .envファイルを編集
\`\`\`

4. **アプリケーションの起動**

\`\`\`bash
npm run dev
\`\`\`

## 機能一覧

### 主要機能

1. **ユーザー認証**
   - ログイン・ログアウト
   - パスワードリセット
   - ユーザー登録

2. **ダッシュボード**
   - 概要表示
   - 統計情報
   - クイックアクション

3. **データ管理**
   - CRUD操作
   - 検索・フィルター
   - エクスポート機能

## 画面ガイド

### ログイン画面

"
    
    # ログイン画面のスクリーンショット
    mcp__mcp-playwright__browser_navigate "http://localhost:3000/login"
    sleep 3
    mcp__mcp-playwright__browser_take_screenshot "manual_login_$(date +'%Y%m%d').png"
    
    manual_content+="![[screenshots/manual_login_$(date +'%Y%m%d').png]]

**使い方:**
1. ユーザー名またはメールアドレスを入力
2. パスワードを入力
3. 「ログイン」ボタンをクリック

### ダッシュボード

"
    
    # ダッシュボード画面のスクリーンショット
    mcp__mcp-playwright__browser_navigate "http://localhost:3000/dashboard"
    sleep 3
    mcp__mcp-playwright__browser_take_screenshot "manual_dashboard_$(date +'%Y%m%d').png"
    
    manual_content+="![[screenshots/manual_dashboard_$(date +'%Y%m%d').png]]

**主な機能:**
- 最新の活動状況
- 重要なメトリクス
- クイックナビゲーション

## API仕様

### 認証API

\`\`\`http
POST /api/auth/login
Content-Type: application/json

{
  \"email\": \"user@example.com\",
  \"password\": \"password123\"
}
\`\`\`

### ユーザーAPI

\`\`\`http
GET /api/users
Authorization: Bearer {token}
\`\`\`

## トラブルシューティング

### よくある質問

**Q: ログインできません**
A: 以下を確認してください：
- 正しいメールアドレスが入力されているか
- パスワードが正しいか
- アカウントが有効化されているか

**Q: データが表示されません**  
A: ブラウザのキャッシュをクリアして再度お試しください。

### エラーコード一覧

| コード | 説明 | 対処法 |
|--------|------|-------|
| 401 | 認証エラー | 再ログインしてください |
| 404 | ページが見つかりません | URLを確認してください |
| 500 | サーバーエラー | 管理者にお問い合わせください |

---

## サポート

技術的な問題や質問がある場合は、以下にお問い合わせください：

- GitHub Issues: [repository_url]/issues
- Email: support@example.com

---

このマニュアルは Claude Code チームによって自動生成されました。
最終更新: $(date +'%Y年%m月%d日 %H:%M')
"
    
    # ブラウザを閉じる
    mcp__mcp-playwright__browser_close
    
    # Obsidianにマニュアルを保存
    mcp__mcp-obsidian__obsidian_append_content \
        "$OBSIDIAN_MANUAL_DIR/${project_name}_完全マニュアル.md" \
        "$manual_content"
    
    log_success "包括的マニュアルを生成しました"
}

# チーム作業ログの自動記録
log_team_activity() {
    local team="$1"
    local activity="$2"
    local details="$3"
    
    local log_entry="### $(date +'%H:%M:%S') - $team

**活動**: $activity

$details

"
    
    # 今日の作業ログに追記
    mcp__mcp-obsidian__obsidian_append_content \
        "$OBSIDIAN_PROGRESS_DIR/$(date +'%Y%m%d')_チーム活動ログ.md" \
        "$log_entry"
}

# プロジェクト完了時の総括ドキュメント生成
generate_project_summary() {
    local project_name="$1"
    local completion_summary="$2"
    
    local summary_content="# $project_name プロジェクト完了報告

## プロジェクト概要

**プロジェクト名**: $project_name
**完了日時**: $(date +'%Y年%m月%d日 %H:%M')
**開発期間**: [開始日から計算]

## 完了サマリー

$completion_summary

## チーム別成果

### Frontend Team
- 実装した画面数: X画面
- コンポーネント数: X個
- テストカバレッジ: X%

### Backend Team  
- 実装したAPI数: X個
- エンドポイント数: X個
- パフォーマンステスト結果: 良好

### Database Team
- テーブル数: X個
- インデックス最適化: 完了
- データ移行: 成功

### DevOps Team
- CI/CDパイプライン: 構築完了
- デプロイ環境: 3環境（dev/staging/prod）
- 監視システム: 導入完了

## 技術的ハイライト

- 使用技術の詳細
- 技術的課題と解決策
- パフォーマンス最適化

## 今後の展望

- 次期バージョンでの予定機能
- 技術的改善点
- スケーラビリティ対応

---

このレポートは Claude Code チームが自動生成しました。
"
    
    mcp__mcp-obsidian__obsidian_append_content \
        "$OBSIDIAN_PROJECT_DIR/${project_name}_プロジェクト完了報告.md" \
        "$summary_content"
    
    log_success "プロジェクト完了報告を生成しました"
}