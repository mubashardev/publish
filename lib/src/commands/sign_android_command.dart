part of '../../publish.dart';

class AndroidSignCommand extends Command {
  @override
  String get description => 'Set up Android signing configurations.';

  @override
  String get name => 'sign-android';

  @override
  void run() async {
    if (!_Validator.isPubspecValid) {
      _ConsoleUI.printError(
          "This directory doesn't seem to be a valid Flutter project.");
      return;
    }

    _ConsoleUI.printHeader('🔐 Android Signing Setup',
        subtitle: 'Keystore Generator');

    if (_ConsoleUI.promptConfirm(
        'This will generate a keystore and update your build.gradle. Proceed?')) {
      final success = await _AndroidSigning.sign();
      if (success) {
        _ConsoleUI.printSuccess('Android signing configured successfully!');
        _ConsoleUI.printInfo('You can now run: flutter build appbundle');
      } else {
        _ConsoleUI.printError('Android signing configuration failed.');
      }
    }
  }
}
