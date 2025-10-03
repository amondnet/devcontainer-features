#!/usr/bin/env bash
set -e

INSTALLBUN=${INSTALLBUN:-"true"}
INSTALLDENO=${INSTALLDENO:-"true"}
INSTALLSDKMAN=${INSTALLSDKMAN:-"true"}
INSTALLCLAUDECODE=${INSTALLCLAUDECODE:-"true"}
INSTALLFVM=${INSTALLFVM:-"true"}

echo "Installing development tools..."

# Install SDKMAN
if [ "${INSTALLSDKMAN}" = "true" ]; then
    echo "Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
    echo "✅ SDKMAN installed"
fi

# Install Bun
if [ "${INSTALLBUN}" = "true" ]; then
    echo "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    echo "✅ Bun installed"
fi

# Install Deno
if [ "${INSTALLDENO}" = "true" ]; then
    echo "Installing Deno..."
    curl -fsSL https://deno.land/install.sh | sh -s -- --yes
    echo "✅ Deno installed"
fi

# Install Claude Code CLI
if [ "${INSTALLCLAUDECODE}" = "true" ]; then
    echo "Installing Claude Code CLI..."
    curl -fsSL https://claude.ai/install.sh | bash

    # Add to PATH
    if [ -f "${HOME}/.zshrc" ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.zshrc"
    fi
    if [ -f "${HOME}/.bashrc" ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.bashrc"
    fi

    echo "✅ Claude Code CLI installed"
fi

# Install FVM
if [ "${INSTALLFVM}" = "true" ]; then
    echo "Installing FVM..."
    curl -fsSL https://fvm.app/install.sh | bash
    echo "✅ FVM installed"
fi

echo "✅ All development tools installed successfully!"