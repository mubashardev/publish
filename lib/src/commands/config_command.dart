part of '../../publish.dart';

class ConfigCommand extends Command {
  @override
  String get name => 'config';

  @override
  String get description => 'Manage multiple application configurations.';

  ConfigCommand() {
    addSubcommand(_ConfigListCommand());
    addSubcommand(_ConfigSwitchCommand());
    addSubcommand(_ConfigDeleteCommand());
    addSubcommand(_ConfigRenameCommand());
    addSubcommand(_ConfigEditCommand());
    addSubcommand(_ConfigExportCommand());
    addSubcommand(_ConfigImportCommand());
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

      final hasIcons = Directory(config.androidIconsBackupDir).existsSync() ||
          Directory(config.iosIconsBackupDir).existsSync();
      final iconStatus = hasIcons ? '${green}✓${reset}' : '${yellow}○${reset}';
      final suffix =
          config.versionSuffix != null ? ' (${config.versionSuffix})' : '';

      print('$prefix${bold}${config.name}${reset}$status$suffix');
      print('    ${cyan}App Name:${reset}   ${config.appName}');
      print('    ${cyan}Package ID:${reset} ${config.packageId}');
      print('    ${cyan}Keystore:${reset}   ${config.keystorePath}');
      print('    ${cyan}Icons:${reset}      $iconStatus');
      print('');
    }

    _ConsoleUI.printInfo(
        'Commands: switch, delete, rename, edit, export, import');
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

class _ConfigDeleteCommand extends Command {
  @override
  String get name => 'delete';

  @override
  String get description => 'Delete a configuration and optionally its files.';

  @override
  void run() {
    ConfigsManager().load();
    if (argResults?.rest.isEmpty ?? true) {
      _ConsoleUI.printError('Please provide a configuration name.');
      _ConsoleUI.printInfo('Usage: publish config delete <name>');
      return;
    }

    final name = argResults!.rest.first;
    final config = ConfigsManager().getConfig(name);

    if (config == null) {
      _ConsoleUI.printError('Configuration "$name" not found.');
      return;
    }

    if (!_ConsoleUI.promptConfirm('Delete configuration "$name"?')) {
      return;
    }

    final deleteFiles = _ConsoleUI.promptConfirm(
        'Also delete config files (keystore, icons, etc.)?');

    ConfigsManager().removeConfig(name);
    _ConsoleUI.printSuccess('Configuration "$name" removed from JSON.');

    if (deleteFiles) {
      final dir = Directory(config.configDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
        _ConsoleUI.printSuccess('Deleted directory: ${config.configDir}');
      }
    }
  }
}

class _ConfigRenameCommand extends Command {
  @override
  String get name => 'rename';

  @override
  String get description => 'Rename a configuration.';

  @override
  void run() {
    ConfigsManager().load();
    final rest = argResults?.rest ?? [];
    if (rest.length < 2) {
      _ConsoleUI.printError('Please provide old and new names.');
      _ConsoleUI.printInfo('Usage: publish config rename <old> <new>');
      return;
    }

    final oldName = rest[0];
    final newName = rest[1];
    final config = ConfigsManager().getConfig(oldName);

    if (config == null) {
      _ConsoleUI.printError('Configuration "$oldName" not found.');
      return;
    }

    if (ConfigsManager().getConfig(newName) != null) {
      _ConsoleUI.printError('Configuration "$newName" already exists.');
      return;
    }

    // Update config with new name and keystore path
    final newKeystorePath = 'publish_configs/$newName/keystore.jks';
    final updatedConfig =
        config.copyWith(name: newName, keystorePath: newKeystorePath);

    // Rename directory
    final oldDir = Directory(config.configDir);
    final newDir = Directory('publish_configs/$newName');
    if (oldDir.existsSync()) {
      oldDir.renameSync(newDir.path);
    }

    // Update configs
    ConfigsManager().removeConfig(oldName);
    ConfigsManager().addConfig(updatedConfig);

    if (ConfigsManager().activeConfigName == oldName) {
      ConfigsManager().setActiveConfig(newName);
    }

    _ConsoleUI.printSuccess('Renamed "$oldName" to "$newName".');
  }
}

class _ConfigEditCommand extends Command {
  @override
  String get name => 'edit';

