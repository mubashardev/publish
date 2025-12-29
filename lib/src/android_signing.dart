part of '../publish.dart';

/// Helper to handle Android signing configuration
class _AndroidSigning {
  static Future<PublishConfig?> sign({String? configName}) async {
    _ConsoleUI.printHeader('🔐 Android Signing Setup',
        subtitle:
            configName != null ? 'Config: $configName' : 'Keystore Generator');

    String? name = configName;
    if (name == null) {
      name = _ConsoleUI.prompt("Enter configuration name (e.g. prod, staging)",
          required: true);
      if (name == null) return null;
    }

    // Determine paths
    final configDir = Directory('publish_configs/$name');
    if (!configDir.existsSync()) configDir.createSync(recursive: true);
    final keystorePath = "${configDir.path}/keystore.jks";

    var appId = _AndroidConfigs.appId;
    final newId = await _askToChangeId(appId);
    if (newId != null) {
      appId = newId;
    }

    // Check App Name
    var appName = _AndroidConfigs.appName;
    if (_ConsoleUI.promptConfirm("Do you want to change the App Name?")) {
      final newName = _ConsoleUI.prompt("Enter new App Name", required: true);
      if (newName != null) appName = newName;
    }

    // Ask for icon
    String? iconSourcePath;
    if (_ConsoleUI.promptConfirm(
        "Do you want to set an icon for this configuration?")) {
      iconSourcePath = _ConsoleUI.prompt(
          "Enter path to icon source image (1024x1024 png recommended)",
          required: true);
      if (iconSourcePath != null && File(iconSourcePath).existsSync()) {
        _ConsoleUI.printInfo('Icons will be generated and backed up...');
        await IconsCommand.generate(File(iconSourcePath));
      } else if (iconSourcePath != null) {
        _ConsoleUI.printWarning(
            'Icon file not found at $iconSourcePath. Skipping icon generation.');
        iconSourcePath = null;
      }
    }

    // Ask for version suffix
    String? versionSuffix;
    if (_ConsoleUI.promptConfirm(
        "Do you want to add a version suffix? (e.g. -staging, -beta)")) {
      versionSuffix = _ConsoleUI.prompt("Enter version suffix");
    }

    // Ask for splash color
    String? splashColor;
    if (_ConsoleUI.promptConfirm("Do you want to set a splash screen color?")) {
      splashColor = _ConsoleUI.prompt("Enter splash color (hex, e.g. #FF5722)");
    }

    final credentials = await _generateKeystore(keystorePath);
    if (credentials == null) return null;

    // Ensure build.gradle is configured
    _configureBuildConfig();

    // Detect existing schema to ensure new config is compatible with build.gradle
    final schema = _detectGradleSchema();

    // Read current version
    String? appVersion;
    final pubspecFile = File('pubspec.yaml');
    if (pubspecFile.existsSync()) {
      for (var line in pubspecFile.readAsLinesSync()) {
        if (line.trim().startsWith('version:')) {
          appVersion = line.split(':')[1].trim();
          break;
        }
      }
    }

    return PublishConfig(
      name: name,
      appName: appName,
      packageId: appId,
      iconSourcePath: iconSourcePath,
      keystorePath: keystorePath,
      keyAlias: credentials['alias']!,
      storePassword: credentials['storePass']!,
      keyPassword: credentials['keyPass']!,
      versionSuffix: versionSuffix,
      splashColor: splashColor,
      appVersion: appVersion,
      propertiesFilePath: schema.path,
      propertyKeys: schema.keys,
      // extraProperties is irrelevant for new config (we only care about signing keys)
      extraProperties: {},
    );
  }

