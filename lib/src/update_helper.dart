part of '../publish.dart';

class _UpdateHelper {
  /// Retrieves the currently installed version of the `publish` package.
  static String get installedVersion {
    try {
      // Run the `dart pub global list` command
      final result = Process.runSync('dart', ['pub', 'global', 'list']);
      if (result.exitCode == 0) {
        // Parse the output to find the version of `publish`
        final regex = RegExp(r'publish (\d+\.\d+\.\d+)');
        final match = regex.firstMatch(result.stdout as String);
        return match?.group(1) ?? 'Unknown';
      }
    } catch (e) {
      print('Error fetching installed version: $e');
    }
    return 'Unknown';
  }

  /// Updates the `publish` package to the latest version.
  static Future<void> update() async {
    try {
      stdout.writeln('Fetching latest update...'.makeWaiting);
      final latestVersion = await _PubspecAPI.getLatestVersion("publish");
      if (latestVersion == null) {
        stdout.writeln(
            'Failed to fetch latest version. Make sure you have active internet connection.'
                .makeError);
        return;
      }

      if (installedVersion == latestVersion) {
        stdout.writeln('Publish package is already up to date.'.makeCheck);
        return;
      }

      final result =
          await Process.run('dart', ['pub', 'global', 'activate', 'publish']);
      if (result.exitCode == 0) {
        stdout.writeln('🚀 Superpowers activated!'.makeCheck);
      } else {
        stdout.writeln(
            'Error updating publish package: ${result.stderr}'.makeError);
      }
    } catch (e) {
      stdout.writeln('Error during update: $e');
    }
  }

  /// Checks if an update for the `publish` package is available, and if so,
  /// prompts the user to update.
  static Future<void> checkIfUpdateAvailable() async {
    try {
      final latestVersion = await _PubspecAPI.getLatestVersion("publish");
      if (latestVersion != null && latestVersion != installedVersion) {
        stdout.write(
            'A new version of publish is available: $latestVersion. Would you like to update [y/n]?'
                .makeInfo);
        final input = stdin.readLineSync();
        if (input?.toLowerCase() == 'y') {
          await update();
        }
      }
    } catch (_) {}
  }
}
