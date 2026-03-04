import 'package:flutter/material.dart';

import '../models/update_strings.dart';
import '../models/version_check_result.dart';

/// A full-screen widget that blocks the app for forced updates.
///
/// Replaces the entire app content, showing version info, optional
/// release notes, and a single "Go to Store" button. The Android
/// back button is intercepted — the user cannot dismiss this screen.
///
/// Text defaults are resolved in this order:
/// 1. Explicit parameter (e.g., `title`)
/// 2. Localized string from `result.strings`
/// 3. Hardcoded English fallback
class UpdateBlockScreen extends StatelessWidget {
  final VersionCheckResult result;
  final String? title;
  final String? message;
  final String? buttonText;

  const UpdateBlockScreen({
    super.key,
    required this.result,
    this.title,
    this.message,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = result.strings ?? const UpdateStrings();

    final effectiveTitle = title ?? s.blockScreenTitle;
    final effectiveMessage = message ??
        s.resolve(
            s.blockScreenMessage, result.storeVersion, result.localVersion);
    final effectiveButtonText = buttonText ?? s.blockScreenButtonText;
    final effectiveReleaseNotesTitle = s.releaseNotesTitle;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.system_update,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    effectiveTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    effectiveMessage,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (result.releaseNotes != null &&
                      result.releaseNotes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(maxHeight: 180),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              effectiveReleaseNotesTitle,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              result.releaseNotes!,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () => result.openStore(),
                      icon: const Icon(Icons.open_in_new),
                      label: Text(
                        effectiveButtonText,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
