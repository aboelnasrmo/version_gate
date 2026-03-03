import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version_gate/version_gate.dart';

void main() {
  group('FrequencyGuard', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('allows check when no previous check exists', () async {
      final guard = FrequencyGuard(frequency: CheckFrequency.onceDaily);
      expect(await guard.shouldCheck(), isTrue);
    });

    test('blocks check when checked recently', () async {
      SharedPreferences.setMockInitialValues({
        'version_gate_last_check': DateTime.now().toIso8601String(),
      });

      final guard = FrequencyGuard(frequency: CheckFrequency.onceDaily);
      expect(await guard.shouldCheck(), isFalse);
    });

    test('allows check when enough time has passed', () async {
      final old = DateTime.now().subtract(const Duration(hours: 25));
      SharedPreferences.setMockInitialValues({
        'version_gate_last_check': old.toIso8601String(),
      });

      final guard = FrequencyGuard(frequency: CheckFrequency.onceDaily);
      expect(await guard.shouldCheck(), isTrue);
    });

    test('weekly frequency blocks within 7 days', () async {
      final recent = DateTime.now().subtract(const Duration(days: 3));
      SharedPreferences.setMockInitialValues({
        'version_gate_last_check': recent.toIso8601String(),
      });

      final guard = FrequencyGuard(frequency: CheckFrequency.oncePerWeek);
      expect(await guard.shouldCheck(), isFalse);
    });

    test('weekly frequency allows after 7 days', () async {
      final old = DateTime.now().subtract(const Duration(days: 8));
      SharedPreferences.setMockInitialValues({
        'version_gate_last_check': old.toIso8601String(),
      });

      final guard = FrequencyGuard(frequency: CheckFrequency.oncePerWeek);
      expect(await guard.shouldCheck(), isTrue);
    });

    test('always frequency always allows', () async {
      SharedPreferences.setMockInitialValues({
        'version_gate_last_check': DateTime.now().toIso8601String(),
      });

      final guard = FrequencyGuard(frequency: CheckFrequency.always);
      expect(await guard.shouldCheck(), isTrue);
    });

    test('per-session frequency always allows', () async {
      SharedPreferences.setMockInitialValues({
        'version_gate_last_check': DateTime.now().toIso8601String(),
      });

      final guard = FrequencyGuard(frequency: CheckFrequency.oncePerSession);
      expect(await guard.shouldCheck(), isTrue);
    });

    test('custom frequency respects custom hours', () async {
      final recent = DateTime.now().subtract(const Duration(hours: 6));
      SharedPreferences.setMockInitialValues({
        'version_gate_last_check': recent.toIso8601String(),
      });

      final guard = FrequencyGuard(
        frequency: const CheckFrequency.custom(hours: 12),
      );
      expect(await guard.shouldCheck(), isFalse);
    });

    test('custom frequency allows after custom hours', () async {
      final old = DateTime.now().subtract(const Duration(hours: 13));
      SharedPreferences.setMockInitialValues({
        'version_gate_last_check': old.toIso8601String(),
      });

      final guard = FrequencyGuard(
        frequency: const CheckFrequency.custom(hours: 12),
      );
      expect(await guard.shouldCheck(), isTrue);
    });

    test('recordCheck saves current timestamp', () async {
      final guard = FrequencyGuard(frequency: CheckFrequency.onceDaily);
      await guard.recordCheck();

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('version_gate_last_check');
      expect(saved, isNotNull);

      final savedDate = DateTime.parse(saved!);
      final diff = DateTime.now().difference(savedDate);
      expect(diff.inSeconds, lessThan(2));
    });

    test('reset clears the stored timestamp', () async {
      SharedPreferences.setMockInitialValues({
        'version_gate_last_check': DateTime.now().toIso8601String(),
      });

      final guard = FrequencyGuard(frequency: CheckFrequency.onceDaily);
      await guard.reset();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('version_gate_last_check'), isNull);
    });

    test('handles corrupted timestamp gracefully', () async {
      SharedPreferences.setMockInitialValues({
        'version_gate_last_check': 'not-a-date',
      });

      final guard = FrequencyGuard(frequency: CheckFrequency.onceDaily);
      expect(await guard.shouldCheck(), isTrue);
    });
  });
}
