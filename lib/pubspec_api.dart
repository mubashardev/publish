part of 'publish.dart';

class _PubspecAPI {
  static final String baseUrl = "https://pub.dev/api/packages/";

  _PubspecAPI();

  static Future<String?> _getLatestVersion(String package) async {
    http.Response res = await http.get(Uri.parse(baseUrl + package));
    if (res.statusCode == 200) {
      Map<String, dynamic> resJson = json.decode(res.body);
      return resJson['latest']['version'];
    } else {
      return null;
    }
  }

  static Future<bool> checkIfLatestVersion(String package) async {
    var pubspec = File("./pubspec.yaml");
    if (!pubspec.existsSync()) {
      stdout.writeln("pubspec.yaml not found");
      return false;
    }
    var yml = loadYaml(pubspec.readAsStringSync());
    var dependencies = yml["dependencies"];

    if (dependencies == null) {
      stdout.writeln("No dependencies found in pubspec.yaml");
      return false;
    }
    if (dependencies[package] == null) {
      stdout.writeln("Package $package not found in pubspec.yaml");
      return false;
    }

    var currentVersion = dependencies[package].toString().replaceAll('^', '');
    var latestVersion = await _getLatestVersion(package);
    if (latestVersion == null) {
      stdout.writeln(
          "Failed to check package \"$package\" from pub.dev. Make sure you have active internet connection.");
      return false;
    }
    if (currentVersion != latestVersion) {
      stdout.writeln(
          "Package $package is not up to date. Please update to the latest version.\n\n$package: ^$latestVersion   ---> Add this latest version to pubspec.yaml\n\n");
      return false;
    }

    return true;
  }
}
