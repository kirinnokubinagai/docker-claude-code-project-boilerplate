#!/bin/bash
# ユーザーレベルでデプロイツールをインストールするスクリプト

set -e

echo "🔍 プロジェクトタイプを検出中..."

# pnpm のグローバルディレクトリを設定（ユーザーディレクトリ）
PNPM_HOME="$HOME/.local/share/pnpm"
mkdir -p "$PNPM_HOME"
export PNPM_HOME
export PATH="$PNPM_HOME:$PATH"

# pnpm設定
pnpm config set global-bin-dir "$PNPM_HOME"
pnpm config set global-dir "$PNPM_HOME"

# ビルドスクリプトを承認（セキュリティ設定）
pnpm config set enable-pre-post-scripts true

# PATHに追加（永続化）
if ! grep -q "PNPM_HOME=" ~/.bashrc; then
    echo 'export PNPM_HOME="$HOME/.local/share/pnpm"' >> ~/.bashrc
    echo 'export PATH="$PNPM_HOME:$PATH"' >> ~/.bashrc
fi

# Web Framework Detection
if [ -f package.json ]; then
    if grep -q '"next"' package.json; then
        echo "📦 Next.js detected → Installing Vercel CLI"
        pnpm add -g vercel
        echo "✅ Vercel CLI installed. Deploy with: vercel --prod"
    elif grep -q '"@remix-run"' package.json; then
        echo "📦 Remix detected → Installing Fly.io CLI"
        curl -L https://fly.io/install.sh | sh -s -- --prefix="$HOME/.fly"
        echo 'export PATH="$HOME/.fly/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/.fly/bin:$PATH"
        echo "✅ Fly CLI installed. Deploy with: fly deploy"
    elif grep -q '"nuxt"' package.json; then
        echo "📦 Nuxt detected → Installing deployment CLIs"
        pnpm add -g vercel netlify-cli
        echo "✅ Deploy with: vercel --prod or netlify deploy --prod"
    elif grep -q '"vite\|vue\|react"' package.json && ! grep -q '"next\|remix"' package.json; then
        echo "📦 Static site detected → Installing Netlify CLI"
        pnpm add -g netlify-cli
        echo "✅ Netlify CLI installed. Deploy with: netlify deploy --prod"
    fi
fi

# Mobile Framework Detection
if [ -f package.json ] && grep -q '"react-native"' package.json; then
    if grep -q '"expo"' package.json; then
        echo "📱 React Native + Expo detected → Installing Expo/EAS CLI"
        pnpm add -g expo-cli eas-cli
        echo "✅ Expo & EAS CLI installed"
        echo "   Development: expo start"
        echo "   Build: eas build --platform all"
        echo "   Submit: eas submit"
    else
        echo "📱 React Native detected → Installing React Native CLI"
        pnpm add -g react-native-cli
        echo "✅ React Native CLI installed"
    fi
fi

# Python Web Framework Detection
if [ -f requirements.txt ] || [ -f pyproject.toml ]; then
    if grep -qE "django|flask|fastapi" requirements.txt pyproject.toml 2>/dev/null; then
        echo "🐍 Python Web project detected → Installing Railway CLI"
        pnpm add -g @railway/cli
        echo "✅ Railway CLI installed. Deploy with: railway up"
    fi
fi

echo ""
echo "✅ デプロイツールのセットアップが完了しました"
echo ""
echo "⚠️  新しいPATHを有効にするには以下を実行してください："
echo "    source ~/.bashrc"
echo "    または新しいターミナルを開いてください"