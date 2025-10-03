#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'node' feature with no options.

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
check "node version" bash -c "node --version"

check "npm installed" bash -c "command -v npm"
check "npm version" bash -c "npm --version"

# Check nvm alias (should be defined in shell config)
check "nvm alias configuration" bash -c "grep -q 'alias nvm' $HOME/.zshrc || grep -q 'alias nvm' $HOME/.bashrc"

# Test node execution
check "node execution" bash -c "node -e \"console.log('test')\""

# Report result
reportResults
