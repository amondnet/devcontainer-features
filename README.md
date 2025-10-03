# Dev Container Features

Reusable Dev Container features for consistent development environments.

## Available Features

### zimfw
Installs Zimfw - Zsh configuration framework with useful modules.

### fnm
Installs Fast Node Manager (fnm) and Node.js versions (LTS and v22).

### ohmyposh
Installs Oh My Posh prompt theme engine for beautiful shell prompts.

### homebrew
Installs Homebrew package manager for Linux.

### graphite
Installs Graphite CLI for stacked pull request workflows.

### bun
Installs Bun - Fast JavaScript runtime and toolkit.

### deno
Installs Deno - Secure TypeScript/JavaScript runtime.

### sdkman
Installs SDKMAN - Software Development Kit Manager for Java/JVM ecosystem.

### claude-code
Installs Claude Code - AI-powered coding assistant CLI.

### fvm
Installs FVM - Flutter Version Management.

## Usage

### In devcontainer.json

```json
{
  "features": {
    "ghcr.io/amondnet/devcontainer-features/zimfw:1": {},
    "ghcr.io/amondnet/devcontainer-features/fnm:1": {
      "version": "22"
    },
    "ghcr.io/amondnet/devcontainer-features/ohmyposh:1": {},
    "ghcr.io/amondnet/devcontainer-features/homebrew:1": {},
    "ghcr.io/amondnet/devcontainer-features/graphite:1": {},
    "ghcr.io/amondnet/devcontainer-features/bun:1": {},
    "ghcr.io/amondnet/devcontainer-features/deno:1": {},
    "ghcr.io/amondnet/devcontainer-features/sdkman:1": {},
    "ghcr.io/amondnet/devcontainer-features/claude-code:1": {},
    "ghcr.io/amondnet/devcontainer-features/fvm:1": {}
  }
}
```

### Local development (submodule)

```json
{
  "features": {
    "./.devcontainer/features/src/zimfw": {},
    "./.devcontainer/features/src/fnm": {}
  }
}
```

## Development

### Directory Structure

```
src/
├── zimfw/
│   ├── devcontainer-feature.json
│   └── install.sh
├── fnm/
│   ├── devcontainer-feature.json
│   └── install.sh
...
```

### Testing Locally

1. Clone this repository as a submodule in your project
2. Reference features with relative path in `devcontainer.json`
3. Rebuild Dev Container to test

## Publishing

Features are automatically published to GitHub Container Registry via GitHub Actions when pushed to main branch.

## License

MIT