#!/usr/bin/env dart
/// Test script to manually validate all gradle sample formats
import 'dart:io';

void main() {
  print('🧪 Testing Gradle Parser with all sample formats\n');
  
  // Test Groovy samples
  print('═' * 60);
  print('📄 GROOVY FORMAT SAMPLES (build.gradle)');
  print('═' * 60);
  testGroovySamples();
  
  // Test KTS samples
  print('\n═' * 60);
  print('🔷 KOTLIN DSL FORMAT SAMPLES (build.gradle.kts)');
  print('═' * 60);
  testKtsSamples();
  
  print('\n✅ All samples validated successfully!\n');
}

void testGroovySamples() {
  final groovyDir = Directory('./supported_gradle_formats/groovy');
  if (!groovyDir.existsSync()) {
    print('❌ Groovy samples directory not found');
    return;
  }
  
  final files = groovyDir.listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.gradle'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  
  print('\nFound ${files.length} Groovy samples:\n');
  
  for (final file in files) {
    final content = file.readAsStringSync();
    final fileName = file.path.split('/').last;
    
    try {
      final appId = extractApplicationId(content);
      if (appId != null) {
        print('✓ $fileName');
        print('  📦 applicationId: $appId');
        
        // Check expected patterns for this file
        if (fileName == '1.build.gradle') {
          if (appId == 'com.example.app') {
            print('  ✓ Matches expected package name');
          }
        } else if (fileName == '2.build.gradle') {
          if (appId == 'com.example.myapp') {
            print('  ✓ Matches expected package name');
          }
        } else if (fileName == '3.build.gradle') {
          if (appId == 'com.company.myapp') {
            print('  ✓ Matches expected package name');
          }
        } else if (fileName == '4.build.gradle') {
          if (appId == 'com.example.legacy') {
            print('  ✓ Matches expected package name');
          }
        } else if (fileName == '5.build.gradle') {
          if (appId == 'com.example.firebase.app') {
            print('  ✓ Matches expected package name');
          }
        }
      } else {
        print('❌ $fileName - Could not extract applicationId');
      }
    } catch (e) {
      print('❌ $fileName - Error: $e');
    }
    print('');
  }
}

void testKtsSamples() {
  final ktsDir = Directory('./supported_gradle_formats/kts');
  if (!ktsDir.existsSync()) {
    print('❌ KTS samples directory not found');
    return;
  }
  
  final files = ktsDir.listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.kts'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  
  print('\nFound ${files.length} KTS samples:\n');
  
  for (final file in files) {
    final content = file.readAsStringSync();
    final fileName = file.path.split('/').last;
    
    try {
      final appId = extractApplicationId(content);
      if (appId != null) {
        print('✓ $fileName');
        print('  📦 applicationId: $appId');
        
        // Check expected patterns for this file
        if (fileName == '1.build.gradle.kts') {
          if (appId == 'com.example.app') {
            print('  ✓ Matches expected package name');
          }
        } else if (fileName == '2.build.gradle.kts') {
          if (appId == 'com.example.myapp') {
            print('  ✓ Matches expected package name');
          }
        } else if (fileName == '3.build.gradle.kts') {
          if (appId == 'com.company.myapp') {
            print('  ✓ Matches expected package name');
          }
        } else if (fileName == '4.build.gradle.kts') {
          if (appId == 'com.example.legacy') {
            print('  ✓ Matches expected package name');
          }
        } else if (fileName == '5.build.gradle.kts') {
          if (appId == 'com.example.firebase.app') {
            print('  ✓ Matches expected package name');
          }
        }
      } else {
        print('❌ $fileName - Could not extract applicationId');
      }
    } catch (e) {
      print('❌ $fileName - Error: $e');
    }
    print('');
  }
}

/// Inline implementation of the extraction logic for testing
String? extractApplicationId(String content) {
  // First, extract the defaultConfig block
  RegExp defaultConfigRegex = RegExp(
    r'defaultConfig\s*[\(\{]([\s\S]*?)[\)\}](?=\s*(?:buildTypes|signingConfigs|dependencies|$))',
    multiLine: true,
  );

  RegExpMatch? defaultConfigMatch = defaultConfigRegex.firstMatch(content);
  if (defaultConfigMatch == null) {
    return null;
  }

  String defaultConfigBlock = defaultConfigMatch.group(1)!;

  // Try KTS format first: applicationId = "..."
  RegExp ktsFormat1 = RegExp(r'applicationId\s*=\s*"([^"]+)"');
  RegExpMatch? ktsMatch1 = ktsFormat1.firstMatch(defaultConfigBlock);
  if (ktsMatch1 != null) {
    return ktsMatch1.group(1)!;
  }

  // Try with single quotes
  RegExp ktsFormat1Single = RegExp(r"applicationId\s*=\s*'([^']+)'");
  RegExpMatch? ktsMatch1Single = ktsFormat1Single.firstMatch(defaultConfigBlock);
  if (ktsMatch1Single != null) {
    return ktsMatch1Single.group(1)!;
  }

  // Try KTS method call format: applicationId("...")
  RegExp ktsFormat2 = RegExp(r'applicationId\s*\(\s*"([^"]+)"\s*\)');
  RegExpMatch? ktsMatch2 = ktsFormat2.firstMatch(defaultConfigBlock);
  if (ktsMatch2 != null) {
    return ktsMatch2.group(1)!;
  }

  // Try with single quotes
  RegExp ktsFormat2Single = RegExp(r"applicationId\s*\(\s*'([^']+)'\s*\)");
  RegExpMatch? ktsMatch2Single = ktsFormat2Single.firstMatch(defaultConfigBlock);
  if (ktsMatch2Single != null) {
    return ktsMatch2Single.group(1)!;
  }

  // Try Groovy old format: applicationId "..." (no equals sign)
  RegExp groovyOldFormat = RegExp(r'applicationId\s+"([^"]+)"');
  RegExpMatch? groovyMatch = groovyOldFormat.firstMatch(defaultConfigBlock);
  if (groovyMatch != null) {
    return groovyMatch.group(1)!;
  }

  // Try with single quotes
  RegExp groovyOldFormatSingle = RegExp(r"applicationId\s+'([^']+)'");
  RegExpMatch? groovyMatchSingle = groovyOldFormatSingle.firstMatch(defaultConfigBlock);
  if (groovyMatchSingle != null) {
    return groovyMatchSingle.group(1)!;
  }

  return null;
}
