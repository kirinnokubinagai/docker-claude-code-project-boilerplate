#!/bin/sh
# Developer user wrapper script
# docker-compose execで実行される際にdeveloperユーザーで実行

if [ "$(id -u)" = "0" ]; then
    # rootユーザーの場合、developerに切り替え
    exec su developer -c "$0 $@"
else
    # すでにdeveloperユーザーの場合、fishを起動
    exec fish "$@"
fi