part of 'publish.dart';

class _Commons {
  static final String basePath = "./lib";
  static final String pubspecPath = './pubspec.yaml';
  static final String appBuildPath = "./android/app/build.gradle";


  static bool fileContainsString(String path, String pattern) {
    String file = getFileAsString(path);
    return file.contains(pattern);
  }

  static bool pluginExists(String plugin) {
    return fileContainsString(pubspecPath, plugin);
  }

  /// Adds provided dependencies to pubspec.yaml file
  static void addDependencise(String dependencies) {
    replaceFirstStringInfile(
        pubspecPath, "dev_dependencies:", "$dependencies\ndev_dependencies:");
  }

  /// replace string in a file at [path] from [from] to [to]
  static void replaceFirstStringInfile(String path, Pattern from, String to) {
    String contents = getFileAsString(path);
    contents = contents.replaceFirst(from, to);
    writeStringToFile(path, contents);
  }

  /// Reads a file at [path] as string
  static String getFileAsString(String path) {
    return File(path).readAsStringSync();
  }

  /// writes a string [contents] to a file at [path]
  static void writeStringToFile(String path, String contents) {
    File(path).writeAsStringSync(contents);
  }

  /// Reads a file at [path] as a list of lines
  static List<String> getFileAsLines(String path) {
    return File(path).readAsLinesSync();
  }
}