/// The OS the app is currently running on, detected automatically by
/// AppUpgrade to pick the right config and check strategy.
enum PlatformType {
  /// Running on Android → uses `AppConfig.android`.
  android,

  /// Running on iOS → uses `AppConfig.ios`.
  ios,
}
