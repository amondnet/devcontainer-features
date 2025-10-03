#!/usr/bin/env bash
set -e

echo "Installing Oh My Posh..."

# Install Oh My Posh
curl -s https://ohmyposh.dev/install.sh | bash -s

# Setup PATH
export PATH="$HOME/.local/bin:$PATH"

# Add Oh My Posh initialization to shell configs
if [ -f "${HOME}/.zshrc" ]; then
    echo '' >> "${HOME}/.zshrc"
    echo '# Oh My Posh initialization' >> "${HOME}/.zshrc"
    echo 'eval "$(oh-my-posh init zsh)"' >> "${HOME}/.zshrc"
fi

if [ -f "${HOME}/.bashrc" ]; then
    echo '' >> "${HOME}/.bashrc"
    echo '# Oh My Posh initialization' >> "${HOME}/.bashrc"
    echo 'eval "$(oh-my-posh init bash)"' >> "${HOME}/.bashrc"
fi

echo "✅ Oh My Posh installed successfully!"
oh-my-posh --version