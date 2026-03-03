# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.0.0]: https://github.com/aboelnasrmo/version_gate/releases/tag/v1.0.0
