#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'graphite' feature with no options.
#
# Thanks to 'dependsOn', node will be automatically installed!

set -e

# Optional: Import test library bundled with the devcontainer CLI
# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "node installed" bash -c "command -v node"
check "npm installed" bash -c "command -v npm"
check "gt installed" bash -c "command -v gt"
check "gt version" bash -c "gt --version"

# Report result
reportResults