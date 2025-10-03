#!/usr/bin/env bash
set -e

# Import options
INSTALLZSH=${INSTALLZSH:-"true"}
CONFIGUREZSH_AS_DEFAULTSHELL=${CONFIGUREZSH_AS_DEFAULTSHELL:-"true"}
SHELLFRAMEWORK=${SHELLFRAMEWORK:-"zimfw"}
INSTALLOHMYPOSH=${INSTALLOHMYPOSH:-"true"}
OHMYPOSHTHEME=${OHMYPOSHTHEME:-"default"}
USERNAME=${USERNAME:-"automatic"}
UPGRADEPACKAGES=${UPGRADEPACKAGES:-"true"}

echo "=========================================="
echo "Installing Shell Utilities..."
echo "=========================================="

# Detect the user to install for (same logic as official features)
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "coder" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
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

echo "Configuring for user: ${USERNAME}"
echo "Home directory: ${USER_HOME}"

# Upgrade packages if requested
if [ "${UPGRADEPACKAGES}" = "true" ]; then
    echo "Upgrading packages..."
    if type apt-get > /dev/null 2>&1; then
        apt-get update && apt-get upgrade -y
    elif type apk > /dev/null 2>&1; then
        apk update && apk upgrade
    fi
fi

# Install Zsh if requested
if [ "${INSTALLZSH}" = "true" ]; then
    echo "Installing Zsh..."
    if type apt-get > /dev/null 2>&1; then
        apt-get install -y zsh
    elif type apk > /dev/null 2>&1; then
        apk add zsh
    fi

    # Set Zsh as default shell if requested
    if [ "${CONFIGUREZSH_AS_DEFAULTSHELL}" = "true" ]; then
        echo "Setting Zsh as default shell for ${USERNAME}..."
        chsh -s $(which zsh) ${USERNAME}
    fi
fi

# Install shell framework
if [ "${SHELLFRAMEWORK}" = "zimfw" ]; then
    echo "Installing Zimfw..."
    su - ${USERNAME} << 'EOF'
set -e
export ZIM_HOME="${HOME}/.zim"
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
EOF
    echo "✅ Zimfw installed"

elif [ "${SHELLFRAMEWORK}" = "ohmyzsh" ]; then
    echo "Installing Oh My Zsh..."
    su - ${USERNAME} << 'EOF'
set -e
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
EOF
    echo "✅ Oh My Zsh installed"
fi

# Install Oh My Posh if requested
if [ "${INSTALLOHMYPOSH}" = "true" ]; then
    echo "Installing Oh My Posh..."
    su - ${USERNAME} << 'EOF'
set -e
curl -s https://ohmyposh.dev/install.sh | bash -s
EOF

    # Add Oh My Posh to shell configs
    cat >> "${USER_HOME}/.zshrc" << 'ZSHRC_EOF'

# Oh My Posh initialization
export PATH="$HOME/.local/bin:$PATH"
eval "$(oh-my-posh init zsh)"
ZSHRC_EOF

    if [ -f "${USER_HOME}/.bashrc" ]; then
        cat >> "${USER_HOME}/.bashrc" << 'BASHRC_EOF'

# Oh My Posh initialization
export PATH="$HOME/.local/bin:$PATH"
eval "$(oh-my-posh init bash)"
BASHRC_EOF
    fi

    # Apply theme if specified
    if [ "${OHMYPOSHTHEME}" != "default" ]; then
        echo "Configuring Oh My Posh theme: ${OHMYPOSHTHEME}..."
        # Note: Theme configuration can be done by users in their shell configs
    fi

    echo "✅ Oh My Posh installed"
fi

echo "=========================================="
echo "✅ Shell utilities installation completed!"
echo "=========================================="

# Show installed components
echo "Installed components:"
if [ "${INSTALLZSH}" = "true" ]; then
    echo "  - Zsh: $(zsh --version)"
fi
if [ "${SHELLFRAMEWORK}" != "none" ]; then
    echo "  - Shell Framework: ${SHELLFRAMEWORK}"
fi
if [ "${INSTALLOHMYPOSH}" = "true" ]; then
    su - ${USERNAME} << 'EOF'
if command -v oh-my-posh &> /dev/null; then
    echo "  - Oh My Posh: $(oh-my-posh --version)"
fi
EOF
fi
