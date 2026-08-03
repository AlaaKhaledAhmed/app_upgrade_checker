/// Compares dotted version strings ("semver-lite").
///
/// Store lookups (especially Apple's iTunes API) only expose a *version name*
/// like `"3.2.0"` — never a numeric build code — so update detection for the
/// public/store path must compare these strings segment by segment rather than
/// numerically. Missing trailing segments are treated as zero, so `"3.2"` and
/// `"3.2.0"` are equal. Non-numeric or empty input is handled defensively.
abstract final class VersionComparator {
  /// Returns `true` when [store] represents a strictly newer version than
  /// [current]. Returns `false` if either input can't be parsed, so a parsing
  /// glitch never nags the user with a phantom update.
  static bool hasUpdate({required String current, required String store}) {
    return compare(store, current) > 0;
  }

  /// Standard comparator contract: negative if [a] < [b], zero if equal,
  /// positive if [a] > [b].
  static int compare(String a, String b) {
    final pa = _parse(a);
    final pb = _parse(b);
    final len = pa.length > pb.length ? pa.length : pb.length;
    for (var i = 0; i < len; i++) {
      final x = i < pa.length ? pa[i] : 0;
      final y = i < pb.length ? pb[i] : 0;
      if (x != y) return x < y ? -1 : 1;
    }
    return 0;
  }

  /// Whether [store] bumps the **first (major) segment** relative to [current]
  /// — e.g. `3.4.1` → `4.0.0`. Used by [ForcePolicy.auto] to treat a major
  /// release as a mandatory update. Returns `false` if [store] is not newer, or
  /// if either version can't be parsed.
  static bool isMajorBump({required String current, required String store}) {
    if (compare(store, current) <= 0) return false;
    final storeMajor = _parse(store);
    final currentMajor = _parse(current);
    final s = storeMajor.isNotEmpty ? storeMajor.first : 0;
    final c = currentMajor.isNotEmpty ? currentMajor.first : 0;
    return s > c;
  }

  /// Splits `"3.2.1-beta+2"` into `[3, 2, 1]`, dropping any pre-release or
  /// build metadata suffix and any non-numeric leftovers.
  static List<int> _parse(String version) {
    final core = version.trim().split(RegExp(r'[-+]')).first;
    if (core.isEmpty) return const [];
    return core
        .split('.')
        .map((seg) => int.tryParse(seg.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList(growable: false);
  }
}
