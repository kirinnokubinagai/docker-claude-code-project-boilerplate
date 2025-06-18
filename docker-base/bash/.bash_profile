#!/bin/bash
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Ensure pnpm global directory is in PATH (for claude command in non-login shells)
export PNPM_HOME=/usr/local/share/pnpm
export PATH="$PNPM_HOME:$PATH"

# User specific environment and startup programs

# Always start in workspace directory
cd /workspace 2>/dev/null || true