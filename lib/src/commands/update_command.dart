part of '../../publish.dart';

class UpdateCommand extends Command {
  @override
  String get description =>
      'Update the `publish` package to the latest version.';

  @override
  String get name => 'update';

  @override
  void run() async {
    _ConsoleUI.printHeader('🔄 Self-Update',
        subtitle: 'Checking for updates...');

    final process =
        await Process.run('dart', ['pub', 'global', 'activate', 'publish']);

    if (process.exitCode == 0) {
      _ConsoleUI.printSuccess('Updated to the latest version! 🚀');
    } else {
      _ConsoleUI.printError('Update failed:\n${process.stderr}');
    }
  }
}
