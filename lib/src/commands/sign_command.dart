part of '../../publish.dart';

class SignCommand extends Command {
  @override
  String get name => 'sign';

  @override
  String get description =>
      'Manage signing configurations for different platforms.';

  SignCommand() {
    addSubcommand(SignAndroidCommand());
    addSubcommand(SignIosCommand());
  }
}
