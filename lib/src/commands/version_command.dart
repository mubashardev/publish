part of '../../publish.dart';

class VersionCommand extends Command {
  @override
  String get name => 'version';

  @override
  String get description => 'Bump the version of your package.';

  VersionCommand() {
    addSubcommand(_BumpCommand('major'));
    addSubcommand(_BumpCommand('minor'));
    addSubcommand(_BumpCommand('patch'));
    addSubcommand(_BumpCommand('build'));
  }
}

class _BumpCommand extends Command {
  final String _type;

  _BumpCommand(this._type);

  @override
  String get name => _type;

  @override
  String get description => 'Bump the $_type version.';

  @override
  void run() {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      _ConsoleUI.printError('pubspec.yaml not found.');
      return;
    }

    String content = pubspecFile.readAsStringSync();

    // Regex to find version with optional build number
    // Matches: version: 1.0.0 or version: 1.0.0+1
    final versionRegex =
        RegExp(r'^version:\s+(\d+)\.(\d+)\.(\d+)(\+(\d+))?', multiLine: true);
    final match = versionRegex.firstMatch(content);

    if (match == null) {
      _ConsoleUI.printError('Could not find a valid version in pubspec.yaml');
      return;
    }

    int major = int.parse(match.group(1)!);
    int minor = int.parse(match.group(2)!);
    int patch = int.parse(match.group(3)!);
    int? build = match.group(5) != null ? int.parse(match.group(5)!) : null;

    final oldVersion = '${match.group(0)!.substring(8).trim()}';

    // Bump logic
    switch (_type) {
      case 'major':
        major++;
        minor = 0;
        patch = 0;
        build =
            null; // Reset build on major bump? Usually yes or keep it. Let's reset to clean slate or absent.
        break;
      case 'minor':
        minor++;
        patch = 0;
        build = null;
        break;
      case 'patch':
        patch++;
        build = null;
        break;
      case 'build':
        build = (build ?? 0) + 1;
        break;
    }

    String newVersion = '$major.$minor.$patch';
    if (build != null) {
      newVersion += '+$build';
    }

    final newContent =
        content.replaceFirst(versionRegex, 'version: $newVersion');
    pubspecFile.writeAsStringSync(newContent);

    _ConsoleUI.printSuccess('Bumped version from $oldVersion to $newVersion');
  }
}
