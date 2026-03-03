import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:version_gate/version_gate.dart';

void main() {
  group('AndroidStoreChecker', () {
    test('parses version from Play Store HTML pattern 1', () async {
      final client = MockClient((request) async {
        expect(request.url.toString(),
            contains('play.google.com/store/apps/details'));
        expect(request.url.queryParameters['id'],
            equals('com.test.app'));

        return http.Response(
          '<html><body>Some content [[["2.1.0"]]] more content</body></html>',
          200,
        );
      });

      final checker = AndroidStoreChecker(client: client);
      final result = await checker.check(packageName: 'com.test.app');

      expect(result, isNotNull);
      expect(result!.version, equals('2.1.0'));
      expect(result.storeUrl, contains('play.google.com'));
    });

    test('parses version from softwareVersion pattern', () async {
      final client = MockClient((request) async {
        return http.Response(
          '<html>"softwareVersion" : "3.0.1"</html>',
          200,
        );
      });

      final checker = AndroidStoreChecker(client: client);
      final result = await checker.check(packageName: 'com.test.app');

      expect(result, isNotNull);
      expect(result!.version, equals('3.0.1'));
    });

    test('returns null for HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final checker = AndroidStoreChecker(client: client);
      final result = await checker.check(packageName: 'com.test.app');

      expect(result, isNull);
    });

    test('returns null for network error', () async {
      final client = MockClient((request) async {
        throw Exception('Network error');
      });

      final checker = AndroidStoreChecker(client: client);
      final result = await checker.check(packageName: 'com.test.app');

      expect(result, isNull);
    });

    test('returns null when version cannot be parsed', () async {
      final client = MockClient((request) async {
        return http.Response(
          '<html><body>No version info here</body></html>',
          200,
        );
      });

      final checker = AndroidStoreChecker(client: client);
      final result = await checker.check(packageName: 'com.test.app');

      expect(result, isNull);
    });

    test('handles two-part version in HTML', () async {
      final client = MockClient((request) async {
        return http.Response(
          '<html><body>[[["1.5"]]] content</body></html>',
          200,
        );
      });

      final checker = AndroidStoreChecker(client: client);
      final result = await checker.check(packageName: 'com.test.app');

      expect(result, isNotNull);
      expect(result!.version, equals('1.5'));
    });
  });
}
