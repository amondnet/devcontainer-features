
# Node.js (via fnm), yarn and pnpm (node)

Installs Node.js via fnm (Fast Node Manager), with yarn and pnpm support. Alternative to nvm with better performance.

## Example Usage

```json
"features": {
    "ghcr.io/amondnet/devcontainer-features/node:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select or enter a Node.js version to install. Use 'lts' for the latest LTS version. | string | lts |
| nodeGypDependencies | Install dependencies to compile native node modules (node-gyp)? | boolean | true |
| fnmInstallPath | The path where fnm will be installed. | string | /usr/local/share/fnm |
| installLts | Install Node.js LTS version in addition to specified version? | boolean | true |
| installYarn | Install Yarn package manager? | boolean | true |
| installPnpm | Install pnpm package manager? | boolean | true |
| pnpmVersion | Select or enter the pnpm version to install | string | latest |
| nvmAlias | Create 'nvm' alias for fnm for compatibility? | boolean | true |

## Customizations

### VS Code Extensions

- `dbaeumer.vscode-eslint`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/amondnet/devcontainer-features/blob/main/src/node/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
