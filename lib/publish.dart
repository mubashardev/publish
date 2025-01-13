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

class CheckAppConfigsCommand extends Command {
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
  String get name => 'check-configs';

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
        printAppDetails("🍎 iOS", "Testing", "1.0.0");
      }
      stdout.writeln('\n==============================\n');
    }
  }

  /// Prints app and package details for Android and iOS in a formatted and colorful manner.
  static void printAppDetails(String type, String appName, String appId) {
    // Android section
    stdout.writeln('${yellow}$type Details:$reset');
    stdout.writeln('\tApp Name:\t\t\t${green}$appName$reset');
    stdout.writeln('\tPackage Name:\t\t\t${blue}$appId$reset');
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
