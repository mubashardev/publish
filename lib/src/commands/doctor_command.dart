part of '../../publish.dart';

class DoctorCommand extends Command {
  @override
  String get name => 'doctor';

  @override
  String get description =>
      'Analyze your project health and get recommendations (run this first!).';

  @override
  void run() async {
    _ConsoleUI.printHeader('🩺 Project Doctor');

    _ConsoleUI.startLoading('Analyzing Health...');

    // Artificial delay to ensure user sees the "Analyzing" animation
    await Future.delayed(Duration(milliseconds: 1500));

    _ConsoleUI.stopLoading(success: true, message: 'Analysis Complete');
    _ConsoleUI.printEmpty();

    bool allGood = true;
    final List<String> criticalIssues = [];
    final List<String> warnings = [];
    final List<String> suggestions = [];

    // 1. Flutter SDK Check
    try {
      final flutterResult = await Process.run('flutter', ['--version']);
      if (flutterResult.exitCode == 0) {
        final versionLine = (flutterResult.stdout as String).split('\n').first;
        final version = versionLine.replaceAll('Flutter ', '').split(' ').first;
        _ConsoleUI.printStatus('Flutter SDK', version, color: green);
      } else {
        _ConsoleUI.printStatus('Flutter SDK', 'Not Found', color: red);
        criticalIssues.add('Install Flutter SDK from https://flutter.dev');
        allGood = false;
      }
    } catch (e) {
      _ConsoleUI.printStatus('Flutter SDK', 'Not Found', color: red);
      criticalIssues.add('Install Flutter SDK from https://flutter.dev');
      allGood = false;
    }

    // 2. Check Pubspec
    if (_Validator.isPubspecValid) {
      _ConsoleUI.printStatus('Pubspec', 'Valid', color: green);
    } else {
      _ConsoleUI.printStatus('Pubspec', 'Invalid or Missing',
          color: red, fix: 'flutter create .');
      criticalIssues.add('Fix pubspec.yaml or create new Flutter project');
      allGood = false;
    }

    // 3. Check Android Manifest
    if (_Validator.isAndroidManifestValid) {
      _ConsoleUI.printStatus('Android Manifest', 'Valid', color: green);
    } else {
      _ConsoleUI.printStatus('Android Manifest', 'Invalid or Missing',
          color: red, fix: 'flutter create .');
      allGood = false;
    }

    // 4. Check Gradle
    if (_Validator.isGradleValid) {
      _ConsoleUI.printStatus('Gradle Config', 'Valid', color: green);
    } else {
      _ConsoleUI.printStatus('Gradle Config', 'Invalid or Missing',
          color: red, fix: 'flutter create .');
      allGood = false;
    }

    // 5. Check iOS Info.plist
    if (_Validator.isPlistValid) {
      _ConsoleUI.printStatus('iOS Info.plist', 'Valid', color: green);
    } else {
      _ConsoleUI.printStatus('iOS Info.plist', 'Invalid or Missing',
          color: red, fix: 'flutter create .');
      allGood = false;
    }

    // 6. Check Signing Key
    if (_Validator.isGradleValid) {
      final keyProps = File('android/key.properties');
      if (keyProps.existsSync()) {
        _ConsoleUI.printStatus('Signing Config', 'key.properties found',
            color: green);
      } else {
        _ConsoleUI.printStatus('Signing Config', 'key.properties missing',
            color: yellow, fix: 'publish sign android');
        warnings.add('Configure Android signing for release builds');
        allGood = false;
      }
    }

    // 7. Check Package Name
    if (_Validator.isGradleValid) {
      final appId = _AndroidConfigs.appId;
      if (_Validator.isDefaultPackageName(appId)) {
        _ConsoleUI.printStatus('Package Name', 'Default ($appId) ⚠️',
            color: red, fix: 'publish config app-id --value "com.your.app"');
        criticalIssues.add('Change default package name before publishing');
        allGood = false;
      } else {
        _ConsoleUI.printStatus('Package Name', 'Valid ($appId)', color: green);
      }
    }

    // 8. Check Icons
    if (_Validator.isAppIconExists) {
      _ConsoleUI.printStatus('App Icons', 'Found', color: green);
    } else {
      _ConsoleUI.printStatus('App Icons', 'Missing or Default',
          color: yellow, fix: 'publish icons');
      warnings.add('Generate custom app icons for better branding');
    }

    // 9. Check Git Repository
    final gitDir = Directory('.git');
    if (gitDir.existsSync()) {
      _ConsoleUI.printStatus('Git Repository', 'Initialized', color: green);
    } else {
      _ConsoleUI.printStatus('Git Repository', 'Not Initialized',
          color: yellow, fix: 'git init');
      suggestions.add('Initialize git for version control');
    }

    // 10. Check Splash Screen
    final splashAndroid =
        File('android/app/src/main/res/drawable/launch_background.xml');
    final splashIos = File('ios/Runner/Assets.xcassets/LaunchImage.imageset');
    if (splashAndroid.existsSync() || splashIos.existsSync()) {
      _ConsoleUI.printStatus('Splash Screen', 'Configured', color: green);
    } else {
      _ConsoleUI.printStatus('Splash Screen', 'Not Configured',
          color: cyan, fix: 'publish splash --color "#FFFFFF"');
      suggestions.add('Configure splash screen for professional look');
    }

    // Summary Section
    stdout.writeln('');
    _ConsoleUI.printHeader('📋 Summary');

    if (allGood) {
      _ConsoleUI.printSuccess('✨ Project is healthy and ready!');
      stdout.writeln('');
      stdout.writeln('  ${green}Next Steps:$reset');
      stdout.writeln(
          '  1. ${cyan}publish build android$reset - Build release app bundle');
      stdout.writeln(
          '  2. ${cyan}publish sign android$reset - Configure signing (if not done)');
      stdout.writeln(
          '  3. ${cyan}publish version patch$reset - Bump version before release');
    } else {
      if (criticalIssues.isNotEmpty) {
        _ConsoleUI.printError('❌ Critical Issues Found:');
        for (final issue in criticalIssues) {
          stdout.writeln('     ${red}•$reset $issue');
        }
        stdout.writeln('');
      }

      if (warnings.isNotEmpty) {
        _ConsoleUI.printWarning('⚠️  Warnings:');
        for (final warning in warnings) {
          stdout.writeln('     ${yellow}•$reset $warning');
        }
        stdout.writeln('');
      }

      if (suggestions.isNotEmpty) {
        stdout.writeln('  ${cyan}💡 Suggestions:$reset');
        for (final suggestion in suggestions) {
          stdout.writeln('     ${cyan}•$reset $suggestion');
        }
        stdout.writeln('');
      }

      stdout.writeln('  ${green}Recommended Actions:$reset');
      if (criticalIssues.isNotEmpty) {
        stdout.writeln('  1. Fix critical issues above');
        stdout.writeln('  2. Run ${cyan}publish init$reset for quick setup');
        stdout.writeln('  3. Run ${cyan}publish doctor$reset again to verify');
      } else {
        stdout.writeln('  1. Address warnings if publishing to stores');
        stdout.writeln(
            '  2. Run ${cyan}publish init$reset for interactive setup');
        stdout
            .writeln('  3. Use ${cyan}publish build android$reset when ready');
      }
    }
    _ConsoleUI.printEmpty();
  }
}
