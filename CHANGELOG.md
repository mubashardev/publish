## [1.3.1] - 2025-12-30
### 🔧 Improvements
- **Better Inputs Handling**: `publish` now better handles default values.

## [1.3.0] - 2025-12-29
### ✨ Features
- **Smart Legacy Migration**: Now strictly checks `build.gradle` to identify the exact custom `key.properties` file and variable names used (`keyAlias`, `storeFile`, etc.) when migrating legacy setups, ensuring your existing build configuration remains untouched.
- **Improved Sign UX**: Better prompts for saving legacy configurations and clearer visual feedback when creating or overwriting profiles.
- **Version Preservation**: Each configuration profile now remembers its own app version (from `pubspec.yaml`), automatically restoring it when you switch profiles. Perfect for managing different versions for dev/staging/prod.
- **Dynamic Property Preservation**: Any extra properties in your `key.properties` file (e.g. API keys) are now preserved and restored safely.

### 🔧 Improvements
- **Robust Parsing**: `publish config` now better handles custom Gradle configurations during migration.

## [1.2.5] - 2025-12-29
### ✨ Features
- **Multi-Config System**: Manage multiple app profiles (dev, staging, prod) with unique settings.
- **Asset Preservation**: Android/iOS icons and splash screens are now backed up and restored automatically when switching configurations.
- **New Commands**: 
  - `publish config`: Full suite for managing configs (`list`, `switch`, `delete`, `rename`, `edit`, `export`, `import`).
  - `publish set`: Quickly update app name or ID (renamed from old `config` command).
- **Build Integration**: Added `--config` flag to `build android` to temporarily build with a specific profile.
- **Enhanced Configuration**: Support for `versionSuffix` (e.g., -beta) and `splashColor` in profiles.

### 🔧 Improvements
- Renamed `write config` command to `set` to avoid conflicts.
- significantly improved documentation and README.## [1.2.4] - 2025-12-25
### 🐛 Bug Fixes
- Update suggested command after successful Android signing.


## [1.2.3] - 2025-12-20
No user-facing changes.

## [1.2.2] - 2025-12-20
No user-facing changes.

## [1.2.1] - 2025-12-20
### ✨ Features
- Introduce build commands, refactor signing commands, and enhance validation with loading UI.

### 🔧 Improvements
- Update custom funding URL

## [1.2.0] - 2025-12-16
No user-facing changes.



## [1.1.9] - 2025-12-16
No user-facing changes.

## [1.1.8] - 2025-12-16
No user-facing changes.

## [1.1.7] - 2025-12-16
### ✨ Features
- Add `init` command for interactive project setup, refactor `icons` command to expose static generation, and implement iOS splash screen updates.
- Introduce new commands for versioning, project health, icon and splash screen generation, changelog management, and gitignore.

### 🔧 Improvements
- Update README with new `publish` commands and improved section organization.
- Fixed argument definition from `required` to `mandatory` and remove unused variable and comment.
- Remove duplicate changelog entries for version 1.1.6

## [1.1.6] - 2025-12-16
No user-facing changes.

## [1.1.5]
 - Added support for multiple build.gradle file formats (Groovy and Kotlin DSL).
 - Enhanced gradle parser to handle various applicationId syntax patterns.
 - Added comprehensive gradle format examples in supported_gradle_formats folder.

## [1.1.4]
 - Update a dependency to the latest release. 

## [1.1.3]
 - Fixed bug in build.gradle default block. 
 - Enhanced error messages for invalid input.

## [1.0.9]
Update README for cleanup instructions, and enhance 

## [1.0.8]
Enhance applicationId regex to support both old and new formats in build file

## [1.0.6]
Added functionality to change package name during signing setup

## [1.0.4]
Fixed validity years input bug.

## [1.0.2]
Improved key generation process with user prompts for Common Name, Organizational Unit,
Organization, Locality, State, Country, and Validity inputs. Defaults provided for easy use.

## [1.0.0]
Added support for generating core and feature directories via the gen command.

## [0.0.1]
Initial release of the publish package, featuring Android signing key generation and signed bundle
creation.
