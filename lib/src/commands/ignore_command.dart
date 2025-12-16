part of '../../publish.dart';

class IgnoreCommand extends Command {
  @override
  String get name => 'ignore';

  @override
  String get description =>
      'Generate a standard .gitignore file for your Flutter project.';

  @override
  void run() {
    final gitignoreFile = File('.gitignore');

    if (gitignoreFile.existsSync()) {
      _ConsoleUI.printWarning('.gitignore already exists.');
      final overwrite =
          _ConsoleUI.promptConfirm('Do you want to overwrite it?');
      if (!overwrite) {
        _ConsoleUI.printInfo('Operation cancelled.');
        return;
      }
    }

    try {
      gitignoreFile.writeAsStringSync(_flutterGitignoreContent);
      _ConsoleUI.printSuccess('Generated .gitignore file successfully.');
    } catch (e) {
      _ConsoleUI.printError('Failed to write .gitignore: $e');
    }
  }

  static const _flutterGitignoreContent = '''
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# The .vscode/ folder contains launch configuration and tasks for VS Code.
# You might want to upload it to version control if you want to share
# the settings with your team.
.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/

# Web related
lib/generated_plugin_registrant.dart

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
**/android/app/build
**/android/.gradle
**/android/local.properties
**/android/key.properties

# iOS
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/flutter_export_environment.sh
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*

# Exceptions to above rules.
!**/android/app/src/main/AndroidManifest.xml
!**/ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json
''';
}
