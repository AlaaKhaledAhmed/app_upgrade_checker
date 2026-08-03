/// Raw payload describing the latest available version, as understood by
/// AppUpgrade. It is filled from a store lookup or from a `CustomSource` URL
/// via [AppUpdateData.fromJson].
///
/// **Not every field is available from every source.** The store path (Google
/// Play / App Store) exposes only a version name and a store link, so the
/// numeric-code fields below are `null` unless a `CustomSource` supplies them.
final class AppUpdateData {
  /// Human-readable version string of the latest release, e.g. `"3.2.0"`.
  /// Available from all sources.
  final String? versionName;

  /// Numeric build code. Stores do not expose this to the device, so it is
  /// `null` on the store path — only a `CustomSource` (JSON/backend) provides it.
  final int? versionCode;

  /// Numeric code of the latest release, used to compute [hasUpdate] against the
  /// device build number.
  ///
  /// `null` on the store path — set it in a `CustomSource` file/backend so the
  /// library can decide by exact numbers. Falls back to [versionCode] if unset.
  final int? latestVersionCode;

  /// The lowest build number still allowed to run; anything below it is
  /// force-updated.
  ///
  /// `null` on the store path — only a `CustomSource` supplies it, to express
  /// "versions older than X must update" without touching every client.
  final int? minSupportedVersionCode;

  /// Optional status flag echoed from the backend (e.g. `"public"`).
  final String? appStatus;

  /// Whether an update is available. When the backend decides this itself it
  /// should set the field; for direct store lookups AppUpgrade computes it.
  final bool? hasUpdate;

  /// Whether the update must be installed before the app can be used.
  final bool? isForceUpdate;

  /// Deep link / web URL to open the store or download page.
  final String? storeUrl;

  /// Optional release notes to show the user.
  final String? releaseNotes;

  const AppUpdateData({
    this.versionName,
    this.versionCode,
    this.latestVersionCode,
    this.minSupportedVersionCode,
    this.appStatus,
    this.hasUpdate,
    this.isForceUpdate,
    this.storeUrl,
    this.releaseNotes,
  });

  factory AppUpdateData.fromJson(Map<String, dynamic> json) {
    return AppUpdateData(
      versionName: json['versionName']?.toString(),
      versionCode: _asInt(json['versionCode']),
      latestVersionCode: _asInt(json['latestVersionCode']),
      minSupportedVersionCode: _asInt(json['minSupportedVersionCode']),
      appStatus: json['appStatus']?.toString(),
      hasUpdate: _asBool(json['hasUpdate']),
      isForceUpdate: _asBool(json['isForceUpdate']),
      storeUrl: json['storeUrl']?.toString(),
      releaseNotes: json['releaseNotes']?.toString(),
    );
  }

  AppUpdateData copyWith({
    String? versionName,
    int? versionCode,
    int? latestVersionCode,
    int? minSupportedVersionCode,
    String? appStatus,
    bool? hasUpdate,
    bool? isForceUpdate,
    String? storeUrl,
    String? releaseNotes,
  }) {
    return AppUpdateData(
      versionName: versionName ?? this.versionName,
      versionCode: versionCode ?? this.versionCode,
      latestVersionCode: latestVersionCode ?? this.latestVersionCode,
      minSupportedVersionCode:
          minSupportedVersionCode ?? this.minSupportedVersionCode,
      appStatus: appStatus ?? this.appStatus,
      hasUpdate: hasUpdate ?? this.hasUpdate,
      isForceUpdate: isForceUpdate ?? this.isForceUpdate,
      storeUrl: storeUrl ?? this.storeUrl,
      releaseNotes: releaseNotes ?? this.releaseNotes,
    );
  }

  Map<String, dynamic> toJson() => {
        'versionName': versionName,
        'versionCode': versionCode,
        'latestVersionCode': latestVersionCode,
        'minSupportedVersionCode': minSupportedVersionCode,
        'appStatus': appStatus,
        'hasUpdate': hasUpdate,
        'isForceUpdate': isForceUpdate,
        'storeUrl': storeUrl,
        'releaseNotes': releaseNotes,
      };

  static int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static bool? _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase();
      if (s == 'true' || s == '1') return true;
      if (s == 'false' || s == '0') return false;
    }
    return null;
  }
}
