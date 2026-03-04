import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../checkers/android_store_checker.dart';
import '../checkers/ios_store_checker.dart';
import '../models/check_frequency.dart';
import '../models/update_mode.dart';
import '../models/update_strings.dart';
import '../models/version_check_result.dart';
import 'frequency_guard.dart';
import 'version_comparator.dart';

/// Main entry point for the version_gate package.
///
/// Checks whether a newer version of the app is available on the
/// App Store (iOS) or Google Play Store (Android), respecting the
/// configured [checkFrequency].
///
/// ## Zero-config usage
/// ```dart
/// final result = await VersionGate().check();
/// if (result != null && result.hasUpdate) {
///   // Show your UI here
/// }
/// ```
///
/// ## Full configuration
/// ```dart
/// final result = await VersionGate(
///   checkFrequency: CheckFrequency.oncePerWeek,
///   updateMode: UpdateMode.forced,
///   minimumVersion: '2.0.0',
///   headers: {'Authorization': 'Bearer token'},
///   strings: UpdateStrings.arabic(),
///   onUpdateAvailable: (result) => analytics.track('update_available'),
///   onNoUpdate: (result) => analytics.track('up_to_date'),
///   onError: (error, result) => analytics.track('check_failed'),
///   packageIdOverride: 'com.production.appid',
///   countryCode: 'sa',
/// ).check();
/// ```
class VersionGate {
  /// How often to check for updates. Defaults to once daily.
  final CheckFrequency checkFrequency;

  /// How the update prompt should behave. Passed through to the result.
  final UpdateMode updateMode;

  /// Override the package/bundle ID used for the store lookup.
  ///
  /// Only needed when the store listing uses a different ID than the
  /// locally installed app (e.g., white-label apps, .dev suffixes).
  /// 99% of apps never need this.
  final String? packageIdOverride;

  /// iTunes country code for the App Store lookup. Defaults to "us".
  final String countryCode;

  /// Optional HTTP client for testing.
  final http.Client? httpClient;

  /// Custom HTTP headers for store API requests.
  ///
  /// Useful when behind corporate proxies or CDNs that require
  /// authentication headers. For Android, these are merged with
  /// the required User-Agent header.
  final Map<String, String>? headers;

  /// Minimum required app version.
  ///
  /// If the installed version is older than [minimumVersion], the
  /// result's [UpdateMode] is automatically overridden to [UpdateMode.forced],
  /// regardless of the configured [updateMode]. This lets you keep
  /// `updateMode: UpdateMode.optional` for most users while forcing
  /// updates for critically outdated versions.
  ///
  /// ```dart
  /// VersionGate(
  ///   updateMode: UpdateMode.optional,
  ///   minimumVersion: '2.0.0', // anything below 2.0.0 becomes forced
  /// )
  /// ```
  final String? minimumVersion;

  /// Localized text for the built-in update widgets.
  ///
  /// Pass an [UpdateStrings] instance (or use a factory like
  /// `UpdateStrings.arabic()`) to display the dialog, banner, and
  /// block screen in a different language.
  final UpdateStrings? strings;

  /// Called when a newer version is available in the store.
  ///
  /// Useful for analytics tracking. Only fires when a check actually
  /// runs (not when the frequency guard blocks it).
  final void Function(VersionCheckResult result)? onUpdateAvailable;

  /// Called when the app is already up to date.
  ///
  /// Only fires when a check actually runs (not when the frequency
  /// guard blocks it).
  final void Function(VersionCheckResult result)? onNoUpdate;

  /// Called when the version check encounters an error.
  ///
  /// The [error] string describes what went wrong. The [result] still
  /// contains `hasUpdate: false` so the app can continue normally.
  final void Function(String error, VersionCheckResult result)? onError;

  VersionGate({
    this.checkFrequency = CheckFrequency.onceDaily,
    this.updateMode = UpdateMode.optional,
    this.packageIdOverride,
    this.countryCode = 'us',
    this.httpClient,
    this.headers,
    this.minimumVersion,
    this.strings,
    this.onUpdateAvailable,
    this.onNoUpdate,
    this.onError,
  });

  /// Checks for an available update.
  ///
  /// Returns a [VersionCheckResult] if the check was performed, or
  /// `null` if the frequency guard determined that a check was not
  /// needed (e.g., already checked today).
  ///
  /// This method never throws. All errors are caught internally and
  /// returned as a result with `hasUpdate: false` and an `error` field.
  Future<VersionCheckResult?> check() async {
    try {
      // 1. Check frequency guard
      final guard = FrequencyGuard(frequency: checkFrequency);
      if (!await guard.shouldCheck()) {
        return null; // Already checked within the configured period
      }

      // 2. Get local package info
      final packageInfo = await PackageInfo.fromPlatform();
      final localVersion = packageInfo.version;
      final packageName = packageIdOverride ?? packageInfo.packageName;

      // 3. Fetch store version
      StoreInfo? storeInfo;

      if (Platform.isIOS) {
        storeInfo = await IosStoreChecker(
          client: httpClient,
          headers: headers,
        ).check(
          bundleId: packageName,
          countryCode: countryCode,
        );
      } else if (Platform.isAndroid) {
        storeInfo = await AndroidStoreChecker(
          client: httpClient,
          headers: headers,
        ).check(
          packageName: packageName,
        );
      } else {
        // Unsupported platform
        final result = VersionCheckResult.noUpdate(
          localVersion: localVersion,
          updateMode: updateMode,
          strings: strings,
          error: 'Unsupported platform',
        );
        onError?.call('Unsupported platform', result);
        return result;
      }

      if (storeInfo == null) {
        // API call failed — don't save timestamp so it retries next launch
        final result = VersionCheckResult.noUpdate(
          localVersion: localVersion,
          updateMode: updateMode,
          strings: strings,
          error: 'Could not fetch store version',
        );
        onError?.call('Could not fetch store version', result);
        return result;
      }

      // 4. Save timestamp AFTER successful API call
      await guard.recordCheck();

      // 5. Compare versions
      const comparator = VersionComparator();
      final hasUpdate = comparator.isNewer(
        storeInfo.version,
        localVersion,
      );

      // 6. Determine effective update mode (minimum version enforcement)
      var effectiveMode = updateMode;
      if (minimumVersion != null && minimumVersion!.isNotEmpty) {
        final belowMinimum = comparator.isNewer(minimumVersion!, localVersion);
        if (belowMinimum) {
          effectiveMode = UpdateMode.forced;
        }
      }

      final result = VersionCheckResult(
        hasUpdate: hasUpdate,
        localVersion: localVersion,
        storeVersion: storeInfo.version,
        releaseNotes: storeInfo.releaseNotes,
        storeUrl: storeInfo.storeUrl,
        updateMode: effectiveMode,
        lastChecked: DateTime.now(),
        strings: strings,
      );

      // 7. Fire callbacks
      if (hasUpdate) {
        onUpdateAvailable?.call(result);
      } else {
        onNoUpdate?.call(result);
      }

      return result;
    } catch (e) {
      // Catch-all safety net — the check should never crash the app
      debugPrint('version_gate: Unexpected error during check: $e');
      final result = VersionCheckResult.noUpdate(
        localVersion: 'unknown',
        updateMode: updateMode,
        strings: strings,
        error: e.toString(),
      );
      onError?.call(e.toString(), result);
      return result;
    }
  }
}
