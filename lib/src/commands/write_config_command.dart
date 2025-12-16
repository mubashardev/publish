part of '../../publish.dart';

class WriteAppConfigsCommand extends Command {
  @override
  String get description =>
      'Write configurations for your flutter app ie. app name, package name, etc.';

  @override
  String get name => 'config';

  WriteAppConfigsCommand() {
    addSubcommand(WriteAppNameConfigsCommand());
    addSubcommand(WriteAppIdConfigsCommand());
  }
}

class WriteAppNameConfigsCommand extends Command {
  WriteAppNameConfigsCommand() {
    argParser
      ..addOption(
        'platforms',
        help: 'Set the app name for specified platforms.',
      )
      ..addOption(
        'value',
        help: 'Set the app name for both or specified platforms.',
      );
  }

  @override
  String get description => 'Update your flutter app name.';

  @override
  String get name => 'app-name';

  @override
  void run() {
    if (!_Validator.isPubspecValid) {
      _ConsoleUI.printError(
          "This directory doesn't seem to be a valid Flutter project.");
      return;
    }

    var value = argResults?['value'];
    if (value == null) {
      _ConsoleUI.printWarning('No app name provided via --value flag');
      value = _ConsoleUI.prompt('Enter new app name', required: true);
      if (value == null || value.isEmpty) {
        _ConsoleUI.printError('App name cannot be empty');
        return;
      }
    }

    if (!_Validator.isValidAppName(value)) {
      _ConsoleUI.printError(
          'Invalid app name: $value\n  App names must contain only letters and spaces');
      return;
    }

    var platforms = (argResults?['platforms'] ?? "android,ios").split(',');

    _ConsoleUI.printHeader('📝 Updating App Name', subtitle: value);

    for (var platform in platforms) {
      platform = platform.trim();
      try {
        var done = ConfigsHelper.updateName(value, platform);
        if (done) {
          _ConsoleUI.printSuccess('Updated $platform app name to: $value');
        } else {
          _ConsoleUI.printWarning('Skipped $platform (not configured)');
        }
      } catch (e) {
        _ConsoleUI.printError('Error updating $platform app name: $e');
      }
    }
  }
}

class WriteAppIdConfigsCommand extends Command {
  WriteAppIdConfigsCommand() {
    argParser
      ..addOption(
        'platforms',
        help: 'Set the app id for specified platform(s).',
      )
      ..addOption(
        'value',
        help: 'Set the app id for both or specified platform(s).',
      );
  }

  @override
  String get description => 'Update your flutter app id (package name).';

  @override
  String get name => 'app-id';

  @override
  void run() {
    if (!_Validator.isPubspecValid) {
      _ConsoleUI.printError(
          "This directory doesn't seem to be a valid Flutter project.");
      return;
    }

    var value = argResults?['value'];
    if (value == null) {
      _ConsoleUI.printWarning('No app ID provided via --value flag');
      value =
          _ConsoleUI.prompt('Enter new app ID (package name)', required: true);
      if (value == null || value.isEmpty) {
        _ConsoleUI.printError('App ID cannot be empty');
        return;
      }
    }

    if (!_Validator.isValidAppId(value)) {
      _ConsoleUI.printError(
          'Invalid app ID: $value\n  Format: com.company.appname (lowercase, dots separated)');
      return;
    }

    var platforms = (argResults?['platforms'] ?? "android,ios").split(',');

    _ConsoleUI.printHeader('📦 Updating App ID', subtitle: value);

    for (var platform in platforms) {
      platform = platform.trim();
      try {
        var done = ConfigsHelper.updateId(value, platform);
        if (done) {
          _ConsoleUI.printSuccess('Updated $platform app ID to: $value');
        } else {
          _ConsoleUI.printWarning('Skipped $platform (not configured)');
        }
      } catch (e) {
        _ConsoleUI.printError('Error updating $platform app ID: $e');
      }
    }
  }
}
