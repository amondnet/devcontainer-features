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

# Setup environment for node (may be from nvm or fnm depending on which node feature is used)
# Check for fnm (amondnet feature) first - it's the primary node installer
if [ -d "/usr/local/share/fnm" ]; then
    export FNM_DIR="/usr/local/share/fnm"
    export PATH="$FNM_DIR:$PATH"
    # Always evaluate fnm env to set up shell functions and paths
    eval "$(fnm env --use-on-cd --fnm-dir $FNM_DIR)"
    # Activate default node version
    DEFAULT_VERSION=$(fnm list 2>/dev/null | grep 'default' | grep -oP 'v\d+\.\d+\.\d+' | head -n1)
    if [ -n "$DEFAULT_VERSION" ]; then
        fnm use "$DEFAULT_VERSION" 2>/dev/null || true
    else
        # If no default is set, use the first available version
        FIRST_VERSION=$(fnm list 2>/dev/null | grep -oP 'v\d+\.\d+\.\d+' | head -n1)
        if [ -n "$FIRST_VERSION" ]; then
            fnm use "$FIRST_VERSION" 2>/dev/null || true
        fi
    fi
# Check for nvm (official devcontainers feature)
elif [ -d "/usr/local/share/nvm" ]; then
    export NVM_DIR="/usr/local/share/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
fi

# Setup PATH to include /usr/local/bin where node symlinks should be
export PATH="/usr/local/bin:$PATH"

# Verify node and npm are available
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is required but not found."
    echo "Please install the 'node' feature before installing graphite."
    echo ""
    echo "Debugging information:"
    echo "  PATH: $PATH"
    echo "  FNM_DIR: ${FNM_DIR:-not set}"
    if [ -d "/usr/local/share/fnm" ]; then
        echo "  fnm installed versions:"
        fnm list 2>/dev/null || echo "    (fnm list failed)"
    else
        echo "  fnm not found in /usr/local/share/fnm"
    fi
    echo "  /usr/local/bin/node* files:"
    ls -la /usr/local/bin/node* 2>/dev/null || echo "    (no node binaries found)"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ npm is required but not found."
    echo "Please ensure the 'node' feature is properly installed."
    echo ""
    echo "Debugging information:"
    echo "  PATH: $PATH"
    echo "  node location: $(command -v node)"
    echo "  node version: $(node --version)"
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
