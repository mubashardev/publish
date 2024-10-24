part of 'publish.dart';

String? alias;
String keystorePath = "keys/keystore.jks";
String? keyPass;
String? keystorePass;
const String keyPropertiesPath = "./android/key.properties";

/// Main function that uses other helper functions to setup android signing
void _androidSign() {
  _generateKeystore();
  _createKeyProperties();
  _configureBuildConfig();
}

/// Generates the keystore with the given settings
void _generateKeystore() {
  String defDname =
      "CN=Mubashar Hussain, OU=MH, O=Mubashar Dev Ltd., L=Layyah, S=Punjab, C=PK";

  stdout.write("enter key alias: ");
  alias = stdin.readLineSync();

  stdout.writeln(
    '''\n
--------------------------------------------------
CN=Mubashar Hussain: Common Name (CN), typically refers to the domain name or the entity that the certificate is issued for. In this case, "Mubashar Hussain"

OU=MH: Organizational Unit (OU), refers to a subdivision within an organization. Here, it could refer to a department or division, like "MH"

O=Mubashar Dev Ltd.: Organization (O), which represents the legal entity, in this case, "Mubashar Dev Ltd."

L=Layyah: Locality (L), which refers to the city where the organization is located. In this case, "Layyah"

S=Punjab: State (S), which is the state or province where the organization is located, here "Punjab"

C=PK: Country (C), refers to the country code in ISO format. "PK" is the code for Pakistan.
--------------------------------------------------\n
    '''
  );
  stdout.write(
      "enter dname as ($defDname): ");
  String? dname = stdin.readLineSync();
  if (dname == null || dname.isEmpty) dname = defDname;
  stdout.write("key password: ");
  keyPass = stdin.readLineSync();
  stdout.write("keystore password: ");
  keystorePass = stdin.readLineSync();
  if (alias == null || alias!.isEmpty ||
      dname.isEmpty ||
      keyPass == null || keyPass!.isEmpty ||
      keystorePass == null || keystorePass!.isEmpty) {
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
    "100000"
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