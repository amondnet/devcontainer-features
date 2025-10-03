#!/usr/bin/env bash
set -e

echo "Installing Homebrew..."

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Setup Homebrew environment
BREW_PREFIX="/home/linuxbrew/.linuxbrew"
if [ -d "${BREW_PREFIX}" ]; then
    # Add to shell configs
    if [ -f "${HOME}/.zshrc" ]; then
        echo "eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\"" >> "${HOME}/.zshrc"
    fi

    if [ -f "${HOME}/.bashrc" ]; then
        echo "eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\"" >> "${HOME}/.bashrc"
    fi

    # Activate for current session
    eval "$(${BREW_PREFIX}/bin/brew shellenv)"
fi

echo "✅ Homebrew installed successfully!"
brew --version