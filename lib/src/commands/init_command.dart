part of '../../publish.dart';

class InitCommand extends Command {
  @override
  String get name => 'init';

  @override
  String get description => 'Interactive wizard to set up your project.';

  @override
  void run() async {
    _ConsoleUI.printHeader('🧙 Publish Wizard',
        subtitle: 'Setting up your project...');

    // 1. App Name
    if (_ConsoleUI.promptConfirm('Do you want to update the App Name?')) {
      final appName = _ConsoleUI.prompt('Enter App Name', required: true);
      if (appName != null) {
        // Since we can't easily invoke another command instance with parsed args directly without hacking `runner.run()`,
        // we'll use the helper directly or construct args.
        // Using ConfigsHelper is cleaner.
        _ConsoleUI.printStatus('Config', 'Updating App Name...');
        ConfigsHelper.updateName(appName, 'android');
        ConfigsHelper.updateName(appName, 'ios');
      }
    }

    // 2. Package Name (App ID)
    if (_ConsoleUI.promptConfirm('Do you want to update the Package ID?')) {
      final appId = _ConsoleUI.prompt('Enter Package ID (e.g. com.example.app)',
          required: true);
      if (appId != null) {
        if (!_Validator.isValidAppId(appId)) {
          _ConsoleUI.printError('Invalid App ID format.');
        } else {
          _ConsoleUI.printStatus('Config', 'Updating App ID...');
          ConfigsHelper.updateId(appId, 'android');
          ConfigsHelper.updateId(appId, 'ios');
        }
      }
    }

    // 3. Icons
    if (_ConsoleUI.promptConfirm('Do you want to generate App Icons?')) {
      final path =
          _ConsoleUI.prompt('Enter path to source image', required: true);
      if (path != null) {
        // Here we invoke the IconsCommand logic.
        // Best way is to instantiate and run or move logic to a helper.
        // For CLI simplicity, we can try to run the command logic if accessible.
        // Or better: manual implementation re-using the private helper if we refactor,
        // but `IconsCommand` logic is inside `run`.
        // Let's instantiate the command and manually run its internal logic if possible,
        // but proper way is `runner.run(['icons', '--file', path])`.
        // We don't have access to the main runner here easily.
        // So we will trigger the command logic by creating an instance and passing args?
        // CommandRunner isn't easily nested.
        // We will just print instructions or try to use `Process.run`? No, same process.

        // Strategy: We'll construct the command and run it?
        // Arguments are parsed by `argParser`.

        // We can't injected parsed args.
        // So we will just tell the user to run it distinctively or refactor IconsCommand to have a static helper.
        // Refactoring IconsCommand to static helper `IconsGenerator` is best practice.
        // But for now, I will just replicate the check and call the function if I move it to a Helper.

        // Simpler: Just run the key logic if I move _generate to public static.
        // Let's refactor IconsCommand later if needed. For now, we'll prompt them to run it.
        // ACTUALLY: The user expects it to RUN.
        // Let's use `Process.run` to call ourselves? `dart pub global run publish icons`?
        // No, we might be in dev mode.
        // FASTEST PATH: Just Instantiate IconsCommand and let it run?
        // Issue: `argResults` will be null.

        // OK, I'll refactor `IconsCommand` slightly to allow calling `generate(File file)` from static,
        // OR I will just copy the logic call here.
        // Since `IconsCommand` is part of this library, I can access its private methods?
        // No, they are private to the class/part.

        _ConsoleUI.printInfo('Generating icons from $path...');
        // The prompt implies we do it.
        // Let's actually execute it. I will modify `IconsCommand` to have a public static `generate` method in the next step.
        // For now, I'll put a placeholder or call a theoretical `IconsCommand.generate(path)`.

        // I will assume I'll add `static void generate(File file)` to IconsCommand.
        await IconsCommand.generate(File(path));
      }
    }

    // 4. Gitignore
    if (_ConsoleUI.promptConfirm('Do you want to generate a .gitignore?')) {
      final cmd = IgnoreCommand();
      cmd.run(); // IgnoreCommand run takes no args and uses prompts, so this works!
    }

    _ConsoleUI.printHeader('🎉 Setup Complete!',
        subtitle: 'Run `publish doctor` to verify.');
  }
}
