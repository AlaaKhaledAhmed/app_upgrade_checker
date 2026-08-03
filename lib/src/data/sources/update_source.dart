import 'package:app_upgrade/src/data/models/data_handle.dart';
import 'package:app_upgrade/src/data/models/app_update_data.dart';

/// A swappable provider of "what is the latest available version?".
///
/// AppUpgrade picks a concrete fetcher from the configured source:
/// - [CustomSource]   -> [RemoteFetcher] (a URL you host: JSON file or backend)
/// - store source     -> [AppStoreFetcher] / [PlayStoreFetcher] (direct lookup)
///
/// Implementations never throw; they return a [PostDataHandle] carrying either
/// the parsed [AppUpdateData] or a typed error.
abstract interface class UpdateSource {
  Future<PostDataHandle<AppUpdateData>> fetchLatest();
}
