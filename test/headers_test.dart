import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:version_gate/version_gate.dart';

void main() {
  group('Custom HTTP Headers', () {
    group('IosStoreChecker', () {
      test('sends custom headers in request', () async {
        Map<String, String>? capturedHeaders;
        final client = MockClient((request) async {
          capturedHeaders = request.headers;
          return http.Response(
            jsonEncode({
              'resultCount': 1,
              'results': [
                {
                  'version': '2.0.0',
                  'trackViewUrl': 'https://apps.apple.com/app/id123',
                }
              ],
            }),
            200,
          );
        });

        final checker = IosStoreChecker(
          client: client,
          headers: {'Authorization': 'Bearer test-token', 'X-Custom': 'value'},
        );
        await checker.check(bundleId: 'com.test.app');

        expect(capturedHeaders, isNotNull);
        expect(capturedHeaders!['Authorization'], equals('Bearer test-token'));
        expect(capturedHeaders!['X-Custom'], equals('value'));
      });

      test('works without custom headers', () async {
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'resultCount': 1,
              'results': [
                {
                  'version': '2.0.0',
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
      });
    });

    group('AndroidStoreChecker', () {
      test('merges custom headers with User-Agent', () async {
        Map<String, String>? capturedHeaders;
        final client = MockClient((request) async {
          capturedHeaders = request.headers;
          return http.Response(
            '<html>[[["3.0.0"]]]</html>',
            200,
          );
        });

        final checker = AndroidStoreChecker(
          client: client,
          headers: {'Authorization': 'Bearer android-token'},
        );
        await checker.check(packageName: 'com.test.app');

        expect(capturedHeaders, isNotNull);
        expect(capturedHeaders!['User-Agent'], equals('Mozilla/5.0'));
        expect(
            capturedHeaders!['Authorization'], equals('Bearer android-token'));
      });

      test('custom User-Agent overrides default', () async {
        Map<String, String>? capturedHeaders;
        final client = MockClient((request) async {
          capturedHeaders = request.headers;
          return http.Response(
            '<html>[[["1.0.0"]]]</html>',
            200,
          );
        });

        final checker = AndroidStoreChecker(
          client: client,
          headers: {'User-Agent': 'CustomAgent/1.0'},
        );
        await checker.check(packageName: 'com.test.app');

        expect(capturedHeaders, isNotNull);
        expect(capturedHeaders!['User-Agent'], equals('CustomAgent/1.0'));
      });

      test('works without custom headers', () async {
        Map<String, String>? capturedHeaders;
        final client = MockClient((request) async {
          capturedHeaders = request.headers;
          return http.Response(
            '<html>[[["1.0.0"]]]</html>',
            200,
          );
        });

        final checker = AndroidStoreChecker(client: client);
        await checker.check(packageName: 'com.test.app');

        expect(capturedHeaders, isNotNull);
        expect(capturedHeaders!['User-Agent'], equals('Mozilla/5.0'));
      });
    });
  });
}
