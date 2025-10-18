#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'bun' feature with no options.
#
# Thanks to 'dependsOn', homebrew will be automatically installed!

set -e

# Optional: Import test library bundled with the devcontainer CLI
# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "bun installed" bash -c "command -v bun"
check "bun version" bash -c "bun --version"

# Test bun execution
check "bun works" bash -c "bun --help | head -n 1"

# Report result
reportResults
