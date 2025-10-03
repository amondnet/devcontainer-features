#!/usr/bin/env bash
set -e

VERSION=${VERSION:-"22"}
INSTALLLTS=${INSTALLLTS:-"true"}

echo "Installing fnm..."

# Install fnm
curl -fsSL https://fnm.vercel.app/install | bash

# Setup fnm environment
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd)"

# Install Node.js versions
if [ "${INSTALLLTS}" = "true" ]; then
    echo "Installing Node.js LTS..."
    fnm install --lts
fi

if [ -n "${VERSION}" ]; then
    echo "Installing Node.js ${VERSION}..."
    fnm install "${VERSION}"
    fnm alias default "${VERSION}"
    fnm use "${VERSION}"
fi

# Add nvm alias for compatibility
if [ -f "${HOME}/.zshrc" ]; then
    echo 'alias nvm="fnm"' >> "${HOME}/.zshrc"
fi

if [ -f "${HOME}/.bashrc" ]; then
    echo 'alias nvm="fnm"' >> "${HOME}/.bashrc"
fi

echo "✅ fnm installed successfully!"
node --version
npm --version