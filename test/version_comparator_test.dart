import 'package:flutter_test/flutter_test.dart';
import 'package:version_gate/version_gate.dart';

void main() {
  const comparator = VersionComparator();

  group('VersionComparator', () {
    group('basic comparisons', () {
      test('detects major version update', () {
        expect(comparator.isNewer('2.0.0', '1.0.0'), isTrue);
      });

      test('detects minor version update', () {
        expect(comparator.isNewer('1.5.0', '1.2.0'), isTrue);
      });

      test('detects patch version update', () {
        expect(comparator.isNewer('1.2.3', '1.2.1'), isTrue);
      });

      test('returns false for same version', () {
        expect(comparator.isNewer('1.2.3', '1.2.3'), isFalse);
      });

      test('returns false when local is newer', () {
        expect(comparator.isNewer('1.0.0', '2.0.0'), isFalse);
      });

      test('returns false when local minor is newer', () {
        expect(comparator.isNewer('1.2.0', '1.5.0'), isFalse);
      });
    });

    group('build metadata', () {
      test('ignores build metadata on store version', () {
        expect(comparator.isNewer('1.5.0+45', '1.2.0'), isTrue);
      });

      test('ignores build metadata on local version', () {
        expect(comparator.isNewer('1.5.0', '1.2.0+12'), isTrue);
      });

      test('ignores build metadata on both', () {
        expect(comparator.isNewer('1.5.0+45', '1.2.0+12'), isTrue);
      });

      test('same version with different build metadata is not newer', () {
        expect(comparator.isNewer('1.2.0+45', '1.2.0+12'), isFalse);
      });
    });

    group('two-part versions', () {
      test('handles two-part version strings', () {
        expect(comparator.isNewer('1.5', '1.2'), isTrue);
      });

      test('treats missing patch as zero', () {
        expect(comparator.isNewer('1.2', '1.2.0'), isFalse);
      });

      test('detects update from two-part to three-part', () {
        expect(comparator.isNewer('1.2.1', '1.2'), isTrue);
      });
    });

    group('pre-release versions', () {
      test('release is newer than pre-release', () {
        expect(comparator.isNewer('1.0.0', '1.0.0-beta.1'), isTrue);
      });

      test('pre-release is older than release', () {
        expect(comparator.isNewer('1.0.0-beta.1', '1.0.0'), isFalse);
      });

      test('higher pre-release number is newer', () {
        expect(comparator.isNewer('1.0.0-beta.2', '1.0.0-beta.1'), isTrue);
      });

      test('alpha is older than beta', () {
        expect(comparator.isNewer('1.0.0-beta.1', '1.0.0-alpha.1'), isTrue);
      });

      test('same pre-release is not newer', () {
        expect(
            comparator.isNewer('1.0.0-beta.1', '1.0.0-beta.1'), isFalse);
      });
    });

    group('edge cases', () {
      test('handles single-digit versions', () {
        expect(comparator.isNewer('2', '1'), isTrue);
      });

      test('handles large version numbers', () {
        expect(comparator.isNewer('100.200.300', '100.200.299'), isTrue);
      });

      test('handles empty parts gracefully', () {
        expect(comparator.isNewer('1.0.0', ''), isTrue);
      });
    });
  });
}