  @override
  String get description =>
      'Edit configuration settings (appName, packageId, versionSuffix).';

  @override
  void run() async {
    ConfigsManager().load();
    if (argResults?.rest.isEmpty ?? true) {
      _ConsoleUI.printError('Please provide a configuration name.');
      _ConsoleUI.printInfo('Usage: publish config edit <name>');
      return;
    }

    final name = argResults!.rest.first;
    final config = ConfigsManager().getConfig(name);

    if (config == null) {
      _ConsoleUI.printError('Configuration "$name" not found.');
      return;
    }

    _ConsoleUI.printHeader('✏️ Edit Configuration: $name',
        subtitle: 'Leave blank to keep current value');

    String? newAppName;
    String? newPackageId;
    String? newVersionSuffix;
    String? newSplashColor;

    if (_ConsoleUI.promptConfirm(
        'Change App Name? (current: ${config.appName})')) {
      newAppName = _ConsoleUI.prompt('New App Name');
    }

    if (_ConsoleUI.promptConfirm(
        'Change Package ID? (current: ${config.packageId})')) {
      newPackageId = _ConsoleUI.prompt('New Package ID');
    }

    if (_ConsoleUI.promptConfirm(
        'Change Version Suffix? (current: ${config.versionSuffix ?? "none"})')) {
      newVersionSuffix =
          _ConsoleUI.prompt('New Version Suffix (e.g. -staging)');
    }

    if (_ConsoleUI.promptConfirm(
        'Change Splash Color? (current: ${config.splashColor ?? "none"})')) {
      newSplashColor =
          _ConsoleUI.prompt('New Splash Color (hex, e.g. #FF5722)');
    }

    final updatedConfig = config.copyWith(
      appName: newAppName,
      packageId: newPackageId,
      versionSuffix: newVersionSuffix,
      splashColor: newSplashColor,
    );

    ConfigsManager().addConfig(updatedConfig);
    _ConsoleUI.printSuccess('Configuration "$name" updated.');

    if (ConfigsManager().activeConfigName == name) {
      if (_ConsoleUI.promptConfirm('Apply changes to project now?')) {
        await ConfigsManager().setActiveConfig(name);
      }
    }
  }
}

class _ConfigExportCommand extends Command {
  @override
  String get name => 'export';

  @override
  String get description => 'Export a configuration as a zip file.';

  @override
  void run() async {
    ConfigsManager().load();
    if (argResults?.rest.isEmpty ?? true) {
      _ConsoleUI.printError('Please provide a configuration name.');
      _ConsoleUI.printInfo('Usage: publish config export <name>');
      return;
    }

    final name = argResults!.rest.first;
    final config = ConfigsManager().getConfig(name);

    if (config == null) {
      _ConsoleUI.printError('Configuration "$name" not found.');
      return;
    }

    final exportDir = Directory('publish_exports');
    if (!exportDir.existsSync()) exportDir.createSync();

    final zipName = '${name}_config_export.zip';
    final zipPath = '${exportDir.path}/$zipName';

    _ConsoleUI.printStatus('Export', 'Creating zip at $zipPath...');

    // Create a temp directory with config.json and copy files
    final tempDir = Directory('${exportDir.path}/.temp_$name');
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    tempDir.createSync();

    // Write config JSON
    final configJson =
        const JsonEncoder.withIndent('  ').convert(config.toJson());
    File('${tempDir.path}/config.json').writeAsStringSync(configJson);

    // Copy config directory contents
    final configDir = Directory(config.configDir);
    if (configDir.existsSync()) {
      _copyDirectoryContents(configDir.path, '${tempDir.path}/$name');
    }

    // Create zip using shell command
    // Create zip using shell command
    try {
      final result = Process.runSync(
          'zip', ['-r', File(zipPath).absolute.path, '.'],
          workingDirectory: tempDir.path);

      // Cleanup temp
      tempDir.deleteSync(recursive: true);

      if (result.exitCode == 0) {
        _ConsoleUI.printSuccess('Exported to: $zipPath');
      } else {
        _ConsoleUI.printError('Failed to create zip:');
        if (result.stdout.toString().isNotEmpty) {
          print('Stdout: ${result.stdout}');
        }
        if (result.stderr.toString().isNotEmpty) {
          print('Stderr: ${result.stderr}');
        }
      }
    } catch (e) {
      // Cleanup temp even on crash
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
      _ConsoleUI.printError('Failed to execute zip command: $e');
    }
  }

