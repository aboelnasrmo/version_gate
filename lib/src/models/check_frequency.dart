/// Defines how often version checks should be performed.
///
/// The frequency guard uses this to decide whether to skip the check
/// based on when the last successful check occurred.
class CheckFrequency {
  /// Check once every 24 hours (default).
  static const CheckFrequency onceDaily = CheckFrequency._(24);

  /// Check on every cold app launch (no caching).
  static const CheckFrequency oncePerSession = CheckFrequency._(0);

  /// Check once every 7 days.
  static const CheckFrequency oncePerWeek = CheckFrequency._(168);

  /// Always check — intended for development/testing only.
  static const CheckFrequency always = CheckFrequency._(-1);

  /// The number of hours between checks.
  ///
  /// A value of -1 means always check. A value of 0 means once per session
  /// (no persistence — always checks on cold launch).
  final int hours;

  const CheckFrequency._(this.hours);

  /// Create a custom frequency with the specified number of [hours].
  ///
  /// ```dart
  /// CheckFrequency.custom(hours: 12) // Check every 12 hours
  /// ```
  const CheckFrequency.custom({required this.hours});

  /// Whether the frequency guard should always allow the check.
  bool get isAlways => hours == -1;

  /// Whether the frequency is session-based (no persistence).
  bool get isPerSession => hours == 0;

  @override
  String toString() => 'CheckFrequency(hours: $hours)';
}
