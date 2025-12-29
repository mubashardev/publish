part of '../../publish.dart';

class BuildAndroidCommand extends Command {
  @override
  String get name => 'android';

  @override
  String get description => 'Build Android App Bundle with validation.';

  BuildAndroidCommand() {
    argParser.addOption(
      'config',
      abbr: 'c',
      help:
          'Build with a specific configuration without permanently switching.',
    );
  }

  @override
  void run() async {
    final configName = argResults?['config'] as String?;
    String? previousConfig;

    // If --config is specified, temporarily switch
    if (configName != null) {
      ConfigsManager().load();
      final config = ConfigsManager().getConfig(configName);
      if (config == null) {
        _ConsoleUI.printError('Configuration "$configName" not found.');
        return;
      }

      previousConfig = ConfigsManager().activeConfigName;
      _ConsoleUI.printInfo('Building with config: $configName');
      await ConfigsManager().setActiveConfig(configName);
    }

    _ConsoleUI.printHeader('🏗️  Android Build');

    /// 1. Validation Checks
    bool hasErrors = false;

    // Check 1: App Configs
    if (!_Validator.isGradleValid || !_Validator.isAndroidManifestValid) {
      _ConsoleUI.printError(
          "Android project is not valid. Please run 'flutter doctor' or check your android folder.");
      hasErrors = true;
    }

    // Check 2: Package Name
    final appId = _AndroidConfigs.appId;
    if (_Validator.isDefaultPackageName(appId)) {
      _ConsoleUI.printError(
          "You are using the default package name '$appId'. This is not accepted by Play Store.");
      _ConsoleUI.printInfo(
          "Run 'publish sign android' to fix this or manually change it.");
      hasErrors = true;
    }

    // Check 3: App Icons
    if (!_Validator.isAppIconExists) {
      _ConsoleUI.printError(
          "Default app icons found or icons missing. You should generate custom icons.");
      _ConsoleUI.printInfo("Run 'publish icons' to generate them.");
      hasErrors = true;
    }

    // Check 4: Signing Config
    final keyProps = File('android/key.properties');
    if (!keyProps.existsSync()) {
      _ConsoleUI.printError(
          "Signing configuration is missing (key.properties not found).");
      _ConsoleUI.printInfo("Run 'publish sign android' to configure signing.");
      hasErrors = true;
    }

    if (hasErrors) {
      _ConsoleUI.printEmpty();
      _ConsoleUI.printError(
          "Please fix the above issues before building. Run 'publish doctor' for more details.");
      // Revert if using temp config
      if (previousConfig != null) {
        await ConfigsManager().setActiveConfig(previousConfig);
      }
      return;
    }

    /// 2. Execution
    _ConsoleUI.startLoading('Building Android App Bundle...');

    await Future.delayed(Duration(seconds: 2));

    final result = await Process.run(
      'flutter',
      ['build', 'appbundle'],
      runInShell: true,
    );

    if (result.exitCode == 0) {
      _ConsoleUI.stopLoading(success: true, message: 'Build Successful!');
      _ConsoleUI.printSuccess(
          'App Bundle: build/app/outputs/bundle/release/app-release.aab');
    } else {
      _ConsoleUI.stopLoading(success: false, message: 'Build Failed');
      print(result.stderr);
      print(result.stdout);
    }

    // Revert to previous config if temp switching
    if (previousConfig != null && previousConfig != configName) {
      _ConsoleUI.printInfo('Reverting to previous config: $previousConfig');
      await ConfigsManager().setActiveConfig(previousConfig);
    }
  }
}
