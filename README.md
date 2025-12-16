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

### 1. Initialize a New Project
Run the interactive wizard to set up your App Name, Package ID, Icons, and Gitignore in seconds:

```bash
publish init
```

### 2. Check Project Health
Ensure your project is ready for development or release:

```bash
publish doctor
```

---

## Detailed Command Reference

| Command & Arguments | Description | Usage Examples |
|--------------------|-------------|----------------|
| `init` | Interactive wizard to set up your project (App Name, ID, Icons, Gitignore). | `publish init` |
| `doctor` | Diagnoses project health (Pubspec, Manifest, Gradle, Signing Keys). | `publish doctor` |
| `config app-name` | Updates the App Name for Android and/or iOS. | `publish config app-name --value "My App"`<br>`publish config app-name --value "My App" --platforms=ios` |
| `config app-id` | Updates the Package Name (Android) and Bundle ID (iOS). | `publish config app-id --value "com.example.app"` |
| `--read-configs` | Displays the current App Name and Package ID/Bundle ID for all platforms. | `publish --read-configs` |
| `sign-android` | interactive wizard generates a keystore, creates `key.properties`, and configures `build.gradle` for release signing. | `publish sign-android` |
| `icons` | Generates all required icon sizes for Android and iOS from a source image. | `publish icons --file assets/logo.png` |
| `splash` | Updates the native splash screen background color. | `publish splash --color "#121212"` |
| `ignore` | Generates a standard Flutter `.gitignore` file. | `publish ignore` |
| `version [type]` | Bumps the package version in `pubspec.yaml`. Types: `major`, `minor`, `patch`, `build`. | `publish version patch` (1.0.0 → 1.0.1)<br>`publish version major` (1.0.0 → 2.0.0) |
| `changelog` | Adds a new entry to `CHANGELOG.md` for the current version. | `publish changelog` |
| `update` | Updates the `publish` CLI package to the latest version. | `publish update` |

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
