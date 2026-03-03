import 'package:flutter/material.dart';

import '../models/update_mode.dart';
import '../models/version_check_result.dart';

/// A built-in Material dialog for notifying the user about an available update.
///
/// Supports customizable title, message, button text, and optional
/// release notes display. In [UpdateMode.forced], the "Later" button
/// is hidden and the dialog cannot be dismissed.
class UpdateDialog extends StatelessWidget {
  final VersionCheckResult result;
  final String? title;
  final String? message;
  final String? updateButtonText;
  final String? laterButtonText;
  final bool showReleaseNotes;

  const UpdateDialog({
    super.key,
    required this.result,
    this.title,
    this.message,
    this.updateButtonText,
    this.laterButtonText,
    this.showReleaseNotes = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isForced = result.updateMode == UpdateMode.forced;
    final effectiveLaterText = isForced ? null : (laterButtonText ?? 'Later');

    return PopScope(
      canPop: !isForced,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.system_update, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title ?? 'Update Available',
                style: theme.textTheme.titleLarge,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message ??
                  'Version ${result.storeVersion} is now available. '
                      'You are using version ${result.localVersion}.',
              style: theme.textTheme.bodyMedium,
            ),
            if (showReleaseNotes &&
                result.releaseNotes != null &&
                result.releaseNotes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                "What's new:",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(maxHeight: 150),
                child: SingleChildScrollView(
                  child: Text(
                    result.releaseNotes!,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (effectiveLaterText != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(effectiveLaterText),
            ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              result.openStore();
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(updateButtonText ?? 'Update Now'),
          ),
        ],
      ),
    );
  }
}
