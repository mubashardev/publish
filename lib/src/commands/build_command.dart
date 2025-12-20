part of '../../publish.dart';

class BuildCommand extends Command {
  @override
  String get name => 'build';

  @override
  String get description => 'Build the application for different platforms.';

  BuildCommand() {
    addSubcommand(BuildAndroidCommand());
  }
}
