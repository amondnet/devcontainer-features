#!/usr/bin/env bash
set -e

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release

BUN_VERSION=${VERSION:-"latest"}

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

echo "Installing Bun via Homebrew..."
echo "Bun version: ${BUN_VERSION}"

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is required but not found."
    echo "Please install the 'homebrew' feature before installing bun."
    exit 1
fi

echo "Homebrew found: $(brew --version | head -n 1)"

# Install Bun via Homebrew
echo "Installing bun via homebrew..."
if [ "${USERNAME}" = "root" ]; then
    # If we must run as root, use HOMEBREW_FORCE_BREWED_CURL
    export HOMEBREW_NO_AUTO_UPDATE=1
    export NONINTERACTIVE=1
    if [ "${BUN_VERSION}" = "latest" ] || [ "${BUN_VERSION}" = "none" ]; then
        HOMEBREW_FORCE_BREWED_CURL=1 brew install bun || {
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
brew install bun
EOF
        }
    else
        HOMEBREW_FORCE_BREWED_CURL=1 brew install bun@${BUN_VERSION} || {
            echo "Warning: brew install failed as root, trying with su..."
            if ! id -u linuxbrew > /dev/null 2>&1; then
                useradd -m -s /bin/bash linuxbrew
            fi
            chown -R linuxbrew:linuxbrew /home/linuxbrew/.linuxbrew
            mkdir -p /home/linuxbrew/.cache
            chown -R linuxbrew:linuxbrew /home/linuxbrew/.cache
            su - linuxbrew << EOF
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:\$PATH"
export HOMEBREW_NO_AUTO_UPDATE=1
brew install bun@${BUN_VERSION}
EOF
        }
    fi
else
    # Run as non-root user
    export HOMEBREW_NO_AUTO_UPDATE=1
    if [ "${BUN_VERSION}" = "latest" ] || [ "${BUN_VERSION}" = "none" ]; then
        su - ${USERNAME} << 'EOF'
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
export HOMEBREW_NO_AUTO_UPDATE=1
brew install bun
EOF
    else
        su - ${USERNAME} << EOF
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:\$PATH"
export HOMEBREW_NO_AUTO_UPDATE=1
brew install bun@${BUN_VERSION}
EOF
    fi
fi

# Verify installation
echo "✅ Bun installed successfully!"
echo "Bun version:"
bun --version

echo "Done!"
