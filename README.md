# publish

**publish** is a Flutter package designed to make it easier for developers to set up Android app
signing and create signed app bundles for Play Store publishing. No need to memorize complex
commands – just use this package to generate keys and configure the signing process with ease.

## Features:

- Automatically generate Android keystores.
- Create and configure the `key.properties` file for signing.
- Update the `build.gradle` file for signing your app.
- Simplified command usage for creating signed bundles.

## Installation:

1. Add the following to your `pubspec.yaml` file:
   ```
   dependencies:
     publish: ^1.0.0
   ```

2. Run the command:
   ```
   flutter pub get
   ```

## Usage:

1. **Setup Android Signing:**
   To generate the signing key and configure necessary files, use this command:
   ```
   flutter pub run publish --android-sign
   ```
   This will:
    - Generate a keystore file.
    - Create the `key.properties` file with your details.
    - Update your `build.gradle` file for release builds.

2. **Generate Feature Directory:**
   You can also generate a feature directory using the command:
   ```
   flutter pub run publish gen <feature_name>
   ```

   For generating a core directory:
   ```
   flutter pub run publish gen --core
   ```

   You can also specify the path with:
   ```
   flutter pub run publish gen --path <your_base_path>
   ```

3. **Help:**
   For a list of available options, run:
   ```
   flutter pub run publish -h
   ```

## Contributions:

You are welcome to open issues or contribute to improving the package.

## License:

This project is licensed under the MIT License.
