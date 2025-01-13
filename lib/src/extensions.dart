import 'constants.dart';

extension ColorExt on String {
  String withColor(String color) {
    return '$color$this$reset';
  }
}
