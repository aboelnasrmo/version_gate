import 'dart:convert';

import 'package:http/http.dart' as http;

/// Fetches the latest app version from the Apple App Store using the
/// iTunes Lookup API.
///
/// The API is free, requires no authentication, and returns clean JSON.
class IosStoreChecker {
  final http.Client _client;

  IosStoreChecker({http.Client? client}) : _client = client ?? http.Client();

  /// Looks up the app by [bundleId] in the iTunes store for the given
  /// [countryCode] (defaults to "us").
  ///
  /// Returns a [StoreInfo] with the store version, release notes, and
  /// store URL, or `null` if the app is not found or the request fails.
  Future<StoreInfo?> check({
    required String bundleId,
    String countryCode = 'us',
  }) async {
    try {
      final url = Uri.parse(
        'https://itunes.apple.com/lookup?bundleId=$bundleId&country=$countryCode',
      );
      final response = await _client.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final resultCount = json['resultCount'] as int? ?? 0;
      if (resultCount == 0) return null;

      final results = json['results'] as List<dynamic>;
      if (results.isEmpty) return null;

      final app = results.first as Map<String, dynamic>;
      final version = app['version'] as String?;
      if (version == null) return null;

      return StoreInfo(
        version: version,
        releaseNotes: app['releaseNotes'] as String?,
        storeUrl: app['trackViewUrl'] as String? ?? '',
      );
    } catch (e) {
      // Network error, timeout, parse error — fail silently
      return null;
    }
  }
}

/// Holds version information retrieved from a store API.
class StoreInfo {
  final String version;
  final String? releaseNotes;
  final String storeUrl;

  const StoreInfo({
    required this.version,
    this.releaseNotes,
    required this.storeUrl,
  });
}
