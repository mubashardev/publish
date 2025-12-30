part of '../../publish.dart';

class InitCommand extends Command {
  @override
  String get name => 'init';

  @override
  String get description =>
      'Quick setup wizard for configuring your app (run "publish doctor" first for best results).';

  @override
  void run() async {
    _ConsoleUI.printHeader('🧙 Publish Wizard',
        subtitle: 'Quick Setup for Your App');

    _ConsoleUI.printInfo(
        'Tip: Run "publish doctor" first to see what needs attention.');
    _ConsoleUI.printEmpty();

    // 1. App Name
    try {
      final currentAppName = _AndroidConfigs.appName;
      final appName = _ConsoleUI.ask('App Name', defaultValue: currentAppName);

      if (appName != currentAppName) {
        _ConsoleUI.printStatus('Config', 'Updating App Name...');
        ConfigsHelper.updateName(appName, 'android');
        ConfigsHelper.updateName(appName, 'ios');
      }
    } catch (e) {
      _ConsoleUI.printWarning('Could not read current App Name: $e');
      final appName = _ConsoleUI.ask('App Name (enter to skip)');
      if (appName.isNotEmpty) {
        ConfigsHelper.updateName(appName, 'android');
        ConfigsHelper.updateName(appName, 'ios');
      }
    }

    // 2. Package Name (App ID)
    try {
      final currentAppId = _AndroidConfigs.appId;
      final appId = _ConsoleUI.ask('Package ID', defaultValue: currentAppId);

      if (appId != currentAppId) {
        if (!_Validator.isValidAppId(appId)) {
          _ConsoleUI.printError('Invalid App ID format.');
        } else {
          _ConsoleUI.printStatus('Config', 'Updating App ID...');
          ConfigsHelper.updateId(appId, 'android');
          ConfigsHelper.updateId(appId, 'ios');
        }
      }
    } catch (e) {
      _ConsoleUI.printWarning('Could not read current App ID: $e');
      final appId = _ConsoleUI.ask('Package ID (enter to skip)');
      if (appId.isNotEmpty) {
        if (!_Validator.isValidAppId(appId)) {
          _ConsoleUI.printError('Invalid App ID format.');
        } else {
          ConfigsHelper.updateId(appId, 'android');
          ConfigsHelper.updateId(appId, 'ios');
        }
      }
    }

    // 3. Icons
    final iconPath =
        _ConsoleUI.ask('Icon source path (leave empty to skip generation)');
    if (iconPath.isNotEmpty) {
      if (File(iconPath).existsSync()) {
        _ConsoleUI.printInfo('Generating icons from $iconPath...');
        await IconsCommand.generate(File(iconPath));
      } else {
        _ConsoleUI.printError('File not found: $iconPath');
      }
    }

    // 4. Gitignore
    if (_ConsoleUI.promptConfirm('Generate .gitignore?', defaultYes: true)) {
      IgnoreCommand().run();
    }

    _ConsoleUI.printHeader('🎉 Setup Complete!',
        subtitle: 'Run `publish doctor` to verify.');
  }
}
