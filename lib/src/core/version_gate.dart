import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../checkers/android_store_checker.dart';
import '../checkers/ios_store_checker.dart';
import '../models/check_frequency.dart';
import '../models/update_mode.dart';
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

  VersionGate({
    this.checkFrequency = CheckFrequency.onceDaily,
    this.updateMode = UpdateMode.optional,
    this.packageIdOverride,
    this.countryCode = 'us',
    this.httpClient,
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
        storeInfo = await IosStoreChecker(client: httpClient).check(
          bundleId: packageName,
          countryCode: countryCode,
        );
      } else if (Platform.isAndroid) {
        storeInfo = await AndroidStoreChecker(client: httpClient).check(
          packageName: packageName,
        );
      } else {
        // Unsupported platform
        return VersionCheckResult.noUpdate(
          localVersion: localVersion,
          updateMode: updateMode,
          error: 'Unsupported platform',
        );
      }

      if (storeInfo == null) {
        // API call failed — don't save timestamp so it retries next launch
        return VersionCheckResult.noUpdate(
          localVersion: localVersion,
          updateMode: updateMode,
          error: 'Could not fetch store version',
        );
      }

      // 4. Save timestamp AFTER successful API call
      await guard.recordCheck();

      // 5. Compare versions
      const comparator = VersionComparator();
      final hasUpdate = comparator.isNewer(
        storeInfo.version,
        localVersion,
      );

      return VersionCheckResult(
        hasUpdate: hasUpdate,
        localVersion: localVersion,
        storeVersion: storeInfo.version,
        releaseNotes: storeInfo.releaseNotes,
        storeUrl: storeInfo.storeUrl,
        updateMode: updateMode,
        lastChecked: DateTime.now(),
      );
    } catch (e) {
      // Catch-all safety net — the check should never crash the app
      debugPrint('version_gate: Unexpected error during check: $e');
      return VersionCheckResult.noUpdate(
        localVersion: 'unknown',
        updateMode: updateMode,
        error: e.toString(),
      );
    }
  }
}
