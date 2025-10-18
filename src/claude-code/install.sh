#!/usr/bin/env bash
set -e

# Determine the appropriate non-root user
USERNAME="${USERNAME:-"automatic"}"
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u ${CURRENT_USER} > /dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

echo "Installing Claude Code CLI via Homebrew..."

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is required but not found."
    echo "Please install the 'homebrew' feature before installing claude-code."
    exit 1
fi

echo "Homebrew found: $(brew --version | head -n 1)"

# Install Claude Code via Homebrew
echo "Installing claude-code via homebrew..."
if [ "${USERNAME}" = "root" ]; then
    # If we must run as root, use HOMEBREW_FORCE_BREWED_CURL
    export HOMEBREW_NO_AUTO_UPDATE=1
    export NONINTERACTIVE=1
    HOMEBREW_FORCE_BREWED_CURL=1 brew install claude-code || {
        echo "Warning: brew install failed as root, trying with su..."
        # Create a temporary user if needed
        if ! id -u linuxbrew > /dev/null 2>&1; then
            useradd -m -s /bin/bash linuxbrew
        fi
        chown -R linuxbrew:linuxbrew /home/linuxbrew/.linuxbrew
        mkdir -p /home/linuxbrew/.cache
        chown -R linuxbrew:linuxbrew /home/linuxbrew/.cache
        su - linuxbrew << 'EOF'
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
export HOMEBREW_NO_AUTO_UPDATE=1
brew install claude-code
EOF
    }
else
    # Run as non-root user
    su - ${USERNAME} << 'EOF'
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
export HOMEBREW_NO_AUTO_UPDATE=1
brew install claude-code
EOF
fi

# Verify installation
echo "✅ Claude Code CLI installed successfully!"
echo "Claude Code version:"
claude --version

echo "Done!"
