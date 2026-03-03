import 'package:shared_preferences/shared_preferences.dart';

import '../models/check_frequency.dart';

/// Guards against too-frequent version checks using [SharedPreferences].
///
/// Stores the timestamp of the last successful API call and compares it
/// against the configured [CheckFrequency] to decide whether a new check
/// should run.
class FrequencyGuard {
  static const _key = 'version_gate_last_check';

  final CheckFrequency frequency;

  const FrequencyGuard({required this.frequency});

  /// Returns `true` if enough time has elapsed since the last check.
  Future<bool> shouldCheck() async {
    if (frequency.isAlways) return true;
    if (frequency.isPerSession) return true;

    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(_key);

    if (last == null) return true;

    try {
      final lastDate = DateTime.parse(last);
      final diff = DateTime.now().difference(lastDate);
      return diff.inHours >= frequency.hours;
    } catch (_) {
      // Corrupted timestamp — allow check
      return true;
    }
  }

  /// Records the current time as the last successful check.
  ///
  /// This should be called after a successful API response, not after
  /// showing a dialog, so that failed network calls trigger a retry
  /// on next launch.
  Future<void> recordCheck() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, DateTime.now().toIso8601String());
  }

  /// Clears the stored timestamp, forcing the next check to run.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
