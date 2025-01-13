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
    // Read the build.gradle file as a string
    String bfString = _Commons.getFileAsString(_Commons.appBuildPath);

    // Match defaultConfig block
    RegExp defaultConfigRegex = RegExp(
      r"defaultConfig\s*\{([\s\S]*?)\}",
      multiLine: true,
    );

    RegExpMatch? defaultConfigMatch = defaultConfigRegex.firstMatch(bfString);

    if (defaultConfigMatch != null) {
      String defaultConfigBlock = defaultConfigMatch.group(1)!;

      // Match applicationId inside defaultConfig block (supports both formats)
      RegExp applicationIdRegex = RegExp(
        r"""applicationId\s*(?:=|)\s*['"]([^'"]+)['"]""",
      );

      RegExpMatch? applicationIdMatch =
          applicationIdRegex.firstMatch(defaultConfigBlock);

      if (applicationIdMatch != null) {
        return applicationIdMatch.group(1)!; // Extract the applicationId
      } else {
        throw Exception("applicationId not found in defaultConfig block.");
      }
    } else {
      throw Exception("defaultConfig block not found.");
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
    List<String> buildfile = _Commons.getFileAsLines(_Commons.appBuildPath);

    // Regex to match both formats
    RegExp applicationIdRegex = RegExp(
      r"""applicationId\s*(=|)\s*['"][^'"]+['"]""",
    );

    buildfile = buildfile.map((line) {
      if (applicationIdRegex.hasMatch(line)) {
        // Determine the existing format
        if (line.contains('=')) {
          // New format: applicationId = "..."
          return "applicationId = '$appId'";
        } else {
          // Old format: applicationId "..."
          return "applicationId '$appId'";
        }
      } else {
        return line;
      }
    }).toList();

    _Commons.writeStringToFile(_Commons.appBuildPath, buildfile.join("\n"));
  }
}
