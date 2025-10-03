#!/usr/bin/env bash
set -e

echo "Installing Claude Code CLI..."

# Install Claude Code
curl -fsSL https://claude.ai/install.sh | bash

# Setup PATH
export PATH="$HOME/.local/bin:$PATH"

# Add to shell configs
if [ -f "${HOME}/.zshrc" ]; then
    grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' "${HOME}/.zshrc" || \
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.zshrc"
fi

if [ -f "${HOME}/.bashrc" ]; then
    grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' "${HOME}/.bashrc" || \
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.bashrc"
fi

echo "✅ Claude Code CLI installed successfully!"
if command -v claude &> /dev/null; then
    claude --version
fi
