import 'package:app_upgrade_checker/src/core/enums/app_error_state.dart';

/// A uniform result envelope for a network call.
///
/// Every network method returns this instead of throwing, so callers can
/// branch on [hasError] without try/catch. On success [data] holds the parsed
/// payload; on failure [state]/[message] describe what went wrong.
final class PostDataHandle<T> {
  final bool hasError;
  final AppErrorState state;
  final String message;
  final int? statusCode;
  final T? data;

  const PostDataHandle({
    required this.hasError,
    required this.state,
    required this.message,
    required this.statusCode,
    required this.data,
  });

  const PostDataHandle.success({
    required this.data,
    this.statusCode = 200,
    this.message = 'success',
  })  : hasError = false,
        state = AppErrorState.done;

  const PostDataHandle.failure({
    required this.state,
    required this.message,
    this.statusCode,
  })  : hasError = true,
        data = null;

  Map<String, dynamic> toJson() => {
        'hasError': hasError,
        'state': state.name,
        'message': message,
        'statusCode': statusCode,
        'data': data,
      };
}
