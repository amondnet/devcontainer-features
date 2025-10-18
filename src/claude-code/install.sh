#!/usr/bin/env bash
set -e

CLAUDE_VERSION=${VERSION:-"stable"}

echo "Installing Claude Code CLI..."
echo "Claude Code version: ${CLAUDE_VERSION}"

# Determine target user
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
elif [ "${USERNAME}" = "none" ] || ! id -u "${USERNAME}" > /dev/null 2>&1; then
    USERNAME=root
fi

# Get user home directory
if [ "${USERNAME}" = "root" ]; then
    USER_HOME="/root"
else
    USER_HOME="/home/${USERNAME}"
fi

echo "Installing for user: ${USERNAME}"
echo "Home directory: ${USER_HOME}"

# Check for curl (required by install script)
if ! command -v curl > /dev/null 2>&1; then
    echo "Installing curl..."
    if type apt-get > /dev/null 2>&1; then
        apt-get update && apt-get install -y curl
    elif type dnf > /dev/null 2>&1; then
        dnf install -y curl
    elif type yum > /dev/null 2>&1; then
        yum install -y curl
    else
        echo "ERROR: Cannot install curl - no supported package manager found"
        exit 1
    fi
fi

# Install Claude Code via official install script (installs to ~/.local/bin)
if [ "${USERNAME}" = "root" ]; then
    # Install as root
    curl -fsSL https://claude.ai/install.sh | bash -s "${CLAUDE_VERSION}"
else
    # Install as target user
    su - "${USERNAME}" -c "curl -fsSL https://claude.ai/install.sh | bash -s '${CLAUDE_VERSION}'"
fi

# Verify installation by checking the expected location
CLAUDE_BIN="${USER_HOME}/.local/bin/claude"
if [ ! -f "${CLAUDE_BIN}" ]; then
    echo "ERROR: Claude Code installation failed - binary not found at ${CLAUDE_BIN}"
    exit 1
fi

echo "✅ Claude Code CLI installed successfully at ${CLAUDE_BIN}"

# Verify it's executable and show version
if [ "${USERNAME}" = "root" ]; then
    "${CLAUDE_BIN}" --version
else
    su - "${USERNAME}" -c "${CLAUDE_BIN} --version"
fi

# Ensure ~/.local/bin is in profile files for all shells
LOCAL_BIN_PATH="${USER_HOME}/.local/bin"

# Add to .bashrc
if [ -f "${USER_HOME}/.bashrc" ]; then
    if ! grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' "${USER_HOME}/.bashrc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${USER_HOME}/.bashrc"
    fi
fi

# Add to .zshrc if it exists
if [ -f "${USER_HOME}/.zshrc" ]; then
    if ! grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' "${USER_HOME}/.zshrc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${USER_HOME}/.zshrc"
    fi
fi

# Copy to root for tests (if installing for non-root user)
if [ "${USERNAME}" != "root" ]; then
    mkdir -p /root/.local/bin
    cp "${CLAUDE_BIN}" /root/.local/bin/
    echo "Copied claude to /root/.local/bin for test execution"
fi

echo "Done!"
