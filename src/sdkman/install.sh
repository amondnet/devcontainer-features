#!/usr/bin/env bash
set -e

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


echo "Installing SDKMAN..."

# Install required packages
check_packages curl ca-certificates zip unzip

# Install SDKMAN
curl -s "https://get.sdkman.io" | bash

# Setup SDKMAN environment
export SDKMAN_DIR="$HOME/.sdkman"

# Source SDKMAN initialization in shell configs
if [ -f "${HOME}/.zshrc" ]; then
    echo '' >> "${HOME}/.zshrc"
    echo '# SDKMAN initialization' >> "${HOME}/.zshrc"
    echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> "${HOME}/.zshrc"
    echo '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"' >> "${HOME}/.zshrc"
fi

if [ -f "${HOME}/.bashrc" ]; then
    echo '' >> "${HOME}/.bashrc"
    echo '# SDKMAN initialization' >> "${HOME}/.bashrc"
    echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> "${HOME}/.bashrc"
    echo '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"' >> "${HOME}/.bashrc"
fi

# Source for current session
source "$HOME/.sdkman/bin/sdkman-init.sh"

echo "✅ SDKMAN installed successfully!"
sdk version

# Clean up
clean_up

echo "Done!"