  static Future<PublishConfig?> createConfigFromCurrent(String name) async {
    // 1. Detect Schema
    final schema = _detectGradleSchema();
    final propertiesPath = schema.path;
    final propertyKeys = schema.keys;

    if (schema.keysFound) {
      _ConsoleUI.printStatus(
          'Legacy', 'Detected custom property keys in build.gradle');
    }

    // 2. Read the properties file
    final keyPropsFile = File(propertiesPath);
    if (!keyPropsFile.existsSync()) {
      _ConsoleUI.printError(
          'Could not find properties file at $propertiesPath');
      return null;
    }

    final props = <String, String>{};
    for (var line in keyPropsFile.readAsLinesSync()) {
      if (line.trim().isEmpty || line.trim().startsWith('#')) continue;
      final parts = line.split('=');
      if (parts.length >= 2) {
        props[parts[0].trim()] = parts.sublist(1).join('=').trim();
      }
    }

    // Validate we have the values for our mapped keys
    if (!props.containsKey(propertyKeys['storePassword']) ||
        !props.containsKey(propertyKeys['keyPassword']) ||
        !props.containsKey(propertyKeys['keyAlias']) ||
        !props.containsKey(propertyKeys['storeFile'])) {
      _ConsoleUI.printError('Properties file missing required keys.');
      _ConsoleUI.printInfo('Expected keys: ${propertyKeys.values.join(", ")}');
      return null;
    }

    // Separate known keys from extra properties
    final extraProps = <String, String>{};
    final knownKeys = propertyKeys.values.toSet();

    props.forEach((key, value) {
      if (!knownKeys.contains(key)) {
        extraProps[key] = value;
      }
    });

    if (extraProps.isNotEmpty) {
      _ConsoleUI.printStatus(
          'Legacy', 'Preserving ${extraProps.length} extra properties.');
    }

    // 3. Read App Name & ID
    final appName = _AndroidConfigs.appName;
    final appId = _AndroidConfigs.appId;

    // Read App Version
    String? appVersion;
    final pubspecFile = File('pubspec.yaml');
    if (pubspecFile.existsSync()) {
      for (var line in pubspecFile.readAsLinesSync()) {
        if (line.trim().startsWith('version:')) {
          appVersion = line.split(':')[1].trim();
          break;
        }
      }
    }

    // 4. Prompt for extras (optional)
    String? versionSuffix;
    if (_ConsoleUI.promptConfirm(
        "Does this setup use a version suffix? (e.g. -beta)")) {
      versionSuffix = _ConsoleUI.prompt("Enter suffix");
    }

    return PublishConfig(
      name: name,
      appName: appName,
      packageId: appId,
      keystorePath: props[propertyKeys['storeFile']]!,
      keyAlias: props[propertyKeys['keyAlias']]!,
      storePassword: props[propertyKeys['storePassword']]!,
      keyPassword: props[propertyKeys['keyPassword']]!,
      versionSuffix: versionSuffix,
      propertiesFilePath: propertiesPath,
      propertyKeys: propertyKeys,
      extraProperties: extraProps,
      appVersion: appVersion,
    );
  }

