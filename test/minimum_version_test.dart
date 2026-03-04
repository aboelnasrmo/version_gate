import 'package:flutter_test/flutter_test.dart';
import 'package:version_gate/version_gate.dart';

void main() {
  group('Minimum Version Enforcement', () {
    const comparator = VersionComparator();

    test('local below minimum triggers isNewer = true', () {
      // minimumVersion: '2.0.0', localVersion: '1.5.0'
      // isNewer('2.0.0', '1.5.0') => true means local < minimum
      expect(comparator.isNewer('2.0.0', '1.5.0'), isTrue);
    });

    test('local at minimum does not trigger', () {
      // isNewer('2.0.0', '2.0.0') => false means local >= minimum
      expect(comparator.isNewer('2.0.0', '2.0.0'), isFalse);
    });

    test('local above minimum does not trigger', () {
      // isNewer('2.0.0', '2.1.0') => false means local >= minimum
      expect(comparator.isNewer('2.0.0', '2.1.0'), isFalse);
    });

    test('VersionCheckResult.noUpdate preserves strings', () {
      final s = UpdateStrings.arabic();
      final result = VersionCheckResult.noUpdate(
        localVersion: '1.0.0',
        updateMode: UpdateMode.optional,
        strings: s,
      );
      expect(result.strings, equals(s));
      expect(result.strings!.title, equals('تحديث متاح'));
    });

    test('VersionCheckResult carries strings through', () {
      final s = UpdateStrings.french();
      final result = VersionCheckResult(
        hasUpdate: true,
        localVersion: '1.0.0',
        storeVersion: '2.0.0',
        storeUrl: 'https://example.com',
        updateMode: UpdateMode.forced,
        lastChecked: DateTime.now(),
        strings: s,
      );
      expect(result.strings, equals(s));
      expect(result.strings!.title, equals('Mise à jour disponible'));
    });
  });
}
