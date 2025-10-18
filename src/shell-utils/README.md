
# Shell Utilities (Zsh, Zimfw, Oh My Posh) (shell-utils)

Installs and configures Zsh with choice of Zimfw or Oh My Zsh, plus Oh My Posh for prompt customization. Enhanced alternative to common-utils.

## Example Usage

```json
"features": {
    "ghcr.io/amondnet/devcontainer-features/shell-utils:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| installZsh | Install Zsh shell? | boolean | true |
| configureZshAsDefaultShell | Set Zsh as the default shell for the user? | boolean | true |
| shellFramework | Choose shell framework: zimfw (modern, fast), ohmyzsh (popular), or none | string | zimfw |
| installOhMyPosh | Install Oh My Posh for customizable prompt themes? | boolean | true |
| ohMyPoshTheme | Oh My Posh theme to use (e.g., 'agnoster', 'paradox', 'default') | string | default |
| username | Username to configure (automatic will detect existing user) | string | automatic |
| upgradePackages | Upgrade OS packages during installation? | boolean | true |

## Customizations

### VS Code Extensions

- `ms-vscode.remote-explorer`
- `eamodio.gitlens`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/amondnet/devcontainer-features/blob/main/src/shell-utils/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
