import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'update_mode.dart';
import 'update_strings.dart';
import '../widgets/update_dialog.dart';
import '../widgets/update_block_screen.dart';

/// The result of a version check performed by [VersionGate.check()].
///
/// Returns `null` from `check()` only when the frequency guard skips the
/// check (e.g., already checked today).
class VersionCheckResult {
  /// Whether a newer version is available in the store.
  final bool hasUpdate;

  /// The version currently installed on the device (e.g., "1.2.0").
  final String localVersion;

  /// The latest version available in the store (e.g., "1.5.0").
  final String storeVersion;

  /// Release notes / "What's new" text from the store, if available.
  final String? releaseNotes;

  /// Direct link to the App Store or Play Store listing.
  final String storeUrl;

  /// The update mode set in [VersionGate].
  final UpdateMode updateMode;

  /// Timestamp of this check.
  final DateTime lastChecked;

  /// Error message if the check failed. `null` on success.
  final String? error;

  /// Localized strings for the built-in widgets.
  ///
  /// When `null`, widgets fall back to their English defaults.
  final UpdateStrings? strings;

  const VersionCheckResult({
    required this.hasUpdate,
    required this.localVersion,
    required this.storeVersion,
    this.releaseNotes,
    required this.storeUrl,
    required this.updateMode,
    required this.lastChecked,
    this.error,
    this.strings,
  });

  /// Creates a "no update" result, typically used when the check fails.
  factory VersionCheckResult.noUpdate({
    required String localVersion,
    required UpdateMode updateMode,
    UpdateStrings? strings,
    String? error,
  }) {
    return VersionCheckResult(
      hasUpdate: false,
      localVersion: localVersion,
      storeVersion: localVersion,
      storeUrl: '',
      updateMode: updateMode,
      lastChecked: DateTime.now(),
      error: error,
      strings: strings,
    );
  }

  /// Shows the built-in update dialog.
  ///
  /// For [UpdateMode.forced], the dialog is not dismissible and the
  /// "Later" button is hidden. For [UpdateMode.optional], both buttons
  /// are shown.
  ///
  /// Text defaults are pulled from [strings] when available. Any
  /// explicit parameter overrides the localized string.
  ///
  /// ```dart
  /// result.showBuiltInDialog(
  ///   context,
  ///   title: 'New Version Available',
  ///   message: 'Version ${result.storeVersion} is now available.',
  ///   updateButtonText: 'Update Now',
  ///   laterButtonText: 'Later',
  ///   showReleaseNotes: true,
  /// );
  /// ```
  void showBuiltInDialog(
    BuildContext context, {
    String? title,
    String? message,
    String? updateButtonText,
    String? laterButtonText,
    bool showReleaseNotes = true,
  }) {
    if (updateMode == UpdateMode.forced) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => UpdateBlockScreen(
            result: this,
            title: title,
            message: message,
            buttonText: updateButtonText,
          ),
        ),
        (_) => false,
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: updateMode != UpdateMode.forced,
      builder: (_) => UpdateDialog(
        result: this,
        title: title,
        message: message,
        updateButtonText: updateButtonText,
        laterButtonText: laterButtonText,
        showReleaseNotes: showReleaseNotes,
      ),
    );
  }

  /// Opens the store listing URL in the platform browser.
  Future<void> openStore() async {
    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  String toString() =>
      'VersionCheckResult(hasUpdate: $hasUpdate, local: $localVersion, store: $storeVersion)';
}
