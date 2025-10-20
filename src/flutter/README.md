
# Flutter (flutter)

Installs Flutter SDK for cross-platform app development with Dart (via FVM - Flutter Version Management)

## Example Usage

```json
"features": {
    "ghcr.io/amondnet/devcontainer-features/flutter:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select a Flutter channel (stable, beta, dev, master) or specific version to install. Channels: stable (production), beta (preview), dev (latest features) | string | stable |
| installAndroidSdk | Install Android SDK and platform tools for mobile development? | boolean | false |
| androidSdkVersion | Android SDK API level to install (only used if installAndroidSdk is true) | string | latest |

## Customizations

### VS Code Extensions

- `Dart-Code.dart-code`
- `Dart-Code.flutter`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/amondnet/devcontainer-features/blob/main/src/flutter/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
