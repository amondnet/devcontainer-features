#!/usr/bin/env bash
set -e

VERSION=${VERSION:-"latest"}

echo "Installing Deno..."

# Install Deno
if [ "${VERSION}" = "latest" ]; then
    curl -fsSL https://deno.land/install.sh | sh -s -- --yes
else
    curl -fsSL https://deno.land/install.sh | sh -s -- --yes "${VERSION}"
fi

# Setup PATH
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# Add to shell configs
if [ -f "${HOME}/.zshrc" ]; then
    echo 'export DENO_INSTALL="$HOME/.deno"' >> "${HOME}/.zshrc"
    echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> "${HOME}/.zshrc"
fi

if [ -f "${HOME}/.bashrc" ]; then
    echo 'export DENO_INSTALL="$HOME/.deno"' >> "${HOME}/.bashrc"
    echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> "${HOME}/.bashrc"
fi

echo "✅ Deno installed successfully!"
deno --version
