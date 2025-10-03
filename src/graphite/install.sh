#!/usr/bin/env bash
set -e

echo "Installing Graphite CLI..."

# Ensure Homebrew is available
BREW_PREFIX="/home/linuxbrew/.linuxbrew"
if [ -d "${BREW_PREFIX}" ]; then
    eval "$(${BREW_PREFIX}/bin/brew shellenv)"
fi

if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is required but not found. Please install homebrew feature first."
    exit 1
fi

# Install Graphite CLI via Homebrew
brew install withgraphite/tap/graphite

echo "✅ Graphite CLI installed successfully!"
gt --version