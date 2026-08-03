import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:app_upgrade/src/core/constants/constants.dart';
import 'package:app_upgrade/src/core/enums/app_error_state.dart';
import 'package:app_upgrade/src/data/models/data_handle.dart';
import 'package:app_upgrade/src/services/network/inetwork_services.dart';

/// [INetworkService] backed by the lightweight `http` package.
///
/// Chosen over `dio` to keep this library's dependency footprint minimal and
/// avoid version-conflict friction for consumers. Never throws; all failures
/// come back as a [PostDataHandle.failure].
final class HttpNetworkService implements INetworkService {
  final http.Client _client;
  final Duration timeout;

  HttpNetworkService({http.Client? client, this.timeout = AppConstants.timeOut})
      : _client = client ?? http.Client();

  @override
  Future<PostDataHandle<T>> get<T>({
    required String url,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    return _send<T>(
      method: 'GET',
      url: url,
      queryParams: queryParams,
      headers: headers,
      fromJson: fromJson,
    );
  }

  @override
  Future<PostDataHandle<T>> post<T>({
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    return _send<T>(
      method: 'POST',
      url: url,
      body: body,
      headers: headers,
      fromJson: fromJson,
    );
  }

  Future<PostDataHandle<T>> _send<T>({
    required String method,
    required String url,
    required T Function(Map<String, dynamic> json) fromJson,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    final Uri uri;
    try {
      uri = _buildUri(url, queryParams);
    } on FormatException catch (e) {
      return PostDataHandle.failure(
        state: AppErrorState.format,
        message: 'invalid url: ${e.message}',
      );
    }

    final mergedHeaders = <String, String>{
      'Accept': 'application/json',
      if (method == 'POST') 'Content-Type': 'application/json',
      ...?headers,
    };

    try {
      final http.Response response = await switch (method) {
        'POST' => _client.post(
            uri,
            headers: mergedHeaders,
            body: body == null ? null : jsonEncode(body),
          ),
        _ => _client.get(uri, headers: mergedHeaders),
      }
          .timeout(timeout);

      final code = response.statusCode;
      if (code >= 200 && code < 300) {
        return _parseSuccess<T>(response, fromJson);
      }
      if (code == 401 || code == 403) {
        return PostDataHandle.failure(
          state: AppErrorState.unAuthorized,
          message: 'unauthorized',
          statusCode: code,
        );
      }
      if (code == 400 || code == 404 || code == 422) {
        return PostDataHandle.failure(
          state: AppErrorState.format,
          message: _messageFrom(response) ?? 'request rejected ($code)',
          statusCode: code,
        );
      }
      return PostDataHandle.failure(
        state: AppErrorState.server,
        message: _messageFrom(response) ?? 'server error ($code)',
        statusCode: code,
      );
    } on TimeoutException {
      return PostDataHandle.failure(
        state: AppErrorState.timeout,
        message: 'request timed out',
      );
    } on SocketException {
      return PostDataHandle.failure(
        state: AppErrorState.socket,
        message: 'no internet connection',
      );
    } on http.ClientException catch (e) {
      return PostDataHandle.failure(
        state: AppErrorState.socket,
        message: e.message,
      );
    } catch (e) {
      return PostDataHandle.failure(
        state: AppErrorState.server,
        message: e.toString(),
      );
    }
  }

  PostDataHandle<T> _parseSuccess<T>(
    http.Response response,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (response.body.isEmpty) {
      return PostDataHandle.failure(
        state: AppErrorState.format,
        message: 'empty response body',
        statusCode: response.statusCode,
      );
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return PostDataHandle.failure(
          state: AppErrorState.format,
          message: 'expected a JSON object, got ${decoded.runtimeType}',
          statusCode: response.statusCode,
        );
      }
      return PostDataHandle.success(
        data: fromJson(decoded),
        statusCode: response.statusCode,
      );
    } on FormatException {
      return PostDataHandle.failure(
        state: AppErrorState.format,
        message: 'response was not valid JSON',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return PostDataHandle.failure(
        state: AppErrorState.format,
        message: 'failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }

  Uri _buildUri(String url, Map<String, dynamic>? queryParams) {
    final uri = Uri.parse(url);
    if (queryParams == null || queryParams.isEmpty) return uri;
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      for (final e in queryParams.entries) e.key: '${e.value}',
    });
  }

  /// Best-effort extraction of a `message` field from an error body.
  String? _messageFrom(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['message'] is String) {
        return decoded['message'] as String;
      }
    } catch (_) {}
    return null;
  }

  void close() => _client.close();
}
