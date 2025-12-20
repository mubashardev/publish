part of '../../publish.dart';

class IconsCommand extends Command {
  @override
  String get name => 'icons';

  @override
  String get description =>
      'Generate app icons for Android and iOS from a single source image.';

  IconsCommand() {
    argParser.addOption(
      'file',
      abbr: 'f',
      help: 'Path to source image (1024x1024 png recommended).',
      defaultsTo: 'assets/icon.png',
    );
  }

  @override
  void run() async {
    final filePath = argResults?['file'];
    final file = File(filePath);

    if (!file.existsSync()) {
      _ConsoleUI.printError('Source image not found at $filePath');
      return;
    }

    _ConsoleUI.printHeader('🎨 Generating App Icons',
        subtitle: 'Processing $filePath...');
    await generate(file);
  }

  static Future<void> generate(File file) async {
    _ConsoleUI.startLoading('Generating App Icons...');
    try {
      final bytes = file.readAsBytesSync();
      final image = img.decodeImage(bytes);

      if (image == null) {
        _ConsoleUI.stopLoading(
            success: false, message: 'Could not decode image file.');
        return;
      }

      // Android Icons
      _generateAndroidIcons(image);

      // iOS Icons
      _generateIosIcons(image);

      _ConsoleUI.stopLoading(
          success: true, message: 'Icons generated successfully! 🚀');
    } catch (e) {
      _ConsoleUI.stopLoading(
          success: false, message: 'Error generating icons: $e');
    }
  }

  static void _generateAndroidIcons(img.Image image) {
    _ConsoleUI.printStatus('Android', 'Generating mipmap icons...');
    final androidRes = 'android/app/src/main/res';

    final icons = [
      {'name': 'mipmap-mdpi', 'size': 48},
      {'name': 'mipmap-hdpi', 'size': 72},
      {'name': 'mipmap-xhdpi', 'size': 96},
      {'name': 'mipmap-xxhdpi', 'size': 144},
      {'name': 'mipmap-xxxhdpi', 'size': 192},
    ];

    for (var config in icons) {
      final size = config['size'] as int;
      final name = config['name'] as String;
      final resized = img.copyResize(image,
          width: size, height: size, interpolation: img.Interpolation.cubic);

      final dir = Directory('$androidRes/$name');
      if (!dir.existsSync()) dir.createSync(recursive: true);

      File('${dir.path}/ic_launcher.png')
          .writeAsBytesSync(img.encodePng(resized));
    }
  }

  static void _generateIosIcons(img.Image image) {
    _ConsoleUI.printStatus('iOS', 'Generating AppIcon.appiconset...');
    final iosRes = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
    final dir = Directory(iosRes);
    if (!dir.existsSync()) dir.createSync(recursive: true);

    // Standard iOS sizes
    final sizes = [20.0, 29.0, 40.0, 60.0, 76.0, 83.5, 1024.0];
    final scales = [1, 2, 3];

    for (var size in sizes) {
      for (var scale in scales) {
        if (size == 1024 && scale != 1) {
          continue; // Marketing icon is 1024x1024 (1x)
        }
        if (size == 83.5 && scale != 2) {
          continue; // iPad Pro 12.9 is 167px (83.5 * 2)
        }

        final px = (size * scale).round();
        final filename = 'Icon-App-${size}x$size@${scale}x.png';
        final resized = img.copyResize(image,
            width: px, height: px, interpolation: img.Interpolation.cubic);

        File('${dir.path}/$filename').writeAsBytesSync(img.encodePng(resized));
      }
    }

    // Write Contents.json
    File('${dir.path}/Contents.json').writeAsStringSync(_iosContentsJson);
  }

  static const _iosContentsJson = '''
{
  "images" : [
    { "size" : "20x20", "idiom" : "iphone", "filename" : "Icon-App-20.0x20.0@2x.png", "scale" : "2x" },
    { "size" : "20x20", "idiom" : "iphone", "filename" : "Icon-App-20.0x20.0@3x.png", "scale" : "3x" },
    { "size" : "29x29", "idiom" : "iphone", "filename" : "Icon-App-29.0x29.0@2x.png", "scale" : "2x" },
    { "size" : "29x29", "idiom" : "iphone", "filename" : "Icon-App-29.0x29.0@3x.png", "scale" : "3x" },
    { "size" : "40x40", "idiom" : "iphone", "filename" : "Icon-App-40.0x40.0@2x.png", "scale" : "2x" },
    { "size" : "40x40", "idiom" : "iphone", "filename" : "Icon-App-40.0x40.0@3x.png", "scale" : "3x" },
    { "size" : "60x60", "idiom" : "iphone", "filename" : "Icon-App-60.0x60.0@2x.png", "scale" : "2x" },
    { "size" : "60x60", "idiom" : "iphone", "filename" : "Icon-App-60.0x60.0@3x.png", "scale" : "3x" },
    { "size" : "20x20", "idiom" : "ipad", "filename" : "Icon-App-20.0x20.0@1x.png", "scale" : "1x" },
    { "size" : "20x20", "idiom" : "ipad", "filename" : "Icon-App-20.0x20.0@2x.png", "scale" : "2x" },
    { "size" : "29x29", "idiom" : "ipad", "filename" : "Icon-App-29.0x29.0@1x.png", "scale" : "1x" },
    { "size" : "29x29", "idiom" : "ipad", "filename" : "Icon-App-29.0x29.0@2x.png", "scale" : "2x" },
    { "size" : "40x40", "idiom" : "ipad", "filename" : "Icon-App-40.0x40.0@1x.png", "scale" : "1x" },
    { "size" : "40x40", "idiom" : "ipad", "filename" : "Icon-App-40.0x40.0@2x.png", "scale" : "2x" },
    { "size" : "76x76", "idiom" : "ipad", "filename" : "Icon-App-76.0x76.0@1x.png", "scale" : "1x" }, 
    { "size" : "76x76", "idiom" : "ipad", "filename" : "Icon-App-76.0x76.0@2x.png", "scale" : "2x" },
    { "size" : "83.5x83.5", "idiom" : "ipad", "filename" : "Icon-App-83.5x83.5@2x.png", "scale" : "2x" },
    { "size" : "1024x1024", "idiom" : "ios-marketing", "filename" : "Icon-App-1024.0x1024.0@1x.png", "scale" : "1x" }
  ],
  "info" : { "version" : 1, "author" : "xcode" }
}
''';
}
