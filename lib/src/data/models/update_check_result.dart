import 'package:app_upgrade_checker/src/core/enums/app_error_state.dart';
import 'package:app_upgrade_checker/src/data/models/app_update_data.dart';

/// Outcome of [AppUpgrade.checkUpdate].
///
/// A sealed type instead of a nullable [AppUpdateData], so callers must handle
/// every case explicitly (via `switch`) and never confuse "no update" with
/// "the check failed" — the two used to collapse into a single `null`.
sealed class UpdateCheckResult {
  const UpdateCheckResult();

  /// The raw payload behind this result, when there is one.
  AppUpdateData? get data => null;
}

/// A newer version is available.
///
/// The convenience getters mirror [data]. Note that some values are only
/// present when the result came from a `CustomSource`; on the direct store
/// path they are `null` (the store doesn't expose them). Each getter says so.
final class UpdateAvailable extends UpdateCheckResult {
  @override
  final AppUpdateData data;

  const UpdateAvailable(this.data);

  /// Whether the update is mandatory. Available from any source.
  bool get isForceUpdate => data.isForceUpdate ?? false;

  /// Latest version name, e.g. `"3.5.0"`. Available from any source.
  String? get versionName => data.versionName;

  /// URL the "Update now" button opens. Available from any source.
  String? get storeUrl => data.storeUrl;

  /// Latest numeric build code. **`null` on the store path** — only a
  /// `CustomSource` provides it.
  int? get versionCode => data.latestVersionCode ?? data.versionCode;

  /// Lowest supported build code. **`null` on the store path** — only a
  /// `CustomSource` provides it.
  int? get minSupportedVersionCode => data.minSupportedVersionCode;

  /// Release notes. From a `CustomSource` or the iOS store lookup; **`null` on
  /// the Android store path.**
  String? get releaseNotes => data.releaseNotes;
}

/// The installed app is already up to date.
final class NoUpdate extends UpdateCheckResult {
  @override
  final AppUpdateData? data;

  const NoUpdate([this.data]);
}

/// The check could not be completed (network, parsing, config, or the target
/// app simply wasn't found on the store).
final class UpdateCheckError extends UpdateCheckResult {
  final AppErrorState state;
  final String message;

  const UpdateCheckError({required this.state, required this.message});

  @override
  String toString() => 'UpdateCheckError($state): $message';
}
