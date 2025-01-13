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
      stdout.writeln('\n==============================');
      stdout.writeln('${cyan}🚀 Application Details$reset');
      stdout.writeln('==============================\n');
      if (validAndroid) {
        printAppDetails(
            "📱 Android", _AndroidConfigs.appName, _AndroidConfigs.appId);
      }
      if (validAndroid && validIos) {
        stdout.writeln('\n------------------------------\n');
      }
      if (validIos) {
        printAppDetails("🍎 iOS", _IosConfigs.appName, _IosConfigs.appId);
      }
      stdout.writeln('\n==============================\n');
    }
  }

  /// Prints app and package details for Android and iOS in a formatted and colorful manner.
  static void printAppDetails(String type, String appName, String appId) {
    // Android section
    stdout.writeln('${yellow}$type Details:$reset');
    stdout.writeln('\tApp Name:\t\t${green}$appName$reset');
    stdout.writeln('\t  App ID:\t\t${blue}$appId$reset');
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
      stdout.writeln(
          'Please provide a name for your app. Example: flutter pub run publish app-name --value "My App"'.makeWarning);
      return;
    }
    if (!_Validator.isValidAppName(value)) {
      stdout.writeln('Invalid app name: $value'.makeError);
      return;
    }

    var platforms = (argResults?['platforms'] ?? "android,ios").split(',');
    for (var platform in platforms) {
      try {
        var done = ConfigsHelper.updateName(value, platform);
        if (done) {
          stdout.writeln('Successfully updated $platform app name to: $value'.makeCheck);
        }
      } catch (e) {
        stdout.writeln('Error updating $platform app name: $e'.makeError);
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
      stdout.writeln(
          'Please provide a name for your app. Example: flutter pub run publish app-id --value "com.myapp"'.makeWarning);
      return;
    }
    if (!_Validator.isValidAppId(value)) {
      stdout.writeln('Invalid app id: $value'.withColor(red));
      return;
    }

    var platforms = (argResults?['platforms'] ?? "android,ios").split(',');
    for (var platform in platforms) {
      try {
        var done = ConfigsHelper.updateId(value, platform);
        if (done) {
          stdout.writeln(
              'Successfully set $platform app id to: $value'.makeCheck);
        }
      } catch (e) {
        stdout.writeln(
            'Failed to set $platform app id to: $value'.makeError);
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
          'This directory doesn\'t seem to be a valid Flutter project.'.makeError);
      return;
    } else if (!_Validator.isAndroidManifestValid) {
      stdout.writeln(
          'Your Flutter project doesn\'t have a valid AndroidManifest.xml file.'.makeError);
      return;
    } else if (!_Validator.isGradleValid) {
      stdout.writeln(
          'Your Flutter android project doesn\'t have a valid build.gradle file.'.makeError);
      return;
    }

    _UpdateHelper.checkIfUpdateAvailable().then((_) {
      _androidSign(); // Calls your existing signing logic
    });
  }
}
