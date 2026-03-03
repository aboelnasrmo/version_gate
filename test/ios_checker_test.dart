import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:version_gate/version_gate.dart';

void main() {
  group('IosStoreChecker', () {
    test('returns store info for valid response', () async {
      final client = MockClient((request) async {
        expect(request.url.toString(),
            contains('itunes.apple.com/lookup'));
        expect(request.url.queryParameters['bundleId'],
            equals('com.test.app'));
        expect(request.url.queryParameters['country'], equals('us'));

        return http.Response(
          jsonEncode({
            'resultCount': 1,
            'results': [
              {
                'version': '2.0.0',
                'releaseNotes': 'Bug fixes and improvements',
                'trackViewUrl': 'https://apps.apple.com/app/id123',
              }
            ],
          }),
          200,
        );
      });

      final checker = IosStoreChecker(client: client);
      final result = await checker.check(bundleId: 'com.test.app');

      expect(result, isNotNull);
      expect(result!.version, equals('2.0.0'));
      expect(result.releaseNotes, equals('Bug fixes and improvements'));
      expect(result.storeUrl, equals('https://apps.apple.com/app/id123'));
    });

    test('returns null for empty results', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'resultCount': 0, 'results': []}),
          200,
        );
      });

      final checker = IosStoreChecker(client: client);
      final result = await checker.check(bundleId: 'com.nonexistent.app');

      expect(result, isNull);
    });

    test('returns null for HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final checker = IosStoreChecker(client: client);
      final result = await checker.check(bundleId: 'com.test.app');

      expect(result, isNull);
    });

    test('returns null for network error', () async {
      final client = MockClient((request) async {
        throw Exception('Network error');
      });

      final checker = IosStoreChecker(client: client);
      final result = await checker.check(bundleId: 'com.test.app');

      expect(result, isNull);
    });

    test('returns null for malformed JSON', () async {
      final client = MockClient((request) async {
        return http.Response('not json', 200);
      });

      final checker = IosStoreChecker(client: client);
      final result = await checker.check(bundleId: 'com.test.app');

      expect(result, isNull);
    });

    test('uses custom country code', () async {
      String? capturedCountry;
      final client = MockClient((request) async {
        capturedCountry = request.url.queryParameters['country'];
        return http.Response(
          jsonEncode({
            'resultCount': 1,
            'results': [
              {
                'version': '1.0.0',
                'trackViewUrl': 'https://apps.apple.com/sa/app/id123',
              }
            ],
          }),
          200,
        );
      });

      final checker = IosStoreChecker(client: client);
      await checker.check(bundleId: 'com.test.app', countryCode: 'sa');

      expect(capturedCountry, equals('sa'));
    });

    test('handles missing releaseNotes gracefully', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'resultCount': 1,
            'results': [
              {
                'version': '1.5.0',
                'trackViewUrl': 'https://apps.apple.com/app/id123',
              }
            ],
          }),
          200,
        );
      });

      final checker = IosStoreChecker(client: client);
      final result = await checker.check(bundleId: 'com.test.app');

      expect(result, isNotNull);
      expect(result!.version, equals('1.5.0'));
      expect(result.releaseNotes, isNull);
    });
  });
}
