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

    // 1. Detect Legacy Config (No configs in file, but key.properties exists)
    if (!ConfigsManager().hasConfigs &&
        File('android/key.properties').existsSync()) {
      _ConsoleUI.printWarning(
          '⚠️  Found existing signing configurations (Legacy).');
      _ConsoleUI.printInfo(
          'It is recommended to save your current settings as a profile first.');
      if (_ConsoleUI.promptConfirm(
          'Do you want to save current settings as a named configuration?')) {
        final legacyName = _ConsoleUI.prompt(
            'Enter name for current settings (e.g. original, beta)',
            required: true);
        if (legacyName != null) {
          final legacyConfig =
              await _AndroidSigning.createConfigFromCurrent(legacyName);
          if (legacyConfig != null) {
            if (_ConsoleUI.promptConfirm(
                'Do you want to backup current icons and splash screen for this configuration?',
                defaultYes: true)) {
              ConfigsManager().backupIconsForNewConfig(legacyConfig);
            }
            ConfigsManager().addConfig(legacyConfig);
            await ConfigsManager().setActiveConfig(
                legacyConfig.name); // This will just confirm it as active
            _ConsoleUI.printSuccess('Current settings saved as "$legacyName"!');
          }
        }
      }
    }

    // 2. Handle Existing Profiles
    if (ConfigsManager().hasConfigs) {
      final active = ConfigsManager().activeConfig;
      if (active != null) {
        _ConsoleUI.printStatus(
            'Config', 'Active Configuration: ${active.name}');

        final createNew = _ConsoleUI.promptConfirm(
            'Do you want to create a NEW configuration?');

        if (createNew) {
          _ConsoleUI.printSuccess(
              'Great! Your previous config "${active.name}" will remain safe.');
          _ConsoleUI.printInfo(
              'You will be switched to the new configuration automatically.');
        } else {
          // User wants to overwrite?
          if (!_ConsoleUI.promptConfirm(
              'Do you want to overwrite the ACTIVE configuration "${active.name}"?')) {
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

    // 3. Proceed to Signing
    if (_ConsoleUI.promptConfirm(
        'This will generate a keystore and update your build.gradle. Proceed?')) {
      final config = await _AndroidSigning.sign(configName: configName);

      if (config != null) {
        // Backup current icons for this new config
        if (_ConsoleUI.promptConfirm(
            'Do you want to backup current icons and splash screen for this configuration?',
            defaultYes: true)) {
          ConfigsManager().backupIconsForNewConfig(config);
        }

        ConfigsManager().addConfig(config);

        // This handles switching AND showing the restore messages + switch tip
        await ConfigsManager().setActiveConfig(config.name);

        _ConsoleUI.printSuccess('Android signing configured successfully!');
        _ConsoleUI.printInfo('Configuration "${config.name}" is now active.');
        _ConsoleUI.printInfo('You can now run: publish build android');

        // 4. Social Plug
        _ConsoleUI.printHeader('🎉 Woooho!', subtitle: 'Success');
        _ConsoleUI.printInfo('You successfully created a new configuration!');
        _ConsoleUI.printInfo(
            'If you like this tool, consider following me on GitHub.');
        if (_ConsoleUI.promptConfirm('Open GitHub profile (@mubashardev)?',
            defaultYes: true)) {
          final url = 'https://github.com/mubashardev';
          if (Platform.isWindows) {
            Process.run('start', [url], runInShell: true);
          } else if (Platform.isMacOS) {
            Process.run('open', [url]);
          } else if (Platform.isLinux) {
            Process.run('xdg-open', [url]);
          }
        }
      } else {
        _ConsoleUI.printError('Android signing configuration failed.');
      }
    }
  }
}
