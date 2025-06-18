#!/bin/bash
# Host Playwright Executor
# コンテナからホスト側でPlaywrightを実行するスクリプト

# SSHを使用してホストで実行
ssh -o StrictHostKeyChecking=no host.docker.internal "cd $PWD && npx playwright $@"