  static _GradleSchema _detectGradleSchema() {
    final buildFile = File(_Commons.appBuildPath);
    // Default values
    String propertiesPath = 'android/key.properties';
    Map<String, String> propertyKeys = {
      'storePassword': 'storePassword',
      'keyPassword': 'keyPassword',
      'keyAlias': 'keyAlias',
      'storeFile': 'storeFile',
    };
    bool keysFound = false;

    if (!buildFile.existsSync()) {
      return _GradleSchema(propertiesPath, propertyKeys, false);
    }

    final buildContent = buildFile.readAsStringSync();
    // --- Smart Detection Logic ---

    // 1. Find the property object name used in signingConfigs.release
    final signingBlockRegex = RegExp(r"signingConfigs\s*\{[\s\S]*?\}");
    final signingMatch = signingBlockRegex.firstMatch(buildContent);

    String? propObjectName;

    if (signingMatch != null) {
      final signingBlock = signingMatch.group(0)!;
      // Find release block inside
      final releaseBlockRegex = RegExp(r"release\s*\{([\s\S]*?)\}");
      final releaseMatch = releaseBlockRegex.firstMatch(signingBlock);

      if (releaseMatch != null) {
        final releaseContent = releaseMatch.group(1)!;

        // Helper to extract var name and key
        void checkField(String fieldName, String defaultKey) {
          // Pattern A: keyAlias =? var['key']
          final regexA = RegExp(
              fieldName + r"\s*=?\s*([\w\.]+)\s*\[\s*['\x22](.*?)['\x22]\s*\]");
          // Pattern B: keyAlias =? var.getProperty('key')
          final regexB = RegExp(fieldName +
              r"\s*=?\s*([\w\.]+)\.getProperty\(\s*['\x22](.*?)['\x22]\s*\)");

          var match = regexA.firstMatch(releaseContent);
          if (match == null) match = regexB.firstMatch(releaseContent);

          if (match != null) {
            propObjectName = match.group(1);
            propertyKeys[defaultKey] = match.group(2)!;
            keysFound = true;
          }
        }

        checkField('keyAlias', 'keyAlias');
        checkField('keyPassword', 'keyPassword');
        checkField('storePassword', 'storePassword');

        // Store File is special: storeFile file(var['key'])
        final storeFileRegex = RegExp(
            r"storeFile\s*=?\s*(?:rootProject\.)?file\s*\(\s*([\w\.]+)\s*\[\s*['\x22](.*?)['\x22]\s*\]\s*\)");
        final storeFileMatch = storeFileRegex.firstMatch(releaseContent);
        if (storeFileMatch != null) {
          propObjectName = storeFileMatch.group(1);
          propertyKeys['storeFile'] = storeFileMatch.group(2)!;
          keysFound = true;
        }
      }
    }

    // 2. Trace the file definition for propObjectName
    if (propObjectName != null) {
      _ConsoleUI.printStatus(
          'Legacy', 'Tracing configuration for variable: $propObjectName');

      final fileDefRegex = RegExp(
          r"(?:def|val)\s+(\w+)\s*=\s*(?:rootProject\.)?file\s*\(['\x22](.*?)['\x22]\)");
      final matches = fileDefRegex.allMatches(buildContent);

      String? bestPathCandidate;

      for (var m in matches) {
        final varName = m.group(1)!;
        final path = m.group(2)!;

        if (varName.toLowerCase().contains(propObjectName!.toLowerCase())) {
          bestPathCandidate = path;
          break;
        }
      }

      if (bestPathCandidate != null) {
        propertiesPath = 'android/$bestPathCandidate';
        _ConsoleUI.printStatus(
            'Legacy', 'Resolved properties file: $propertiesPath');
      } else {
        // Fallback
        for (var m in matches) {
          final path = m.group(2)!;
          if (path.contains("key") && !path.contains("local.properties")) {
            propertiesPath = 'android/$path';
            break;
          }
        }
      }
    } else {
      // Fallback to old heuristic
      final simpleFileRegex =
          RegExp(r"(?:rootProject\.)?file\s*\(['\x22](.*?)['\x22]\)");
      final simpleMatch = simpleFileRegex.firstMatch(buildContent);
      if (simpleMatch != null) {
        final path = simpleMatch.group(1);
        if (path != null &&
            (path.contains("key") || path.contains("prop")) &&
            !path.contains("local")) {
          propertiesPath = 'android/$path';
        }
      }
    }

    return _GradleSchema(propertiesPath, propertyKeys, keysFound);
  }

  static Future<String?> _askToChangeId(String oldId) async {
    _ConsoleUI.printStatus('Config', 'Current package name: $oldId');
    if (_ConsoleUI.promptConfirm('Do you want to change the package ID?')) {
      final newId =
          _ConsoleUI.prompt('Enter new package ID (e.g. com.example.app)');
      if (newId != null && newId.isNotEmpty) {
        return newId;
      }
    }
    return null;
  }

