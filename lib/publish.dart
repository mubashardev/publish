library publish;

import 'dart:io';
import 'dart:convert';
import 'dart:isolate';

void main() async {
  // Get the current working directory
  String cwd = Directory.current.path;
  // Get the path to the pubspec.yaml file
  String pubspecPath = '$cwd/pubspec.yaml';
  // Read the contents of the pubspec.yaml file
  String pubspecContent = File(pubspecPath).readAsStringSync();
  // Parse the contents of the pubspec.yaml file
  // Map<String, dynamic> pubspec = loadYaml(pubspecContent);
  // // Get the name of the package
  // String packageName = pubspec['name'];
  // Get the path to the android folder
  String androidPath = '$cwd/android';
  // Get the path to the signingConfigs folder
  String signingConfigsPath = '$androidPath/signingConfigs';
  // Get the path to the keystore.jks file
  String keystorePath = '$signingConfigsPath/keystore.jks';
  // Get the path to the keystore.properties file
  String keystorePropertiesPath = '$signingConfigsPath/keystore.properties';
  // Get the path to the keystore.properties file
  String keystorePropertiesContent =
      File(keystorePropertiesPath).readAsStringSync();
  // Parse the contents of the keystore.properties file
  Map<String, String> keystoreProperties = <String, String>{};
}
