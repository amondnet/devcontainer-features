#!/bin/bash

# This test verifies a minimal JavaScript development environment
# with shell utilities, Node.js 20 (no yarn/pnpm), and Bun

set -e

# Optional: Import test library bundled with the devcontainer CLI
# shellcheck source=/dev/null
source dev-container-features-test-lib

# Setup environment
export FNM_DIR="/usr/local/share/fnm"
export PATH="$FNM_DIR:$HOME/.local/bin:$HOME/.bun/bin:$PATH"
if command -v fnm &> /dev/null; then
    eval "$(fnm env --use-on-cd --fnm-dir $FNM_DIR 2>/dev/null)" || true
fi

# Test shell utilities
check "zsh installed" bash -c "zsh --version"

# Test Node.js (version 20, without yarn and pnpm)
check "fnm installed" bash -c "command -v fnm"
check "node installed" bash -c "command -v node"
check "npm installed" bash -c "command -v npm"
check "yarn not installed" bash -c "! command -v yarn"
check "pnpm not installed" bash -c "! command -v pnpm"

# Test Bun
check "bun installed" bash -c "command -v bun"

# Verify execution
check "node execution" bash -c "node -e \"console.log('Node.js works')\""
check "bun execution" bash -c "bun --version"

# Report result
reportResults
