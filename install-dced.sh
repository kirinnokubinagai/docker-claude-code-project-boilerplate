#!/bin/bash

# DCEDコマンドのインストールスクリプト

echo "🚀 Docker Claude Easy Development (DCED) インストーラー"
echo ""

# インストール先の確認
SHELL_RC=""
if [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_RC="$HOME/.bash_profile"
elif [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
else
    echo "エラー: .bashrc、.bash_profile、.zshrcが見つかりません"
    exit 1
fi

echo "インストール先: $SHELL_RC"

# 既存のインストールをチェック
if grep -q "# Docker Claude Easy Development" "$SHELL_RC" 2>/dev/null; then
    echo "既にインストールされています。上書きしますか？ [y/N]"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "インストールをキャンセルしました"
        exit 0
    fi
    # 既存の設定を削除
    sed -i.bak '/# Docker Claude Easy Development/,/# End of DCED/d' "$SHELL_RC"
fi

# DCEDコマンドを追加
cat >> "$SHELL_RC" << 'EOF'

# Docker Claude Easy Development
source ~/claude-project/docker-base/scripts/dced-function.sh

# create-projectのエイリアス（グローバルで使えるように）
alias create-project='~/claude-project/create-project.sh'

# End of DCED
EOF

echo "✅ インストールが完了しました！"
echo ""
echo "以下のコマンドでシェルを再読み込みしてください:"
echo "  source $SHELL_RC"
echo ""
echo "使用可能なコマンド:"
echo "  dced <project>    - プロジェクトコンテナに接続"
echo "  dcls              - プロジェクト一覧を表示"
echo "  dcstop <project>  - プロジェクトを停止"
echo "  dcrestart <project> - プロジェクトを再起動"
echo "  create-project <name> - 新規プロジェクト作成"
echo ""
echo "例:"
echo "  dced beatlink     - beatlinkプロジェクトに接続"