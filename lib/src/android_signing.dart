part of '../publish.dart';

/// Helper to handle Android signing configuration
class _AndroidSigning {
  static String? alias;
  static String keystorePath = "keys/keystore.jks";
  static String? keyPass;
  static String? keystorePass;
  static const String keyPropertiesPath = "./android/key.properties";

  static Future<bool> sign() async {
    _ConsoleUI.printHeader('🔐 Android Signing Setup',
        subtitle: 'Keystore Generator');

    var appId = _AndroidConfigs.appId;
    final newId = await _askToChangeId(appId);
    if (newId != null) {
      _setAppId(newId);
    }

    if (!_generateKeystore()) return false;
    _createKeyProperties();
    _configureBuildConfig();

    return true;
  }

  static Future<String?> _askToChangeId(String oldId) async {
    _ConsoleUI.printStatus('Config', 'Current package name: $oldId');
    if (_ConsoleUI.promptConfirm("Do you want to change the package name?")) {
      return _ConsoleUI.prompt("Enter new package name", required: true);
    }
    return null;
  }

  static bool _generateKeystore() {
    alias = _ConsoleUI.prompt("Enter key alias");
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

    keyPass = _ConsoleUI.prompt("Key password", required: true);
    keystorePass = _ConsoleUI.prompt("Keystore password", required: true);

    if (alias == null ||
        alias!.isEmpty ||
        keyPass == null ||
        keystorePass == null) {
      _ConsoleUI.printError("Key Alias and Passwords are required.");
      return false;
    }

    final keysDir = Directory("keys");
    if (!keysDir.existsSync()) keysDir.createSync();

    final res = Process.runSync("keytool", [
      "-genkey",
      "-noprompt",
      "-alias",
      alias!,
      "-dname",
      dname,
      "-keystore",
      keystorePath,
      "-storepass",
      keystorePass!,
      "-keypass",
      keyPass!,
      "-keyalg",
      "RSA",
      "-keysize",
      "2048",
      "-validity",
      "$days"
    ]);

    if (res.exitCode != 0) {
      _ConsoleUI.printError("Keytool failed: ${res.stderr}");
      return false;
    }

    _ConsoleUI.printSuccess("Generated keystore at $keystorePath");
    return true;
  }

  static void _createKeyProperties() {
    _Commons.writeStringToFile(keyPropertiesPath, """storePassword=$keystorePass
keyPassword=$keyPass
keyAlias=$alias
storeFile=../../$keystorePath
""");
    _ConsoleUI.printSuccess("Created $keyPropertiesPath");
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

  static void _setAppId(String appId) {
    String bfString = _Commons.getFileAsString(_Commons.appBuildPath);
    String updated = _GradleParser.replaceApplicationId(bfString, appId);
    _Commons.writeStringToFile(_Commons.appBuildPath, updated);
  }
}
