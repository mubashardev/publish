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
      final xmlString = File("./android/app/src/main/AndroidManifest.xml")
          .readAsStringSync();
      // Parse the XML
      XmlDocument.parse(xmlString);
      return true; // The XML is valid
    } catch (e) {
      return false; // The XML is not valid
    }
  }

  static bool get isGradleExists => File("./android/build.gradle").existsSync();

  static bool get isGradleValid {
    if (!isGradleExists) return false;
    try {
      _AndroidConfigs.appId;
      return true;
    } catch (e) {
      return false;
    }
  }
}
