# CLAUDE.md

This file provides guidance to Claude Code when working with devcontainer features in this repository.

## Repository Information

- **Repository**: amondnet/devcontainer-features
- **Published Registry**: ghcr.io/amondnet/devcontainer-features
- **Purpose**: Custom devcontainer features for development environments

Features are modular, reusable installation units that can be composed in `devcontainer.json`.

## Repository Overview

This repository contains custom devcontainer features for development environments. Features are modular, reusable installation units that can be composed in `devcontainer.json`.

**Note**: `shell-utils` provides the same functionality as the official `common-utils` feature, offering a complete shell setup with Zsh and Oh My Zsh.

### Available Features

1. **shell-utils** - Zsh with Zimfw/Oh My Zsh + Oh My Posh
2. **node** - Node.js via fnm (Fast Node Manager, system-wide at `/usr/local/share/fnm`)
3. **deno** - Deno runtime (system-wide at `/usr/local/deno`)
4. **flutter** - Flutter (via FVM official install script, system-wide at `/usr/local/share/fvm`)
5. **bun** - Bun JavaScript runtime (via official install script at `/usr/local`)
6. **graphite** - Graphite CLI for stacked PRs (via Homebrew, requires homebrew feature)
7. **claude-code** - Claude Code CLI (via official install script)

## Architecture

Each feature follows this structure:

```
src/feature-name/
├── devcontainer-feature.json    # Metadata and options
└── install.sh                   # Installation script

test/feature-name/
├── test.sh                      # Test script
└── scenarios.json               # Optional test scenarios
```

## Key Patterns

### 1. Package Management (CRITICAL)

**Always use these utility functions** (from official devcontainer features):

```bash
check_packages curl ca-certificates unzip  # Installs only if missing
clean_up  # Removes package manager caches at end
```

These functions handle both Debian (apt) and RHEL (dnf/yum) systems automatically.

### 2. Installation Paths (System-wide vs User)

**Preferred: System-wide Installation** (no root copy needed)
- Install to `/usr/local/` paths (e.g., `/usr/local/deno`, `/usr/local/share/fnm`)
- Works automatically for both root and non-root users
- Example: node, deno features
- Environment: Set `containerEnv` in `devcontainer-feature.json`

**Alternative: User-specific Installation** (copy to root for tests)
- Install to user home (`$HOME/.config`, `$HOME/.local`)
- Tests run as root, so must copy configs to `/root/`
- Example: shell-utils, fvm, claude-code features

```bash
# For user-specific installs, copy to root after installation
if [ "${USERNAME}" != "root" ]; then
    copy_files=()
    [ -f "${USER_HOME}/.zshrc" ] && copy_files+=("${USER_HOME}/.zshrc")
    [ -d "${USER_HOME}/.zim" ] && copy_files+=("${USER_HOME}/.zim")
    if [ ${#copy_files[@]} -gt 0 ]; then
        cp -rf "${copy_files[@]}" /root/
    fi
fi
```

### 3. Shell Config Files

1. Check `/etc/skel` first (may have defaults)
2. Create if missing
3. Add PATH exports with `grep -qxF` to avoid duplicates
4. **Copy to root for non-root installs**

### 3. Dependencies (dependsOn)

Some features require other features to be installed first:

```json
{
  "dependsOn": {
    "ghcr.io/amondnet/devcontainer-features/node": {}
  }
}
```

**IMPORTANT**: Use `ghcr.io/amondnet/devcontainer-features/` prefix for all feature dependencies in this repository.

**Features with dependencies:**
- **graphite** - Requires node (from this registry)

### 4. Environment Variables (containerEnv)

Set environment variables in `devcontainer-feature.json` for system-wide installations:

```json
{
  "containerEnv": {
    "DENO_INSTALL": "/usr/local/deno",
    "PATH": "/usr/local/deno/bin:${PATH}"
  }
}
```

### 5. VS Code Customizations

All features include VS Code customizations for better developer experience:

```json
{
  "customizations": {
    "vscode": {
      "extensions": ["relevant-extensions-for-this-tool"],
      "settings": {
        "language-specific-settings": "values"
      }
    }
  }
}
```

**What features provide**:
- **shell-utils** - Remote Explorer, GitLens, Zsh terminal integration
- **node** - ESLint extension for JavaScript linting
- **deno** - Deno extension with linting and formatting
- **bun** - Bun VS Code extension
- **flutter** - Dart-Code extensions for Dart/Flutter development
- **graphite** - Git integration via Copilot instructions
- **claude-code** - Anthropic Claude Code extension

