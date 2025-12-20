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
    if (_ConsoleUI.promptConfirm('Do you want to update the App Name?')) {
      final appName = _ConsoleUI.prompt('Enter App Name', required: true);
      if (appName != null) {
        _ConsoleUI.printStatus('Config', 'Updating App Name...');
        ConfigsHelper.updateName(appName, 'android');
        ConfigsHelper.updateName(appName, 'ios');
      }
    }

    // 2. Package Name (App ID)
    if (_ConsoleUI.promptConfirm('Do you want to update the Package ID?')) {
      final appId = _ConsoleUI.prompt('Enter Package ID (e.g. com.example.app)',
          required: true);
      if (appId != null) {
        if (!_Validator.isValidAppId(appId)) {
          _ConsoleUI.printError('Invalid App ID format.');
        } else {
          _ConsoleUI.printStatus('Config', 'Updating App ID...');
          ConfigsHelper.updateId(appId, 'android');
          ConfigsHelper.updateId(appId, 'ios');
        }
      }
    }

    // 3. Icons
    if (_ConsoleUI.promptConfirm('Do you want to generate App Icons?')) {
      final path =
          _ConsoleUI.prompt('Enter path to source image', required: true);
      if (path != null) {
        _ConsoleUI.printInfo('Generating icons from $path...');
        await IconsCommand.generate(File(path));
      }
    }

    // 4. Gitignore
    if (_ConsoleUI.promptConfirm('Do you want to generate a .gitignore?')) {
      IgnoreCommand().run();
    }

    _ConsoleUI.printHeader('🎉 Setup Complete!',
        subtitle: 'Run `publish doctor` to verify.');
  }
}
