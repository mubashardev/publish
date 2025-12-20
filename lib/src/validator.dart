part of '../publish.dart';

class _Validator {
  static bool get isPubspecExists => File("./pubspec.yaml").existsSync();

  static bool get isPubspecValid {
    if (!isPubspecExists) return false;
    try {
      loadYaml(File("./pubspec.yaml").readAsStringSync());
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool get isAndroidManifestExists =>
      File("./android/app/src/main/AndroidManifest.xml").existsSync();

  static bool get isAndroidManifestValid {
    if (!isAndroidManifestExists) return false;

    try {
      // Read the XML file
      final xmlString =
          File("./android/app/src/main/AndroidManifest.xml").readAsStringSync();
      // Parse the XML
      XmlDocument.parse(xmlString);
      return true; // The XML is valid
    } catch (e) {
      print(e);
      return false; // The XML is not valid
    }
  }

  static bool get isGradleExists {
    return File("./android/app/build.gradle").existsSync() ||
        File("./android/app/build.gradle.kts").existsSync();
  }

  static bool get isGradleValid {
    if (!isGradleExists) return false;
    try {
      _AndroidConfigs.appId;
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static bool get isPListExists => File("./ios/Runner/Info.plist").existsSync();
  static bool get isPlistValid {
    if (!isPListExists) return false;
    try {
      _IosConfigs.appId;
      _IosConfigs.appName;
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool get isPbxprojExists =>
      File("./ios/Runner.xcodeproj/project.pbxproj").existsSync();
  static bool get isPbxprojValid {
    if (!isPbxprojExists) return false;
    try {
      _IosConfigs.appId;
      _IosConfigs.appName;
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool get isValidAndroid => isAndroidManifestValid && isGradleValid;
  static bool get isValidIos => isPlistValid && isPbxprojValid;

  static bool isValidAppId(String appId) {
    // Regular expression to validate the app ID
    final appIdRegex =
        RegExp(r'^([A-Za-z]{1}[A-Za-z\d_]*\.)+[A-Za-z][A-Za-z\d_]*$');

    // Check if the app ID matches the pattern
    return appIdRegex.hasMatch(appId);
  }

  static bool isValidAppName(String name) {
    // Regular expression to validate the app name
    final appNameRegex = RegExp(r'^[A-Za-z\s]+$');

    // Check if the app name matches the pattern
    return appNameRegex.hasMatch(name);
  }

  static bool isDefaultPackageName(String appId) {
    return appId.startsWith('com.example');
  }

  static bool get isAppIconExists {
    // Check for default android icon path.
    // Note: This is a basic check.
    return File('android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png')
        .existsSync();
  }
}
