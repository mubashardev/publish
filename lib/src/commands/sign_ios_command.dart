part of '../../publish.dart';

class SignIosCommand extends Command {
  @override
  String get name => 'ios';

  @override
  String get description => 'Set up iOS signing configurations.';

  @override
  void run() {
    _ConsoleUI.printHeader('🍎 iOS Settings', subtitle: 'Coming Soon');
    _ConsoleUI.printInfo(
        'This feature is under development and will be live soon.');
    _ConsoleUI.printInfo(
        'For now, you can perform other operations as documented.');
  }
}
