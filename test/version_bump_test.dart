import 'package:flutter_test/flutter_test.dart';
import 'package:publish/publish.dart';

void main() {
  group('Version Bump Logic', () {
    test('Patch bump standard', () {
      expect(VersionCommand.getNextVersion('1.0.0', 'patch'), '1.0.1');
      expect(VersionCommand.getNextVersion('1.0.8', 'patch'), '1.0.9');
    });

    test('Patch bump rollover (1.0.9 -> 1.1.0)', () {
      expect(VersionCommand.getNextVersion('1.0.9', 'patch'), '1.1.0');
    });

    test('Patch bump double rollover (1.9.9 -> 2.0.0)', () {
      expect(VersionCommand.getNextVersion('1.9.9', 'patch'), '2.0.0');
    });

    test('Minor bump standard', () {
      expect(VersionCommand.getNextVersion('1.0.0', 'minor'), '1.1.0');
      expect(VersionCommand.getNextVersion('1.8.8', 'minor'), '1.9.0');
    });

    test('Minor bump rollover (1.9.0 -> 2.0.0)', () {
      expect(VersionCommand.getNextVersion('1.9.0', 'minor'), '2.0.0');
    });

    test('Minor bump rollover from lower patch (1.9.5 -> 2.0.0)', () {
      expect(VersionCommand.getNextVersion('1.9.5', 'minor'), '2.0.0');
    });

    test('Major bump', () {
      expect(VersionCommand.getNextVersion('1.5.5', 'major'), '2.0.0');
    });

    test('Build number increment', () {
      expect(VersionCommand.getNextVersion('1.0.0+1', 'build'), '1.0.0+2');
    });

    test('Retains build number on version bump? No, logic resets it.', () {
      expect(VersionCommand.getNextVersion('1.0.0+1', 'patch'), '1.0.1');
    });
  });
}
