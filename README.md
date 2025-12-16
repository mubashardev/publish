# Publish 🚀

[![pub package](https://img.shields.io/pub/v/publish.svg)](https://pub.dev/packages/publish)
[![license](https://img.shields.io/github/license/mubashardev/publish.svg)](https://github.com/mubashardev/publish/blob/master/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/mubashardev/publish.svg)](https://github.com/mubashardev/publish/stargazers)

**Publish** is the ultimate CLI tool for Flutter developers. It automates the tedious parts of app configuration, release management, and asset generation, letting you focus on writing code. From "Zero to Hero" project setup to seamless Play Store publishing preparation, `publish` has you covered.

## ✨ Features

- **🧙‍♂️ Interactive Setup**: Wizard-style setup for new projects (`init`).
- **📦 Release Workflow**: Automate version bumps and changelog updates.
- **🎨 Asset Management**: Generate icons (`Android/iOS`) and splash screens from a single file.
- **🩺 Project Doctor**: Diagnose and fix configuration issues (`pubspec`, `gradle`, `manifest`).
- **🔐 Android Signing**: Auto-generate keystores and modify `build.gradle` safely.
- **⚙️ App Config**: Update App Name and Package ID across platforms with one command.

---

## 🛠️ Installation

Activate the package globally from pub.dev:

```bash
flutter pub global activate publish
```

You can now use the `publish` command anywhere in your terminal.

---

## 🚀 Quick Start

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

## 📖 Command Reference

### 🎨 Assets & UI

| Command | Description |
|---------|-------------|
| `publish icons` | Generate Android & iOS icons from a source image (default: `assets/icon.png`). |
| `publish splash` | Update native splash screen background color (Android & iOS). |

**Examples:**
```bash
# Generate icons from specific file
publish icons --file assets/logo.png

# Update splash screen color
publish splash --color "#4285F4"
```

### 📦 Release Automation

| Command | Description |
|---------|-------------|
| `publish version` | Bump package version (`major`, `minor`, `patch`, `build`). |
| `publish changelog` | Add a new entry to `CHANGELOG.md` for the current version. |
| `publish ignore` | Generate a standard Flutter `.gitignore` file. |

**Examples:**
```bash
# Increment patch version (1.0.0 -> 1.0.1)
publish version patch

# Prepare changelog for release
publish changelog
```

### ⚙️ Configuration & Signing

| Command | Description |
|---------|-------------|
| `publish config` | Read or write App Name and Package ID. |
| `publish sign-android` | Generate keystore and configure `build.gradle` for release. |

**Examples:**
```bash
# Update App Name for all platforms
publish config app-name --value "My Awesome App"

# Update Package ID (Bundle ID)
publish config app-id --value "com.example.awesome"

# Setup Android Signing (Keystore + Gradle)
publish sign-android
```

---

## 🤖 Advanced Usage

### Gradle Format Support
`publish` intelligently detects and handles both **Groovy** (`build.gradle`) and **Kotlin DSL** (`build.gradle.kts`) formats. Whether you use the legacy or modern Android build system, `publish` will correctly parse and update your `applicationId` and signing configs without breaking your build scripts.

### iOS Support
The `splash` command modifies the `LaunchScreen.storyboard` directly using color transformation logic to ensure your splash screen looks perfect on iOS devices.

---

## 🤝 Contributing

We welcome contributions!
1. **Star** the repo on [GitHub](https://github.com/mubashardev/publish).
2. **Open an issue** for bugs or feature requests.
3. **Submit a PR** to help improve the tool.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
