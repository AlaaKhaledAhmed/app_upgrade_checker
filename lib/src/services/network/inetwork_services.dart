import 'package:app_upgrade_checker/src/data/models/data_handle.dart';

/// Abstraction over the transport used to reach a backend or a store API.
///
/// Kept intentionally small: AppUpgrade only ever needs simple GET/POST of
/// JSON. Implementations must never throw — every outcome (success, HTTP
/// error, timeout, no connection) is returned as a [PostDataHandle].
abstract interface class INetworkService {
  Future<PostDataHandle<T>> get<T>({
    required String url,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    required T Function(Map<String, dynamic> json) fromJson,
  });

  Future<PostDataHandle<T>> post<T>({
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    required T Function(Map<String, dynamic> json) fromJson,
  });
}
