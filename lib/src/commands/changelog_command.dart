part of '../../publish.dart';

class ChangelogCommand extends Command {
  @override
  String get name => 'changelog';

  @override
  String get description =>
      'Add a new entry to CHANGELOG.md for the current version.';

  @override
  void run() {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      _ConsoleUI.printError('pubspec.yaml not found.');
      return;
    }

    // Read version
    String content = pubspecFile.readAsStringSync();
    final versionRegex = RegExp(r'^version:\s+([^\s]+)', multiLine: true);
    final match = versionRegex.firstMatch(content);
    if (match == null) {
      _ConsoleUI.printError('Could not find version in pubspec.yaml');
      return;
    }
    final version = match.group(1)!;

    final changelogFile = File('CHANGELOG.md');
    String existingContent = '';
    if (changelogFile.existsSync()) {
      existingContent = changelogFile.readAsStringSync();
    }

    final date = DateTime.now().toIso8601String().split('T').first;
    final header = '## [$version] - $date';

    if (existingContent.contains(header)) {
      _ConsoleUI.printWarning('Changelog entry for $version already exists.');
      return;
    }

    final newEntry = '''
$header
 - 

''';

    changelogFile.writeAsStringSync(newEntry + existingContent);
    _ConsoleUI.printSuccess('Added new changelog entry for $version');
  }
}
