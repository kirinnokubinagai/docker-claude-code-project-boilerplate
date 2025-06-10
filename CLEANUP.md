# Claude Code Docker Projects - ファイル構成

## ✅ 最終的な必要ファイル

```
claude-code-docker-projects/
├── .env.example              # 環境変数テンプレート
├── .gitignore               # Git除外設定
├── CLAUDE.md                # Claude Code指示書
├── Dockerfile               # コンテナ設定
├── README.md                # 使い方説明
├── docker-compose.yml       # Docker設定
├── init-project.sh          # プロジェクト初期化スクリプト
├── docker/
│   └── fish/
│       └── config.fish      # Fish shell + tmux設定
└── screenshots/             # 空ディレクトリ（実行時作成）
```

## 🗑️ 削除した不要ファイル

- `docker-compose.dynamic-playwright.yml`
- `docker-compose.multi-container.yml` 
- `docker-compose.playwright-ports.yml`
- `docker-compose.yml.no-ports`
- `switch-mode.sh`
- `examples/` ディレクトリ
- `docs/` ディレクトリ
- `temp/` ディレクトリ
- `logs/` ディレクトリ
- `docker/scripts/` ディレクトリ

## 🎯 残したのは必要最小限

- **docker-compose.yml**: メインの設定
- **Dockerfile**: コンテナ定義
- **init-project.sh**: 初期化スクリプト
- **CLAUDE.md**: Claude Code動作指示
- **docker/fish/config.fish**: Shell環境
- **.env.example**: 設定テンプレート
- **README.md**: 使い方

これで**シンプル＆クリーン**な構成になりました！
