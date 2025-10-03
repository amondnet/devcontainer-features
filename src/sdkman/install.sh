#!/usr/bin/env bash
set -e

echo "Installing SDKMAN..."

# Install SDKMAN
curl -s "https://get.sdkman.io" | bash

# Setup SDKMAN environment
export SDKMAN_DIR="$HOME/.sdkman"

# Source SDKMAN initialization in shell configs
if [ -f "${HOME}/.zshrc" ]; then
    echo '' >> "${HOME}/.zshrc"
    echo '# SDKMAN initialization' >> "${HOME}/.zshrc"
    echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> "${HOME}/.zshrc"
    echo '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"' >> "${HOME}/.zshrc"
fi

if [ -f "${HOME}/.bashrc" ]; then
    echo '' >> "${HOME}/.bashrc"
    echo '# SDKMAN initialization' >> "${HOME}/.bashrc"
    echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> "${HOME}/.bashrc"
    echo '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"' >> "${HOME}/.bashrc"
fi

# Source for current session
source "$HOME/.sdkman/bin/sdkman-init.sh"

echo "✅ SDKMAN installed successfully!"
sdk version
