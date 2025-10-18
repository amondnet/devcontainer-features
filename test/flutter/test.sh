#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'flutter' feature with no options.

set -e

# Optional: Import test library bundled with the devcontainer CLI
# shellcheck source=/dev/null
source dev-container-features-test-lib

# Setup environment for system-wide Flutter
export FVM_HOME="/usr/local/share/fvm"
export PATH="$FVM_HOME/default/bin:$PATH"

# Debug info for test failures
echo "=== Flutter Installation Diagnostics ==="
echo "FVM_HOME: ${FVM_HOME}"
echo "Current PATH: ${PATH}"
echo ""
echo "Checking FVM installation:"
if [ -d "${FVM_HOME}" ]; then
    echo "✓ FVM_HOME directory exists"
    ls -la "${FVM_HOME}" | head -10
else
    echo "✗ FVM_HOME directory does not exist"
fi
echo ""
if [ -f /usr/local/bin/fvm ]; then
    echo "✓ FVM symlink exists at /usr/local/bin/fvm"
else
    echo "✗ FVM symlink missing"
fi
echo ""

# Feature-specific tests
check "fvm installed" bash -c "command -v fvm"
check "fvm version" bash -c "fvm --version"
check "flutter installed" bash -c "command -v flutter"
check "flutter version" bash -c "flutter --version"
check "dart installed" bash -c "command -v dart"

# Report result
reportResults
