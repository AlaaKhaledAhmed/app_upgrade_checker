import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

import 'package:app_upgrade/src/core/enums/platform_type.dart';

/// Snapshot of the *currently installed* app, read from the platform.
final class AppInfo {
  final String versionName;
  final int versionCode;
  final String packageName;
  final PlatformType platform;

  const AppInfo({
    required this.versionName,
    required this.versionCode,
    required this.packageName,
    required this.platform,
  });

  static Future<AppInfo> load() async {
    final info = await PackageInfo.fromPlatform();
    return AppInfo(
      platform: Platform.isIOS ? PlatformType.ios : PlatformType.android,
      versionName: info.version,
      versionCode: int.tryParse(info.buildNumber) ?? 0,
      packageName: info.packageName,
    );
  }

  Map<String, dynamic> toJson() => {
        'versionName': versionName,
        'versionCode': versionCode,
        'packageName': packageName,
        'platform': platform.name,
      };
}
