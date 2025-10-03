#!/usr/bin/env bash
set -e

echo "Installing FVM..."

# Install FVM
curl -fsSL https://fvm.app/install.sh | bash

# Setup PATH
export PATH="$HOME/.pub-cache/bin:$PATH"

# Add to shell configs
if [ -f "${HOME}/.zshrc" ]; then
    grep -qxF 'export PATH="$HOME/.pub-cache/bin:$PATH"' "${HOME}/.zshrc" || \
        echo 'export PATH="$HOME/.pub-cache/bin:$PATH"' >> "${HOME}/.zshrc"
fi

if [ -f "${HOME}/.bashrc" ]; then
    grep -qxF 'export PATH="$HOME/.pub-cache/bin:$PATH"' "${HOME}/.bashrc" || \
        echo 'export PATH="$HOME/.pub-cache/bin:$PATH"' >> "${HOME}/.bashrc"
fi

echo "✅ FVM installed successfully!"
if command -v fvm &> /dev/null; then
    fvm --version
fi
