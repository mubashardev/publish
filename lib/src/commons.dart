part of '../publish.dart';

class _Commons {
  // static final String basePath = "./lib";
  // static final String pubspecPath = './pubspec.yaml';
  static final String appManifestPath =
      "./android/app/src/main/AndroidManifest.xml";
  static final String iosPlistPath = './ios/Runner/Info.plist';
  static final String iosPbxprojPath = './ios/Runner.xcodeproj/project.pbxproj';

  /// Gets the app build file path (build.gradle or build.gradle.kts)
  /// Prefers build.gradle.kts if it exists, otherwise falls back to build.gradle
  static String get appBuildPath {
    return _GradleParser.findAppBuildFile();
  }

  // static bool fileContainsString(String path, String pattern) {
  //   String file = getFileAsString(path);
  //   return file.contains(pattern);
  // }

  // static Map loadConfig() {
  //   return Map.from(loadYaml(File(pubspecPath).readAsStringSync()));
  // }

  // static bool pluginExists(String plugin) {
  //   return fileContainsString(pubspecPath, plugin);
  // }

  // /// Adds provided dependencies to pubspec.yaml file
  // static void addDependencise(String dependencies) {
  //   replaceFirstStringInfile(
  //       pubspecPath, "dev_dependencies:", "$dependencies\ndev_dependencies:");
  // }

  /// replace string in a file at [path] from [from] to [to]
  // static void replaceFirstStringInfile(String path, Pattern from, String to) {
  //   String contents = getFileAsString(path);
  //   contents = contents.replaceFirst(from, to);
  //   writeStringToFile(path, contents);
  // }

  /// Reads a file at [path] as string
  static String getFileAsString(String path) {
    return File(path).readAsStringSync();
  }

  /// writes a string [contents] to a file at [path]
  static void writeStringToFile(String path, String contents) {
    File(path).writeAsStringSync(contents);
  }

  /// Reads a file at [path] as a list of lines
  /// This method is kept for potential future use despite current analysis warnings
  // ignore: unused_element
  static List<String> getFileAsLines(String path) {
    return File(path).readAsLinesSync();
  }
}
