part of '../../publish.dart';

class ConfigCommand extends Command {
  @override
  String get name => 'config';

  @override
  String get description => 'Manage multiple application configurations.';

  ConfigCommand() {
    addSubcommand(_ConfigListCommand());
    addSubcommand(_ConfigSwitchCommand());
  }
}

class _ConfigListCommand extends Command {
  @override
  String get name => 'list';

  @override
  String get description => 'List all available configurations.';

  @override
  void run() {
    ConfigsManager().load();
    final configs = ConfigsManager().configs;
    final active = ConfigsManager().activeConfig;

    if (configs.isEmpty) {
      _ConsoleUI.printInfo('No configurations found.');
      _ConsoleUI.printInfo('Run "publish sign android" to create one.');
      return;
    }

    _ConsoleUI.printHeader('📋 Configurations (${configs.length} total)',
        subtitle: active != null
            ? 'Active: ${active.name}'
            : 'No active configuration');

    print('');

    for (var config in configs) {
      final isActive = active?.name == config.name;
      final prefix = isActive ? '${green}➜${reset} ' : '  ';
      final status = isActive ? ' ${green}(Active)${reset}' : '';

      // Check icon status
      final hasAndroidIcons =
          Directory(config.androidIconsBackupDir).existsSync();
      final hasIosIcons = Directory(config.iosIconsBackupDir).existsSync();
      final iconStatus = hasAndroidIcons || hasIosIcons
          ? '${green}✓${reset}'
          : '${yellow}○${reset}';

      print('$prefix${bold}${config.name}${reset}$status');
      print('    ${cyan}App Name:${reset}   ${config.appName}');
      print('    ${cyan}Package ID:${reset} ${config.packageId}');
      print('    ${cyan}Keystore:${reset}   ${config.keystorePath}');
      print('    ${cyan}Icons:${reset}      $iconStatus');
      print('');
    }

    _ConsoleUI.printInfo(
        'Use "publish config switch <name>" to switch configs.');
  }
}

class _ConfigSwitchCommand extends Command {
  @override
  String get name => 'switch';

  @override
  String get description => 'Switch to a different configuration.';

  @override
  void run() async {
    ConfigsManager().load();
    if (argResults?.rest.isEmpty ?? true) {
      _ConsoleUI.printError('Please provide a configuration name.');
      _ConsoleUI.printInfo('Usage: publish config switch <name>');
      return;
    }

    final name = argResults!.rest.first;
    final config = ConfigsManager().getConfig(name);

    if (config == null) {
      _ConsoleUI.printError('Configuration "$name" not found.');
      return;
    }

    await ConfigsManager().setActiveConfig(name);
  }
}
