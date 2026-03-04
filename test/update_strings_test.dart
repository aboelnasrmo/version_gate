import 'package:flutter_test/flutter_test.dart';
import 'package:version_gate/version_gate.dart';

void main() {
  group('UpdateStrings', () {
    test('default constructor has English text', () {
      const s = UpdateStrings();
      expect(s.title, equals('Update Available'));
      expect(s.updateButtonText, equals('Update Now'));
      expect(s.laterButtonText, equals('Later'));
      expect(s.blockScreenTitle, equals('Update Required'));
      expect(s.blockScreenButtonText, equals('Go to Store'));
      expect(s.dismissButtonText, equals('Dismiss'));
    });

    test('english factory matches default', () {
      const s = UpdateStrings.english();
      expect(s.title, equals('Update Available'));
      expect(s.updateButtonText, equals('Update Now'));
    });

    test('arabic factory returns Arabic text', () {
      final s = UpdateStrings.arabic();
      expect(s.title, equals('تحديث متاح'));
      expect(s.updateButtonText, equals('تحديث الآن'));
      expect(s.laterButtonText, equals('لاحقاً'));
      expect(s.blockScreenTitle, equals('تحديث مطلوب'));
    });

    test('spanish factory returns Spanish text', () {
      final s = UpdateStrings.spanish();
      expect(s.title, equals('Actualización disponible'));
      expect(s.updateButtonText, equals('Actualizar ahora'));
    });

    test('french factory returns French text', () {
      final s = UpdateStrings.french();
      expect(s.title, equals('Mise à jour disponible'));
      expect(s.updateButtonText, equals('Mettre à jour'));
    });

    test('german factory returns German text', () {
      final s = UpdateStrings.german();
      expect(s.title, equals('Update verfügbar'));
      expect(s.updateButtonText, equals('Jetzt aktualisieren'));
    });

    test('turkish factory returns Turkish text', () {
      final s = UpdateStrings.turkish();
      expect(s.title, equals('Güncelleme mevcut'));
    });

    test('urdu factory returns Urdu text', () {
      final s = UpdateStrings.urdu();
      expect(s.title, equals('اپ ڈیٹ دستیاب ہے'));
    });

    test('chinese factory returns Chinese text', () {
      final s = UpdateStrings.chinese();
      expect(s.title, equals('有可用更新'));
      expect(s.updateButtonText, equals('立即更新'));
    });

    test('japanese factory returns Japanese text', () {
      final s = UpdateStrings.japanese();
      expect(s.title, equals('アップデートがあります'));
    });

    test('korean factory returns Korean text', () {
      final s = UpdateStrings.korean();
      expect(s.title, equals('업데이트 가능'));
    });

    group('resolve', () {
      test('replaces storeVersion placeholder', () {
        const s = UpdateStrings();
        final result = s.resolve(s.message, '2.0.0', '1.0.0');
        expect(result, contains('2.0.0'));
        expect(result, contains('1.0.0'));
        expect(result, isNot(contains('{storeVersion}')));
        expect(result, isNot(contains('{localVersion}')));
      });

      test('replaces placeholders in banner message', () {
        const s = UpdateStrings();
        final result = s.resolve(s.bannerMessage, '3.0.0', '1.5.0');
        expect(result, contains('3.0.0'));
        expect(result, isNot(contains('{storeVersion}')));
      });

      test('replaces placeholders in block screen message', () {
        const s = UpdateStrings();
        final result = s.resolve(s.blockScreenMessage, '4.0.0', '2.0.0');
        expect(result, contains('4.0.0'));
        expect(result, contains('2.0.0'));
      });

      test('handles string with no placeholders', () {
        const s = UpdateStrings();
        final result = s.resolve('No placeholders here', '2.0.0', '1.0.0');
        expect(result, equals('No placeholders here'));
      });

      test('works with Arabic strings', () {
        final s = UpdateStrings.arabic();
        final result = s.resolve(s.message, '2.0.0', '1.0.0');
        expect(result, contains('2.0.0'));
        expect(result, contains('1.0.0'));
        expect(result, isNot(contains('{storeVersion}')));
      });
    });

    test('custom strings override individual fields', () {
      const s = UpdateStrings(
        title: 'My Custom Title',
        updateButtonText: 'Go!',
      );
      expect(s.title, equals('My Custom Title'));
      expect(s.updateButtonText, equals('Go!'));
      // Other fields keep defaults
      expect(s.laterButtonText, equals('Later'));
      expect(s.blockScreenTitle, equals('Update Required'));
    });
  });
}
