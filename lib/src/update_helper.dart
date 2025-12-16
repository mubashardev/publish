part of '../publish.dart';

class UpdateHelper {
  /// Retrieves the currently installed version of the `publish` package.
  static Future<String> get installedVersion async {
    try {
      // Run the `dart pub global list` command
      final result = await Process.run('dart', ['pub', 'global', 'list']);
      if (result.exitCode == 0) {
        // Parse the output to find the version of `publish`
        final regex = RegExp(r'publish (\d+\.\d+\.\d+)');
        final match = regex.firstMatch(result.stdout as String);
        return match?.group(1) ?? 'Unknown';
      }
    } catch (_) {}
    return 'Unknown';
  }

  /// Updates the `publish` package to the latest version.
  static Future<void> update() async {
    try {
      _ConsoleUI.printHeader('🔄 Updating Publish',
          subtitle: 'Fetching latest version...');

      final latestVersion = await _PubspecAPI.getLatestVersion("publish");
      if (latestVersion == null) {
        _ConsoleUI.printError(
            'Failed to fetch latest version. Check your internet connection.');
        return;
      }

      final current = await installedVersion;
      if (current == latestVersion) {
        _ConsoleUI.printSuccess('Publish is already up to date ($current).');
        return;
      }

      // Update Global Activation
      stdout.writeln(
          'Global Update: ${blue}Running dart pub global activate...$reset');
      final globalResult =
          await Process.run('dart', ['pub', 'global', 'activate', 'publish']);
      if (globalResult.exitCode == 0) {
        stdout.writeln('Global: ${green}Success$reset');
      } else {
        stdout.writeln('Global: ${red}Failed${reset}\n${globalResult.stderr}');
      }

      // Update Local Dependency (if applicable)
      final hasLocalDependency = _hasLocalDependency();
      if (hasLocalDependency) {
        stdout.writeln(
            'Local Project: ${blue}Running flutter pub upgrade...$reset');
        final localResult =
            await Process.run('flutter', ['pub', 'upgrade', 'publish']);
        if (localResult.exitCode == 0) {
          stdout.writeln('Local: ${green}Success$reset');
        } else {
          stdout.writeln('Local: ${red}Failed${reset}\n${localResult.stderr}');
        }
      }

      _ConsoleUI.printSuccess('🚀 Update completed!');
    } catch (e) {
      _ConsoleUI.printError('Error during update: $e');
    }
  }

  static bool _hasLocalDependency() {
    try {
      final file = File('pubspec.yaml');
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        // Simple check if 'publish:' is in dependencies or dev_dependencies
        return content.contains(RegExp(r'^\s*publish:', multiLine: true));
      }
    } catch (_) {}
    return false;
  }

  /// Checks if an update for the `publish` package is available, and if so,
  /// prompts the user to update.
  static Future<void> checkIfUpdateAvailable() async {
    try {
      final latestVersion = await _PubspecAPI.getLatestVersion("publish");
      final currentVersion = await installedVersion;

      if (latestVersion != null &&
          latestVersion != currentVersion &&
          currentVersion != 'Unknown') {
        stdout.write(
            '\n${blue}A new version of publish is available: ${green}$latestVersion${blue} (current: $currentVersion). Would you like to update? [y/N] $reset');
        final input = stdin.readLineSync();
        if (input?.toLowerCase() == 'y') {
          await update();
          // Force exit to ensure user runs the command again with the new version if globally active,
          // though mostly for CLI tools updates apply on next run.
          exit(0);
        }
      }
    } catch (_) {}
  }
}
