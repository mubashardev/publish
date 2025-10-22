part of '../publish.dart';

class _AndroidConfigs {
  static String get appName {
    // Get the AndroidManifest.xml content as a string
    String manifestString = _Commons.getFileAsString(_Commons.appManifestPath);

    // Regex to match the android:label attribute with possible variations
    RegExp appNameRegex = RegExp(
      r'<application[^>]*\s+android:label\s*=\s*"([^"]+)"',
      dotAll: true,
    );

    // Match the regex pattern
    RegExpMatch? appNameMatch = appNameRegex.firstMatch(manifestString);

    if (appNameMatch != null) {
      return appNameMatch.group(1)!;
    } else {
      throw Exception(
          "App name not found or improperly formatted in AndroidManifest.xml.");
    }
  }

  static String get appId {
    // Read the build.gradle or build.gradle.kts file as a string
    String bfString = _Commons.getFileAsString(_Commons.appBuildPath);

    // Use universal parser to extract applicationId
    String? appId = _GradleParser.extractApplicationId(bfString);

    if (appId != null) {
      return appId;
    } else {
      throw Exception("applicationId not found in build file.");
    }
  }

  static void setAppName(String name) {
    // Read the AndroidManifest.xml file as a string
    String manifestString = _Commons.getFileAsString(_Commons.appManifestPath);

    // Replace the app name with the new name
    manifestString = manifestString.replaceAll(
        RegExp(r'<application\s+android:label="([^"]+)"'),
        '<application android:label="$name"');

    // Write the modified string back to the file
    File(_Commons.appManifestPath).writeAsStringSync(manifestString);
  }

  static void setAppId(String id) {
    String bfString = _Commons.getFileAsString(_Commons.appBuildPath);

    // Use universal parser to replace applicationId
    String updated = _GradleParser.replaceApplicationId(bfString, id);

    _Commons.writeStringToFile(_Commons.appBuildPath, updated);
  }
}
