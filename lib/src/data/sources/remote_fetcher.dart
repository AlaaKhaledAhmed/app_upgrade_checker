import 'package:app_upgrade/src/core/enums/app_error_state.dart';
import 'package:app_upgrade/src/services/version_comparator.dart';
import 'package:app_upgrade/src/data/models/app_info.dart';
import 'package:app_upgrade/src/data/models/app_update_data.dart';
import 'package:app_upgrade/src/data/models/data_handle.dart';
import 'package:app_upgrade/src/data/sources/update_source.dart';
import 'package:app_upgrade/src/services/network/inetwork_services.dart';

/// Reads the latest version from a URL the developer controls — a static JSON
/// file or a backend, treated identically: a GET that returns the
/// [AppUpdateData] contract.
///
/// The endpoint only reports "the latest version is X"; this source reads the
/// installed build locally and derives `hasUpdate` / `isForceUpdate` from the
/// returned `latestVersionCode` / `minSupportedVersionCode` (or, lacking those,
/// the version-name string). Values the response states explicitly are kept.
final class RemoteFetcher implements UpdateSource {
  final INetworkService network;
  final String url;
  final AppInfo appInfo;
  final Map<String, String>? headers;
  final String? fallbackStoreUrl;

  RemoteFetcher({
    required this.network,
    required this.url,
    required this.appInfo,
    this.headers,
    this.fallbackStoreUrl,
  });

  @override
  Future<PostDataHandle<AppUpdateData>> fetchLatest() async {
    if (url.trim().isEmpty) {
      return const PostDataHandle.failure(
        state: AppErrorState.format,
        message: 'update source url is empty',
      );
    }

    final result = await network.get<AppUpdateData>(
      url: url,
      headers: headers,
      fromJson: _parse,
    );
    if (result.hasError || result.data == null) {
      return PostDataHandle.failure(
        state: result.state,
        message: result.message,
        statusCode: result.statusCode,
      );
    }

    return PostDataHandle.success(
      data: _decide(result.data!),
      statusCode: result.statusCode,
    );
  }

  /// Strict contract, with one convenience: `latestVersionName` is accepted as
  /// an alias for `versionName`. Payload may be nested under `data`.
  AppUpdateData _parse(Map<String, dynamic> json) {
    final body = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return AppUpdateData.fromJson({
      'versionName': body['latestVersionName'] ?? body['versionName'],
      ...body,
    });
  }

  AppUpdateData _decide(AppUpdateData data) {
    final latestCode = data.latestVersionCode ?? data.versionCode;
    final minCode = data.minSupportedVersionCode;
    final deviceCode = appInfo.versionCode;

    bool? hasUpdate = data.hasUpdate;
    bool? force = data.isForceUpdate;

    if (latestCode != null) {
      hasUpdate ??= deviceCode < latestCode;
      force ??= minCode != null && deviceCode < minCode;
    } else if (data.versionName != null) {
      hasUpdate ??= VersionComparator.hasUpdate(
        current: appInfo.versionName,
        store: data.versionName!,
      );
      force ??= false;
    }

    return data.copyWith(
      hasUpdate: hasUpdate ?? false,
      isForceUpdate: force ?? false,
      storeUrl: data.storeUrl ?? fallbackStoreUrl,
    );
  }
}
