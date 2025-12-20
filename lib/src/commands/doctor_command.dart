part of '../../publish.dart';

class DoctorCommand extends Command {
  @override
  String get name => 'doctor';

  @override
  String get description => 'Check your project for potential issues.';

  @override
  void run() {
    _ConsoleUI.printHeader('🩺 Project Doctor',
        subtitle: 'Analyzing Health...');

    bool allGood = true;

    // 1. Check Pubspec
    if (_Validator.isPubspecValid) {
      _ConsoleUI.printStatus('Pubspec', 'Valid', color: green);
    } else {
      _ConsoleUI.printStatus('Pubspec', 'Invalid or Missing', color: red);
      allGood = false;
    }

    // 2. Check Android Manifest
    if (_Validator.isAndroidManifestValid) {
      _ConsoleUI.printStatus('Android Manifest', 'Valid', color: green);
    } else {
      _ConsoleUI.printStatus('Android Manifest', 'Invalid or Missing',
          color: red);
      allGood = false;
    }

    // 3. Check Gradle
    if (_Validator.isGradleValid) {
      _ConsoleUI.printStatus('Gradle Config', 'Valid', color: green);
    } else {
      _ConsoleUI.printStatus('Gradle Config', 'Invalid or Missing', color: red);
      allGood = false;
    }

    // 4. Check iOS Info.plist
    if (_Validator.isPlistValid) {
      _ConsoleUI.printStatus('iOS Info.plist', 'Valid', color: green);
    } else {
      _ConsoleUI.printStatus('iOS Info.plist', 'Invalid or Missing',
          color: red);
      allGood = false;
    }

    // 5. Check Signing Key
    if (_Validator.isGradleValid) {
      final keyProps = File('android/key.properties');
      if (keyProps.existsSync()) {
        _ConsoleUI.printStatus('Signing Config', 'key.properties found',
            color: green);
      } else {
        _ConsoleUI.printStatus('Signing Config', 'key.properties missing',
            color: yellow);
        allGood = false; // Now considering this an issue for "publish" context
      }
    }

    // 6. Check Package Name
    if (_Validator.isGradleValid) {
      final appId = _AndroidConfigs.appId;
      if (_Validator.isDefaultPackageName(appId)) {
        _ConsoleUI.printStatus('Package Name', 'Default ($appId) ⚠️',
            color: red);
        allGood = false;
      } else {
        _ConsoleUI.printStatus('Package Name', 'Valid ($appId)', color: green);
      }
    }

    // 7. Check Icons
    if (_Validator.isAppIconExists) {
      _ConsoleUI.printStatus('App Icons', 'Found', color: green);
    } else {
      _ConsoleUI.printStatus('App Icons', 'Missing or Default', color: yellow);
      // Not strictly fatal for generic projects but bad for publishing
    }

    stdout.writeln('');
    if (allGood) {
      _ConsoleUI.printSuccess('Project looks healthy! 🚀');
    } else {
      _ConsoleUI.printWarning('Some issues were found. Please check above.');
    }
  }
}
