
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
publish --sign-android
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
publish config app-id="com.test"
```

For platform-specific updates:
```bash
publish config app-id --value "com.test" --platforms=android
publish config app-id --value "com.test" --platforms=ios
publish config app-id --value "com.test" --platforms=android,ios
```

---

## Contributions:

We welcome contributions to improve this package! Feel free to open issues or submit pull requests.

---

## License:

This project is licensed under the MIT License.
