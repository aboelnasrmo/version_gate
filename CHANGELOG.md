# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-03-04

### Added
- **Custom HTTP headers** — pass `headers` to `VersionGate()` for apps behind corporate proxies or CDNs that require auth headers on outbound requests
- **Minimum version enforcement** — set `minimumVersion: '2.0.0'` to automatically force updates for critically outdated versions while keeping optional mode for newer ones
- **Callbacks** — `onUpdateAvailable`, `onNoUpdate`, and `onError` callbacks for analytics tracking without manually inspecting the result
- **Localization** — new `UpdateStrings` class with factory constructors for 10 languages: English, Arabic, Spanish, French, German, Turkish, Urdu, Chinese, Japanese, Korean. Pass `strings: UpdateStrings.arabic()` to show all built-in widgets in the target language
- `UpdateStrings` supports custom text and `{storeVersion}` / `{localVersion}` placeholders

### Changed
- Built-in widgets (`UpdateDialog`, `UpdateBanner`, `UpdateBlockScreen`) now resolve text from `UpdateStrings` when available, falling back to English defaults
- `VersionCheckResult` now carries an optional `strings` field for localization

## [1.0.5] - 2026-03-04

### Added
- Platform Setup section in README — Android `<queries>` and iOS `LSApplicationQueriesSchemes` config required by `url_launcher` for opening store URLs

### Changed
- Widened `package_info_plus` dependency to `>=8.0.0 <10.0.0` so consumers on v9 don't need a dependency override

## [1.0.4] - 2026-03-04

### Changed
- Updated README installation version to latest

## [1.0.3] - 2026-03-03

### Changed
- Updated README installation version to latest

## [1.0.2] - 2026-03-03

### Fixed
- Fixed GitHub Actions CI workflow — removed `--fatal-infos` flag and `dart pub publish --dry-run` step that caused false failures

## [1.0.1] - 2026-03-03

### Fixed
- Added `const` constructors in test files to resolve all `prefer_const_constructors` lint warnings
- Added GitHub Actions CI workflow for automated analysis and testing

## [1.0.0] - 2026-03-03

### 🎉 Initial Release

**Core Features:**
- Zero-configuration version checking — reads bundle ID and app version automatically via `package_info_plus`
- iOS support via iTunes Lookup API (JSON, free, no authentication)
- Android support via Google Play Store HTML parsing (multi-pattern regex for resilience)

**Frequency Guard:**
- Smart check throttling with `SharedPreferences` — prevents repeated, annoying update prompts
- Built-in frequencies: `onceDaily` (default), `oncePerSession`, `oncePerWeek`, `always`
- Custom frequency support: `CheckFrequency.custom(hours: 12)`

**Update Modes:**
- `UpdateMode.optional` — dismissible dialog, user can tap "Later"
- `UpdateMode.flexible` — persistent banner, app remains usable
- `UpdateMode.forced` — full-screen blocker, cannot be dismissed (intercepts back button)

**Built-in Widgets:**
- `UpdateDialog` — Material dialog with customizable title, message, buttons, and release notes
- `UpdateBanner` — persistent `MaterialBanner` with dismiss and update actions
- `UpdateBlockScreen` — full-screen forced update with `PopScope` back-button interception

**Version Comparison:**
- Semantic versioning: `major.minor.patch`
- Build metadata stripping: `1.2.3+45` → `1.2.3`
- Pre-release support: `2.0.0-beta.1` < `2.0.0`
- Handles partial versions: `1.2` treated as `1.2.0`

**Error Handling:**
- `check()` never throws — all errors caught internally
- Returns `hasUpdate: false` with `error` field on failure
- Network timeouts (10s) prevent hanging
- Timestamp saved only after successful API call — retries on next launch if network fails

**Dependencies:**
- `package_info_plus` — auto-read bundle ID and version
- `shared_preferences` — persist last-check timestamp
- `http` — store API calls
- `url_launcher` — open store listing

[1.1.0]: https://github.com/aboelnasrmo/version_gate/releases/tag/v1.1.0
[1.0.5]: https://github.com/aboelnasrmo/version_gate/releases/tag/v1.0.5
[1.0.4]: https://github.com/aboelnasrmo/version_gate/releases/tag/v1.0.4
[1.0.3]: https://github.com/aboelnasrmo/version_gate/releases/tag/v1.0.3
[1.0.2]: https://github.com/aboelnasrmo/version_gate/releases/tag/v1.0.2
[1.0.1]: https://github.com/aboelnasrmo/version_gate/releases/tag/v1.0.1
[1.0.0]: https://github.com/aboelnasrmo/version_gate/releases/tag/v1.0.0
