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
      // Only check key properties if gradle is arguably there,
      // essentially we want to check key.properties file existence.
      // There isn't a direct public validator for key.properties in _Validator,
      // but we can check the file directly.
      final keyProps = File('android/key.properties');
      if (keyProps.existsSync()) {
        _ConsoleUI.printStatus('Signing Config', 'key.properties found',
            color: green);
      } else {
        _ConsoleUI.printStatus('Signing Config', 'key.properties missing',
            color: yellow);
        // Not strictly "Error" as they might not have set it up yet, but for "publish" package context usually they want it.
      }
    }

    stdout.writeln('');
    if (allGood) {
      _ConsoleUI.printSuccess('Project looks healthy! 🚀');
    } else {
      _ConsoleUI.printWarning('Some issues were found. Please check above.');
    }
  }
}
