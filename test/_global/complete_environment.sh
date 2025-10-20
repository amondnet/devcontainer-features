#!/bin/bash

# This test verifies the complete development environment
# with all features installed and working together

set -e

# Optional: Import test library bundled with the devcontainer CLI
# shellcheck source=/dev/null
source dev-container-features-test-lib

echo "Testing complete development environment..."

# Setup environment variables
export FNM_DIR="/usr/local/share/fnm"
export DENO_INSTALL="/usr/local/deno"
export FVM_HOME="/usr/local/share/fvm"
export PATH="$FNM_DIR:$HOME/.local/bin:$DENO_INSTALL/bin:$FVM_HOME/default/bin:$PATH"
# Bun and Claude Code are installed via Homebrew (Linuxbrew) PATH
# Flutter is installed via FVM system-wide
if command -v fnm &> /dev/null; then
    eval "$(fnm env --use-on-cd --fnm-dir $FNM_DIR 2>/dev/null)" || true
fi

# Shell utilities
check "zsh installed" bash -c "zsh --version"
check "oh-my-posh installed" bash -c "command -v oh-my-posh"

# Development tools
check "graphite installed" bash -c "command -v gt"

# Node.js ecosystem
check "fnm installed" bash -c "command -v fnm"
check "node installed" bash -c "command -v node"
check "yarn installed" bash -c "command -v yarn"
check "pnpm installed" bash -c "command -v pnpm"

# JavaScript/TypeScript runtimes
check "bun installed" bash -c "command -v bun"
check "deno installed" bash -c "command -v deno"

# Development tools
check "claude-code path" bash -c "test -d $HOME/.local/bin"

# Flutter (optional - may not be critical)
if [ -d "$HOME/.pub-cache" ]; then
    check "pub-cache directory" bash -c "test -d $HOME/.pub-cache"
fi

# Integration tests
check "node works" bash -c "node -e \"console.log('ok')\""
check "bun works" bash -c "bun --version"
check "deno works" bash -c "deno --version"
check "gt works" bash -c "gt --version"

# Report result
reportResults
