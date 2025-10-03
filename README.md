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

### dev-tools
Installs additional development tools (Bun, Deno, SDKMAN, Claude Code, FVM).

## Usage

### In devcontainer.json

```json
{
  "features": {
    "ghcr.io/rebooter-dev/devcontainer-features/zimfw:1": {},
    "ghcr.io/rebooter-dev/devcontainer-features/fnm:1": {
      "nodeVersion": "22"
    },
    "ghcr.io/rebooter-dev/devcontainer-features/ohmyposh:1": {},
    "ghcr.io/rebooter-dev/devcontainer-features/homebrew:1": {},
    "ghcr.io/rebooter-dev/devcontainer-features/graphite:1": {},
    "ghcr.io/rebooter-dev/devcontainer-features/dev-tools:1": {}
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