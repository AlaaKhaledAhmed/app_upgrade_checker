/// Category of a failed update check, carried by [UpdateCheckError].
///
/// Purpose: lets you react differently per failure — e.g. silently retry on
/// [socket]/[timeout], but log a [format] error (a misconfigured backend
/// response or an app that isn't on the store).
enum AppErrorState {
  /// The backend rejected the request as unauthorized (HTTP 401/403). Usually
  /// a missing or wrong auth header.
  unAuthorized,

  /// The server failed (HTTP 5xx or an unexpected status).
  server,

  /// No network connection could be established.
  socket,

  /// The request took too long and timed out.
  timeout,

  /// The response could not be understood, or the app wasn't found on the
  /// store — includes invalid URLs, non-JSON bodies, and empty lookups.
  format,

  /// Not an error — the operation completed successfully. Used internally by
  /// the network layer for success results.
  done,
}
