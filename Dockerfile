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
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    # dockerグループに追加（Docker内でdockerコマンドを使えるように）
    addgroup -S docker 2>/dev/null || true && \
    adduser developer docker

# developerユーザーの環境ディレクトリを作成
RUN mkdir -p /home/developer/.config/fish/functions \
    /home/developer/.npm \
    /home/developer/.local/share \
    /home/developer/.cache \
    /home/developer/.anthropic \
    && chown -R developer:developer /home/developer

# zのインストール
RUN curl -sS https://raw.githubusercontent.com/jethrokuan/z/master/z.fish > /home/developer/.config/fish/functions/z.fish \
    && chown developer:developer /home/developer/.config/fish/functions/z.fish

# Claude Codeをインストール（これは必要）
RUN npm install -g @anthropic-ai/claude-code

# MCPサーバーはnpxで実行時に取得するため、グローバルインストール不要
# 必要に応じて使用される開発ツールのみインストール
RUN npm install -g \
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

# developerユーザーの環境設定
USER developer
WORKDIR /home/developer

# gitの初期設定
RUN git config --global user.name "Developer" && \
    git config --global user.email "developer@claude-teams.local" && \
    git config --global init.defaultBranch main && \
    git config --global safe.directory /workspace

# .anthropicディレクトリ作成（Claude Code設定用）
RUN mkdir -p /home/developer/.anthropic

# rootに戻る（entrypointのため）
USER root

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
# デフォルトコマンドは設定しない（docker-entrypoint.shで制御）