  static Future<Map<String, String>?> _generateKeystore(
      String keystorePath) async {
    final alias = _ConsoleUI.prompt("Enter key alias");
    final cn =
        _ConsoleUI.prompt("Publisher's Common Name (e.g. Mubashar Dev)") ??
            'Mubashar Dev';
    final ou = _ConsoleUI.prompt("Organizational Unit (e.g. MH)") ?? 'MH';
    final org = _ConsoleUI.prompt("Organization (e.g. MicroProgramers)") ??
        'MicroProgramers';
    final locality = _ConsoleUI.prompt("Locality (e.g. Layyah)") ?? 'Layyah';
    final state = _ConsoleUI.prompt("State (e.g. Punjab)") ?? 'Punjab';
    final country = _ConsoleUI.prompt("Country ISO (e.g. PK)") ?? 'PK';

    final validityInput = _ConsoleUI.prompt("Validity Years (e.g. 100)");
    final validity = int.tryParse(validityInput ?? "");
    final days = validity != null
        ? (validity * 365)
        : (DateTime(9999).difference(DateTime.now()).inDays);

    final dname = "CN=$cn, OU=$ou, O=$org, L=$locality, S=$state, C=$country";

    final keyPass = _ConsoleUI.prompt("Key password", required: true);
    final keystorePass = _ConsoleUI.prompt("Keystore password", required: true);

    if (alias == null ||
        alias.isEmpty ||
        keyPass == null ||
        keystorePass == null) {
      _ConsoleUI.printError("Key Alias and Passwords are required.");
      return null;
    }

    // Check if keystore exists
    if (File(keystorePath).existsSync()) {
      if (!_ConsoleUI.promptConfirm(
          "Keystore already exists at $keystorePath. Overwrite?")) {
        return null;
      }
      File(keystorePath).deleteSync();
    }

    final res = Process.runSync("keytool", [
      "-genkey",
      "-noprompt",
      "-alias",
      alias,
      "-dname",
      dname,
      "-keystore",
      keystorePath,
      "-storepass",
      keystorePass,
      "-keypass",
      keyPass,
      "-keyalg",
      "RSA",
      "-keysize",
      "2048",
      "-validity",
      "$days"
    ]);

    if (res.exitCode != 0) {
      _ConsoleUI.printError("Keytool failed: ${res.stderr}");
      return null;
    }

    _ConsoleUI.printSuccess("Generated keystore at $keystorePath");
    return {
      'alias': alias,
      'keyPass': keyPass,
      'storePass': keystorePass,
    };
  }

  static void _configureBuildConfig() {
    String bfString = _Commons.getFileAsString(_Commons.appBuildPath);
    String buildFileType =
        _GradleParser.detectBuildFileType(_Commons.appBuildPath);

    if (!bfString.contains("key.properties")) {
      String updated;
      if (buildFileType == 'kts') {
        updated = _configureBuildConfigKts(bfString);
      } else {
        updated = _configureBuildConfigGroovy(bfString);
      }
      _Commons.writeStringToFile(_Commons.appBuildPath, updated);
      _ConsoleUI.printSuccess("Configured build.gradle signing configs");
    } else {
      _ConsoleUI.printWarning(
          "Signing configs likely already present in build.gradle");
    }
  }

  static String _configureBuildConfigGroovy(String content) {
    List<String> buildfile = content.split('\n');
    buildfile = buildfile.map((line) {
      if (line.contains(RegExp("android.*{"))) {
        return """
  def keystoreProperties = new Properties()
  def keystorePropertiesFile = rootProject.file('key.properties')
  if (keystorePropertiesFile.exists()) {
      keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
  }

  android {
              """;
      } else if (line.contains(RegExp("buildTypes.*{"))) {
        return """
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
              """;
      } else if (line.contains("signingConfig signingConfigs.debug")) {
        return "            signingConfig signingConfigs.release";
      } else {
        return line;
      }
    }).toList();
    return buildfile.join("\n");
  }

  static String _configureBuildConfigKts(String content) {
    // Check if import statement exists, add it if missing
    const String propertiesImport = 'import java.util.Properties';
    if (!content.contains(propertiesImport)) {
      // Add import at the very top of the file
      content = '$propertiesImport\n\n$content';
    }

    List<String> buildfile = content.split('\n');
    buildfile = buildfile.map((line) {
      if (line.contains(RegExp("android\\s*\\{"))) {
        return """
  val keystoreProperties = Properties()
  val keystorePropertiesFile = rootProject.file("key.properties")
  if (keystorePropertiesFile.exists()) {
      keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
  }

  android {
              """;
      } else if (line.contains(RegExp("buildTypes\\s*\\{"))) {
        return """
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = file(keystoreProperties["storeFile"] as String?)
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    buildTypes {
              """;
      } else if (line.contains("signingConfig = signingConfigs.debug") ||
          line.contains("signingConfig signingConfigs.debug")) {
        return '            signingConfig = signingConfigs.getByName("release")';
      } else {
        return line;
      }
    }).toList();
    return buildfile.join("\n");
  }
}

class _GradleSchema {
  final String path;
  final Map<String, String> keys;
  final bool keysFound;

  _GradleSchema(this.path, this.keys, this.keysFound);
}
