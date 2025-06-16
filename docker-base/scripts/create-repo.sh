#!/bin/bash

# 新しいGitHubリポジトリを作成するスクリプト

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}${BOLD}======================================${NC}"
echo -e "${CYAN}${BOLD} GitHub Repository Creator${NC}"
echo -e "${CYAN}${BOLD}======================================${NC}"
echo ""

# GitHub CLI認証確認
if ! gh auth status >/dev/null 2>&1; then
    echo -e "${RED}❌ GitHub CLIが認証されていません。${NC}"
    echo ""
    echo "以下のコマンドでGitHub CLIにログインしてください："
    echo -e "${YELLOW}gh auth login${NC}"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ GitHub CLI認証済み${NC}"
echo ""

# リポジトリ名の入力
while true; do
    read -p "🚀 リポジトリ名を入力してください: " repo_name
    
    if [ -z "$repo_name" ]; then
        echo -e "${RED}❌ リポジトリ名は必須です${NC}"
        continue
    fi
    
    # リポジトリ名の妥当性チェック
    if [[ ! "$repo_name" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        echo -e "${RED}❌ リポジトリ名に使用できない文字が含まれています${NC}"
        echo "使用可能文字: a-z, A-Z, 0-9, ., _, -"
        continue
    fi
    
    break
done

# 説明の入力
read -p "📝 リポジトリの説明を入力してください（オプション）: " description

# 可視性の選択
echo ""
echo "🔒 リポジトリの可視性を選択してください:"
echo "1) Public（公開）"
echo "2) Private（非公開）"
echo ""

while true; do
    read -p "選択してください [1-2]: " visibility_choice
    
    case $visibility_choice in
        1)
            visibility="public"
            visibility_flag="--public"
            break
            ;;
        2)
            visibility="private"
            visibility_flag="--private"
            break
            ;;
        *)
            echo -e "${RED}❌ 1または2を入力してください${NC}"
            ;;
    esac
done

# README.mdの作成オプション
echo ""
read -p "📄 README.mdを作成しますか？ [y/N]: " create_readme
create_readme=${create_readme:-n}

# Gitリポジトリの初期化確認
if [ ! -d ".git" ]; then
    echo ""
    echo -e "${YELLOW}⚠️  現在のディレクトリがGitリポジトリではありません${NC}"
    read -p "Gitリポジトリを初期化しますか？ [Y/n]: " init_git
    init_git=${init_git:-y}
    
    if [[ $init_git =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}📦 Gitリポジトリを初期化中...${NC}"
        git init
        
        # README.mdを作成
        if [[ $create_readme =~ ^[Yy]$ ]]; then
            if [ ! -f "README.md" ]; then
                echo "# $repo_name" > README.md
                if [ -n "$description" ]; then
                    echo "" >> README.md
                    echo "$description" >> README.md
                fi
                echo "" >> README.md
                echo "## Getting Started" >> README.md
                echo "" >> README.md
                echo "TODO: Add setup instructions" >> README.md
            fi
        fi
        
        # .gitignoreを作成（存在しない場合）
        if [ ! -f ".gitignore" ]; then
            echo "node_modules/" > .gitignore
            echo ".env" >> .gitignore
            echo ".DS_Store" >> .gitignore
            echo "*.log" >> .gitignore
        fi
        
        # 初回コミット
        git add .
        git commit -m "Initial commit

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
        
        echo -e "${GREEN}✅ 初回コミット完了${NC}"
    fi
fi

# 設定の確認
echo ""
echo -e "${CYAN}${BOLD}📋 設定確認${NC}"
echo "リポジトリ名: $repo_name"
echo "説明: ${description:-"（なし）"}"
echo "可視性: $visibility"
echo ""

read -p "この設定でリポジトリを作成しますか？ [Y/n]: " confirm
confirm=${confirm:-y}

if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⚠️  リポジトリ作成をキャンセルしました${NC}"
    exit 0
fi

# GitHubリポジトリの作成
echo ""
echo -e "${BLUE}🚀 GitHubリポジトリを作成中...${NC}"

# GitHub CLI コマンドを構築
gh_command="gh repo create $repo_name $visibility_flag --source=. --push"

if [ -n "$description" ]; then
    gh_command="$gh_command --description \"$description\""
fi

# リポジトリ作成実行
if eval $gh_command; then
    echo ""
    echo -e "${GREEN}${BOLD}🎉 リポジトリ作成完了！${NC}"
    echo ""
    
    # リポジトリURLを取得
    repo_url=$(gh repo view --json url --jq '.url')
    echo -e "${CYAN}📍 リポジトリURL: $repo_url${NC}"
    
    # リモート確認
    echo ""
    echo -e "${BLUE}🔗 リモートリポジトリ設定:${NC}"
    git remote -v
    
    echo ""
    echo -e "${GREEN}✅ 全ての設定が完了しました！${NC}"
    echo ""
    echo "📝 次のステップ:"
    echo "  - コードを編集"
    echo "  - git add . && git commit -m \"your message\""
    echo "  - git push"
    echo ""
    
else
    echo ""
    echo -e "${RED}❌ リポジトリの作成に失敗しました${NC}"
    echo ""
    echo "可能な原因:"
    echo "  - 同名のリポジトリが既に存在する"
    echo "  - GitHub CLIの権限が不足している"
    echo "  - ネットワーク接続の問題"
    echo ""
    exit 1
fi