# publish

**publish** is a Flutter package designed to make it easier for developers to set up Android app
signing and create signed app bundles for Play Store publishing. No need to memorize complex
commands – just use this package to generate keys and configure the signing process with ease.

## Features:

- Automatically generate Android keystores.
- Create and configure the `key.properties` file for signing.
- Update the `build.gradle` file for signing your app.
- Update your **Android App Package Name**
- Simplified command usage for creating signed bundles.

## Installation:

1. Add the following to your `pubspec.yaml` file:
   ```
   dependencies:
     publish: ^latest-version
   ```

2. Run the command:
   ```
   flutter pub get
   ```

## Steps:

1. **Setup Android Signing:**
   To generate the signing key and configure necessary files, use this command:
   ```
   flutter pub run publish --android-sign
   ```
   This will:
    - Update package name
    - Generate a keystore file.
    - Create the `key.properties` file with your details.
    - Update your `build.gradle` file for release builds.


2. **Generate App Bundle:**
   - To update app version, open `pubspec.yaml` and update the `version` field accordingly.
   - To create a signed app bundle, use this command:
      ```
      flutter build appbundle
      ```
      This will generate a signed app bundle in the `build/app/outputs/bundle/release` directory.

3. **Publish to Play Store:**
   Once the app bundle is generated, you can upload it to the Play Store for distribution.


## Optional:
   Add the generated keystore and `key.properties` file to your Git repository to avoid re-generating them.


## Contributions:

You are welcome to open issues or contribute to improving the package.

## License:

This project is licensed under the MIT License.
