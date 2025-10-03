#!/usr/bin/env bash
set -e

# Import options
VERSION=${VERSION:-"lts"}
INSTALLLTS=${INSTALLLTS:-"true"}
INSTALLYARN=${INSTALLYARN:-"true"}
INSTALLPNPM=${INSTALLPNPM:-"true"}
PNPMVERSION=${PNPMVERSION:-"latest"}
NVMALIAS=${NVMALIAS:-"true"}

echo "=========================================="
echo "Installing Node.js via fnm..."
echo "=========================================="

# Detect the user to install for (same logic as official features)
USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u "${CURRENT_USER}" > /dev/null 2>&1; then
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

USER_HOME="/home/${USERNAME}"
if [ "${USERNAME}" = "root" ]; then
    USER_HOME="/root"
fi

echo "Installing for user: ${USERNAME}"
echo "Home directory: ${USER_HOME}"

# Install fnm as the target user
su - ${USERNAME} << 'EOF'
set -e

echo "Installing fnm..."
curl -fsSL https://fnm.vercel.app/install | bash

# Setup fnm environment
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd)"

EOF

# Add fnm to shell configs
cat >> "${USER_HOME}/.bashrc" << 'BASHRC_EOF'

# fnm (Fast Node Manager)
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd)"
BASHRC_EOF

if [ -f "${USER_HOME}/.zshrc" ]; then
    cat >> "${USER_HOME}/.zshrc" << 'ZSHRC_EOF'

# fnm (Fast Node Manager)
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd)"
ZSHRC_EOF
fi

# Install Node.js versions as the target user
su - ${USERNAME} << EOF
set -e

# Setup fnm environment
export PATH="\$HOME/.local/share/fnm:\$PATH"
eval "\$(fnm env --use-on-cd)"

# Install LTS if requested
if [ "${INSTALLLTS}" = "true" ]; then
    echo "Installing Node.js LTS..."
    fnm install --lts
fi

# Install specified version
if [ "${VERSION}" != "none" ]; then
    echo "Installing Node.js ${VERSION}..."
    fnm install "${VERSION}"
    fnm default "${VERSION}"
    fnm use "${VERSION}"
fi

# Show installed versions
echo "Installed Node.js versions:"
fnm list

# Show current version
node --version
npm --version

EOF

# Install Yarn if requested
if [ "${INSTALLYARN}" = "true" ]; then
    echo "Installing Yarn..."
    su - ${USERNAME} << 'EOF'
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --use-on-cd)"
    npm install -g yarn
    yarn --version
EOF
fi

# Install pnpm if requested
if [ "${INSTALLPNPM}" = "true" ]; then
    echo "Installing pnpm ${PNPMVERSION}..."
    su - ${USERNAME} << EOF
    export PATH="\$HOME/.local/share/fnm:\$PATH"
    eval "\$(fnm env --use-on-cd)"
    if [ "${PNPMVERSION}" = "latest" ]; then
        npm install -g pnpm
    else
        npm install -g pnpm@${PNPMVERSION}
    fi
    pnpm --version
EOF
fi

# Add nvm alias for compatibility if requested
if [ "${NVMALIAS}" = "true" ]; then
    echo "Adding nvm alias for compatibility..."
    echo 'alias nvm="fnm"' >> "${USER_HOME}/.bashrc"
    if [ -f "${USER_HOME}/.zshrc" ]; then
        echo 'alias nvm="fnm"' >> "${USER_HOME}/.zshrc"
    fi
fi

echo "=========================================="
echo "✅ Node.js installation completed!"
echo "=========================================="
su - ${USERNAME} << 'EOF'
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd)"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
if command -v yarn &> /dev/null; then
    echo "Yarn: $(yarn --version)"
fi
if command -v pnpm &> /dev/null; then
    echo "pnpm: $(pnpm --version)"
fi
EOF
