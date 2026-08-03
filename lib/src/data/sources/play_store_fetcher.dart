import 'package:http/http.dart' as http;

import 'package:app_upgrade/src/core/constants/constants.dart';
import 'package:app_upgrade/src/core/enums/app_error_state.dart';
import 'package:app_upgrade/src/core/enums/force_policy.dart';
import 'package:app_upgrade/src/services/version_comparator.dart';
import 'package:app_upgrade/src/data/models/app_info.dart';
import 'package:app_upgrade/src/data/models/data_handle.dart';
import 'package:app_upgrade/src/data/models/app_update_data.dart';
import 'package:app_upgrade/src/data/sources/update_source.dart';

/// Reads the current Play Store version by scraping the public app listing.
///
/// ⚠️ UNOFFICIAL. Google provides no free public version API for Android, so
/// this parses the HTML of `play.google.com/store/apps/details`. It can break
/// whenever Google changes that page, and many apps now show
/// "Varies with device" instead of a version — in which case this returns a
/// "not found" error. For anything reliable (or for closed tracks), use
/// [BackendSource] with the Play Developer API behind your server.
final class PlayStoreFetcher implements UpdateSource {
  final AppInfo appInfo;
  final String? language; // e.g. "en", "ar"
  final String? country; // e.g. "US", "SA"
  final ForcePolicy forcePolicy;
  final http.Client _client;
  final Duration timeout;

  PlayStoreFetcher({
    required this.appInfo,
    this.language,
    this.country,
    this.forcePolicy = ForcePolicy.auto,
    http.Client? client,
    this.timeout = AppConstants.timeOut,
  }) : _client = client ?? http.Client();

  @override
  Future<PostDataHandle<AppUpdateData>> fetchLatest() async {
    final uri = Uri.parse(AppConstants.playStoreDetails).replace(
      queryParameters: {
        'id': appInfo.packageName,
        if (language != null) 'hl': language,
        if (country != null) 'gl': country,
      },
    );

    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode == 404) {
        return PostDataHandle.failure(
          state: AppErrorState.format,
          message: 'app not found on the Play Store: ${appInfo.packageName}',
          statusCode: 404,
        );
      }
      if (response.statusCode != 200) {
        return PostDataHandle.failure(
          state: AppErrorState.server,
          message: 'play store returned ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final storeVersion = _extractVersion(response.body);
      if (storeVersion == null) {
        return const PostDataHandle.failure(
          state: AppErrorState.format,
          message: 'could not read version from the Play listing '
              '(it may show "Varies with device")',
          statusCode: 200,
        );
      }

      final hasUpdate = VersionComparator.hasUpdate(
        current: appInfo.versionName,
        store: storeVersion,
      );
      return PostDataHandle.success(
        data: AppUpdateData(
          versionName: storeVersion,
          appStatus: 'public',
          hasUpdate: hasUpdate,
          isForceUpdate: hasUpdate &&
              resolveForcePolicy(
                forcePolicy,
                current: appInfo.versionName,
                store: storeVersion,
              ),
          storeUrl: uri.toString(),
        ),
      );
    } on Exception catch (e) {
      return PostDataHandle.failure(
        state: AppErrorState.socket,
        message: e.toString(),
      );
    }
  }

  /// Tries a couple of known patterns Google has used to embed the version in
  /// the listing HTML. Best-effort by nature.
  static String? _extractVersion(String html) {
    // Pattern seen in the embedded data blob: [[["1.2.3"]]] near "Current Version".
    final patterns = <RegExp>[
      RegExp(r'\[\[\["([0-9]+(?:\.[0-9]+)+)"\]\]'),
      RegExp(r'Current Version.*?>([0-9]+(?:\.[0-9]+)+)<', dotAll: true),
      RegExp(r'"softwareVersion"\s*:\s*"([0-9]+(?:\.[0-9]+)+)"'),
    ];
    for (final re in patterns) {
      final m = re.firstMatch(html);
      final v = m?.group(1);
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  void close() => _client.close();
}
