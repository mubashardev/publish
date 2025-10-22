part of '../publish.dart';

/// Universal parser for Android Gradle files (both Groovy and Kotlin DSL formats)
class _GradleParser {
  /// Detects whether the build file is Groovy (build.gradle) or Kotlin DSL (build.gradle.kts)
  static String detectBuildFileType(String filePath) {
    if (filePath.endsWith('.kts')) {
      return 'kts';
    } else if (filePath.endsWith('.gradle')) {
      return 'groovy';
    }

    return 'groovy'; // Default to groovy
  }

  /// Extracts applicationId from gradle file content
  /// Supports both Groovy and KTS formats:
  /// - Groovy: applicationId "com.example.app" or applicationId = "com.example.app"
  /// - KTS: applicationId = "com.example.app" or applicationId("com.example.app")
  static String? extractApplicationId(String content) {
    // First, extract the defaultConfig block
    RegExp defaultConfigRegex = RegExp(
      r'defaultConfig\s*[\(\{]([\s\S]*?)[\)\}](?=\s*(?:buildTypes|signingConfigs|dependencies|$))',
      multiLine: true,
    );

    RegExpMatch? defaultConfigMatch = defaultConfigRegex.firstMatch(content);
    if (defaultConfigMatch == null) {
      return null;
    }

    String defaultConfigBlock = defaultConfigMatch.group(1)!;

    // Try KTS format first: applicationId = "..." or applicationId = '...'
    RegExp ktsFormat1 = RegExp(
      r'applicationId\s*=\s*"([^"]+)"',
    );
    RegExpMatch? ktsMatch1 = ktsFormat1.firstMatch(defaultConfigBlock);
    if (ktsMatch1 != null) {
      return ktsMatch1.group(1)!;
    }
    
    // Try with single quotes
    RegExp ktsFormat1Single = RegExp(
      r"applicationId\s*=\s*'([^']+)'",
    );
    RegExpMatch? ktsMatch1Single = ktsFormat1Single.firstMatch(defaultConfigBlock);
    if (ktsMatch1Single != null) {
      return ktsMatch1Single.group(1)!;
    }

    // Try KTS method call format: applicationId("...")
    RegExp ktsFormat2 = RegExp(
      r'applicationId\s*\(\s*"([^"]+)"\s*\)',
    );
    RegExpMatch? ktsMatch2 = ktsFormat2.firstMatch(defaultConfigBlock);
    if (ktsMatch2 != null) {
      return ktsMatch2.group(1)!;
    }
    
    // Try with single quotes
    RegExp ktsFormat2Single = RegExp(
      r"applicationId\s*\(\s*'([^']+)'\s*\)",
    );
    RegExpMatch? ktsMatch2Single = ktsFormat2Single.firstMatch(defaultConfigBlock);
    if (ktsMatch2Single != null) {
      return ktsMatch2Single.group(1)!;
    }

    // Try Groovy old format: applicationId "..." (no equals sign)
    RegExp groovyOldFormat = RegExp(
      r'applicationId\s+"([^"]+)"',
    );
    RegExpMatch? groovyMatch = groovyOldFormat.firstMatch(defaultConfigBlock);
    if (groovyMatch != null) {
      return groovyMatch.group(1)!;
    }
    
    // Try with single quotes
    RegExp groovyOldFormatSingle = RegExp(
      r"applicationId\s+'([^']+)'",
    );
    RegExpMatch? groovyMatchSingle = groovyOldFormatSingle.firstMatch(defaultConfigBlock);
    if (groovyMatchSingle != null) {
      return groovyMatchSingle.group(1)!;
    }

    return null;
  }

  /// Replaces applicationId in gradle file content
  /// Preserves the original format (Groovy or KTS)
  static String replaceApplicationId(String content, String newId) {
    // First, find the defaultConfig block and extract the applicationId line
    RegExp defaultConfigRegex = RegExp(
      r'(defaultConfig\s*[\(\{])([\s\S]*?)([\)\}](?=\s*(?:buildTypes|signingConfigs|dependencies|$)))',
      multiLine: true,
    );

    return content.replaceAllMapped(defaultConfigRegex, (match) {
      String prefix = match.group(1)!;
      String block = match.group(2)!;
      String suffix = match.group(3)!;

      // Try to replace KTS format first: applicationId = "..."
      String updated = block.replaceAll(
        RegExp(r'applicationId\s*=\s*"[^"]+"'),
        'applicationId = "$newId"',
      );

      // If not replaced, try with single quotes
      if (updated == block) {
        updated = block.replaceAll(
          RegExp(r"applicationId\s*=\s*'[^']+'"),
          "applicationId = '$newId'",
        );
      }

      // If not replaced, try KTS method call format: applicationId("...")
      if (updated == block) {
        updated = block.replaceAll(
          RegExp(r'applicationId\s*\(\s*"[^"]+"\s*\)'),
          'applicationId("$newId")',
        );
      }

      // If not replaced, try with single quotes
      if (updated == block) {
        updated = block.replaceAll(
          RegExp(r"applicationId\s*\(\s*'[^']+'\s*\)"),
          "applicationId('$newId')",
        );
      }

      // If not replaced, try Groovy old format: applicationId "..."
      if (updated == block) {
        updated = block.replaceAll(
          RegExp(r'applicationId\s+"[^"]+"'),
          'applicationId "$newId"',
        );
      }

      // If not replaced, try with single quotes
      if (updated == block) {
        updated = block.replaceAll(
          RegExp(r"applicationId\s+'[^']+'"),
          "applicationId '$newId'",
        );
      }

      return prefix + updated + suffix;
    });
  }

  /// Finds the app-level build.gradle file
  /// Returns the path to either build.gradle or build.gradle.kts
  static String findAppBuildFile() {
    final buildGradleKtsFile = File("./android/app/build.gradle.kts");
    final buildGradleFile = File("./android/app/build.gradle");

    if (buildGradleKtsFile.existsSync()) {
      return "./android/app/build.gradle.kts";
    } else if (buildGradleFile.existsSync()) {
      return "./android/app/build.gradle";
    }

    // Default to build.gradle if neither exists yet
    return "./android/app/build.gradle";
  }
}
