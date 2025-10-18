#!/usr/bin/env bash
set -e

CLAUDE_VERSION=${VERSION:-"stable"}

echo "Installing Claude Code CLI..."
echo "Claude Code version: ${CLAUDE_VERSION}"

# Check for curl (required by install script)
if ! command -v curl > /dev/null 2>&1; then
    echo "Installing curl..."
    if type apt-get > /dev/null 2>&1; then
        apt-get update && apt-get install -y curl
    elif type dnf > /dev/null 2>&1; then
        dnf install -y curl
    elif type yum > /dev/null 2>&1; then
        yum install -y curl
    else
        echo "ERROR: Cannot install curl - no supported package manager found"
        exit 1
    fi
fi

# Install Claude Code via official install script
if [ "${CLAUDE_VERSION}" = "stable" ] || [ "${CLAUDE_VERSION}" = "latest" ]; then
    curl -fsSL https://claude.ai/install.sh | bash -s "${CLAUDE_VERSION}"
else
    # Specific version
    curl -fsSL https://claude.ai/install.sh | bash -s "${CLAUDE_VERSION}"
fi

# Verify installation
if ! command -v claude > /dev/null 2>&1; then
    echo "ERROR: Claude Code installation failed - claude command not found in PATH"
    exit 1
fi

echo "✅ Claude Code CLI installed successfully!"
echo "Claude Code version:"
claude --version

echo "Done!"
