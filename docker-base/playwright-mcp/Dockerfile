FROM mcr.microsoft.com/playwright:v1.48.2-noble

WORKDIR /app

# Install Node.js 20
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Playwright MCP
RUN npm install -g @playwright/mcp@latest

# ブラウザは既にインストール済み
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

# ヘッドレスモード用の環境変数
ENV DISPLAY=:99
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

EXPOSE 8931