  void _copyDirectoryContents(String source, String destination) {
    final sourceDir = Directory(source);
    final destDir = Directory(destination);
    if (!destDir.existsSync()) destDir.createSync(recursive: true);

    for (var entity in sourceDir.listSync(recursive: false)) {
      final name = entity.path.split(Platform.pathSeparator).last;
      if (entity is Directory) {
        _copyDirectoryContents(entity.path, '$destination/$name');
      } else if (entity is File) {
        entity.copySync('$destination/$name');
      }
    }
  }
}

class _ConfigImportCommand extends Command {
  @override
  String get name => 'import';

  @override
  String get description => 'Import a configuration from a zip file.';

  @override
  void run() async {
    ConfigsManager().load();
    if (argResults?.rest.isEmpty ?? true) {
      _ConsoleUI.printError('Please provide a path to the zip file.');
      _ConsoleUI.printInfo('Usage: publish config import <path.zip>');
      return;
    }

    final zipPath = argResults!.rest.first;
    final zipFile = File(zipPath);

    if (!zipFile.existsSync()) {
      _ConsoleUI.printError('File not found: $zipPath');
      return;
    }

    _ConsoleUI.printStatus('Import', 'Extracting $zipPath...');

    // Create temp directory
    final tempDir = Directory('.publish_import_temp');
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    tempDir.createSync();

    // Extract zip
    final result =
        Process.runSync('unzip', ['-o', zipPath, '-d', tempDir.path]);

    if (result.exitCode != 0) {
      tempDir.deleteSync(recursive: true);
      _ConsoleUI.printError('Failed to extract zip: ${result.stderr}');
      return;
    }

    // Read config.json
    final configFile = File('${tempDir.path}/config.json');
    if (!configFile.existsSync()) {
      tempDir.deleteSync(recursive: true);
      _ConsoleUI.printError('Invalid export: config.json not found.');
      return;
    }

    try {
      final jsonStr = configFile.readAsStringSync();
      final config = PublishConfig.fromJson(json.decode(jsonStr));

      // Check if config already exists
      if (ConfigsManager().getConfig(config.name) != null) {
        if (!_ConsoleUI.promptConfirm(
            'Configuration "${config.name}" already exists. Overwrite?')) {
          tempDir.deleteSync(recursive: true);
          return;
        }
      }

      // Copy files to publish_configs
      // Check for new structure (folder named as config.name) or old structure (files/)
      var filesDir = Directory('${tempDir.path}/${config.name}');
      if (!filesDir.existsSync()) {
        filesDir = Directory('${tempDir.path}/files');
      }

      if (filesDir.existsSync()) {
        final destDir = Directory(config.configDir);
        if (destDir.existsSync()) destDir.deleteSync(recursive: true);
        filesDir.renameSync(destDir.path);
      }

      // Add config
      ConfigsManager().addConfig(config);
      _ConsoleUI.printSuccess('Imported configuration: ${config.name}');

      // Cleanup
      tempDir.deleteSync(recursive: true);
    } catch (e) {
      tempDir.deleteSync(recursive: true);
      _ConsoleUI.printError('Failed to import: $e');
    }
  }
}
