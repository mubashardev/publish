part of '../../publish.dart';

class ReadAppConfigsCommand extends Command {
  @override
  String get description =>
      'Check current configurations of your flutter app ie. app name, package name, etc.';

  @override
  String get name => 'show-config';

  @override
  void run() {
    if (!_Validator.isPubspecValid) {
      _ConsoleUI.printError(
          "This directory doesn't seem to be a valid Flutter project.");
      return;
    }

    final validAndroid = _Validator.isValidAndroid;
    final validIos = _Validator.isValidIos;

    if (validAndroid || validIos) {
      _ConsoleUI.printHeader('🚀 Application Details',
          subtitle: 'Flutter Project Configuration');

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
      _ConsoleUI.printError(
          'No valid Android or iOS configuration found in this project');
    }
  }
}
