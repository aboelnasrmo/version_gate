import 'package:flutter/material.dart';

import '../models/version_check_result.dart';

/// A persistent banner widget for the "flexible" update mode.
///
/// Displays at the top or bottom of the screen, showing a message
/// about the available update with an "Update" button and an optional
/// dismiss (X) button.
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

    return MaterialBanner(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        Icons.system_update,
        color: theme.colorScheme.primary,
      ),
      content: Text(
        message ??
            'Version ${result.storeVersion} is available. '
                'Tap Update to get the latest features.',
        style: theme.textTheme.bodyMedium,
      ),
      actions: [
        if (showDismiss)
          TextButton(
            onPressed: onDismiss,
            child: const Text('Dismiss'),
          ),
        FilledButton(
          onPressed: () => result.openStore(),
          child: Text(updateButtonText ?? 'Update'),
        ),
      ],
    );
  }
}
