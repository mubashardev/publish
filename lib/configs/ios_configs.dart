part of '../publish.dart';

class _IosConfigs {
  static String get appName {
    // Get app name from Info.plist
    String infoPlistString =
        _Commons.getFileAsString("./ios/Runner/Info.plist");
    RegExp appNameRegex =
        RegExp(r'<key>CFBundleDisplayName<\/key>\s*<string>([^<]+)<\/string>');

    RegExpMatch? appNameMatch = appNameRegex.firstMatch(infoPlistString);
    if (appNameMatch != null) {
      return appNameMatch.group(1)!;
    } else {
      throw Exception("App name not found in Info.plist.");
    }
  }

  static String get appId {
    // Get bundle identifier from project.pbxproj
    String pbxprojString =
        _Commons.getFileAsString("./ios/Runner.xcodeproj/project.pbxproj");
    RegExp bundleIdRegex = RegExp(r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*([^;]+);');

    RegExpMatch? bundleIdMatch = bundleIdRegex.firstMatch(pbxprojString);
    if (bundleIdMatch != null) {
      return bundleIdMatch.group(1)!.trim();
    } else {
      throw Exception("Bundle identifier not found in project.pbxproj.");
    }
  }

  static void setAppName(String name) {
    // Read the Info.plist file as a string
    String plistString = _Commons.getFileAsString(_Commons.iosPlistPath);

    // Replace the app name with the new name
    plistString = plistString.replaceAll(
        RegExp(r'<key>CFBundleDisplayName</key>\s*<string>[^<]+</string>'),
        '<key>CFBundleDisplayName</key>\n    <string>$name</string>');

    // Write the modified string back to the file
    File(_Commons.iosPlistPath).writeAsStringSync(plistString);
  }

  static void setAppId(String appId) {
    final filePath =
        _Commons.iosPbxprojPath; // Use your iosPbxprojPath from _Commons
    List<String> contentLineByLine = _Commons.getFileAsString(filePath)
        .split('\n'); // Read the file content as lines

    // Iterate through the lines and find the one that contains 'PRODUCT_BUNDLE_IDENTIFIER'
    for (var i = 0; i < contentLineByLine.length; i++) {
      if (contentLineByLine[i].contains('PRODUCT_BUNDLE_IDENTIFIER')) {
        contentLineByLine[i] =
            'PRODUCT_BUNDLE_IDENTIFIER = $appId;'; // Set the new appId
      }
    }
    // Write the updated content back to the file using your existing function
    _Commons.writeStringToFile(filePath, contentLineByLine.join('\n'));
  }
}
