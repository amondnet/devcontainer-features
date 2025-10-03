#!/usr/bin/env bash
set -e

echo "Installing Zimfw..."

# Install Zimfw
export ZIM_HOME="${HOME}/.zim"
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

echo "✅ Zimfw installed successfully!"