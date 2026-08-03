import 'package:app_upgrade_checker/src/config/update_method.dart';

/// Top-level configuration passed to [AppUpgrade.checkUpdate].
///
/// Everything is optional. A `null` platform defaults to checking that store
/// directly ([PlayStoreSource] on Android, [AppStoreSource] on iOS), so:
///
/// ```dart
/// AppUpgrade.checkUpdate();                         // both stores, defaults
/// AppUpgrade.checkUpdate(AppConfig(ios: mySource)); // custom iOS, Android store
/// ```
///
/// Provide a method only when you need something other than the plain public
/// store check (a custom URL, an Apple ID, a force policy, …).
final class AppConfig {
  /// How to check on Android. `null` → [PlayStoreSource] with defaults.
  final AndroidConfig? android;

  /// How to check on iOS. `null` → [AppStoreSource] with defaults.
  final IosConfig? ios;

  const AppConfig({this.android, this.ios});
}
