library publish;

import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:publish/src/extensions.dart';
import 'package:xml/xml.dart';
import 'package:yaml/yaml.dart';
import 'package:http/http.dart' as http;

import 'src/constants.dart';

part 'src/android_signing.dart';
part 'src/commons.dart';
part 'src/console_ui.dart';
part 'src/gradle_parser.dart';
part 'src/pubspec_api.dart';
part 'src/update_helper.dart';
part 'src/validator.dart';
part 'configs/android_configs.dart';
part 'configs/ios_configs.dart';
part 'configs/configs_helper.dart';

class ReadAppConfigsCommand extends Command {
  @override
  String get description =>
      'Check current configurations of your flutter app ie. app name, package name, etc.';

  @override
  String get name => '--read-configs';

  @override
  void run() {
    if (!_Validator.isPubspecValid) {
      stdout.writeln(
        "This directory doesn't seem to be a valid Flutter project.".makeError,
      );
      return;
    }

    final validAndroid = _Validator.isValidAndroid;
    final validIos = _Validator.isValidIos;

    if (validAndroid || validIos) {
      _ConsoleUI.printHeader('🚀 Application Details', subtitle: 'Flutter Project Configuration');
      
      if (validAndroid) {
        try {
          final androidName = _AndroidConfigs.appName;
          final androidId = _AndroidConfigs.appId;
          _ConsoleUI.printSection('📱 Android Configuration', [
            'App Name: ${green}$androidName$reset',
            'Package Name: ${blue}$androidId$reset',
          ]);
        } catch (e) {
          _ConsoleUI.printError('Failed to read Android config: $e');
        }
      }
      
      if (validIos) {
        try {
          final iosName = _IosConfigs.appName;
          final iosId = _IosConfigs.appId;
          _ConsoleUI.printSection('🍎 iOS Configuration', [
            'App Name: ${green}$iosName$reset',
            'Bundle ID: ${blue}$iosId$reset',
          ]);
        } catch (e) {
          _ConsoleUI.printError('Failed to read iOS config: $e');
        }
      }
    } else {
      _ConsoleUI.printError('No valid Android or iOS configuration found in this project');
    }
  }
}

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

  @override
  void run() {
    if (!_Validator.isPubspecValid) {
      stdout.writeln(
        "This directory doesn't seem to be a valid Flutter project.".makeError,
      );
      return;
    }
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
      stdout.writeln(
        "This directory doesn't seem to be a valid Flutter project.".makeError,
      );
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
      _ConsoleUI.printError('Invalid app name: $value\n  App names must contain only letters and spaces');
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
      stdout.writeln(
        "This directory doesn't seem to be a valid Flutter project.".makeError,
      );
      return;
    }

    var value = argResults?['value'];
    if (value == null) {
      _ConsoleUI.printWarning('No app ID provided via --value flag');
      value = _ConsoleUI.prompt('Enter new app ID (package name)', required: true);
      if (value == null || value.isEmpty) {
        _ConsoleUI.printError('App ID cannot be empty');
        return;
      }
    }

    if (!_Validator.isValidAppId(value)) {
      _ConsoleUI.printError(
        'Invalid app ID: $value\n  Format: com.company.appname (lowercase, dots separated)',
      );
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

class UpdateCommand extends Command {
  @override
  String get description =>
      'Update the `publish` package to the latest version.';

  @override
  String get name => 'update';

  @override
  void run() {
    _UpdateHelper.update();
  }
}

class AndroidSignCommand extends Command {
  @override
  String get description => 'Set up Android signing configurations.';

  @override
  String get name => 'sign-android';

  @override
  void run() {
    if (!_Validator.isPubspecValid) {
      stdout.writeln(
          'This directory doesn\'t seem to be a valid Flutter project.'
              .makeError);
      return;
    } else if (!_Validator.isAndroidManifestValid) {
      stdout.writeln(
          'Your Flutter project doesn\'t have a valid AndroidManifest.xml file.'
              .makeError);
      return;
    } else if (!_Validator.isGradleValid) {
      stdout.writeln(
          'Your Flutter android project doesn\'t have a valid build.gradle file.'
              .makeError);
      return;
    }

    _ConsoleUI.printHeader('🔐 Android App Signing Setup', subtitle: 'Generate keystore and configure signing');

    _UpdateHelper.checkIfUpdateAvailable().then((_) {
      _androidSign(); // Calls your existing signing logic
    });
  }
}
