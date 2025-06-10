#!/bin/bash

# ドキュメント自動生成システム

# Obsidianのプロジェクトフォルダ
OBSIDIAN_PROJECT_DIR="Projects/$(basename $WORKSPACE)"
OBSIDIAN_DOCS_DIR="$OBSIDIAN_PROJECT_DIR/docs"
OBSIDIAN_PROGRESS_DIR="$OBSIDIAN_PROJECT_DIR/progress"
OBSIDIAN_MANUAL_DIR="$OBSIDIAN_PROJECT_DIR/manual"

# スクリーンショット保存先
SCREENSHOT_DIR="$WORKSPACE/screenshots"

# 初期化
init_documentation_system() {
    ensure_directory "$SCREENSHOT_DIR"
    log_success "ドキュメントシステムを初期化しました"
}

# 進捗をObsidianに送信
send_progress_to_obsidian() {
    local team="$1"
    local title="$2"
    local content="$3"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local filename="$(date +%Y%m%d)_進捗_${team}.md"
    
    # Obsidianに進捗を記録
    local obsidian_content="## $timestamp - $team

### $title

$content

---
"
    
    # MCPを使ってObsidianに追記
    echo "mcp__mcp-obsidian__obsidian_append_content \"$OBSIDIAN_PROGRESS_DIR/$filename\" \"$obsidian_content\""
}

