# Master Claude System

🎯 **最新技術** × 🧠 **5つの天才AI** × 🇯🇵 **日本市場最適化**

## 🌟 システムの特徴

親Claudeが持つ**5つの天才的能力**：
- 💻 **天才エンジニア** - 常に最新技術を使用、完璧なコード品質
- 🎨 **天才デザイナー** - ミニマルで日本人に優しいUI/UX
- 🧠 **行動心理学の天才** - ユーザー行動を予測し最適化
- 🔍 **SEOの天才** - 検索上位＆AI検索対応
- 💼 **ビジネスの天才** - 完璧なマネタイズ戦略

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
SENTRY_DSN=your_sentry_dsn
```

### 2. 起動
```bash
docker-compose up -d  # OWASP ZAPも自動起動
docker-compose exec claude-code fish
master  # 親Claude起動（初回はMCP自動設定）
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

| チーム | 専門分野 | 主要MCP |
|--------|----------|---------|
| Frontend | UI/UX実装 | Context7, Playwright, Filesystem |
| Backend | API開発 | Supabase, Stripe, Postgres |
| Database | DB設計 | Supabase, Obsidian, Postgres |
| DevOps | インフラ | Playwright, LINE Bot, GitHub |
| QA | 品質保証 | Playwright, Context7, OWASP ZAP |

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
- ✅ **監視体制** - エラー追跡＆性能監視

## 💡 便利コマンド

```bash
check_mcp                    # MCP確認
Ctrl-b 1-6                  # チーム切替
tmux capture-pane -t "..." -p  # 進捗確認

# OWASP ZAP確認
curl http://localhost:8090   # ZAPデーモン確認
ls zap-reports/             # セキュリティレポート確認
```

---

**要件を伝えるだけで、最高品質のプロダクトを自動開発。**