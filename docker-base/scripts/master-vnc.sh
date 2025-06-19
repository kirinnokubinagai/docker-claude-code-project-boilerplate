#!/bin/bash
# Master Claude Teams System with VNC support

# VNCサポートを有効化
export PLAYWRIGHT_VNC_ENABLED=true

# 通常のmasterコマンドを実行
exec /opt/claude-system/scripts/master-claude-teams.sh "$@"