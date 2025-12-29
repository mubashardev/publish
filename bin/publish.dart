import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:publish/publish.dart';
import 'package:publish/src/constants.dart';

void main(List<String> arguments) async {
  final runner = CommandRunner(
    'publish',
    'The ultimate Flutter CLI tool for streamlined app publishing.\n\n'
        'Getting Started:\n'
        '  1. Run "publish doctor" to analyze your project\n'
        '  2. Fix any issues found\n'
        '  3. Use "publish init" for quick interactive setup\n'
        '  4. Build and sign your app for release',
  )
    ..argParser.addFlag(
      'version',
      negatable: false,
      help: 'Print the version of publish CLI.',
    )
    ..addCommand(DoctorCommand())
    ..addCommand(InitCommand())
    ..addCommand(SignCommand())
    ..addCommand(BuildCommand())
    ..addCommand(ReadAppConfigsCommand())
    ..addCommand(WriteAppConfigsCommand())
    ..addCommand(IconsCommand())
    ..addCommand(SplashCommand())
    ..addCommand(VersionCommand())
    ..addCommand(ChangelogCommand())
    ..addCommand(UpdateCommand())
    ..addCommand(IgnoreCommand())
    ..addCommand(ConfigCommand());

  // Parse arguments to check for global flags
  final argResults = runner.argParser.parse(arguments);

  // Handle --version flag
  if (argResults['version'] == true) {
    await UpdateHelper.printVersionInfo();
    exit(0);
  }

  // Check for updates (unless running update command)
  if (!arguments.contains('update')) {
    await UpdateHelper.checkIfUpdateAvailable();
  }

  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    print(e);
    exit(64);
  } catch (e) {
    // If no command provided, show helpful message
    if (arguments.isEmpty) {
      stdout.writeln('');
      stdout.writeln('${cyan}👋 Welcome to Publish CLI!$reset');
      stdout.writeln('');
      stdout.writeln('${green}Quick Start:$reset');
      stdout.writeln(
          '  ${cyan}publish doctor$reset  - Analyze your project (recommended first step)');
      stdout
          .writeln('  ${cyan}publish init$reset    - Interactive setup wizard');
      stdout.writeln(
          '  ${cyan}publish --help$reset  - Show all available commands');
      stdout.writeln('');
      exit(0);
    }
    rethrow;
  }
}
