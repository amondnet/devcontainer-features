#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'deno' feature with no options.

set -e

# Optional: Import test library bundled with the devcontainer CLI
# shellcheck source=/dev/null
source dev-container-features-test-lib

# Setup environment for system-wide Deno
export DENO_INSTALL="/usr/local/deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# Feature-specific tests
check "deno installed" bash -c "command -v deno"
check "deno version" bash -c "deno --version"

# Test deno execution
check "deno works" bash -c "deno eval \"console.log('Hello from Deno')\""

# Report result
reportResults
