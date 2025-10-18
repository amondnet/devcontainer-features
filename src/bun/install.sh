#!/usr/bin/env bash
set -e

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release

BUN_VERSION=${VERSION:-"latest"}

echo "Installing Bun via Homebrew..."
echo "Bun version: ${BUN_VERSION}"

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is required but not found."
    echo "Please install the 'homebrew' feature before installing bun."
    exit 1
fi

echo "Homebrew found: $(brew --version | head -n 1)"

# Install Bun via Homebrew
echo "Installing bun via homebrew..."
export HOMEBREW_NO_AUTO_UPDATE=1
export NONINTERACTIVE=1

if [ "${BUN_VERSION}" = "latest" ] || [ "${BUN_VERSION}" = "none" ]; then
    brew install bun
else
    brew install bun@${BUN_VERSION}
fi

# Verify installation
echo "✅ Bun installed successfully!"
echo "Bun version:"
bun --version

echo "Done!"