# 実装内容をObsidianに記録
document_implementation() {
    local team="$1"
    local feature="$2"
    local description="$3"
    local code_snippet="$4"
    
    local filename="${feature}_実装.md"
    local content="# $feature

## 担当チーム
$team

## 概要
$description

## 実装詳細
\`\`\`typescript
$code_snippet
\`\`\`

## 関連ファイル
- 実装ファイル一覧をここに記載

## テスト方法
- テスト手順をここに記載

---
作成日時: $(date +"%Y-%m-%d %H:%M:%S")
"
    
    # MCPを使ってObsidianに保存
    echo "mcp__mcp-obsidian__obsidian_append_content \"$OBSIDIAN_DOCS_DIR/$filename\" \"$content\""
}

# Playwrightでスクリーンショットを撮影
capture_screenshot() {
    local url="$1"
    local filename="$2"
    local description="$3"
    
    log_info "スクリーンショットを撮影中: $description"
    
    # Playwright MCPを使用してスクリーンショット撮影
    # 1. ブラウザを開く
    echo "mcp__mcp-playwright__browser_navigate \"$url\""
    
    # 2. 少し待機
    sleep 3
    
    # 3. スクリーンショットを撮影
    echo "mcp__mcp-playwright__browser_take_screenshot \"$SCREENSHOT_DIR/$filename\""
    
    # 4. ブラウザを閉じる
    echo "mcp__mcp-playwright__browser_close"
    
    log_success "スクリーンショットを保存: $filename"
}

# マニュアルを生成
generate_manual() {
    local project_name="$1"
    local version="${2:-1.0.0}"
    
    log_info "マニュアルを生成中..."
    
    local manual_content="# $project_name ユーザーマニュアル

バージョン: $version
作成日: $(date +"%Y年%m月%d日")

## 目次

1. [はじめに](#はじめに)
2. [システム概要](#システム概要)
3. [セットアップ](#セットアップ)
4. [基本的な使い方](#基本的な使い方)
5. [各機能の詳細](#各機能の詳細)
6. [トラブルシューティング](#トラブルシューティング)

---

## はじめに

このマニュアルでは、$project_name の使い方について説明します。

## システム概要

### アーキテクチャ

![[architecture_screenshot.png]]

### 主な機能

1. **Frontend機能**
   - ユーザーインターフェース
   - レスポンシブデザイン

2. **Backend機能**
   - API提供
   - データ処理

3. **Database機能**
   - データ永続化
   - 高速検索

4. **DevOps機能**
   - 自動デプロイ
   - 監視・ログ

## セットアップ

### 必要な環境

- Node.js 20以上
- Docker
- Git

### インストール手順

1. リポジトリをクローン
\`\`\`bash
git clone [repository_url]
cd $project_name
\`\`\`

2. 依存関係をインストール
\`\`\`bash
npm install
\`\`\`

3. 環境変数を設定
\`\`\`bash
cp .env.example .env
# .envファイルを編集
\`\`\`

### 起動方法

![[startup_screenshot.png]]

\`\`\`bash
npm run dev
\`\`\`

## 基本的な使い方

### ログイン

![[login_screenshot.png]]

1. ブラウザで http://localhost:3000 にアクセス
2. ユーザー名とパスワードを入力
3. ログインボタンをクリック

### メイン画面

![[main_screenshot.png]]

各機能へのアクセス方法：
- サイドバーからメニューを選択
- ダッシュボードから直接アクセス

## 各機能の詳細

### 機能1: ユーザー管理

![[user_management_screenshot.png]]

**使い方：**
1. ユーザー一覧を表示
2. 新規ユーザーを追加
3. 既存ユーザーを編集

### 機能2: データ管理

![[data_management_screenshot.png]]

**使い方：**
1. データの検索
2. データの追加・編集
3. データのエクスポート

## トラブルシューティング

### よくある質問

**Q: ログインできない**
A: パスワードをリセットしてください

**Q: データが表示されない**
A: キャッシュをクリアしてください

### エラーメッセージ一覧

| エラーコード | 説明 | 対処法 |
|------------|------|-------|
| E001 | 認証エラー | 再ログイン |
| E002 | データベースエラー | 管理者に連絡 |

---

## 付録

### ショートカットキー一覧

| キー | 機能 |
|-----|------|
| Ctrl+S | 保存 |
| Ctrl+Z | 元に戻す |

### 更新履歴

- v1.0.0 ($(date +"%Y-%m-%d")) - 初版リリース
"
    
    # Obsidianに保存
    echo "mcp__mcp-obsidian__obsidian_append_content \"$OBSIDIAN_MANUAL_DIR/${project_name}_マニュアル.md\" \"$manual_content\""
}

# スクリーンショット付きドキュメントを作成
create_visual_documentation() {
    local feature="$1"
    local urls=("${@:2}")
    
    log_info "ビジュアルドキュメントを作成中: $feature"
    
    # 各URLのスクリーンショットを撮影
    local screenshots=()
    local index=1
    
    for url in "${urls[@]}"; do
        local screenshot_name="${feature}_${index}.png"
        capture_screenshot "$url" "$screenshot_name" "$feature - 画面${index}"
        screenshots+=("$screenshot_name")
        ((index++))
    done
    
    # ドキュメントを生成
    local doc_content="# $feature - ビジュアルガイド

## 画面フロー

"
    
    index=1
    for screenshot in "${screenshots[@]}"; do
        doc_content+="### ステップ $index

![[screenshots/$screenshot]]

"
        ((index++))
    done
    
    # Obsidianに保存
    echo "mcp__mcp-obsidian__obsidian_append_content \"$OBSIDIAN_DOCS_DIR/${feature}_ビジュアルガイド.md\" \"$doc_content\""
}

# チーム作業完了時の自動ドキュメント化
finalize_team_documentation() {
    local team="$1"
    local summary="$2"
    
    log_info "[$team] 作業完了ドキュメントを生成中..."
    
    # 1. 進捗サマリーを作成
    send_progress_to_obsidian "$team" "作業完了" "$summary"
    
    # 2. 実装内容をまとめる
    local impl_summary="## $team チーム実装サマリー

完了日時: $(date +"%Y-%m-%d %H:%M:%S")

### 実装内容
$summary

### 成果物
- 作成したファイル一覧
- 実装した機能一覧

### 次のステップ
- 他チームとの連携事項
- 追加タスク
"
    
    echo "mcp__mcp-obsidian__obsidian_append_content \"$OBSIDIAN_DOCS_DIR/${team}_実装完了.md\" \"$impl_summary\""
}