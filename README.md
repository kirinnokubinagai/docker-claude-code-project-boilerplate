# Master Claude System

🎯 **最新技術** × 🧠 **5つの天才AI** × 🇯🇵 **日本市場最適化**

## 🌟 システムの特徴
claudeが複数プロセスでシステムを構築していくシステム

## 🚀 使い方（3ステップ）

### 1. セットアップ
```bash
git clone [repository-url] master-claude
cd master-claude
./init-project.sh my-project
cd my-project

# .env設定（必須）
ANTHROPIC_API_KEY=your_key

# オプション（追加MCP用）
GITHUB_TOKEN=your_github_token
POSTGRES_CONNECTION_STRING=your_pg_url
SLACK_BOT_TOKEN=your_slack_token

# エラー監視（Sentry）- MCP経由で自動設定
# Sentry MCPが自動的に設定されます
# 各チームがmcp__sentry__で始まるツールを使用してエラー監視を行います
```

### 2. 起動
```bash
docker-compose up -d  # OWASP ZAPも自動起動
docker-compose exec claude-code fish
sh master-claude.sh  # 親Claude起動（初回はMCP自動設定）
```

### 3. 要件を伝える
```
ECサイトを作って
```

これだけ！あとは全自動。

## 🤖 自動実行される内容

1. **最新技術調査** → Context7で最新バージョン確認
2. **要件定義作成** → ビジネス目標・SEO戦略・セキュリティ要件含む
3. **5チーム起動** → 専門分野ごとに並列作業
4. **品質管理** → 15分ごとにチェック＆調整
5. **エラー自動復旧** → 問題発生時も自動で対処
6. **ドキュメント生成** → API仕様書・マニュアル自動作成
7. **セキュリティスキャン** → 脆弱性チェック＆修正
8. **成果物統合** → 最高品質で納品

## 💎 開発品質基準

全チーム共通のルール：
- 📝 **JSDoc必須** - 全関数に詳細ドキュメント
- 🚀 **早期リターン** - else/elseif禁止
- 🔄 **関数分割** - コメント不要な明確な設計
- 🌏 **日本人向け** - 分かりやすい実装
- ⚡ **最新技術** - 常に最新版を使用

## 🏢 5つの専門チーム

| チーム   | 専門分野  | 主要MCP                                  |
| -------- | --------- | ---------------------------------------- |
| Frontend | UI/UX実装 | Context7, Playwright, Sentry, Filesystem |
| Backend  | API開発   | Supabase, Stripe, Postgres, Sentry       |
| Database | DB設計    | Supabase, Obsidian, Postgres, Sentry     |
| DevOps   | インフラ  | Playwright, LINE Bot, GitHub, Sentry     |
| QA       | 品質保証  | Playwright, Context7, OWASP ZAP, Sentry  |

## 📊 納品物の特徴

- ✅ **最新技術スタック** - 常に最先端
- ✅ **SEO完璧対応** - 検索上位＆AI検索対応
- ✅ **日本市場最適化** - 文化に合わせた設計
- ✅ **収益化機能** - マネタイズ戦略実装済
- ✅ **完全テスト済** - バグゼロ保証
- ✅ **セキュリティ万全** - OWASP Top 10対策
- ✅ **アクセシビリティ** - WCAG 2.1 AA準拠
- ✅ **ドキュメント完備** - 保守も安心
- ✅ **国際化対応** - グローバル展開可能
- ✅ **監視体制** - Sentry MCPによるエラー追跡＆性能監視

## 💡 便利コマンド

```bash
check_mcp                    # MCP確認
Ctrl-b 1-6                  # チーム切替
tmux capture-pane -t "..." -p  # 進捗確認

# OWASP ZAP確認（コンテナ内から）
curl http://zap:8090         # ZAPデーモン確認
curl http://zap:8090/JSON/core/view/version/ | jq  # バージョン確認
ls zap-reports/             # セキュリティレポート確認
```

---

**要件を伝えるだけで、最高品質のプロダクトを自動開発。**