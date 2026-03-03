# version_gate

<p align="center">
  <img src="https://raw.githubusercontent.com/aboelnasr/version_gate/main/screenshots/version_gate_demo.gif" alt="version_gate demo" width="300"/>
</p>

<p align="center">
  A lightweight Flutter package that checks for app updates on the <b>App Store</b> and <b>Google Play Store</b> with <b>zero configuration</b>.
</p>

<p align="center">
  <a href="https://pub.dev/packages/version_gate"><img src="https://img.shields.io/pub/v/version_gate.svg" alt="pub package"></a>
  <a href="https://github.com/aboelnasr/version_gate/actions"><img src="https://img.shields.io/github/actions/workflow/status/aboelnasr/version_gate/ci.yml?branch=main" alt="build status"></a>
  <a href="https://pub.dev/packages/version_gate/score"><img src="https://img.shields.io/pub/points/version_gate" alt="pub points"></a>
  <a href="https://pub.dev/packages/version_gate/score"><img src="https://img.shields.io/pub/popularity/version_gate" alt="popularity"></a>
  <a href="https://pub.dev/packages/version_gate/score"><img src="https://img.shields.io/pub/likes/version_gate" alt="likes"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg" alt="Platform"></a>
</p>

---

## Table of Contents

- [Why version\_gate?](#why-version_gate)
- [Features](#features)
- [Screenshots](#screenshots)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage Patterns](#usage-patterns)
  - [Pattern A: Custom UI](#pattern-a-custom-ui)
  - [Pattern B: Built-in Dialog](#pattern-b-built-in-dialog)
  - [Pattern C: Forced Update](#pattern-c-forced-update)
  - [Pattern D: Banner](#pattern-d-banner)
  - [Pattern E: Weekly Check](#pattern-e-weekly-check)
  - [Pattern F: Override Package ID](#pattern-f-override-package-id)
- [Configuration](#configuration)
  - [Check Frequencies](#check-frequencies)
  - [Update Modes](#update-modes)
- [API Reference](#api-reference)
  - [VersionGate](#versiongate)
  - [VersionCheckResult](#versioncheckresult)
- [How It Works](#how-it-works)
- [Comparison with Other Packages](#comparison-with-other-packages)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## Why version_gate?

Two popular packages exist for version checking — `new_version` (broken since 2022, no Dart 3 support) and `upgrader` (overly complex, heavy dependencies, hard to customize UI). **version_gate** was built to be:

- **Zero-config** — reads bundle ID and app version automatically
- **Lightweight** — only 4 dependencies, all Flutter Favorites
- **Customizable** — use built-in widgets or bring your own UI
- **Modern** — built for Dart 3 and Flutter 3.x

---

## Features

- **Zero configuration** — no API keys, no manual bundle IDs
- **Smart frequency guard** — checks once daily (configurable)
- **Three update modes** — optional, flexible, forced
- **Built-in widgets** — dialog, banner, full-screen blocker
- **Custom UI friendly** — get the data, build your own UI
- **Release notes** — shows "What's new" from the store
- **Fail-safe** — never crashes your app, even on network errors
- **Minimal footprint** — 4 lightweight, production-grade dependencies

---

## Screenshots

<p align="center">
  <img src="https://raw.githubusercontent.com/aboelnasr/version_gate/main/screenshots/update_dialog.png" width="250" alt="Update Dialog"/>
  &nbsp;&nbsp;
  <img src="https://raw.githubusercontent.com/aboelnasr/version_gate/main/screenshots/update_block_screen.png" width="250" alt="Forced Update Screen"/>
  &nbsp;&nbsp;
  <img src="https://raw.githubusercontent.com/aboelnasr/version_gate/main/screenshots/update_banner.png" width="250" alt="Update Banner"/>
</p>

<p align="center">
  <em>Left: Optional dialog &nbsp;|&nbsp; Center: Forced update screen &nbsp;|&nbsp; Right: Persistent banner</em>
</p>

---

## Installation

### 1. Add dependency

```yaml
dependencies:
  version_gate: ^1.0.0
```

### 2. Install packages

```bash
flutter pub get
```

### 3. Import

```dart
import 'package:version_gate/version_gate.dart';
```

---

## Quick Start

The simplest possible usage — **3 lines, zero config**:

```dart
final result = await VersionGate().check();

if (result != null && result.hasUpdate) {
  result.showBuiltInDialog(context);
}
```

That's it. The package automatically reads your app's bundle ID and version, checks the store, and shows a Material dialog if an update exists.

---

## Usage Patterns

### Pattern A: Custom UI

Maximum flexibility — handle the result yourself.

```dart
final result = await VersionGate().check();

if (result != null && result.hasUpdate) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Update Available'),
      content: Text('Version ${result.storeVersion} is ready.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Later'),
        ),
        ElevatedButton(
          onPressed: () => result.openStore(),
          child: Text('Update Now'),
        ),
      ],
    ),
  );
}
```

### Pattern B: Built-in Dialog

Drop-in dialog — customize text only.

```dart
final result = await VersionGate().check();

if (result != null && result.hasUpdate) {
  result.showBuiltInDialog(
    context,
    title: 'New Version Available',
    message: 'Version ${result.storeVersion} is now available.',
    updateButtonText: 'Update Now',
    laterButtonText: 'Later',
    showReleaseNotes: true,
  );
}
```

### Pattern C: Forced Update

Block the entire app until the user updates.

```dart
final result = await VersionGate(
  updateMode: UpdateMode.forced,
).check();

if (result != null && result.hasUpdate) {
  result.showBuiltInDialog(context);
  // Shows full-screen blocker — cannot be dismissed
}
```

### Pattern D: Banner

Persistent banner while the user continues using the app.

```dart
final result = await VersionGate(
  updateMode: UpdateMode.flexible,
).check();

if (result != null && result.hasUpdate) {
  // Add to your widget tree:
  UpdateBanner(
    result: result,
    onDismiss: () => setState(() => showBanner = false),
  );
}
```

### Pattern E: Weekly Check

```dart
final result = await VersionGate(
  checkFrequency: CheckFrequency.oncePerWeek,
).check();
```

### Pattern F: Override Package ID

Only needed when the store bundle ID differs from the app's local ID (e.g., white-label apps).

```dart
final result = await VersionGate(
  packageIdOverride: 'com.production.appid',
).check();
```

---

## Configuration

All parameters are **optional**:

```dart
VersionGate(
  checkFrequency: CheckFrequency.onceDaily,    // How often to check
  updateMode: UpdateMode.optional,              // Dialog behavior
  packageIdOverride: 'com.production.appid',    // Override bundle ID
  countryCode: 'us',                            // iTunes region
)
```

### Check Frequencies

| Value | Behavior |
|:------|:---------|
| `CheckFrequency.onceDaily` | Check once every 24 hours **(default)** |
| `CheckFrequency.oncePerSession` | Check on every cold app launch |
| `CheckFrequency.oncePerWeek` | Check once every 7 days |
| `CheckFrequency.always` | Always check — **dev/testing only** |
| `CheckFrequency.custom(hours: 12)` | Check every N hours |

### Update Modes

| Value | Behavior |
|:------|:---------|
| `UpdateMode.optional` | Dismissible dialog — user can tap "Later" **(default)** |
| `UpdateMode.flexible` | Persistent banner — app still usable |
| `UpdateMode.forced` | Full-screen blocker — cannot dismiss |

---

## API Reference

### VersionGate

The main entry point. Create an instance and call `check()`.

```dart
final gate = VersionGate(
  checkFrequency: CheckFrequency.onceDaily,
  updateMode: UpdateMode.optional,
  packageIdOverride: null,
  countryCode: 'us',
);

final result = await gate.check(); // Returns VersionCheckResult?
```

`check()` returns `null` when the frequency guard skips the check (e.g., already checked today).

### VersionCheckResult

| Property | Type | Description |
|:---------|:-----|:------------|
| `hasUpdate` | `bool` | `true` if store version > local version |
| `localVersion` | `String` | Installed version (e.g., `"1.2.0"`) |
| `storeVersion` | `String` | Store version (e.g., `"1.5.0"`) |
| `releaseNotes` | `String?` | "What's new" from the store |
| `storeUrl` | `String` | Direct link to store listing |
| `updateMode` | `UpdateMode` | The mode set in `VersionGate()` |
| `lastChecked` | `DateTime` | Timestamp of this check |
| `error` | `String?` | Error message if check failed |

| Method | Description |
|:-------|:------------|
| `showBuiltInDialog(context, {...})` | Shows the built-in update UI (dialog or block screen) |
| `openStore()` | Opens the store listing in the platform browser |

---

## How It Works

```
App launches
    │
    ▼
Was a check already done today? ──YES──▶ Skip. Return null.
    │
   NO
    │
    ▼
Read local version + package name (automatic via package_info_plus)
    │
    ▼
Detect platform
    │
    ├── iOS ──▶ iTunes Lookup API (JSON) ── free, no auth
    └── Android ──▶ Google Play Store page (HTML parse)
    │
    ▼
Save timestamp to SharedPreferences (only after successful API call)
    │
    ▼
Compare versions (semantic versioning)
    │
    ├── Same ──▶ VersionCheckResult(hasUpdate: false)
    └── Store is newer ──▶ VersionCheckResult(hasUpdate: true)
```

**Key design decisions:**
- Timestamp is saved **after** a successful API response, not after showing a dialog. If the network fails, it retries on next launch.
- The version comparator handles all semver formats: `1.2.3`, `1.2.3+45`, `1.2`, `2.0.0-beta.1`.
- All errors are caught internally. `check()` **never throws** — it returns `hasUpdate: false` with an `error` field on failure.

---

## Comparison with Other Packages

| Feature | **version_gate** | upgrader | new_version |
|:--------|:----------------:|:--------:|:-----------:|
| Zero config (auto bundle ID) | ✅ | ❌ Manual | ❌ Manual |
| Dart 3 / Flutter 3.x | ✅ | ❌ Broken | ⚠️ Issues |
| Once-daily check | ✅ | ✅ | ✅ |
| Custom check frequency | ✅ | ❌ | ❌ |
| Forced update mode | ✅ | ✅ | ❌ |
| Custom UI (bring your own) | ✅ Easy | ❌ Hard | ❌ |
| Built-in dismissible dialog | ✅ | ✅ | ❌ |
| Release notes from store | ✅ | ✅ | ❌ |
| Lightweight dependencies | ✅ (4 pkgs) | ❌ Heavy | ✅ Minimal |
| Active maintenance (2026) | ✅ | ❌ Stale | ❌ Stale |

---

## Troubleshooting

**Q: `check()` always returns `null`.**
The frequency guard is skipping the check. You already checked within the configured period. Use `CheckFrequency.always` for testing, or call `FrequencyGuard.reset()` to clear the stored timestamp.

**Q: `hasUpdate` is always `false` on Android.**
Google may have changed the Play Store HTML structure. File an issue — the parser may need a new regex pattern.

**Q: The app on the store uses a different bundle ID.**
Pass `packageIdOverride: 'com.your.store.id'` to `VersionGate()`.

**Q: I need to check a specific App Store region.**
Pass `countryCode: 'sa'` (or any valid iTunes country code) to `VersionGate()`.

---

## Contributing

Contributions are welcome! Here's how:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please make sure to update tests as appropriate and run `dart pub publish --dry-run` before submitting.

### Reporting Bugs

Found a bug? [Open an issue](https://github.com/aboelnasr/version_gate/issues/new?template=bug_report.md) with:
- Flutter version (`flutter --version`)
- Platform (iOS/Android)
- Steps to reproduce
- Expected vs actual behavior

### Feature Requests

Have an idea? [Open a feature request](https://github.com/aboelnasr/version_gate/issues/new?template=feature_request.md).

---

## License

```
MIT License — Copyright (c) 2026 aboelnasr.com
```

See [LICENSE](LICENSE) for details.

---

<p align="center">
  Made with ❤️ by <a href="https://aboelnasr.com">aboelnasr.com</a>
</p>

<p align="center">
  <a href="https://buymeacoffee.com/aboelnasrmo"><img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-☕-yellow.svg" alt="Buy Me a Coffee"></a>
</p>
