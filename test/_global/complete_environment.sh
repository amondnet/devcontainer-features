#!/bin/bash

# This test verifies the complete development environment
# with all features installed and working together

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

echo "Testing complete development environment..."

# Shell utilities
check "zsh installed" zsh --version
check "oh-my-posh installed" command -v oh-my-posh

# Package managers
check "brew installed" command -v brew
check "graphite installed" command -v gt

# Node.js ecosystem
check "fnm installed" command -v fnm
check "node installed" command -v node
check "yarn installed" command -v yarn
check "pnpm installed" command -v pnpm

# JavaScript/TypeScript runtimes
check "bun installed" command -v bun
check "deno installed" command -v deno

# JVM ecosystem
check "sdkman directory" test -d ~/.sdkman

# Development tools
check "claude-code path" test -d ~/.local/bin

# Flutter
check "pub-cache directory" test -d ~/.pub-cache || echo "FVM not critical"

# Integration tests
check "node works" node -e "console.log('ok')"
check "bun works" bun --version
check "deno works" deno --version
check "brew works" brew --version

# Report result
reportResults
