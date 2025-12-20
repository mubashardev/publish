# Publish

[![pub package](https://img.shields.io/pub/v/publish.svg)](https://pub.dev/packages/publish)
[![license](https://img.shields.io/github/license/mubashardev/publish.svg)](https://github.com/mubashardev/publish/blob/master/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/mubashardev/publish.svg)](https://github.com/mubashardev/publish/stargazers)

**Publish** is the ultimate CLI tool for Flutter developers. It automates the tedious parts of app configuration, release management, and asset generation, letting you focus on writing code. From "Zero to Hero" project setup to seamless Play Store publishing preparation, `publish` has you covered.

## Features

- **Interactive Setup**: Wizard-style setup for new projects (`init`).
- **Release Workflow**: Automate version bumps and changelog updates.
- **Asset Management**: Generate icons (`Android/iOS`) and splash screens from a single file.
- **Project Doctor**: Diagnose and fix configuration issues (`pubspec`, `gradle`, `manifest`).
- **Android Signing**: Auto-generate keystores and modify `build.gradle` safely.
- **App Config**: Update App Name and Package ID across platforms with one command.

---

## Installation

Activate the package globally from pub.dev:

```bash
flutter pub global activate publish
```

You can now use the `publish` command anywhere in your terminal.

---

## Quick Start

### Recommended Workflow

**For New Projects:**
1. **Analyze** your project first:
   ```bash
   publish doctor
   ```
2. **Quick Setup** with the interactive wizard:
   ```bash
   publish init
   ```
3. **Verify** everything is configured:
   ```bash
   publish doctor
   ```

**For Existing Projects:**
1. Run `publish doctor` to identify issues
2. Fix issues using suggested commands
3. Build and sign your app for release

---

## Detailed Command Reference

### Core Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `doctor` | **[Start Here]** Comprehensive project health check with 10+ validations (Flutter SDK, configs, signing, icons, git, etc.). Provides actionable fix suggestions. | `publish doctor` |
| `init` | Quick setup wizard for App Name, Package ID, Icons, and Gitignore. Best used after running `doctor`. | `publish init` |
| `show-config` | Display current app configurations (App Name, Package ID/Bundle ID). | `publish show-config` |
| `--version` | Show publish CLI version and check for updates. | `publish --version` |

### Build & Sign

| Command | Description | Usage |
|---------|-------------|-------|
| `build android` | Validates configuration and builds Android App Bundle (`.aab`). | `publish build android` |
| `sign android` | Interactive wizard to generate keystore and configure release signing. | `publish sign android` |
| `sign ios` | **(Coming Soon)** iOS code signing configuration wizard. | `publish sign ios` |

### Configuration

| Command | Description | Usage |
|---------|-------------|-------|
| `config app-name` | Update App Name for Android and/or iOS. | `publish config app-name --value "My App"`<br>`publish config app-name --platforms=ios` |
| `config app-id` | Update Package Name (Android) and Bundle ID (iOS). | `publish config app-id --value "com.example.app"` |

### Assets

| Command | Description | Usage |
|---------|-------------|-------|
| `icons` | Generate all required icon sizes for Android and iOS from a single source image. | `publish icons --file assets/logo.png` |
| `splash` | Update native splash screen background color. | `publish splash --color "#121212"` |
| `ignore` | Generate a standard Flutter `.gitignore` file. | `publish ignore` |

### Version Management

| Command | Description | Usage |
|---------|-------------|-------|
| `version [type]` | Bump version in `pubspec.yaml`. Types: `major`, `minor`, `patch`, `build`. | `publish version patch` (1.0.0 → 1.0.1)<br>`publish version major` (1.0.0 → 2.0.0) |
| `changelog` | Add a new entry to `CHANGELOG.md` for the current version. | `publish changelog` |

### Maintenance

| Command | Description | Usage |
|---------|-------------|-------|
| `update` | Update the publish CLI to the latest version. | `publish update` |

---

## Advanced Usage

### Gradle Format Support
`publish` intelligently detects and handles both **Groovy** (`build.gradle`) and **Kotlin DSL** (`build.gradle.kts`) formats. Whether you use the legacy or modern Android build system, `publish` will correctly parse and update your `applicationId` and signing configs without breaking your build scripts.

### iOS Support
The `splash` command modifies the `LaunchScreen.storyboard` directly using color transformation logic to ensure your splash screen looks perfect on iOS devices.

---

## Contributing

We welcome contributions!
1. **Star** the repo on [GitHub](https://github.com/mubashardev/publish).
2. **Open an issue** for bugs or feature requests.
3. **Submit a PR** to help improve the tool.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
