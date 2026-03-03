/// Compares two semantic version strings.
///
/// Handles formats like "1.2.3", "1.2.3+45", "1.2", and "2.0.0-beta.1".
/// Build metadata (e.g., +45) is stripped before comparison.
/// Pre-release versions (e.g., -beta.1) are considered older than
/// the corresponding release version per semver spec.
class VersionComparator {
  const VersionComparator();

  /// Returns `true` if [storeVersion] is newer than [localVersion].
  bool isNewer(String storeVersion, String localVersion) {
    final store = _parse(storeVersion);
    final local = _parse(localVersion);

    // Compare major.minor.patch
    for (int i = 0; i < 3; i++) {
      if (store.numbers[i] > local.numbers[i]) return true;
      if (store.numbers[i] < local.numbers[i]) return false;
    }

    // Same major.minor.patch — compare pre-release
    // No pre-release > has pre-release (1.0.0 > 1.0.0-beta)
    if (local.preRelease != null && store.preRelease == null) return true;
    if (local.preRelease == null && store.preRelease != null) return false;

    // Both have pre-release — compare lexically by segments
    if (store.preRelease != null && local.preRelease != null) {
      return _comparePreRelease(store.preRelease!, local.preRelease!);
    }

    return false;
  }

  _ParsedVersion _parse(String version) {
    // Strip build metadata (+...)
    var v = version;
    final plusIndex = v.indexOf('+');
    if (plusIndex != -1) {
      v = v.substring(0, plusIndex);
    }

    // Split pre-release (-...)
    String? preRelease;
    final dashIndex = v.indexOf('-');
    if (dashIndex != -1) {
      preRelease = v.substring(dashIndex + 1);
      v = v.substring(0, dashIndex);
    }

    // Parse numbers
    final parts = v.split('.');
    final numbers = <int>[0, 0, 0];
    for (int i = 0; i < parts.length && i < 3; i++) {
      numbers[i] = int.tryParse(parts[i]) ?? 0;
    }

    return _ParsedVersion(numbers, preRelease);
  }

  bool _comparePreRelease(String store, String local) {
    final storeParts = store.split('.');
    final localParts = local.split('.');

    final len = storeParts.length > localParts.length
        ? storeParts.length
        : localParts.length;

    for (int i = 0; i < len; i++) {
      if (i >= localParts.length) return true; // store has more = newer
      if (i >= storeParts.length) return false; // local has more = newer

      final storeNum = int.tryParse(storeParts[i]);
      final localNum = int.tryParse(localParts[i]);

      if (storeNum != null && localNum != null) {
        if (storeNum > localNum) return true;
        if (storeNum < localNum) return false;
      } else {
        // Lexical comparison for non-numeric segments
        final cmp = storeParts[i].compareTo(localParts[i]);
        if (cmp > 0) return true;
        if (cmp < 0) return false;
      }
    }

    return false;
  }
}

class _ParsedVersion {
  final List<int> numbers;
  final String? preRelease;

  const _ParsedVersion(this.numbers, this.preRelease);
}
