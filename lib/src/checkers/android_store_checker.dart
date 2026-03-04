import 'package:http/http.dart' as http;

import 'ios_store_checker.dart' show StoreInfo;

/// Fetches the latest app version from the Google Play Store by
/// scraping the store listing HTML page.
///
/// No official API exists for this, so the package parses version
/// information from the HTML — the same approach used by other
/// popular Flutter packages.
class AndroidStoreChecker {
  final http.Client _client;

  /// Optional custom HTTP headers for the store request.
  final Map<String, String>? headers;

  AndroidStoreChecker({http.Client? client, this.headers})
      : _client = client ?? http.Client();

  /// Looks up the app by [packageName] on the Google Play Store.
  ///
  /// Returns a [StoreInfo] with the store version and store URL,
  /// or `null` if the app is not found or the request fails.
  Future<StoreInfo?> check({required String packageName}) async {
    try {
      final url = Uri.parse(
        'https://play.google.com/store/apps/details?id=$packageName&hl=en',
      );

      // Merge custom headers with the required User-Agent
      final mergedHeaders = <String, String>{
        'User-Agent': 'Mozilla/5.0',
        ...?headers,
      };

      final response = await _client.get(
        url,
        headers: mergedHeaders,
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) return null;

      final version = _parseVersion(response.body);
      if (version == null) return null;

      // Extract "What's new" text if available
      final releaseNotes = _parseReleaseNotes(response.body);

      return StoreInfo(
        version: version,
        releaseNotes: releaseNotes,
        storeUrl: url.toString(),
      );
    } catch (e) {
      // Network error, timeout, parse error — fail silently
      return null;
    }
  }

  /// Attempts multiple regex patterns to extract the version string
  /// from the Play Store HTML. Google frequently changes the page
  /// structure, so we try several known patterns.
  String? _parseVersion(String html) {
    // Pattern 1: Version string in JSON-LD or structured data
    // Looks for patterns like [[[\"1.5.0\"]]]
    final patterns = <RegExp>[
      // Current version in AF_initDataCallback
      RegExp(r'\[\[\[\"(\d+\.\d+\.?\d*)\"\]\]'),
      // Version in meta tag or script data
      RegExp(r'Current Version.*?>([\d.]+)<'),
      // Generic version pattern in structured data
      RegExp(r'"softwareVersion"\s*:\s*"([\d.]+)"'),
      // Fallback: version-like strings near "Current Version" text
      RegExp(r'Current Version<.*?>([\d.]+)', dotAll: true),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(html);
      if (match != null && match.group(1) != null) {
        return match.group(1);
      }
    }

    return null;
  }

  /// Attempts to extract "What's new" / release notes from the HTML.
  String? _parseReleaseNotes(String html) {
    try {
      final pattern = RegExp(
        r'What&#39;s new.*?<div[^>]*>(.*?)</div>',
        dotAll: true,
      );
      final match = pattern.firstMatch(html);
      if (match != null) {
        // Strip HTML tags and decode entities
        var text = match.group(1) ?? '';
        text = text.replaceAll(RegExp(r'<[^>]+>'), '');
        text = text.replaceAll('&#39;', "'");
        text = text.replaceAll('&amp;', '&');
        text = text.replaceAll('&quot;', '"');
        text = text.trim();
        return text.isNotEmpty ? text : null;
      }
    } catch (_) {
      // Parsing failed — release notes are optional
    }
    return null;
  }
}
