part of 'publish.dart';

String? alias;
String keystorePath = "keys/keystore.jks";
String? keyPass;
String? keystorePass;
const String keyPropertiesPath = "./android/key.properties";

/// Main function that uses other helper functions to setup android signing
void _androidSign() async {
  stdout.writeln('--------------------------------------------');
  var appId = _getApplicationId();
  await _askToChangeId(appId);
  _generateKeystore();
  _createKeyProperties();
  _configureBuildConfig();
}

Future<void> _askToChangeId(String oldId) async {
  stdout.writeln("Current package name: $oldId");
  stdout.write("Do you want to change the package name? [y/n] ");
  var input = stdin.readLineSync();
  if (input == "y" || input == "Y") {
    stdout.write("Enter new package name: ");
    var appId = stdin.readLineSync();
    if (appId != null) {
      _setAppId(appId);
    }
  }
}

/// Generates the keystore with the given settings
void _generateKeystore() {
  stdout.write("Enter key alias: ");
  alias = stdin.readLineSync();

  stdout.write("Publisher's Common Name (i.e. Mubashar Hussain): ");
  String cn = (stdin.readLineSync() ?? "").trim();
  cn = cn.isEmpty ? 'Mubashar Hussain' : cn;

  stdout.write("Organizational Unit (i.e. MH): ");
  String ou = (stdin.readLineSync() ?? "").trim();
  ou = ou.isEmpty ? 'MH' : ou;

  stdout.write("Organization (i.e. MicroProgramers): ");
  String org = (stdin.readLineSync() ?? "").trim();
  org = org.isEmpty ? 'MicroProgramers' : org;

  stdout.write("Locality (i.e. Layyah): ");
  String locality = (stdin.readLineSync() ?? "").trim();
  locality = locality.isEmpty ? 'Layyah' : locality;

  stdout.write("State (i.e. Punjab): ");
  String state = (stdin.readLineSync() ?? "").trim();
  state = state.isEmpty ? 'Punjab' : state;

  stdout.write("Country ISO (i.e. PK for Pakistan): ");
  String country = (stdin.readLineSync() ?? "").trim();
  country = country.isEmpty ? 'PK' : country;

  stdout.write("Validity Years (i.e. 100): ");
  var validity = int.tryParse(stdin.readLineSync() ?? "");
  int days = validity != null
      ? (validity * 365)
      : (DateTime(9999).difference(DateTime.now()).inDays);

  String dname = "CN=$cn, OU=$ou, O=$org, L=$locality, S=$state, C=$country";

  stdout.write("key password: ");
  keyPass = stdin.readLineSync();
  stdout.write("keystore password: ");
  keystorePass = stdin.readLineSync();
  if (alias == null ||
      alias!.isEmpty ||
      dname.isEmpty ||
      keyPass == null ||
      keyPass!.isEmpty ||
      keystorePass == null ||
      keystorePass!.isEmpty) {
    stderr.writeln("All inputs that don't have default mentioned are required");
    return;
  }

  Directory keys = Directory("keys");
  if (!keys.existsSync()) {
    keys.createSync();
  }

  ProcessResult res = Process.runSync("keytool", [
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
  stdout.write(res.stdout);
  stderr.write(res.stderr);
  stdout.writeln("generated keystore with provided input");
}

/// Creates key.properties file required by signing config in build.gradle file
void _createKeyProperties() {
  _Commons.writeStringToFile(keyPropertiesPath, """storePassword=$keystorePass
keyPassword=$keyPass
keyAlias=$alias
storeFile=../../$keystorePath
""");
  stdout.writeln("key properties file created");
}

/// configures build.gradle with release config with the generated key details
void _configureBuildConfig() {
  String bfString = _Commons.getFileAsString(_Commons.appBuildPath);
  List<String> buildfile = _Commons.getFileAsLines(_Commons.appBuildPath);
  if (!bfString.contains("deft keystoreProperties") &&
      !bfString.contains("keystoreProperties['keyAlias']")) {
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

    _Commons.writeStringToFile(_Commons.appBuildPath, buildfile.join("\n"));
    stdout.writeln("configured release configs");
  } else {
    stdout.writeln("release configs already configured");
  }
}

String _getApplicationId() {
  // Read the build.gradle file as a string
  String bfString = _Commons.getFileAsString(_Commons.appBuildPath);

  // Match defaultConfig block
  RegExp defaultConfigRegex = RegExp(
    r"defaultConfig\s*\{([\s\S]*?)\}",
    multiLine: true,
  );

  RegExpMatch? defaultConfigMatch = defaultConfigRegex.firstMatch(bfString);

  if (defaultConfigMatch != null) {
    String defaultConfigBlock = defaultConfigMatch.group(1)!;

    // Match applicationId inside defaultConfig block (supports both formats)
    RegExp applicationIdRegex = RegExp(
      r"""applicationId\s*(?:=|)\s*['"]([^'"]+)['"]""",
    );

    RegExpMatch? applicationIdMatch =
        applicationIdRegex.firstMatch(defaultConfigBlock);

    if (applicationIdMatch != null) {
      return applicationIdMatch.group(1)!; // Extract the applicationId
    } else {
      throw Exception("applicationId not found in defaultConfig block.");
    }
  } else {
    throw Exception("defaultConfig block not found.");
  }
}


void _setAppId(String appId) {
  List<String> buildfile = _Commons.getFileAsLines(_Commons.appBuildPath);

  // Regex to match both formats
  RegExp applicationIdRegex = RegExp(
    r"""applicationId\s*(=|)\s*['"][^'"]+['"]""",
  );

  buildfile = buildfile.map((line) {
    if (applicationIdRegex.hasMatch(line)) {
      // Determine the existing format
      if (line.contains('=')) {
        // New format: applicationId = "..."
        return "applicationId = '$appId'";
      } else {
        // Old format: applicationId "..."
        return "applicationId '$appId'";
      }
    } else {
      return line;
    }
  }).toList();

  _Commons.writeStringToFile(_Commons.appBuildPath, buildfile.join("\n"));
}
