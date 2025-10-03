#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'graphite' feature with no options.

set -e

# Optional: Import test library bundled with the devcontainer CLI
# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "gt installed" bash -c "command -v gt"
check "gt version" bash -c "gt --version"

# Report result
reportResults