All features include GitHub Copilot chat code generation instructions for context-aware AI assistance.

## Common Commands

### Testing

```bash
# Test specific feature
cd .devcontainer/features
devcontainer features test --skip-scenarios -f feature-name -i ubuntu:latest .

# Test all features
devcontainer features test .

# Test built image directly (useful for debugging)
docker run --rm <image-id> bash -c "test -f /root/.zshrc && echo OK"
```

### Development

```bash
# Run feature install script directly
bash src/feature-name/install.sh

# Check git submodule
cd .devcontainer/features
git status
git add -A
git commit -m "feat: ..."
git push
```

## Installation Patterns by Feature

### System-wide Installations (Preferred)

**Pattern**: Install to `/usr/local/` with `containerEnv`

Features:
- **node** - `/usr/local/share/fnm`
- **deno** - `/usr/local/deno`
- **flutter** - `/usr/local/share/fvm`

Benefits:
- No user copying needed
- Works for all users automatically
- Clean test execution
- Automatic updates with `containerEnv`

### Package Manager Installations

**Pattern**: Use Homebrew via `dependsOn`

Features:
- **bun** - `brew install bun`
- **graphite** - `brew install withgraphite/tap/graphite`
- **claude-code** - `brew install --cask claude-code`

**Key Pattern**: These features declare `dependsOn` on the Homebrew feature, which ensures:
- Automatic installation order (Homebrew first)
- Simplified install scripts (just call brew commands)
- Consistent package management
- Automatic system-wide PATH in `/home/linuxbrew/.linuxbrew/bin`

Benefits:
- Automatic dependency resolution (via `dependsOn`)
- Simple install scripts
- Package manager handles updates and versioning
- Works seamlessly across all users in container

### User-specific Installations

**Pattern**: Install to home directory, copy to root

Features:
- **shell-utils** - `~/.zshrc`, `~/.zim`, `~/.oh-my-zsh` (replaces common-utils)

Note: Tests run as root, so configs are copied to `/root/` for test execution.

## Common Issues and Solutions

### Issue: "command not found" in tests
**Cause**: System-wide tools not in PATH for root
**Solution**: Set `containerEnv.PATH` in `devcontainer-feature.json`

### Issue: Test fails with user-specific tools
**Cause**: Configs/binaries only in user home, not root home
**Solution**: Copy to root after installation, or use system-wide path

### Issue: Package installation fails
**Cause**: Missing dependencies or wrong package manager
**Solution**: Use `check_packages` instead of raw apt-get/dnf

### Issue: Feature dependency not installed
**Cause**: Missing `dependsOn` declaration
**Solution**: Add proper feature dependency in `devcontainer-feature.json`

## Important Files

- `DEVELOPMENT.md` - Detailed development guide with all patterns
- `README.md` - User-facing documentation
- `src/*/install.sh` - Installation scripts (must follow patterns)
- `test/*/test.sh` - Test scripts

## Instructions for Claude Code

### When modifying features:

1. **Always follow the official patterns** documented in DEVELOPMENT.md
2. **Use utility functions**: check_packages, pkg_mgr_update, clean_up
3. **Handle user context**: Detect user, install for user, copy to root
4. **Test thoroughly**: Run tests with ubuntu:latest base image
5. **Check /etc/skel**: Look for default config files before creating new ones

### When creating new features:

1. Copy structure from existing feature (e.g., `src/bun/`)
2. Include all utility functions in install.sh
3. Follow the Feature Development Checklist in DEVELOPMENT.md
4. Create test script in test/feature-name/test.sh
5. Test with: `devcontainer features test --skip-scenarios -f feature-name -i ubuntu:latest .`

### When debugging test failures:

1. Check if issue is user context related (root vs target user)
2. Verify configs exist in /root/ for root-run tests
3. Test the built image directly with docker run
4. Review DEVELOPMENT.md "Common Test Issues" section

### Critical Reminders:

- ⚠️ **Prefer system-wide installations** to `/usr/local/` when possible
- ⚠️ **Use `dependsOn`** for feature dependencies (bun, graphite)
- ⚠️ **Set `containerEnv`** for system-wide installations
- ⚠️ **Copy configs to root** for user-specific installations
- ⚠️ **Always use check_packages** instead of raw apt-get/dnf
- ⚠️ **Always call clean_up()** at the end to reduce image size
- ⚠️ **Use `grep -qxF`** to avoid duplicate PATH exports

## References

See DEVELOPMENT.md for comprehensive patterns, examples, and best practices.
