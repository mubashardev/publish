# Publish

[![pub package](https://img.shields.io/pub/v/publish.svg)](https://pub.dev/packages/publish)
[![license](https://img.shields.io/github/license/mubashardev/publish.svg)](https://github.com/mubashardev/publish/blob/master/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/mubashardev/publish.svg)](https://github.com/mubashardev/publish/stargazers)

**Publish** is the ultimate CLI tool for Flutter developers. It automates the tedious parts of app configuration, release management, and asset generation, letting you focus on writing code. From "Zero to Hero" project setup to seamless Play Store publishing preparation, `publish` has you covered.

## Features

- **🚀 Interactive Setup**: Wizard-style setup for new projects (`init`).
- **🔀 Multi-Config Support**: Manage multiple environments (dev, staging, prod) with unique App Names, Package IDs, Icons, and Splash Screens.
- **🎨 Asset Management**: Generate icons (`Android/iOS`) and splash screens from a single file. **Preserves assets per configuration!**
- **🏗️ Release Workflow**: Automate version bumps and changelog updates.
- **⚕️ Project Doctor**: Diagnose and fix configuration issues (`pubspec`, `gradle`, `manifest`).
- **🔐 Android Signing**: Auto-generate keystores and modify `build.gradle` safely.
- **📦 Import/Export**: Share configurations across teams with ease.

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
   ![Publish Doctor](https://github.com/mubashardev/publish/raw/main/assets/publish_doctor.gif)
2. **Quick Setup** with the interactive wizard:
   ```bash
   publish init
   ```
   ![Publish Init](https://github.com/mubashardev/publish/raw/main/assets/publish_init.gif)
3. **Verify** everything is configured:
   ```bash
   publish doctor
   ```

**For Existing Projects:**
1. Run `publish doctor` to identify issues.
2. Fix issues using suggested commands.
3. Create configurations for different environments (e.g., `staging`, `prod`).

---

## 🔥 Multi-Configuration System

`publish` introduces a powerful configuration system that lets you switch between different app profiles instantly. Each profile maintains its own:
- **App Name** & **Package ID**
- **Keystore** & **Signing Credentials**
- **App Icons** (Android & iOS)
- **Splash Screen**
- **Version Suffix** (e.g., `-beta`)
- **App Version** (preserves `pubspec.yaml` version)

### 🛡 This is "Data Preservation"
When you create profiles or build legacy setups, `publish` ensures complete data safety:
1.  **Version Preservation**: Switching profiles automatically updates the `version` in `pubspec.yaml` to match that profile's last state.
2.  **Asset Preservation**: Your `android` and `ios` icons and splash screens are backed up per-profile. Switching restores them instantly.
3.  **Legacy Intelligence**: If you have a custom properties file (e.g., `android/secrets.props`) with extra variables (like `API_KEY`), `publish` detects and preserves them alongside your signing keys. Nothing is lost!

### Managing Configs

| Command | Description | Usage |
|---------|-------------|-------|
| `config list` | List all configs & active status. | `publish config list` |
| `config switch` | Switch active profile. Restores icons/splash. | `publish config switch production` |
| `config export` | Export config as zip (e.g., for team). | `publish config export production` |
| `config import` | Import config from zip. | `publish config import ./config.zip` |
| `config edit` | Edit config settings interactively. | `publish config edit production` |
| `config delete` | Delete a configuration. | `publish config delete staging` |
| `config rename` | Rename a configuration. | `publish config rename old new` |

<br>

**List Configurations**

![Config List](https://github.com/mubashardev/publish/raw/main/assets/publish_config_list.gif)

**Switch Configuration**

![Config Switch](https://github.com/mubashardev/publish/raw/main/assets/publish_config_switch.gif)

**Export Configuration**

![Config Export](https://github.com/mubashardev/publish/raw/main/assets/publish_config_export.gif)

**Exported Output Structure**

![Exported Output](https://github.com/mubashardev/publish/raw/main/assets/publish_exported_output.gif)

### Building with Configs

You can build with a specific configuration without permanently switching to it:

```bash
publish build android --config staging
```

![Publish Build Android](https://github.com/mubashardev/publish/raw/main/assets/publish_build_android.gif)

This temporary applies the `staging` profile (icons, ids, signing), builds the app, and reverts to your previous state.

---

## Detailed Command Reference

### Core Commands

| Command | Description |
|---------|-------------|
| `doctor` | **[Start Here]** Comprehensive health check (Flutter SDK, configs, signing, icons, git, etc.). |
| `init` | Quick setup wizard for App Name, Package ID, Icons, and Gitignore. |
| `show-config` | Display current app configurations (App Name, Package ID/Bundle ID). |
| `set` | Quickly set App Name or Package ID for current config. |

### Build & Sign

| Command | Description |
|---------|-------------|
| `build android` | Validates configuration and builds Android App Bundle (`.aab`). Supports `--config`. |
| `sign android` | Interactive wizard to setup signing. **Supports migrating existing keys!** |

<br>

**Signing Android App**

![Publish Sign Android](https://github.com/mubashardev/publish/raw/main/assets/publish_sign_android.gif)

**Signing Another Configuration**

![Publish Sign 2nd Config](https://github.com/mubashardev/publish/raw/main/assets/publish_sign_2nd_config.gif)

### Assets

| Command | Description |
|---------|-------------|
| `icons` | Generate all icon sizes for Android and iOS from a single source image. |
| `splash` | Update native splash screen background color (Android/iOS). |
| `ignore` | Generate a standard Flutter `.gitignore` file. |

### Version Management

| Command | Description |
|---------|-------------|
| `version` | Bump version (`major`, `minor`, `patch`, `build`). |
| `changelog` | Add a new entry to `CHANGELOG.md` for the current version. |

### Maintenance

| Command | Description |
|---------|-------------|
| `update` | Update the publish CLI to the latest version. |

---

## Advanced Usage

### Gradle Format Support
`publish` intelligently detects and handles both **Groovy** (`build.gradle`) and **Kotlin DSL** (`build.gradle.kts`) formats.

### iOS Support
The `splash` command modifies the `LaunchScreen.storyboard` directly using color transformation logic to ensure your splash screen looks perfect on iOS devices.

---

## Contributing

We welcome contributions!
1. **Star** the repo on [GitHub](https://github.com/mubashardev/publish).
2. **Open an issue** for bugs or feature requests.
3. **Submit a PR** to help improve the tool.

---

## Author

<a href="https://mubashar.dev" rel="dofollow">Available as Senior App Developer</a>

Follow on [GitHub](https://github.com/mubashardev) for more open source repos like this.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
