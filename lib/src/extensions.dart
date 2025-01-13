import 'constants.dart';

extension ColorExt on String {
  String withColor(String color) {
    return '$color$this$reset';
  }

  String get makeError => "❌ $this".withColor(red);
  String get makeCheck => "✅ $this".withColor(green);
  String get makeWarning => "⚠️ $this".withColor(yellow);
  String get makeWaiting => "⌛️ $this".withColor(cyan);
  String get makeInfo => "ℹ️ $this".withColor(blue);
}
