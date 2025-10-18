#!/usr/bin/env bash
set -e

# Save VERSION option before sourcing os-release
FLUTTER_VERSION=${VERSION:-"stable"}
export FVM_HOME="/usr/local/share/fvm"

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release

# Get an adjusted ID independent of distro variants
ADJUSTED_ID="${ID}"
if [ "${ID}" = "debian" ] || [ "${ID_LIKE#*debian*}" != "${ID_LIKE}" ]; then
    ADJUSTED_ID="debian"
elif [ "${ID}" = "rhel" ] || [ "${ID}" = "fedora" ] || [ "${ID}" = "mariner" ] || [ "${ID_LIKE#*rhel*}" != "${ID_LIKE}" ] || [ "${ID_LIKE#*fedora*}" != "${ID_LIKE}" ] || [ "${ID_LIKE#*mariner*}" != "${ID_LIKE}" ]; then
    ADJUSTED_ID="rhel"
fi

# Setup INSTALL_CMD & PKG_MGR_CMD
if type apt-get > /dev/null 2>&1; then
    PKG_MGR_CMD=apt-get
    INSTALL_CMD="${PKG_MGR_CMD} -y install --no-install-recommends"
elif type microdnf > /dev/null 2>&1; then
    PKG_MGR_CMD=microdnf
    INSTALL_CMD="${PKG_MGR_CMD} -y install --refresh --best --nodocs --noplugins --setopt=install_weak_deps=0"
elif type dnf > /dev/null 2>&1; then
    PKG_MGR_CMD=dnf
    INSTALL_CMD="${PKG_MGR_CMD} -y install"
elif type yum > /dev/null 2>&1; then
    PKG_MGR_CMD=yum
    INSTALL_CMD="${PKG_MGR_CMD} -y install"
else
    echo "(Error) Unable to find a supported package manager."
    exit 1
fi

pkg_mgr_update() {
    case ${ADJUSTED_ID} in
        debian)
            if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
                echo "Running apt-get update..."
                ${PKG_MGR_CMD} update -y
            fi
            ;;
        rhel)
            if [ ${PKG_MGR_CMD} = "microdnf" ]; then
                if [ "$(ls /var/cache/yum/* 2>/dev/null | wc -l)" = 0 ]; then
                    echo "Running ${PKG_MGR_CMD} makecache..."
                    ${PKG_MGR_CMD} makecache
                fi
            else
                if [ "$(ls /var/cache/${PKG_MGR_CMD}/* 2>/dev/null | wc -l)" = 0 ]; then
                    echo "Running ${PKG_MGR_CMD} check-update..."
                    set +e
                    stderr_messages=$(${PKG_MGR_CMD} -q check-update 2>&1)
                    rc=$?
                    if [ $rc != 0 ] && [ $rc != 100 ]; then
                        echo "(Error) ${PKG_MGR_CMD} check-update produced the following error message(s):"
                        echo "${stderr_messages}"
                        exit 1
                    fi
                    set -e
                fi
            fi
            ;;
    esac
}

# Checks if packages are installed and installs them if not
check_packages() {
    case ${ADJUSTED_ID} in
        debian)
            if ! dpkg -s "$@" > /dev/null 2>&1; then
                pkg_mgr_update
                ${INSTALL_CMD} "$@"
            fi
            ;;
        rhel)
            if ! rpm -q "$@" > /dev/null 2>&1; then
                pkg_mgr_update
                ${INSTALL_CMD} "$@"
            fi
            ;;
    esac
}

# Clean up
clean_up() {
    case ${ADJUSTED_ID} in
        debian)
            rm -rf /var/lib/apt/lists/*
            ;;
        rhel)
            rm -rf /var/cache/dnf/* /var/cache/yum/*
            ;;
    esac
}

echo "Installing Flutter via FVM..."
echo "Flutter channel: ${FLUTTER_VERSION}"
echo "FVM home: ${FVM_HOME}"

# Install required packages
check_packages curl ca-certificates git unzip xz-utils

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

# Verify Homebrew is available
if ! command -v brew > /dev/null 2>&1; then
    echo "ERROR: Homebrew is required but not found. Please ensure the homebrew feature is installed."
    exit 1
fi

echo "Homebrew found: $(brew --version | head -n 1)"

# Install FVM via Homebrew
echo "Installing FVM via Homebrew..."
if [ "${USERNAME}" = "root" ]; then
    # If we must run as root, use HOMEBREW_FORCE_BREWED_CURL
    export HOMEBREW_NO_AUTO_UPDATE=1
    export NONINTERACTIVE=1
    HOMEBREW_FORCE_BREWED_CURL=1 brew tap leoafarias/fvm || {
        echo "Warning: brew tap failed as root, trying with su..."
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
brew tap leoafarias/fvm
brew install fvm
EOF
    }
    HOMEBREW_FORCE_BREWED_CURL=1 brew install fvm || true
else
    # Run as non-root user
    su - ${USERNAME} << 'EOF'
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
export HOMEBREW_NO_AUTO_UPDATE=1
brew tap leoafarias/fvm
brew install fvm
EOF
fi

# Verify FVM installation
if ! command -v fvm > /dev/null 2>&1; then
    echo "ERROR: FVM installation failed - fvm command not found in PATH"
    exit 1
fi

echo "FVM installed successfully:"
fvm --version

# Create system-wide FVM cache directory
mkdir -p "${FVM_HOME}"

# Install Flutter version
echo "Installing Flutter ${FLUTTER_VERSION}..."
FVM_HOME="${FVM_HOME}" fvm install "${FLUTTER_VERSION}"

# Set global Flutter version
echo "Setting global Flutter version to ${FLUTTER_VERSION}..."
FVM_HOME="${FVM_HOME}" fvm global "${FLUTTER_VERSION}"

# Verify Flutter installation
echo "Verifying Flutter installation..."
if [ -f "${FVM_HOME}/default/bin/flutter" ]; then
    echo "✅ Flutter installed successfully!"
    echo "Flutter version:"
    "${FVM_HOME}/default/bin/flutter" --version
else
    echo "ERROR: Flutter binary not found at ${FVM_HOME}/default/bin/flutter"
    echo "Contents of ${FVM_HOME}:"
    ls -la "${FVM_HOME}" || true
    exit 1
fi

# Clean up
clean_up

echo "Done!"
