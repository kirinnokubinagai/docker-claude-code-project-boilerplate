#!/bin/bash
# .bashrc for developer user

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Playwright環境変数（ヘッドレステスト用）
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=0
export CI=true
export PLAYWRIGHT_BROWSERS_PATH=/home/developer/.cache/ms-playwright

# History settings - Ctrl+Rで履歴検索を有効化
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# インタラクティブシェルでのみキーバインド設定
# PS1が設定されていることも確認（インタラクティブシェルの確実な判定）
if [[ $- == *i* ]] && [[ -t 0 ]] && [[ ! -z "$PS1" ]]; then
    # fzf設定 - Ctrl+Rで高度な履歴検索
    if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
        source /usr/share/doc/fzf/examples/key-bindings.bash 2>/dev/null || true
    fi
    
    # peco履歴検索機能
    function peco-history-selection() {
        BUFFER=$(history | cut -c 8- | sort | uniq | peco --query "$LBUFFER")
        CURSOR=$#BUFFER
        zle clear-screen
    }
    
    # bindコマンドが利用可能か確認してから実行
    if type bind &>/dev/null; then
        # pecoを使った履歴検索 - Ctrl+Alt+Rで起動
        bind '"\e\C-r": "\C-a\C-kpeco-history-selection\n"' 2>/dev/null || true
    fi
fi

# peco便利関数
function peco-cd() {
    local selected_dir=$(find . -type d | peco)
    if [ -n "$selected_dir" ]; then
        cd "$selected_dir"
    fi
}

function peco-git-branch() {
    local selected_branch=$(git branch -a | peco | sed 's/^..//g' | sed 's/remotes\/origin\///g')
    if [ -n "$selected_branch" ]; then
        git checkout "$selected_branch"
    fi
}

# z設定 - ディレクトリジャンプ
if [ -f /usr/local/bin/z.sh ]; then
    . /usr/local/bin/z.sh
fi

# Prompt customization
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias vi='vim'
alias v='vim'

# Claude Code aliases
alias cc='claude'
alias ccd='claude --dangerously-skip-permissions'
alias check_mcp='claude mcp list'
alias setup-mcp='/opt/claude-system/scripts/setup-mcp.sh'
alias master='/opt/claude-system/scripts/master-claude-teams.sh'
alias auto-assign='/opt/claude-system/scripts/auto-assign-tasks.sh'
alias help='/opt/claude-system/scripts/show-help.sh'
alias h='/opt/claude-system/scripts/show-help.sh'

# peco aliases
alias pcd='peco-cd'
alias pgb='peco-git-branch'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --all'
alias gd='git diff'

# GitHub CLI aliases
alias ghpr='gh pr create'
alias ghprl='gh pr list'
alias ghprv='gh pr view'
alias ghprc='gh pr checkout'
alias ghissue='gh issue create'
alias ghissuel='gh issue list'
alias ghrepo='gh repo view --web'
alias ghbrowse='gh browse'

# tmux
alias ta='tmux attach -t'
alias tl='tmux list-sessions'
alias tn='tmux new -s'

# Environment variables
export EDITOR='vim'
export VISUAL='vim'

# Bashのviモードを無効化（emacsモードを使用）
set -o emacs

# Set working directory
cd /workspace 2>/dev/null || true

# Welcome message and shortcuts
echo ""
echo "==============================================="
echo "🚀 Claude Code Development Environment"
echo "==============================================="
echo ""
echo "📋 ショートカット:"
echo "  cc              - Claude CLIを起動"
echo "  ccd             - Claude CLI（権限確認スキップ）"
echo "  master          - Master Claude Teamsを起動"
echo "  setup-mcp       - MCPサーバーを設定"
echo "  check_mcp       - MCPサーバーの状態確認"
echo "  help / h        - ヘルプとコマンド一覧を表示"
echo ""
echo "📝 次のステップ:"
echo "  1. cc または ccd と入力してアプリの要件を説明"
echo "  2. teams.jsonが生成されたら master を実行"
echo "  3. 各チームが並行開発を開始"
echo ""
echo "💡 Tips:"
echo "  - 初回実行時の質問は自動でスキップされます"
echo "  - Ctrl+R で履歴検索（fzf）、Ctrl+Alt+R で履歴検索（peco）"
echo "  - pcd でディレクトリ選択、pgb でブランチ選択"
echo "  - z [directory] でディレクトリジャンプ"
echo "  - tmux attach -t claude-teams でチーム画面に接続"
echo "  - help でtmuxコマンドの詳細を確認"
echo ""
echo "==============================================="
echo ""