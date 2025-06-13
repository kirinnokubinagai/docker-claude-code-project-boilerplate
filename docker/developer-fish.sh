#!/bin/sh
# Developer Fish wrapper script
# docker compose execで実行される際にdeveloperユーザーでfishを起動

# 作業ディレクトリを明示的に設定
cd /workspace 2>/dev/null || cd /home/developer

if [ "$(id -u)" = "0" ]; then
    # rootユーザーの場合、developerに切り替えてfishを起動
    exec su developer -c "cd /workspace 2>/dev/null || cd /home/developer; exec fish"
else
    # すでにdeveloperユーザーの場合、fishを起動
    exec fish
fi