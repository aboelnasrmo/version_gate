/// Defines how the update prompt should behave.
///
/// This is passed through to [VersionCheckResult] and used by built-in
/// widgets to determine dismissibility and layout.
enum UpdateMode {
  /// Show a dismissible dialog or banner. User can tap "Later".
  optional,

  /// Show a persistent banner. App is still usable but the banner remains.
  flexible,

  /// Block the app with a full-screen prompt. User cannot dismiss.
  forced,
}
