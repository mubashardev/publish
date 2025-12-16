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

  static String getNextVersion(String currentVersion, String type) {
    final versionRegex = RegExp(r'^(\d+)\.(\d+)\.(\d+)(\+(\d+))?');
    final match = versionRegex.firstMatch(currentVersion);

    if (match == null) {
      throw FormatException('Invalid version format: $currentVersion');
    }

    int major = int.parse(match.group(1)!);
    int minor = int.parse(match.group(2)!);
    int patch = int.parse(match.group(3)!);
    int? build = match.group(5) != null ? int.parse(match.group(5)!) : null;

    switch (type) {
      case 'major':
        major++;
        minor = 0;
        patch = 0;
        build = null;
        break;
      case 'minor':
        if (minor < 9) {
          minor++;
        } else {
          minor = 0;
          major++;
        }
        patch = 0;
        build = null;
        break;
      case 'patch':
        if (patch < 9) {
          patch++;
        } else {
          patch = 0;
          if (minor < 9) {
            minor++;
          } else {
            minor = 0;
            major++;
          }
        }
        build = null;
        break;
      case 'build':
        build = (build ?? 0) + 1;
        break;
      default:
        throw ArgumentError('Invalid bump type: $type');
    }

    String newVersion = '$major.$minor.$patch';
    if (build != null) {
      newVersion += '+$build';
    }
    return newVersion;
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

    final oldVersion = match.group(0)!.substring(8).trim();
    // Reconstruct version string from loading to pass to logic if needed,
    // or just pass components.
    // passing the whole version string is easier if we have a parser,
    // but here we already parsed it.
    // Let's make getNextVersion take the string and return the string, reliable and cleaner.
    final matchVersion = match.group(1)! +
        '.' +
        match.group(2)! +
        '.' +
        match.group(3)! +
        (match.group(5) != null ? '+${match.group(5)}' : '');

    try {
      final newVersion = VersionCommand.getNextVersion(matchVersion, _type);
      final newContent =
          content.replaceFirst(versionRegex, 'version: $newVersion');
      pubspecFile.writeAsStringSync(newContent);

      _ConsoleUI.printSuccess('Bumped version from $oldVersion to $newVersion');
    } catch (e) {
      _ConsoleUI.printError(e.toString());
    }
  }
}
