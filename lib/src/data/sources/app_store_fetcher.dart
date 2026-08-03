import 'package:app_upgrade_checker/src/core/constants/constants.dart';
import 'package:app_upgrade_checker/src/core/enums/app_error_state.dart';
import 'package:app_upgrade_checker/src/core/enums/force_policy.dart';
import 'package:app_upgrade_checker/src/services/version_comparator.dart';
import 'package:app_upgrade_checker/src/services/network/inetwork_services.dart';
import 'package:app_upgrade_checker/src/data/models/app_info.dart';
import 'package:app_upgrade_checker/src/data/models/data_handle.dart';
import 'package:app_upgrade_checker/src/data/models/app_update_data.dart';
import 'package:app_upgrade_checker/src/data/sources/update_source.dart';

/// Reads the current App Store version straight from the device using Apple's
/// public iTunes Lookup API — no auth, no backend, no cost.
///
/// Only works for apps that are actually listed on the App Store (public or
/// Unlisted). Custom Apps distributed via Apple Business Manager are NOT
/// returned by this API; use [BackendSource] for those.
final class AppStoreFetcher implements UpdateSource {
  final INetworkService network;
  final AppInfo appInfo;

  /// Numeric Apple ID (trackId). Optional — [appInfo.packageName] (bundleId)
  /// is used when absent.
  final String? appleId;

  /// Storefront country code, e.g. `"us"`, `"sa"`. Affects availability.
  final String? country;

  /// How to decide whether the update is mandatory (Apple gives no signal).
  final ForcePolicy forcePolicy;

  AppStoreFetcher({
    required this.network,
    required this.appInfo,
    this.appleId,
    this.country,
    this.forcePolicy = ForcePolicy.auto,
  });

  @override
  Future<PostDataHandle<AppUpdateData>> fetchLatest() async {
    final result = await network.get<_ITunesLookup>(
      url: AppConstants.iTunesLookup,
      queryParams: {
        if (appleId != null && appleId!.isNotEmpty)
          'id': appleId
        else
          'bundleId': appInfo.packageName,
        if (country != null && country!.isNotEmpty) 'country': country,
      },
      fromJson: _ITunesLookup.fromJson,
    );

    if (result.hasError) {
      return PostDataHandle.failure(
        state: result.state,
        message: result.message,
        statusCode: result.statusCode,
      );
    }

    final lookup = result.data;
    if (lookup == null || lookup.storeVersion == null) {
      // resultCount == 0 → the bundleId isn't publicly listed on the store.
      return PostDataHandle.failure(
        state: AppErrorState.format,
        message: 'app not found on the App Store for '
            '${appleId != null ? 'id=$appleId' : 'bundleId=${appInfo.packageName}'}',
        statusCode: result.statusCode,
      );
    }

    final hasUpdate = VersionComparator.hasUpdate(
      current: appInfo.versionName,
      store: lookup.storeVersion!,
    );

    return PostDataHandle.success(
      data: AppUpdateData(
        versionName: lookup.storeVersion,
        appStatus: 'public',
        hasUpdate: hasUpdate,
        // Apple exposes no mandatory-update signal, so derive it from policy.
        isForceUpdate: hasUpdate &&
            resolveForcePolicy(
              forcePolicy,
              current: appInfo.versionName,
              store: lookup.storeVersion!,
            ),
        storeUrl: lookup.trackViewUrl,
        releaseNotes: lookup.releaseNotes,
      ),
      statusCode: result.statusCode,
    );
  }
}

/// Minimal projection of the iTunes lookup response.
final class _ITunesLookup {
  final String? storeVersion;
  final String? trackViewUrl;
  final String? releaseNotes;

  const _ITunesLookup(
      {this.storeVersion, this.trackViewUrl, this.releaseNotes});

  factory _ITunesLookup.fromJson(Map<String, dynamic> json) {
    final results = json['results'];
    if (results is! List || results.isEmpty) return const _ITunesLookup();
    final first = results.first;
    if (first is! Map) return const _ITunesLookup();
    return _ITunesLookup(
      storeVersion: first['version']?.toString(),
      trackViewUrl: first['trackViewUrl']?.toString(),
      releaseNotes: first['releaseNotes']?.toString(),
    );
  }
}
