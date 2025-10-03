#!/bin/bash

# Test for node with version 22, LTS, yarn, and pnpm

set -e

# Optional: Import test library bundled with the devcontainer CLI
# shellcheck source=/dev/null
source dev-container-features-test-lib

# Setup fnm environment if needed
export PATH="$HOME/.local/share/fnm:$PATH"
if command -v fnm &> /dev/null; then
    eval "$(fnm env --use-on-cd 2>/dev/null || fnm env 2>/dev/null)" || true
fi

# Feature-specific tests
check "fnm installed" bash -c "command -v fnm"
check "fnm version" bash -c "fnm --version"

check "node installed" bash -c "command -v node"

# Check node version starts with v22
check "node version 22" bash -c "node --version | grep -q '^v22\.'"

check "npm installed" bash -c "command -v npm"
check "npm version" bash -c "npm --version"

# Check yarn (enabled in scenario)
check "yarn installed" bash -c "command -v yarn"
check "yarn version" bash -c "yarn --version"

# Check pnpm (enabled in scenario)
check "pnpm installed" bash -c "command -v pnpm"
check "pnpm version" bash -c "pnpm --version"

# Check that LTS is also installed (installLts: true)
check "lts version installed" bash -c "fnm list | grep -q 'lts-latest'"

# Check nvm alias
check "nvm alias configuration" bash -c "grep -q 'alias nvm' $HOME/.zshrc || grep -q 'alias nvm' $HOME/.bashrc"

# Test node execution
check "node execution" bash -c "node -e \"console.log('test')\""

# Report result
reportResults
