# 環境変数の分離について

## 概要
プロジェクトの環境変数を以下の2つのファイルに分離しています：

### 1. `.env` - プロジェクト固有の設定
- `PROJECT_NAME` - プロジェクト名
- `CLAUDE_PROJECT_DIR` - Claude Projectのディレクトリパス
- `PLAYWRIGHT_MCP_PORT` - Playwright MCPサーバーのポート
- プロジェクト固有の環境変数（DATABASE_URL、REDIS_URL等）

### 2. `.env.mcp` - MCPサービスの認証情報
- `ANTHROPIC_API_KEY` - Claude API
- `GITHUB_TOKEN` - GitHub
- `SUPABASE_ACCESS_TOKEN` - Supabase
- `STRIPE_SEC_KEY` - Stripe
- `CHANNEL_ACCESS_TOKEN` - LINE Bot
- `DESTINATION_USER_ID` - LINE Bot User ID
- `OBSIDIAN_API_KEY` - Obsidian
- `MAGIC_API_KEY` - Magic MCP
- その他MCPサービスのAPI Keys

## メリット
1. **セキュリティ** - プロジェクト固有の設定とAPIキーを分離
2. **可読性** - プロジェクトの設定が見やすい
3. **管理性** - APIキーの更新が簡単
4. **チーム開発** - `.env`はプロジェクトメンバーで共有、`.env.mcp`は個人管理

## 使用方法
1. 新規プロジェクト作成時、`create-project.sh`が自動的に：
   - `.env`を作成（プロジェクト設定のみ）
   - `.env.mcp`をコピー（boilerplateの`.env`から）

2. docker-entrypoint.shが起動時に両方のファイルを読み込み

## 移行方法（既存プロジェクト）
```bash
# 1. 既存の.envをバックアップ
cp .env .env.backup

# 2. プロジェクト設定のみの新しい.envを作成
cat > .env << 'EOF'
# ==============================================
# Project Configuration
# ==============================================
PROJECT_NAME=your_project_name
CLAUDE_PROJECT_DIR=/path/to/claude-project
PLAYWRIGHT_MCP_PORT=8931

# ==============================================
# Project-specific Environment Variables
# ==============================================
# Add your project-specific variables here
EOF

# 3. MCPサービスの設定を.env.mcpに移動
mv .env.backup .env.mcp

# 4. .env.mcpから不要な行を削除
# PROJECT_NAME、CLAUDE_PROJECT_DIR、PLAYWRIGHT_MCP_PORTの行を削除
```