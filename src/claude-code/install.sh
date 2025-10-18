#!/usr/bin/env bash
set -e

echo "Installing Claude Code CLI via Homebrew..."

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is required but not found."
    echo "Please install the 'homebrew' feature before installing claude-code."
    exit 1
fi

echo "Homebrew found: $(brew --version | head -n 1)"

# Install Claude Code via Homebrew
echo "Installing claude-code via homebrew..."
export HOMEBREW_NO_AUTO_UPDATE=1
export NONINTERACTIVE=1

brew install claude-code

# Verify installation
echo "✅ Claude Code CLI installed successfully!"
echo "Claude Code version:"
claude --version

echo "Done!"
