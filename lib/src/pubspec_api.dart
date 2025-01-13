part of '../publish.dart';

class _PubspecAPI {
  static final String baseUrl = "https://pub.dev/api/packages/";

  /// Gets the latest version of a package from pub.dev.
  ///
  /// Throws an [Exception] if the package doesn't exist or the request fails.
  ///
  /// Returns `null` if the package doesn't exist or the request fails.
  static Future<String?> getLatestVersion(String package) async {
    http.Response res = await http.get(Uri.parse(baseUrl + package));
    if (res.statusCode == 200) {
      Map<String, dynamic> resJson = json.decode(res.body);
      return resJson['latest']['version'];
    } else {
      return null;
    }
  }
}
