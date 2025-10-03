#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'node' feature with no options.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "fnm installed" command -v fnm
check "fnm version" fnm --version

check "node installed" command -v node
check "node version" node --version

check "npm installed" command -v npm
check "npm version" npm --version

# Check nvm alias
check "nvm alias exists" type nvm

# Test node execution
check "node execution" node -e "console.log('test')"

# Report result
reportResults
