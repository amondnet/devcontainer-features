#!/bin/bash

# This test verifies a full-stack development environment setup
# with shell utilities, Node.js ecosystem, and modern runtimes

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test shell utilities
check "zsh installed" zsh --version
check "oh-my-posh installed" command -v oh-my-posh

# Test Node.js ecosystem
check "fnm installed" command -v fnm
check "node installed" command -v node
check "npm installed" command -v npm
check "yarn installed" command -v yarn
check "pnpm installed" command -v pnpm

# Test Homebrew
check "brew installed" command -v brew

# Test modern runtimes
check "bun installed" command -v bun
check "deno installed" command -v deno

# Verify integrations work
check "node execution" node -e "console.log('Node.js works')"
check "bun execution" bun --version
check "deno execution" deno eval "console.log('Deno works')"

# Report result
reportResults
