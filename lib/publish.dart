library publish;

import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:xml/xml.dart';
import 'package:yaml/yaml.dart';
import 'package:http/http.dart' as http;

part 'src/android_signing.dart';
part 'src/commons.dart';
part 'src/pubspec_api.dart';
part 'src/update_helper.dart';
part 'src/validator.dart';
part 'configs/android_configs.dart';
part 'configs/ios_configs.dart';

class ReadAppConfigsCommand extends Command {
  // ANSI escape codes for colors
  static const String reset = '\x1B[0m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String cyan = '\x1B[36m';

  @override
  String get description =>
      'Check current configurations of your flutter app ie. app name, package name, etc.';

  @override
  String get name => '--read-configs';

  @override
  void run() {
    if (!_Validator.isPubspecValid) {
      stdout.writeln(
        "This directory doesn't seem to be a valid Flutter project.",
      );
      return;
    }

    var validAndroid =
        _Validator.isAndroidManifestValid && _Validator.isGradleValid;
    var validIos = true;

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
    addSubcommand(WriteAndroidConfigsCommand());
    addSubcommand(WriteIosConfigsCommand());
  }

  @override
  void run() {
    if (!_Validator.isPubspecValid) {
      stdout.writeln(
        "This directory doesn't seem to be a valid Flutter project.",
      );
      return;
    }
  }
}

class WriteAndroidConfigsCommand extends Command {
  WriteAndroidConfigsCommand() {
    argParser
      ..addOption(
        'name',
        help: 'Set the app name for the Android project.',
      )
      ..addOption(
        'id',
        help: 'Set the package name (applicationId) for the Android project.',
      );
  }

  @override
  String get description =>
      'Write configurations for your Android app (e.g., app name, package name).';

  @override
  String get name => 'android';

  @override
  void run() {
    if (!_Validator.isAndroidManifestValid || !_Validator.isGradleValid) {
      stdout.writeln(
        "This directory doesn't seem to be a valid Flutter Android project.",
      );
      return;
    }

    final appName = argResults?['name'];
    final appId = argResults?['id'];

    if (appName != null) {
      if (!_Validator.isValidAppName(appName)){
        stdout.writeln('Invalid app name: $appName');
        return;
      }
      // Call method to update Android app name
      stdout.writeln('Setting Android app name to: $appName');
      _AndroidConfigs.setAppName(appName);
    }

    if (appId != null) {
      if (!_Validator.isValidAppId(appId)){
        stdout.writeln('Invalid app ID: $appId');
        return;
      }
      // Call method to update Android package name
      stdout.writeln('Setting Android package name to: $appId');
      _AndroidConfigs.setAppId(appId);
    }

    if (appName == null && appId == null) {
      stdout.writeln('No options provided. Use --name or --id to set values.');
    }
  }
}

class WriteIosConfigsCommand extends Command {
  WriteIosConfigsCommand() {
    argParser
      ..addOption(
        'name',
        help: 'Set the app name for the iOS project.',
      )
      ..addOption(
        'id',
        help: 'Set the package name (app id) for the iOS project.',
      );
  }

  @override
  String get description =>
      'Write configurations for your Android app (e.g., app name, package name).';

  @override
  String get name => 'ios';

  @override
  void run() {
    if (!_Validator.isAndroidManifestValid || !_Validator.isGradleValid) {
      stdout.writeln(
        "This directory doesn't seem to be a valid Flutter iOS project.",
      );
      return;
    }

    final appName = argResults?['name'];
    final appId = argResults?['id'];


    if (appName != null) {
      if (!_Validator.isValidAppName(appName)){
        stdout.writeln('Invalid app name: $appName');
        return;
      }
      // Call method to update Android app name
      stdout.writeln('Setting iOS app name to: $appName');
      _IosConfigs.setAppName(appName);
    }

    if (appId != null) {
      if (!_Validator.isValidAppId(appId)){
        stdout.writeln('Invalid app ID: $appId');
        return;
      }
      // Call method to update Android package name
      stdout.writeln('Setting iOS package name to: $appId');
      _IosConfigs.setAppId(appId);
    }

    if (appName == null && appId == null) {
      stdout.writeln('No options provided. Use --name or --id to set values.');
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
          'This directory doesn\'t seem to be a valid Flutter project.');
      return;
    } else if (!_Validator.isAndroidManifestValid) {
      stdout.writeln(
          'Your Flutter project doesn\'t have a valid AndroidManifest.xml file.');
      return;
    } else if (!_Validator.isGradleValid) {
      stdout.writeln(
          'Your Flutter android project doesn\'t have a valid build.gradle file.');
      return;
    }

    _UpdateHelper.checkIfUpdateAvailable().then((isLatest) {
      _androidSign(); // Calls your existing signing logic
    });
  }
}
