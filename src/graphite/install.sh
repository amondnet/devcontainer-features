#!/usr/bin/env bash
set -e

# Save feature options BEFORE sourcing /etc/os-release
GRAPHITE_VERSION="${VERSION:-"stable"}"

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release
# Get an adjusted ID independent of distro variants
ADJUSTED_ID="${ID}"
if [ "${ID}" = "debian" ] || [ "${ID_LIKE#*debian*}" != "${ID_LIKE}" ]; then
    ADJUSTED_ID="debian"
elif [ "${ID}" = "rhel" ] || [ "${ID}" = "fedora" ] || [ "${ID}" = "mariner" ] || [ "${ID_LIKE#*rhel*}" != "${ID_LIKE}" ] || [ "${ID_LIKE#*fedora*}" != "${ID_LIKE}" ] || [ "${ID_LIKE#*mariner*}" != "${ID_LIKE}" ]; then
    ADJUSTED_ID="rhel"
fi

# Clean up
clean_up() {
    case ${ADJUSTED_ID} in
        debian)
            rm -rf /var/lib/apt/lists/*
            ;;
        rhel)
            rm -rf /var/cache/dnf/* /var/cache yum/*
            ;;
    esac
}

echo "Installing Graphite CLI..."

# Setup PATH to include /usr/local/bin where node symlinks should be
export PATH="/usr/local/bin:$PATH"

# Setup environment for node (may be from nvm or fnm depending on which node feature is used)
# Check for nvm (official devcontainers feature)
if [ -d "/usr/local/share/nvm" ]; then
    export NVM_DIR="/usr/local/share/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
# Check for fnm (amondnet feature)
elif [ -d "/usr/local/share/fnm" ]; then
    export FNM_DIR="/usr/local/share/fnm"
    export PATH="$FNM_DIR:$PATH"
    # Source fnm environment if available
    if [ -s "/usr/local/bin/fnm" ]; then
        eval "$(fnm env --use-on-cd --fnm-dir $FNM_DIR)"
        # Activate default node version
        DEFAULT_VERSION=$(fnm list 2>/dev/null | grep 'default' | grep -oP 'v\d+\.\d+\.\d+' | head -n1)
        if [ -n "$DEFAULT_VERSION" ]; then
            fnm use "$DEFAULT_VERSION" 2>/dev/null || true
        fi
    fi
fi

# Verify node and npm are available
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is required but not found."
    echo "Please install a 'node' feature before installing graphite."
    echo "PATH: $PATH"
    echo "Available commands:"
    ls -la /usr/local/bin/node* 2>/dev/null || echo "No node binaries found in /usr/local/bin"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ npm is required but not found."
    echo "Please install a 'node' feature before installing graphite."
    echo "PATH: $PATH"
    exit 1
fi

echo "✅ Node.js found: $(node --version)"
echo "✅ npm found: $(npm --version)"

# Install Graphite CLI via npm globally
echo "Installing @withgraphite/graphite-cli@${GRAPHITE_VERSION}..."
npm install -g "@withgraphite/graphite-cli@${GRAPHITE_VERSION}"

echo "✅ Graphite CLI installed successfully!"
gt --version

# Clean up
clean_up

echo "Done!"
