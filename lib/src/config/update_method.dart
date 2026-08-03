import 'package:app_upgrade/src/core/enums/force_policy.dart';

/// How the Android version is checked. Pick exactly one — each asks only for the
/// data it needs, so an invalid combination can't be expressed.
///
/// - [PlayStoreSource] → read the Play Store listing directly (public apps)
/// - [CustomSource]    → GET a URL you control (a static JSON file *or* your
///   backend) that returns the [AppUpdateData] contract.
sealed class AndroidConfig {
  const AndroidConfig();
}

/// How the iOS version is checked. Pick exactly one.
///
/// - [AppStoreSource] → query Apple's public iTunes lookup directly
/// - [CustomSource]   → GET a URL you control (static JSON or backend)
sealed class IosConfig {
  const IosConfig();
}

/// Check the public Google Play listing directly from the device.
///
/// No backend needed. This is an unofficial HTML read and only works for apps
/// published publicly on Google Play.
final class PlayStoreSource extends AndroidConfig {
  /// How to decide whether the update is mandatory (Play exposes no signal):
  /// [ForcePolicy.auto] forces on a major version bump.
  final ForcePolicy forcePolicy;

  /// UI language for the listing read (`hl=`), e.g. `"en"`, `"ar"`.
  final String? language;

  /// Storefront region for the listing read (`gl=`), e.g. `"US"`, `"SA"`.
  final String? country;

  const PlayStoreSource({
    this.forcePolicy = ForcePolicy.auto,
    this.language,
    this.country,
  });
}

/// Check the App Store version directly via Apple's public iTunes Lookup API.
/// No backend, no auth. Works for listed and Unlisted apps (not ABM Custom
/// Apps — use a [CustomSource] pointing at your backend for those).
final class AppStoreSource extends IosConfig {
  /// How to decide whether the update is mandatory (Apple exposes no signal):
  /// [ForcePolicy.auto] forces on a major version bump.
  final ForcePolicy forcePolicy;

  /// Numeric Apple ID (trackId). Optional — the bundle identifier is used when
  /// omitted. Provide it if the bundle-id lookup returns nothing.
  final String? appleId;

  /// App Store storefront to query, e.g. `"us"`, `"sa"`.
  final String? country;

  const AppStoreSource({
    this.forcePolicy = ForcePolicy.auto,
    this.appleId,
    this.country,
  });
}

/// Check for updates from a URL you control — a static JSON file (GitHub raw,
/// Firebase Hosting, S3) *or* your own backend. To the library these are the
/// same: it GETs the URL and expects the [AppUpdateData] contract back.
///
/// Usable as both an [AndroidConfig] and an [IosConfig], so the same
/// source can serve both platforms.
///
/// The library reads the installed build itself and computes
/// `hasUpdate` / `isForceUpdate` from the returned `latestVersionCode` /
/// `minSupportedVersionCode`, so the endpoint does not need the device version.
final class CustomSource implements AndroidConfig, IosConfig {
  /// The URL to GET. Must return JSON matching the [AppUpdateData] contract.
  final String url;

  /// Optional HTTP headers (e.g. `{'Authorization': 'Bearer ...'}`). No other
  /// constraints — pass whatever your endpoint needs.
  final Map<String, String>? headers;

  /// The URL "Update now" opens **only if** the response has no `storeUrl`.
  ///
  /// `storeUrl` from the response always wins; this is a fallback for the case
  /// where you'd rather keep the download destination fixed in the app than put
  /// it in the JSON (e.g. an internal download page, an APK link, a TestFlight
  /// link). Leave `null` if your source always returns `storeUrl`.
  final String? fallbackStoreUrl;

  const CustomSource({
    required this.url,
    this.headers,
    this.fallbackStoreUrl,
  });
}
