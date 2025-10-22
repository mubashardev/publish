part of '../publish.dart';

// Helper for max function (not available in dart:core by default)
int _max(int a, int b) => a > b ? a : b;

/// Professional console UI utilities for formatting input/output
// ignore: unused_element
class _ConsoleUI {
  // Border characters
  static const String _cornerTL = '╔';
  static const String _cornerTR = '╗';
  static const String _cornerBL = '╚';
  static const String _cornerBR = '╝';
  static const String _horizontal = '═';
  static const String _vertical = '║';
  static const String _tee = '╟';

  /// Prints a formatted header box with title
  static void printHeader(String title, {String? subtitle}) {
    final width = 60;
    final paddedTitle = _centerText(title, width - 4);

    stdout.writeln('');
    stdout.writeln('$_cornerTL${_horizontal * (width - 2)}$_cornerTR');
    stdout.writeln('$_vertical$paddedTitle$_vertical');

    if (subtitle != null) {
      final paddedSubtitle = _centerText(subtitle, width - 4);
      stdout.writeln('$_tee${_horizontal * (width - 2)}$_tee');
      stdout.writeln('$_vertical$paddedSubtitle$_vertical');
    }

    stdout.writeln('$_cornerBL${_horizontal * (width - 2)}$_cornerBR');
    stdout.writeln('');
  }

  /// Prints a section with title and content
  // ignore: unused_element
  static void printSection(String title, List<String> lines) {
    stdout.writeln('');
    stdout.writeln('  ${cyan}┌─ $title $reset');
    for (final line in lines) {
      stdout.writeln('  ${cyan}│$reset  $line');
    }
    stdout.writeln(
        '  ${cyan}└──────────────────────────────────────────────────────────$reset');
    stdout.writeln('');
  }

  /// Prints a key-value pair with alignment
  // ignore: unused_element
  static void printKeyValue(String key, String value, {String? color}) {
    final colorCode = color ?? green;
    final formatted = '$key:'.padRight(25);
    stdout.writeln('    $formatted $colorCode$value$reset');
  }

  /// Prints an indented list item
  // ignore: unused_element
  static void printListItem(String item, {int indent = 2, String icon = '•'}) {
    final spacing = ' ' * indent;
    stdout.writeln('$spacing$icon  $item');
  }

  /// Prints a success message
  // ignore: unused_element
  static void printSuccess(String message) {
    stdout.writeln('  ${green}✓$reset  $message');
  }

  /// Prints a warning message
  // ignore: unused_element
  static void printWarning(String message) {
    stdout.writeln('  ${yellow}⚠$reset  $message');
  }

  /// Prints an error message
  static void printError(String message) {
    stdout.writeln('  ${red}✗$reset  $message');
  }

  /// Prints an info message
  // ignore: unused_element
  static void printInfo(String message) {
    stdout.writeln('  ${blue}ℹ$reset  $message');
  }

  /// Prompts user for input with formatted message
  // ignore: unused_element
  static String? prompt(String message, {bool required = false}) {
    stdout.write('\n  ${cyan}?$reset  $message: ');
    final input = stdin.readLineSync();

    if (required && (input == null || input.isEmpty)) {
      printError('This field is required');
      return prompt(message, required: required);
    }

    return input;
  }

  /// Prompts user for confirmation (yes/no)
  // ignore: unused_element
  static bool promptConfirm(String message, {bool defaultYes = false}) {
    final defaultIndicator = defaultYes ? '[Y/n]' : '[y/N]';
    stdout.write('\n  ${cyan}?$reset  $message $defaultIndicator: ');
    final input = stdin.readLineSync()?.toLowerCase() ?? '';

    if (input.isEmpty) {
      return defaultYes;
    }

    return input == 'y' || input == 'yes';
  }

  /// Prompts user to select from a list
  // ignore: unused_element
  static String? promptSelect(String message, List<String> options) {
    stdout.writeln('\n  ${cyan}?$reset  $message');

    for (int i = 0; i < options.length; i++) {
      stdout.writeln('    ${cyan}${i + 1}${reset}) ${options[i]}');
    }

    stdout
        .write('\n  ${cyan}?$reset  Enter your choice (1-${options.length}): ');
    final input = stdin.readLineSync();

    try {
      final index = int.parse(input ?? '') - 1;
      if (index >= 0 && index < options.length) {
        return options[index];
      } else {
        printError('Invalid selection');
        return promptSelect(message, options);
      }
    } catch (e) {
      printError('Invalid input');
      return promptSelect(message, options);
    }
  }

  /// Prints a table with headers and rows
  // ignore: unused_element
  static void printTable(
    String title,
    List<String> headers,
    List<List<String>> rows, {
    List<int>? columnWidths,
  }) {
    printHeader(title);

    // Calculate column widths
    columnWidths ??= headers.map((h) => h.length).toList();

    for (int i = 0; i < rows.length; i++) {
      for (int j = 0; j < rows[i].length; j++) {
        columnWidths[j] = _max(columnWidths[j], rows[i][j].length);
      }
    }

    // Print headers
    final headerLine = headers
        .asMap()
        .entries
        .map((e) => e.value.padRight(columnWidths![e.key]))
        .join(' ${cyan}│$reset ');
    stdout.writeln('  ${cyan}$headerLine$reset');

    // Print separator
    final separator = columnWidths.map((w) => '─' * w).join('─${cyan}┼$reset─');
    stdout.writeln('  ${cyan}$separator$reset');

    // Print rows
    for (final row in rows) {
      final rowLine = row
          .asMap()
          .entries
          .map((e) => e.value.padRight(columnWidths![e.key]))
          .join(' ${cyan}│$reset ');
      stdout.writeln('  $rowLine');
    }

    stdout.writeln('');
  }

  /// Prints a status line with progress
  // ignore: unused_element
  static void printStatus(String status, String value, {String? color}) {
    final colorCode = color ?? cyan;
    stdout.writeln('  $status $colorCode→$reset $value');
  }

  /// Centers text within a given width
  static String _centerText(String text, int width) {
    if (text.length >= width) {
      return text.substring(0, width);
    }
    final padding = (width - text.length) ~/ 2;
    final left = ' ' * padding;
    final right = ' ' * (width - text.length - padding);
    return '$left$text$right';
  }
}
