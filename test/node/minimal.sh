#!/bin/bash

# Test for minimal node installation with version 20 only (no LTS, no yarn, no pnpm)

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

# Check node version starts with v20
check "node version 20" bash -c "node --version | grep -q '^v20\.'"

check "npm installed" bash -c "command -v npm"
check "npm version" bash -c "npm --version"

# Check yarn NOT installed (disabled in scenario)
check "yarn not installed" bash -c "! command -v yarn"

# Check pnpm NOT installed (disabled in scenario)
check "pnpm not installed" bash -c "! command -v pnpm"

# Check that ONLY version 20 is installed (installLts: false)
check "only v20 installed" bash -c "fnm list | grep -q '^[* ]*v20\.' && ! fnm list | grep -q 'lts-latest'"

# Check nvm alias
check "nvm alias configuration" bash -c "grep -q 'alias nvm' $HOME/.zshrc || grep -q 'alias nvm' $HOME/.bashrc"

# Test node execution
check "node execution" bash -c "node -e \"console.log('test')\""

# Report result
reportResults
