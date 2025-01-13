part of '../publish.dart';

class ConfigsHelper {
  static bool updateName(String name, String platform) {
    if (platform == 'android') {
      if (!_Validator.isValidAndroid) {
        stdout.writeln(
          "This directory doesn't seem to be a valid Flutter Android project."
              .withColor(red),
        );
        return false;
      }

      _AndroidConfigs.setAppName(name);
      return true;
    } else if (platform == 'ios') {
      if (!_Validator.isValidIos) {
        stdout.writeln(
          "This directory doesn't seem to be a valid Flutter iOS project."
              .withColor(red),
        );
        return false;
      }
      _IosConfigs.setAppName(name);
      return true;
    }

    return false;
  }

  static bool updateId(String id, String platform) {
    if (platform == 'android') {
      if (!_Validator.isValidAndroid) {
        stdout.writeln(
          "This directory doesn't seem to be a valid Flutter Android project."
              .withColor(red),
        );
        return false;
      }
      _AndroidConfigs.setAppId(id);
      return true;
    } else if (platform == 'ios') {
      if (!_Validator.isValidIos) {
        stdout.writeln(
          "This directory doesn't seem to be a valid Flutter iOS project."
              .withColor(red),
        );
        return false;
      }
      _IosConfigs.setAppId(id);
      return true;
    }
    return false;
  }
}
