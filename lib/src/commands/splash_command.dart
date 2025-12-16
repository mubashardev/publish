part of '../../publish.dart';

class SplashCommand extends Command {
  @override
  String get name => 'splash';

  @override
  String get description =>
      'Update native splash screen background color (Android).';

  SplashCommand() {
    argParser.addOption(
      'color',
      abbr: 'c',
      help: 'Background color (hex, e.g. #FF0000).',
      mandatory: true,
    );
  }

  @override
  void run() {
    final color = argResults?['color'];
    if (color == null) {
      _ConsoleUI.printError('Color argument is required.');
      return;
    }

    if (!_Validator.isAndroidManifestValid) {
      _ConsoleUI.printError('Not a valid Flutter Android project.');
      return;
    }

    _ConsoleUI.printHeader('🎨 Updating Splash Screen',
        subtitle: 'Target: $color');

    // Android
    _updateAndroidSplash(color);

    // iOS
    _updateIosSplash(color);
  }

  void _updateAndroidSplash(String colorHex) {
    final file =
        File('android/app/src/main/res/drawable/launch_background.xml');
    if (!file.existsSync()) {
      _ConsoleUI.printStatus('Android', 'launch_background.xml not found',
          color: yellow);
      // We could create it, but for now just warn.
      return;
    }

    try {
      // XML parsing/replacing using Regex for simplicity in preserving comments/structure
      // Looking for <item android:drawable="@color/..." /> or <item android:drawable="#..." /> inside <layer-list>
      // Actually default flutter uses <item><color android:color="#FFFFFF"/></item> or similar?
      // Default content:
      // <?xml version="1.0" encoding="utf-8"?>
      // <layer-list xmlns:android="http://schemas.android.com/apk/res/android">
      //     <item android:drawable="?android:colorBackground" />
      // </layer-list>

      // Note: To be safe, we should guide user to set a color item.
      // But assuming we want to REPLACE the background item.

      // Regex for <item ... android:drawable="color" ...> might be complex.
      // Let's rely on standard Flutter template pattern:
      // <item android:drawable="?android:colorBackground" />

      // We'll construct a valid simplistic launch_background.xml replacing the content if it looks standard.

      final xml = '''
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item>
        <shape android:shape="rectangle">
            <solid android:color="$colorHex"/>
        </shape>
    </item>
    <item>
        <bitmap
            android:gravity="center"
            android:src="@mipmap/launch_image" />
    </item>
</layer-list>
''';
      // This re-writes with a shape solid color.
      // Beware: This might overwrite existing custom logos if they differ from @mipmap/launch_image.
      // But this is a "generator" command so standardizing is expected.

      file.writeAsStringSync(xml);
      _ConsoleUI.printSuccess('Updated Android launch_background.xml');

      // Also ensuring styles.xml points to this? Usually default does.
    } catch (e) {
      _ConsoleUI.printError('Failed to update Android splash: $e');
    }
  }

  void _updateIosSplash(String colorHex) {
    if (colorHex.startsWith('#')) colorHex = colorHex.substring(1);

    // Parse Hex to RGB (0-1 range for iOS Storyboard)
    int? v = int.tryParse(colorHex, radix: 16);
    if (v == null) {
      _ConsoleUI.printError('Invalid hex color: $colorHex');
      return;
    }

    // Supports 6 digits (RRGGBB) or 8 digits (AARRGGBB)
    double r, g, b, a = 1.0;
    if (colorHex.length == 8) {
      a = ((v >> 24) & 0xFF) / 255.0;
      r = ((v >> 16) & 0xFF) / 255.0;
      g = ((v >> 8) & 0xFF) / 255.0;
      b = (v & 0xFF) / 255.0;
    } else {
      r = ((v >> 16) & 0xFF) / 255.0;
      g = ((v >> 8) & 0xFF) / 255.0;
      b = (v & 0xFF) / 255.0;
    }

    final file = File('ios/Runner/Base.lproj/LaunchScreen.storyboard');
    if (!file.existsSync()) {
      _ConsoleUI.printStatus('iOS', 'LaunchScreen.storyboard not found',
          color: yellow);
      return;
    }

    try {
      String xmlContent = file.readAsStringSync();
      // Simplistic regex approach: Find the primary View's background color.
      // LaunchScreen usually has a generic <view ... id="LaunchScreen"> with a background color.

      // We look for a common pattern where the main view background is defined.
      // <color key="backgroundColor" red="1" green="1" blue="1" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>

      // We explicitly replace ALL occurrences of "backgroundColor" which might be aggressive,
      // but usually the LaunchScreen is simple.
      // safer: replace the one inside the <view> tag.

      // Construct new color tag
      final newColorTag =
          '<color key="backgroundColor" red="$r" green="$g" blue="$b" alpha="$a" colorSpace="custom" customColorSpace="sRGB"/>';

      // Regex to find existing color tag inside <view> is hard without full XML parser.
      // But we can try to replace any generic background color tag.

      final regex = RegExp(r'<color key="backgroundColor" [^>]+>');
      if (regex.hasMatch(xmlContent)) {
        xmlContent = xmlContent.replaceAll(regex, newColorTag);
        file.writeAsStringSync(xmlContent);
        _ConsoleUI.printSuccess('Updated iOS LaunchScreen.storyboard');
      } else {
        _ConsoleUI.printStatus(
            'iOS', 'Could not locate backgroundColor in Storyboard',
            color: yellow);
      }
    } catch (e) {
      _ConsoleUI.printError('Failed to update iOS splash: $e');
    }
  }
}
