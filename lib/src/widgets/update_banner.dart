import 'package:flutter/material.dart';

import '../models/update_strings.dart';
import '../models/version_check_result.dart';

/// A persistent banner widget for the "flexible" update mode.
///
/// Displays at the top or bottom of the screen, showing a message
/// about the available update with an "Update" button and an optional
/// dismiss (X) button.
///
/// Text defaults are resolved in this order:
/// 1. Explicit parameter (e.g., `message`)
/// 2. Localized string from `result.strings`
/// 3. Hardcoded English fallback
///
/// Usage:
/// ```dart
/// UpdateBanner(
///   result: result,
///   onDismiss: () => setState(() => showBanner = false),
/// )
/// ```
class UpdateBanner extends StatelessWidget {
  final VersionCheckResult result;
  final VoidCallback? onDismiss;
  final String? message;
  final String? updateButtonText;
  final bool showDismiss;

  const UpdateBanner({
    super.key,
    required this.result,
    this.onDismiss,
    this.message,
    this.updateButtonText,
    this.showDismiss = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = result.strings ?? const UpdateStrings();

    final effectiveMessage = message ??
        s.resolve(s.bannerMessage, result.storeVersion, result.localVersion);
    final effectiveUpdateText = updateButtonText ?? s.updateButtonText;
    final effectiveDismissText = s.dismissButtonText;

    return MaterialBanner(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        Icons.system_update,
        color: theme.colorScheme.primary,
      ),
      content: Text(
        effectiveMessage,
        style: theme.textTheme.bodyMedium,
      ),
      actions: [
        if (showDismiss)
          TextButton(
            onPressed: onDismiss,
            child: Text(effectiveDismissText),
          ),
        FilledButton(
          onPressed: () => result.openStore(),
          child: Text(effectiveUpdateText),
        ),
      ],
    );
  }
}
