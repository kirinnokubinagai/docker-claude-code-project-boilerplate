# lib ディレクトリ - ライブラリファイル説明

このディレクトリには、Master Claude Teams Systemで使用されるシェルスクリプトライブラリが含まれています。

## 📁 ファイル構成

### 🔧 core-lib.sh
**基本機能を提供するコアライブラリ**
- ログ出力関数（log_info, log_success, log_warning, log_error）
- バナー表示
- タイムアウト処理
- Git操作（リポジトリ初期化、worktree管理）
- tmux操作（セッション管理、ペイン操作）
- ユーティリティ関数（ディレクトリ作成、依存関係チェック）

### 🤝 team-operations.sh
**チーム操作に関する統合ライブラリ**
- メッセージキューによる非同期通信
- 階層的コミュニケーション（Master ↔ Boss ↔ メンバー）
- Git worktreeマージワークフロー
- チーム設定管理
- 技術スタック情報

### 🌟 universal-characteristics.sh
**全メンバーが持つ5つの核となる特性を定義**
- ビジョナリー（先見者）
- ストラテジスト（戦略家）
- メディエーター（調停者）
- クオリティゲートキーパー（品質の守護者）
- イノベーター（革新者）

## 📝 使い方

master-claude-teams.sh で以下のように読み込まれます：

```bash
# ライブラリをロード
source "$SCRIPT_DIR/lib/core-lib.sh"
source "$SCRIPT_DIR/lib/team-operations.sh"
source "$SCRIPT_DIR/lib/universal-characteristics.sh"
```

## 🔄 主要な関数

### core-lib.sh
- `init_git_repo()` - Gitリポジトリ初期化
- `kill_tmux_session()` - tmuxセッション削除
- `send_to_pane()` - tmuxペインへコマンド送信
- `check_dependencies()` - 依存関係チェック

### team-operations.sh
- `master_to_boss()` - Master→Boss通信
- `boss_to_boss()` - Boss間通信
- `master_merge_team_work()` - チーム成果物マージ
- `run_integration_workflow()` - 統合ワークフロー実行

### universal-characteristics.sh
- `get_universal_characteristics()` - 共通特性取得
- `generate_complete_characteristics()` - チーム別特性生成