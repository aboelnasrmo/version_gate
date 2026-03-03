// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:version_gate/version_gate.dart';

void main() {
  runApp(const VersionGateExampleApp());
}

/// Example app demonstrating all version_gate usage patterns.
///
/// Run this app on a real device or emulator with a published app
/// to see live version checking. On debug builds, the check will
/// likely return hasUpdate: false (app not in store).
class VersionGateExampleApp extends StatelessWidget {
  const VersionGateExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'version_gate Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _status = 'Ready — tap a pattern to check for updates';
  bool _isLoading = false;
  bool _showBanner = false;
  VersionCheckResult? _lastResult;

  // ═══════════════════════════════════════════════════════════════════
  // Pattern A: Silent Check + Custom UI
  //
  // Developer handles the UI themselves. Maximum flexibility.
  // ═══════════════════════════════════════════════════════════════════
  Future<void> _patternA() async {
    _setLoading(true);

    final result = await VersionGate(
      checkFrequency: CheckFrequency.always, // Always for demo purposes
      updateMode: UpdateMode.optional,
    ).check();

    if (!mounted) return;
    _setLoading(false);

    if (result == null) {
      _setStatus('⏭️ Skipped — frequency guard blocked this check');
      return;
    }

    _lastResult = result;

    if (result.hasUpdate) {
      _setStatus('🆕 Update found: v${result.storeVersion}');
      _showCustomDialog(result);
    } else {
      _setStatus('✅ Up to date — v${result.localVersion}');
    }
  }

  void _showCustomDialog(VersionCheckResult result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.rocket_launch, size: 40),
        title: const Text('New Version Available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Version ${result.storeVersion} is ready to install.'),
            if (result.releaseNotes != null) ...[
              const SizedBox(height: 12),
              Text(
                result.releaseNotes!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              result.openStore();
            },
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Pattern B: Built-in Dialog (One-Liner)
  //
  // Uses version_gate's built-in Material dialog.
  // ═══════════════════════════════════════════════════════════════════
  Future<void> _patternB() async {
    _setLoading(true);

    final result = await VersionGate(
      checkFrequency: CheckFrequency.always,
      updateMode: UpdateMode.optional,
    ).check();

    if (!mounted) return;
    _setLoading(false);

    if (result == null) {
      _setStatus('⏭️ Skipped — frequency guard blocked this check');
      return;
    }

    _lastResult = result;

    if (result.hasUpdate) {
      _setStatus('🆕 Update found — showing built-in dialog');
      result.showBuiltInDialog(
        context,
        title: 'Time to Update!',
        message: 'Version ${result.storeVersion} includes new features.',
        updateButtonText: 'Get It Now',
        laterButtonText: 'Not Now',
        showReleaseNotes: true,
      );
    } else {
      _setStatus('✅ Up to date — v${result.localVersion}');
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Pattern C: Forced Update (Block App)
  //
  // Full-screen blocker — user MUST update.
  // ═══════════════════════════════════════════════════════════════════
  Future<void> _patternC() async {
    _setLoading(true);

    final result = await VersionGate(
      checkFrequency: CheckFrequency.always,
      updateMode: UpdateMode.forced,
    ).check();

    if (!mounted) return;
    _setLoading(false);

    if (result == null) {
      _setStatus('⏭️ Skipped — frequency guard blocked this check');
      return;
    }

    _lastResult = result;

    if (result.hasUpdate) {
      _setStatus('🚨 Critical update — blocking app');
      result.showBuiltInDialog(context);
      // Pushes UpdateBlockScreen — no way to dismiss
    } else {
      _setStatus('✅ Up to date — v${result.localVersion}');
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Pattern D: Flexible Banner
  //
  // Persistent banner — app still usable.
  // ═══════════════════════════════════════════════════════════════════
  Future<void> _patternD() async {
    _setLoading(true);

    final result = await VersionGate(
      checkFrequency: CheckFrequency.always,
      updateMode: UpdateMode.flexible,
    ).check();

    if (!mounted) return;
    _setLoading(false);

    if (result == null) {
      _setStatus('⏭️ Skipped — frequency guard blocked this check');
      return;
    }

    _lastResult = result;

    if (result.hasUpdate) {
      setState(() => _showBanner = true);
      _setStatus('📢 Update available — banner shown above');
    } else {
      _setStatus('✅ Up to date — v${result.localVersion}');
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════════════

  void _setStatus(String status) {
    if (mounted) setState(() => _status = status);
    print('version_gate: $status');
  }

  void _setLoading(bool loading) {
    if (mounted) setState(() => _isLoading = loading);
  }

  // ═══════════════════════════════════════════════════════════════════
  // UI
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('version_gate'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Banner (Pattern D) ──
          if (_showBanner && _lastResult != null)
            UpdateBanner(
              result: _lastResult!,
              onDismiss: () => setState(() => _showBanner = false),
            ),

          // ── Main Content ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Status Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        if (_isLoading)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          const Icon(Icons.info_outline, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _status,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Section Header
                Text(
                  'Usage Patterns',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Each button demonstrates a different integration pattern.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // Pattern Buttons
                _PatternCard(
                  icon: Icons.build_outlined,
                  title: 'Pattern A: Custom UI',
                  subtitle: 'You handle the UI — maximum flexibility',
                  onTap: _isLoading ? null : _patternA,
                ),
                _PatternCard(
                  icon: Icons.chat_bubble_outline,
                  title: 'Pattern B: Built-in Dialog',
                  subtitle: 'Drop-in Material dialog — one line',
                  onTap: _isLoading ? null : _patternB,
                ),
                _PatternCard(
                  icon: Icons.block_outlined,
                  title: 'Pattern C: Forced Update',
                  subtitle: 'Blocks the app until user updates',
                  onTap: _isLoading ? null : _patternC,
                ),
                _PatternCard(
                  icon: Icons.flag_outlined,
                  title: 'Pattern D: Banner',
                  subtitle: 'Persistent banner — app still usable',
                  onTap: _isLoading ? null : _patternD,
                ),

                // Result Details
                if (_lastResult != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Last Check Result',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DetailRow('Has Update', '${_lastResult!.hasUpdate}'),
                          _DetailRow('Local Version', _lastResult!.localVersion),
                          _DetailRow('Store Version', _lastResult!.storeVersion),
                          _DetailRow('Update Mode', _lastResult!.updateMode.name),
                          _DetailRow('Store URL', _lastResult!.storeUrl.isEmpty ? '—' : _lastResult!.storeUrl),
                          if (_lastResult!.error != null)
                            _DetailRow('Error', _lastResult!.error!),
                          if (_lastResult!.releaseNotes != null)
                            _DetailRow('Release Notes', _lastResult!.releaseNotes!),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Reusable Widgets
// ═══════════════════════════════════════════════════════════════════════

class _PatternCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _PatternCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
