#!/bin/sh
# Developer user wrapper script
# docker-compose execで実行される際にdeveloperユーザーで実行

# 作業ディレクトリを明示的に設定
cd /workspace 2>/dev/null || cd /home/developer

# 動的チーム構成の自動セットアップ関数
setup_dynamic_teams() {
    # teams.jsonが存在しないか、空の場合に実行
    if [ ! -f "config/teams.json" ] || [ "$(jq -r '.teams | length' config/teams.json 2>/dev/null || echo 0)" = "0" ]; then
        echo "==================================="
        echo "🚀 Claude Code 動的チーム構成の初期化"
        echo "==================================="
        echo ""
        echo "プロジェクトに最適なチーム構成を自動で作成します。"
        echo ""
        
        # join-company.shが存在する場合のみ実行
        if [ -f "./join-company.sh" ]; then
            # 動的チーム構成を実行
            ./join-company.sh --dynamic
            
            # セットアップ完了メッセージ
            echo ""
            echo "✅ チーム構成が完了しました！"
            echo ""
            echo "📝 使い方："
            echo "  1. 'master' コマンドでtmuxセッションを開始"
            echo "  2. 各チームが自動的に専用ウィンドウで起動します"
            echo ""
            echo "==================================="
            echo ""
            # 少し待機してメッセージを読めるようにする
            sleep 2
        else
            echo "⚠️  join-company.shが見つかりません。手動でセットアップしてください。"
            echo ""
        fi
    fi
}

if [ "$(id -u)" = "0" ]; then
    # rootユーザーの場合、developerに切り替えて動的チーム構成をセットアップ
    exec su developer -c "cd /workspace 2>/dev/null || cd /home/developer; $(declare -f setup_dynamic_teams); setup_dynamic_teams; fish $*"
else
    # すでにdeveloperユーザーの場合、動的チーム構成をセットアップしてからfishを起動
    setup_dynamic_teams
    exec fish "$@"
fi