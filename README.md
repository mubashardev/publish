
# publish

**publish** is a Flutter CLI package designed to simplify app configuration, including setting app names, app IDs, and Android signing configurations for Play Store publishing. It removes the hassle of manual setup and allows developers to focus on building great apps.

## Features:

- Easily configure **App name** and **App ID** for both Android and iOS platforms.
- Platform-specific configuration options.
- Automatically generate Android keystores and configure signing files.
- Simplified command usage for setting up your project and creating signed app bundles.

---

## Installation:

1. Run the following command in your CMD or Terminal:
   ```bash
   flutter pub global activate publish
   ```
   This will activate the superpowers of **publish** package.
---

## Commands:


### Android Signing Configuration

#### Generate Signing Key and Configure Files:
Use this command in your project terminal to automatically generate a signing key and set up your Android project for release:
```bash
publish sign-android
```

This will:
- Generate a keystore file.
- Create the `key.properties` file with your details.
- Update your `build.gradle` file for release builds.

---

### Generate App Bundle:

To create a signed app bundle, run:
```bash
flutter build appbundle
```

The signed app bundle will be generated in the `build/app/outputs/bundle/release` directory.

---

### App Configuration

#### Check App Current Configuration:
```bash
publish --read-configs
```

This command will print the current app name and app ID for both Android and iOS platforms.

#### Update App Name:
To update the app name for both Android & iOS with single command:
```bash
publish config app-name --value "Test"
```

For platform-specific updates:
```bash
publish config app-name --value "Test" --platforms=android
publish config app-name --value "Test" --platforms=ios
publish config app-name --value "Test" --platforms=android,ios
```

#### Update App ID:
To update the app ID for both Android & iOS with single command:
```bash
publish config app-id --value "com.test"
```

For platform-specific updates:
```bash
publish config app-id --value "com.test" --platforms=android
publish config app-id --value "com.test" --platforms=ios
publish config app-id --value "com.test" --platforms=android,ios
```

---

---

<details>
<summary><b>📚 Advanced: Gradle Format Support (Optional Read)</b></summary>

### Gradle Format Support

The **publish** package automatically detects and handles multiple **build.gradle** file formats. This section provides detailed information for developers who want to understand the gradle parsing capabilities.

#### Supported Gradle Types

The parser supports both **Groovy** and **Kotlin DSL** formats:

**1. Groovy (build.gradle)**
- Traditional Android gradle format
- Uses groovy syntax with flexible property definitions
- Example: `applicationId "com.example.app"`

**2. Kotlin DSL (build.gradle.kts)**
- Modern gradle format with type safety
- More verbose but provides IDE autocomplete support
- Example: `applicationId = "com.example.app"`

#### Main Differences

| Feature | Groovy | Kotlin DSL |
|---------|--------|-----------|
| File Extension | `.gradle` | `.gradle.kts` |
| Syntax | Dynamic, groovy-based | Statically typed, kotlin-based |
| IDE Support | Basic | Enhanced (autocomplete, type checking) |
| Learning Curve | Easier for beginners | Steeper (Kotlin knowledge required) |
| Performance | Slightly faster build times | Slightly slower (type checking overhead) |

#### Application ID Detection

The parser intelligently detects multiple `applicationId` syntax patterns:

- **Groovy old format**: `applicationId "com.example.app"`
- **Groovy assignment**: `applicationId = "com.example.app"`
- **Kotlin DSL assignment**: `applicationId = "com.example.app"`
- **Kotlin DSL method call**: `applicationId("com.example.app")`

Both single (`'`) and double (`"`) quotes are supported across all formats.

#### What the Parser Does

When you run `publish sign-android` or `publish config app-id`, the parser:
1. Detects the gradle file type automatically
2. Locates the `defaultConfig` block
3. Extracts or updates the `applicationId` while preserving the original format
4. Ensures your gradle file remains syntactically correct

This means you can use **any** gradle format, and **publish** will handle it seamlessly without forcing you to change your project structure.

</details>

---

## Contributions:

We welcome contributions to improve this package! Feel free to:

- ⭐ **Star the project** on GitHub: [mubashardev/publish](https://github.com/mubashardev/publish)
- 🐛 **Open an issue** if you find a bug or have a feature request
- 🔧 **Submit a pull request** to contribute code improvements

Visit us on GitHub: https://github.com/mubashardev/publish

---

## License:

This project is licensed under the MIT License.
