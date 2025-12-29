part of '../../publish.dart';

class SignAndroidCommand extends Command {
  @override
  String get description => 'Set up Android signing configurations.';

  @override
  String get name => 'android';

  @override
  void run() async {
    if (!_Validator.isPubspecValid) {
      _ConsoleUI.printError(
          "This directory doesn't seem to be a valid Flutter project.");
      return;
    }

    ConfigsManager().load();

    _ConsoleUI.printHeader('🔐 Android Signing Setup',
        subtitle: 'Keystore Generator');

    String? configName;

    if (ConfigsManager().hasConfigs) {
      final active = ConfigsManager().activeConfig;
      if (active != null) {
        _ConsoleUI.printStatus(
            'Config', 'Active Configuration: ${active.name}');
        _ConsoleUI.printInfo(
            'You can overwrite the active configuration or create a new one.');

        final createNew = _ConsoleUI.promptConfirm(
            'Do you want to create a NEW configuration?');
        if (!createNew) {
          if (!_ConsoleUI.promptConfirm(
              'Overwrite active configuration "${active.name}"?')) {
            return;
          }
          configName = active.name;
        }
      } else {
        _ConsoleUI.printInfo('Existing configurations found, but none active.');
        if (!_ConsoleUI.promptConfirm('Create a new configuration?')) {
          return;
        }
      }
    }

    if (_ConsoleUI.promptConfirm(
        'This will generate a keystore and update your build.gradle. Proceed?')) {
      final config = await _AndroidSigning.sign(configName: configName);

      if (config != null) {
        // Backup current icons for this new config
        ConfigsManager().backupIconsForNewConfig(config);

        ConfigsManager().addConfig(config);
        await ConfigsManager().setActiveConfig(config.name);

        _ConsoleUI.printSuccess('Android signing configured successfully!');
        _ConsoleUI.printInfo('Configuration "${config.name}" is now active.');
        _ConsoleUI.printInfo('You can now run: publish build android');
      } else {
        _ConsoleUI.printError('Android signing configuration failed.');
      }
    }
  }
}
