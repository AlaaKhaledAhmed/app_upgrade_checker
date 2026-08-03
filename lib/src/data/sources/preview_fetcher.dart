import 'package:app_upgrade_checker/src/config/update_preview.dart';
import 'package:app_upgrade_checker/src/core/enums/app_error_state.dart';
import 'package:app_upgrade_checker/src/data/models/app_info.dart';
import 'package:app_upgrade_checker/src/data/models/app_update_data.dart';
import 'package:app_upgrade_checker/src/data/models/data_handle.dart';
import 'package:app_upgrade_checker/src/data/sources/update_source.dart';

/// Serves an [UpdatePreview]'s canned payload without touching the network.
///
/// It mirrors what a real fetcher does *after* the request — filling in the
/// installed build number — so the screen you preview is driven by the same
/// fields production will use.
///
/// Internal: consumers reach this by passing `preview:` to a check.
final class PreviewFetcher implements UpdateSource {
  final UpdatePreview preview;
  final AppInfo appInfo;

  PreviewFetcher({required this.preview, required this.appInfo});

  @override
  Future<PostDataHandle<AppUpdateData>> fetchLatest() async {
    // Warns in debug, throws in release — a preview must never ship.
    preview.warnNotForRelease();

    if (preview.delay > Duration.zero) {
      await Future<void>.delayed(preview.delay);
    }

    final data = preview.data;
    if (data == null) {
      return PostDataHandle.failure(
        state: AppErrorState.server,
        message: preview.errorMessage,
      );
    }

    return PostDataHandle.success(
      // Report the build actually installed, so the screen shows a truthful
      // "current version" next to the simulated "latest".
      data: data.copyWith(
        versionCode: data.versionCode ?? appInfo.versionCode,
      ),
    );
  }
}
