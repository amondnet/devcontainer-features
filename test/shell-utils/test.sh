#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'shell-utils' feature with no options.
#
# Eg:
# {
#    "image": "<..some-base-image...>",
#    "features": {
#      "shell-utils": {}
#    }
# }
#
# This test can be run with the following command:
#
#    devcontainer features test \
#               --features shell-utils \
#               --base-image mcr.microsoft.com/devcontainers/base:ubuntu .

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "zsh installed" zsh --version
check "zshrc exists" test -f ~/.zshrc

# Check for Zimfw or Oh My Zsh
if [ -d ~/.zim ]; then
    check "zimfw directory" test -d ~/.zim
    check "zimfw init" test -f ~/.zim/init.zsh
elif [ -d ~/.oh-my-zsh ]; then
    check "ohmyzsh directory" test -d ~/.oh-my-zsh
fi

# Check Oh My Posh
check "oh-my-posh installed" command -v oh-my-posh
check "oh-my-posh version" oh-my-posh --version

# Report result
reportResults
