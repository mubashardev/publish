part of '../../publish.dart';

class PublishConfig {
  final String name;
  final String appName;
  final String packageId;
  final String? iconSourcePath;
  final String keystorePath;
  final String keyAlias;
  final String storePassword;
  final String keyPassword;
  final String? versionSuffix;
  final String? splashColor;
  final String? propertiesFilePath;
  final Map<String, String>? propertyKeys;
  final Map<String, String>? extraProperties;
  final String? appVersion;

  PublishConfig({
    required this.name,
    required this.appName,
    required this.packageId,
    this.iconSourcePath,
    required this.keystorePath,
    required this.keyAlias,
    required this.storePassword,
    required this.keyPassword,
    this.versionSuffix,
    this.splashColor,
    this.propertiesFilePath,
    this.propertyKeys,
    this.extraProperties,
    this.appVersion,
  });

  /// Directory where this config stores its Android icons backup
  String get androidIconsBackupDir => 'publish_configs/$name/android_icons';

  /// Directory where this config stores its iOS icons backup
  String get iosIconsBackupDir => 'publish_configs/$name/ios_icons';

  /// Directory where this config stores its splash screen backup
  String get splashBackupDir => 'publish_configs/$name/splash';

  /// Directory where this config's files are stored
  String get configDir => 'publish_configs/$name';

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'app_name': appName,
      'package_id': packageId,
      'icon_source_path': iconSourcePath,
      'keystore_path': keystorePath,
      'key_alias': keyAlias,
      'store_password': storePassword,
      'key_password': keyPassword,
      'version_suffix': versionSuffix,
      'splash_color': splashColor,
      'properties_file_path': propertiesFilePath,
      'property_keys': propertyKeys,
      'extra_properties': extraProperties,
      'app_version': appVersion,
    };
  }

  factory PublishConfig.fromJson(Map<String, dynamic> json) {
    return PublishConfig(
      name: json['name'],
      appName: json['app_name'],
      packageId: json['package_id'],
      iconSourcePath: json['icon_source_path'],
      keystorePath: json['keystore_path'],
      keyAlias: json['key_alias'],
      storePassword: json['store_password'],
      keyPassword: json['key_password'],
      versionSuffix: json['version_suffix'],
      splashColor: json['splash_color'],
      propertiesFilePath: json['properties_file_path'],
      propertyKeys: (json['property_keys'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v.toString())),
      extraProperties: (json['extra_properties'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v.toString())),
      appVersion: json['app_version'],
    );
  }

  /// Create a copy with updated fields
  PublishConfig copyWith({
    String? name,
    String? appName,
    String? packageId,
    String? iconSourcePath,
    String? keystorePath,
    String? keyAlias,
    String? storePassword,
    String? keyPassword,
    String? versionSuffix,
    String? splashColor,
    String? propertiesFilePath,
    Map<String, String>? propertyKeys,
    Map<String, String>? extraProperties,
    String? appVersion,
  }) {
    return PublishConfig(
      name: name ?? this.name,
      appName: appName ?? this.appName,
      packageId: packageId ?? this.packageId,
      iconSourcePath: iconSourcePath ?? this.iconSourcePath,
      keystorePath: keystorePath ?? this.keystorePath,
      keyAlias: keyAlias ?? this.keyAlias,
      storePassword: storePassword ?? this.storePassword,
      keyPassword: keyPassword ?? this.keyPassword,
      versionSuffix: versionSuffix ?? this.versionSuffix,
      splashColor: splashColor ?? this.splashColor,
      propertiesFilePath: propertiesFilePath ?? this.propertiesFilePath,
      propertyKeys: propertyKeys ?? this.propertyKeys,
      extraProperties: extraProperties ?? this.extraProperties,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}

class ConfigsManager {
  static const String _configFileName = 'publish_config.json';
  static const String _androidResPath = 'android/app/src/main/res';
  static const String _iosIconsPath =
      'ios/Runner/Assets.xcassets/AppIcon.appiconset';
  static const String _androidSplashPath =
      'android/app/src/main/res/drawable/launch_background.xml';
  static const String _iosSplashPath =
      'ios/Runner/Base.lproj/LaunchScreen.storyboard';

  static final ConfigsManager _instance = ConfigsManager._internal();

  factory ConfigsManager() => _instance;

  ConfigsManager._internal();

  List<PublishConfig> _configs = [];
  String? _activeConfigName;

  List<PublishConfig> get configs => List.unmodifiable(_configs);
  String? get activeConfigName => _activeConfigName;

  PublishConfig? get activeConfig {
    if (_activeConfigName == null) return null;
    try {
      return _configs.firstWhere((c) => c.name == _activeConfigName);
    } catch (_) {
      return null;
    }
  }

  void load() {
    final file = File(_configFileName);
    if (!file.existsSync()) {
      return;
    }

    try {
      final jsonString = file.readAsStringSync();
      final Map<String, dynamic> data = json.decode(jsonString);

      if (data.containsKey('active_config')) {
        _activeConfigName = data['active_config'];
      }

      if (data.containsKey('configs') && data['configs'] is List) {
        _configs = (data['configs'] as List)
            .map((e) => PublishConfig.fromJson(e))
            .toList();
      }
    } catch (e) {
      _ConsoleUI.printError('Failed to load configs: $e');
    }
  }

  void save() {
    final file = File(_configFileName);
    final data = {
      'active_config': _activeConfigName,
      'configs': _configs.map((e) => e.toJson()).toList(),
    };
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  }

  void addConfig(PublishConfig config) {
    // Remove existing config with same name if exists
    _configs.removeWhere((c) => c.name == config.name);
    _configs.add(config);
    save();
  }

  void removeConfig(String name) {
    _configs.removeWhere((c) => c.name == name);
    if (_activeConfigName == name) {
      _activeConfigName = null;
    }
    save();
  }

  Future<void> setActiveConfig(String name, {bool restoreAssets = true}) async {
    final config = _configs.firstWhere((c) => c.name == name,
        orElse: () => throw Exception('Config $name not found'));

    // Backup current icons and splash before switching (if there's an active config)
    if (_activeConfigName != null && _activeConfigName != name) {
      final currentConfig = activeConfig;
      if (currentConfig != null) {
        _backupIcons(currentConfig);
        _backupSplash(currentConfig);
      }
    }

    _activeConfigName = name;
    save();

    // Switch logic
    _ConsoleUI.printStatus('Config', 'Switching to $name...');

    // 1. Update Key Properties
    final keyPropsPath = config.propertiesFilePath ?? 'android/key.properties';

    // Use custom keys if available, otherwise default to standard keys
    final keys = config.propertyKeys ??
        {
          'storePassword': 'storePassword',
          'keyPassword': 'keyPassword',
          'keyAlias': 'keyAlias',
          'storeFile': 'storeFile',
        };

    final buffer = StringBuffer();
    // Write standard properties
    buffer.writeln('${keys['storePassword']}=${config.storePassword}');
    buffer.writeln('${keys['keyPassword']}=${config.keyPassword}');
    buffer.writeln('${keys['keyAlias']}=${config.keyAlias}');
    buffer.writeln('${keys['storeFile']}=${config.keystorePath}');

    // Write extra properties
    config.extraProperties?.forEach((key, value) {
      buffer.writeln('$key=$value');
    });

    _Commons.writeStringToFile(keyPropsPath, buffer.toString());

    // 2. Update IDs
    ConfigsHelper.updateId(config.packageId, 'android');
    ConfigsHelper.updateId(config.packageId, 'ios');

    // 3. Update Name
    ConfigsHelper.updateName(config.appName, 'android');
    ConfigsHelper.updateName(config.appName, 'ios');

    // 4. Update Main.dart Title
    _updateMainDartTitle(config.appName);

    // 5. Update Pubspec Version
    if (config.appVersion != null) {
      _updatePubspecVersion(config.appVersion!);
    }

    // 6. Restore icons and splash for this config (if requested)
    if (restoreAssets) {
      _restoreIcons(config);
      _restoreSplash(config);
    }

    _ConsoleUI.printSuccess('Switched to configuration: $name');
    _ConsoleUI.printInfo(
        'Note: You can switch to any config anytime using: publish config switch <name>');
  }

  void _updatePubspecVersion(String newVersion) {
    final pubspecFile = File('pubspec.yaml');
    if (pubspecFile.existsSync()) {
      final lines = pubspecFile.readAsLinesSync();
      final newLines = lines.map((line) {
        if (line.trim().startsWith('version:')) {
          return 'version: $newVersion';
        }
        return line;
      }).toList();
      pubspecFile.writeAsStringSync(newLines.join('\n') + '\n');
      _ConsoleUI.printStatus(
          'Config', 'Updated pubspec.yaml version to $newVersion');
    }
  }

  /// Backup current project icons to the config's backup directory
  void _backupIcons(PublishConfig config) {
    _ConsoleUI.printStatus('Icons', 'Backing up Android resources (res)...');

    // Backup Android icons (entire res folder)
    _backupDirectory(_androidResPath, config.androidIconsBackupDir);

    _ConsoleUI.printStatus('Icons', 'Backing up iOS icons...');
    // Backup iOS icons
    _backupDirectory(_iosIconsPath, config.iosIconsBackupDir);
  }

  /// Backup splash screen files
  void _backupSplash(PublishConfig config) {
    final splashDir = Directory(config.splashBackupDir);
    if (!splashDir.existsSync()) splashDir.createSync(recursive: true);

    // Backup Android splash
    final androidSplash = File(_androidSplashPath);
    if (androidSplash.existsSync()) {
      androidSplash.copySync('${config.splashBackupDir}/launch_background.xml');
    }

    // Backup iOS splash
    final iosSplash = File(_iosSplashPath);
    if (iosSplash.existsSync()) {
      iosSplash.copySync('${config.splashBackupDir}/LaunchScreen.storyboard');
    }
  }

  /// Restore icons from the config's backup directory to the project
  void _restoreIcons(PublishConfig config) {
    final androidBackup = Directory(config.androidIconsBackupDir);
    final iosBackup = Directory(config.iosIconsBackupDir);

    if (androidBackup.existsSync() || iosBackup.existsSync()) {
      _ConsoleUI.printStatus('Icons', 'Restoring icons for ${config.name}...');
    }

    // Restore Android icons
    if (androidBackup.existsSync()) {
      _restoreDirectory(config.androidIconsBackupDir, _androidResPath);
    }

    // Restore iOS icons
    if (iosBackup.existsSync()) {
      _restoreDirectory(config.iosIconsBackupDir, _iosIconsPath);
    }
  }

  /// Restore splash screen files
  void _restoreSplash(PublishConfig config) {
    final androidBackup =
        File('${config.splashBackupDir}/launch_background.xml');
    final iosBackup = File('${config.splashBackupDir}/LaunchScreen.storyboard');

    if (androidBackup.existsSync()) {
      final dest = File(_androidSplashPath);
      if (!dest.parent.existsSync()) dest.parent.createSync(recursive: true);
      androidBackup.copySync(_androidSplashPath);
      _ConsoleUI.printStatus('Splash', 'Restored Android splash screen.');
    }

    if (iosBackup.existsSync()) {
      iosBackup.copySync(_iosSplashPath);
      _ConsoleUI.printStatus('Splash', 'Restored iOS splash screen.');
    }
  }

  /// Backup a directory's contents to a destination
  void _backupDirectory(String source, String destination) {
    final sourceDir = Directory(source);
    if (!sourceDir.existsSync()) return;

    final destDir = Directory(destination);
    if (!destDir.existsSync()) destDir.createSync(recursive: true);

    for (var entity in sourceDir.listSync()) {
      final name = entity.path.split(Platform.pathSeparator).last;

      final newPath = '${destDir.path}${Platform.pathSeparator}$name';

      if (entity is Directory) {
        _copyRecursive(entity.path, newPath);
      } else if (entity is File) {
        entity.copySync(newPath);
      }
    }
  }

  /// Restore a directory's contents to a destination
  void _restoreDirectory(String source, String destination) {
    final sourceDir = Directory(source);
    if (!sourceDir.existsSync()) return;

    for (var entity in sourceDir.listSync()) {
      final name = entity.path.split(Platform.pathSeparator).last;
      final destPath = '$destination${Platform.pathSeparator}$name';

      if (entity is Directory) {
        _copyRecursive(entity.path, destPath);
      } else if (entity is File) {
        final destFile = File(destPath);
        if (!destFile.parent.existsSync()) {
          destFile.parent.createSync(recursive: true);
        }
        entity.copySync(destFile.path);
      }
    }
  }

  /// Copy a directory recursively
  void _copyRecursive(String source, String destination) {
    final sourceDir = Directory(source);
    final destDir = Directory(destination);

    if (!destDir.existsSync()) destDir.createSync(recursive: true);

    for (var entity in sourceDir.listSync()) {
      final name = entity.path.split(Platform.pathSeparator).last;
      final newPath = '${destDir.path}${Platform.pathSeparator}$name';

      if (entity is Directory) {
        _copyRecursive(entity.path, newPath);
      } else if (entity is File) {
        entity.copySync(newPath);
      }
    }
  }

  void _updateMainDartTitle(String newTitle) {
    final mainFile = File('lib/main.dart');
    if (mainFile.existsSync()) {
      var content = mainFile.readAsStringSync();
      final regex = RegExp(r"title:\s*(['\x22])(.*?)\1");

      if (regex.hasMatch(content)) {
        content = content.replaceAllMapped(regex, (match) {
          final quote = match.group(1);
          return 'title: $quote$newTitle$quote';
        });

        mainFile.writeAsStringSync(content);
        _ConsoleUI.printStatus(
            'Config', 'Updated main.dart title to "$newTitle"');
      }
    }
  }

  bool get hasConfigs => _configs.isNotEmpty;

  PublishConfig? getConfig(String name) {
    try {
      return _configs.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Backup current icons and splash for a newly created config
  void backupIconsForNewConfig(PublishConfig config) {
    _backupIcons(config);
    _backupSplash(config);
    _ConsoleUI.printSuccess('Icons and splash backed up for ${config.name}');
  }

  /// Backup the keystore file to the config directory and return the new path
  String backupKeystore(PublishConfig config) {
    // Resolve source path
    // We assume the path in config is relative to android/app (Gradle default)
    // or absolute.
    File sourceFile = File(config.keystorePath);
    if (!sourceFile.isAbsolute) {
      // Try resolving relative to android/app
      final appRel = File('android/app/${config.keystorePath}');
      if (appRel.existsSync()) {
        sourceFile = appRel;
      } else {
        // Try resolving relative to properties file if known
        if (config.propertiesFilePath != null) {
          final propFile = File(config.propertiesFilePath!);
          final propRel =
              File('${propFile.parent.path}/${config.keystorePath}');
          if (propRel.existsSync()) {
            sourceFile = propRel;
          }
        }

        // Fallback: Check if it exists relative to root (rare but possible)
        if (!sourceFile.existsSync()) {
          // If we can't find it, we can't backup it.
          _ConsoleUI.printWarning(
              'Could not locate keystore at ${config.keystorePath} to backup.');
          return config.keystorePath;
        }
      }
    }

    if (!sourceFile.existsSync()) {
      _ConsoleUI.printWarning('Keystore file not found at ${sourceFile.path}');
      return config.keystorePath;
    }

    final fileName = sourceFile.path.split(Platform.pathSeparator).last;
    final destPath = '${config.configDir}${Platform.pathSeparator}$fileName';
    final destFile = File(destPath);

    // Safety check: Don't copy if source and dest are the same file
    if (sourceFile.absolute.path == destFile.absolute.path) {
      _ConsoleUI.printInfo('Keystore is already in the config directory.');
      return destFile.absolute.path;
    }

    if (!destFile.parent.existsSync()) {
      destFile.parent.createSync(recursive: true);
    }

    sourceFile.copySync(destPath);
    _ConsoleUI.printSuccess('Keystore backed up to $destPath');

    // Return the new path (Absolute is safest for Gradle injection)
    return destFile.absolute.path;
  }
}
