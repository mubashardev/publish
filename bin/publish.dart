import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:publish/publish.dart'; // Import your library

void main(List<String> arguments) async {
  final runner = CommandRunner(
    'publish',
    'A CLI tool for managing Android signing, Updating Package names and code generation.',
  )
    ..addCommand(SignCommand())
    ..addCommand(BuildCommand())
    ..addCommand(ReadAppConfigsCommand())
    ..addCommand(WriteAppConfigsCommand())
    ..addCommand(UpdateCommand())
    ..addCommand(VersionCommand())
    ..addCommand(ChangelogCommand())
    ..addCommand(DoctorCommand())
    ..addCommand(IgnoreCommand())
    ..addCommand(IconsCommand())
    ..addCommand(SplashCommand())
    ..addCommand(InitCommand());

  await UpdateHelper.checkIfUpdateAvailable();

  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    print(e);
    exit(64); // Exit code for incorrect usage
  }
}
