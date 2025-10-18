#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'claude-code' feature with no options.
#
# Thanks to 'dependsOn', homebrew will be automatically installed!

set -e

# Optional: Import test library bundled with the devcontainer CLI
# shellcheck source=/dev/null
source dev-container-features-test-lib

# Feature-specific tests
check "claude installed" bash -c "command -v claude"
check "claude version" bash -c "claude --version"

# Report result
reportResults
