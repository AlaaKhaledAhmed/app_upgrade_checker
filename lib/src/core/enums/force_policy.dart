import 'package:app_upgrade_checker/src/services/version_comparator.dart';

/// Decides whether an available update is mandatory, for the **direct store**
/// path (Google Play / App Store) where no backend or numeric build code is
/// available to make that call.
///
/// Ignored when the answer comes from a backend or a JSON file — those carry
/// their own `isForceUpdate` / `minSupportedVersionCode`.
enum ForcePolicy {
  /// Derive it from the version-name difference: a change in the **first**
  /// (major) segment — e.g. `3.x.x` → `4.x.x` — is treated as mandatory;
  /// minor/patch changes are optional. Follows common semantic-versioning
  /// practice where a major bump signals breaking changes.
  auto,

  /// Any available update is mandatory (blocking screen, no "Later").
  always,

  /// Any available update is optional (the user can dismiss it).
  never,
}

/// Resolves a [ForcePolicy] into a concrete "is this update mandatory?" answer
/// for the direct-store path, given the installed and store version names.
///
/// Assumes an update is already known to exist (call only when there is one).
bool resolveForcePolicy(
  ForcePolicy policy, {
  required String current,
  required String store,
}) {
  return switch (policy) {
    ForcePolicy.always => true,
    ForcePolicy.never => false,
    ForcePolicy.auto =>
      VersionComparator.isMajorBump(current: current, store: store),
  };
}
