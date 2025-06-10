FROM node:alpine

# 必要なパッケージをインストール
RUN apk add --no-cache \
    fish \
    git \
    curl \
    fzf \
    tmux \
    bash \
    python3 \
    py3-pip \
    nodejs \
    npm \
    coreutils \
    sudo \
    docker-cli \
    docker-compose \
    jq

# developerユーザーを作成（既存のGID/UIDを考慮）
RUN addgroup -g 1001 developer || true && \
    adduser -D -u 1001 -G developer -s /usr/bin/fish -h /home/developer developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# fish設定ディレクトリの作成
RUN mkdir -p /home/developer/.config/fish/functions

# zのインストール
RUN curl -sS https://raw.githubusercontent.com/jethrokuan/z/master/z.fish > /home/developer/.config/fish/functions/z.fish

# Claude Codeをインストール
RUN npm install -g @anthropic-ai/claude-code

# 全MCPサーバーをグローバルインストール
RUN npm install -g \
    @upstash/context7-mcp \
    @stripe/mcp \
    @line/line-bot-mcp-server \
    @supabase/mcp-server-supabase \
    @playwright/mcp@latest \
    @modelcontextprotocol/server-github \
    @modelcontextprotocol/server-postgres \
    @modelcontextprotocol/server-filesystem \
    @modelcontextprotocol/server-slack \
    @redocly/openapi-cli \
    redoc-cli \
    lighthouse \
    snyk \
    conventional-changelog-cli

# Pythonベースのツールもインストール（--break-system-packagesフラグを使用）
RUN pip3 install --break-system-packages uv

# tmux設定
RUN echo "set -g default-shell /usr/bin/fish" > /home/developer/.tmux.conf && \
    echo "set -g mouse on" >> /home/developer/.tmux.conf && \
    echo "set -g base-index 1" >> /home/developer/.tmux.conf && \
    echo "set -g pane-base-index 1" >> /home/developer/.tmux.conf && \
    echo "set -g pane-border-status top" >> /home/developer/.tmux.conf && \
    echo "set -g pane-border-format '#{pane_index}: #{pane_title}'" >> /home/developer/.tmux.conf && \
    echo "set -g status-bg colour234" >> /home/developer/.tmux.conf && \
    echo "set -g status-fg colour137" >> /home/developer/.tmux.conf && \
    chown developer:developer /home/developer/.tmux.conf

# ホームディレクトリの権限を設定
RUN chown -R developer:developer /home/developer

# envsubstツールを追加（環境変数展開用）
RUN apk add --no-cache gettext

# entrypointスクリプトをコピー
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# 作業ディレクトリを設定
WORKDIR /workspace

# entrypointを設定（rootで実行してからdeveloperに切り替える）
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["fish"]
