#!/usr/bin/env bash
set -e

echo "Installing Bun..."

# Install Bun
curl -fsSL https://bun.sh/install | bash

# Setup PATH
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Add to shell configs
if [ -f "${HOME}/.zshrc" ]; then
    echo 'export BUN_INSTALL="$HOME/.bun"' >> "${HOME}/.zshrc"
    echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> "${HOME}/.zshrc"
fi

if [ -f "${HOME}/.bashrc" ]; then
    echo 'export BUN_INSTALL="$HOME/.bun"' >> "${HOME}/.bashrc"
    echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> "${HOME}/.bashrc"
fi

echo "✅ Bun installed successfully!"
bun --version
