import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:app_upgrade/src/config/app_config.dart';
import 'package:app_upgrade/src/config/update_preview.dart';
import 'package:app_upgrade/src/config/update_method.dart';
import 'package:app_upgrade/src/core/enums/app_error_state.dart';
import 'package:app_upgrade/src/core/enums/platform_type.dart';
import 'package:app_upgrade/src/data/models/app_info.dart';
import 'package:app_upgrade/src/data/models/update_check_result.dart';
import 'package:app_upgrade/src/data/sources/app_store_fetcher.dart';
import 'package:app_upgrade/src/data/sources/preview_fetcher.dart';
import 'package:app_upgrade/src/data/sources/play_store_fetcher.dart';
import 'package:app_upgrade/src/data/sources/remote_fetcher.dart';
import 'package:app_upgrade/src/data/sources/update_source.dart';
import 'package:app_upgrade/src/presentation/app_upgrade_screen.dart';
import 'package:app_upgrade/src/presentation/app_upgrade_theme.dart';
import 'package:app_upgrade/src/services/network/http_network_service.dart';
import 'package:app_upgrade/src/services/network/inetwork_services.dart';

/// Entry point of the package.
///
/// Typical use:
/// ```dart
/// final result = await AppUpgrade.checkUpdate(config);
/// if (result is UpdateAvailable && context.mounted) {
///   await AppUpgrade.showUpdateDialog(context, result);
/// }
/// ```
final class AppUpgrade {
  final INetworkService _network;

  /// Testing seam: inject a fake [INetworkService]. App code uses the static
  /// [checkUpdate] instead of constructing this directly.
  AppUpgrade({INetworkService? network})
      : _network = network ?? HttpNetworkService();

  /// The check currently in flight, if any.
  ///
  /// A check takes a network round trip, during which nothing on screen has
  /// changed yet — so a user tapping a button will tap it again. Without this,
  /// each tap starts its own request and each one ends by pushing the screen,
  /// stacking two copies. Concurrent callers now share the first result.
  static Future<UpdateCheckResult>? _inFlight;

  /// Whether the built-in screen is on screen right now, so a second prompt is
  /// not pushed over the first.
  static bool _isPrompting = false;

  /// Whether a check is currently running. Useful for driving a spinner:
  ///
  /// ```dart
  /// onPressed: AppUpgrade.isChecking ? null : () => _check(context),
  /// ```
  static bool get isChecking => _inFlight != null;

  /// Checks whether a newer version is available for the current platform.
  ///
  /// [config] is optional — a `null` platform defaults to checking that store
  /// directly, so `AppUpgrade.checkUpdate()` checks the store on both.
  ///
  /// Never throws — failures come back as [UpdateCheckError].
  ///
  /// Calling this while a check is already running does **not** start a second
  /// request: both callers await the same result. That makes it safe to wire
  /// straight to a button, where a user who sees no immediate feedback will tap
  /// again.
  ///
  /// Pass [preview] during development to skip the check entirely and force a
  /// canned outcome — the only way to see the screen before your app is on a
  /// store. It leaves [config] untouched, warns in debug and throws in release.
  static Future<UpdateCheckResult> checkUpdate({
    AppConfig config = const AppConfig(),
    UpdatePreview? preview,
  }) {
    final running = _inFlight;
    if (running != null) return running;

    final future = AppUpgrade().run(config, preview: preview);
    _inFlight = future;
    // Cleared however it settles, so a later check can run normally.
    return future.whenComplete(() => _inFlight = null);
  }

  /// Convenience: checks and, if an update is available, shows a prompt — all in
  /// one call. Use this when you just want the common behaviour and don't need
  /// to handle the result yourself.
  ///
  /// Safe to call from `initState` / app startup: it waits for the first frame
  /// so the [Navigator] is ready before showing anything.
  ///
  /// - Pass [builder] to render **your own** widget for the update (it receives
  ///   the [UpdateAvailable]); omit it to show the built-in [AppUpgradeScreen].
  /// - Pass [theme] to pick a design for the built-in screen, or to tweak one:
  ///   `AppUpgradeTheme.cosmic().copyWith(showFeatures: false)`.
  /// - Pass [preview] during development to force an outcome without a network
  ///   check — see [UpdatePreview]. Remove it before you release.
  /// - On [UpdateCheckError] the user sees nothing, but the error is logged with
  ///   `debugPrint` (debug builds only) and forwarded to [onError] if provided
  ///   — hook that to Crashlytics/Sentry, etc.
  ///
  /// Returns the raw [UpdateCheckResult] too, in case you still want it.
  static Future<UpdateCheckResult> checkAndPrompt(
    BuildContext context, {
    AppConfig config = const AppConfig(),
    UpdatePreview? preview,
    Widget Function(UpdateAvailable update)? builder,
    AppUpgradeTheme? theme,
    void Function(UpdateCheckError error)? onError,
  }) async {
    final result = await checkUpdate(config: config, preview: preview);

    if (result is UpdateCheckError) {
      debugPrint(
          "======🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥======");
      debugPrint('AppUpgrade: update check failed — $result');
      onError?.call(result);
      debugPrint(
          "======🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥======");

      return result;
    }

    if (result is UpdateAvailable) {
      // A prompt is already up — never stack a second one over it.
      if (_isPrompting) return result;

      // Defer to the next frame so a Navigator is available even when called
      // straight from initState.
      await _afterFrame();
      if (context.mounted) {
        if (builder != null) {
          // The custom-widget path owns the flag itself; showUpdateDialog sets
          // its own, so setting it here too would deadlock that branch.
          _isPrompting = true;
          try {
            await Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => builder(result),
              ),
            );
          } finally {
            _isPrompting = false;
          }
        } else {
          await showUpdateDialog(context, result, theme: theme);
        }
      }
    }
    return result;
  }

  /// Waits for the tree to be ready for a [Navigator] push — but only when it
  /// is not ready already.
  ///
  /// Called mid-build (the `initState` case) there is no Navigator yet, so the
  /// push has to wait for the frame to finish. Called from a button the tree is
  /// idle and complete, and there is nothing to wait for.
  ///
  /// The distinction matters: a post-frame callback runs only if a frame is
  /// actually produced, and an idle app schedules none. Waiting unconditionally
  /// would hang the first press until something else happened to draw a frame —
  /// which is why the caller appeared to need two taps.
  static Future<void> _afterFrame() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      return Future<void>.value();
    }

    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) => completer.complete());
    return completer.future;
  }

  /// Instance entry point used by [checkUpdate] and by tests (which inject a
  /// network service via the constructor).
  Future<UpdateCheckResult> run(
    AppConfig config, {
    UpdatePreview? preview,
  }) async {
    final AppInfo appInfo;
    try {
      appInfo = await AppInfo.load();
    } catch (e) {
      return UpdateCheckError(
        state: AppErrorState.server,
        message: 'failed to read app info: $e',
      );
    }

    // A preview replaces the real source outright, so nothing hits the network.
    final source = preview != null
        ? PreviewFetcher(preview: preview, appInfo: appInfo)
        : _resolveSource(config, appInfo);
    final response = await source.fetchLatest();
    if (response.hasError || response.data == null) {
      return UpdateCheckError(
        state: response.state,
        message: response.message,
      );
    }

    final data = response.data!;
    return (data.hasUpdate ?? false) ? UpdateAvailable(data) : NoUpdate(data);
  }

  /// Builds the concrete [UpdateSource] for the platform's chosen method,
  /// defaulting a `null` method to the plain store check.
  UpdateSource _resolveSource(AppConfig config, AppInfo appInfo) {
    return switch (appInfo.platform) {
      // A null method defaults to the plain store check.
      PlatformType.android => switch (
            config.android ?? const PlayStoreSource()) {
          PlayStoreSource(
            :final forcePolicy,
            :final language,
            :final country
          ) =>
            PlayStoreFetcher(
              appInfo: appInfo,
              language: language,
              country: country,
              forcePolicy: forcePolicy,
            ),
          final CustomSource s => _remote(s, appInfo),
        },
      PlatformType.ios => switch (config.ios ?? const AppStoreSource()) {
          AppStoreSource(:final forcePolicy, :final appleId, :final country) =>
            AppStoreFetcher(
              network: _network,
              appInfo: appInfo,
              appleId: appleId,
              country: country,
              forcePolicy: forcePolicy,
            ),
          final CustomSource s => _remote(s, appInfo),
        },
    };
  }

  RemoteFetcher _remote(CustomSource s, AppInfo appInfo) => RemoteFetcher(
        network: _network,
        url: s.url,
        appInfo: appInfo,
        headers: s.headers,
        fallbackStoreUrl: s.fallbackStoreUrl,
      );

  /// Opens [storeUrl] in the store app or browser. Returns whether it launched.
  static Future<bool> openStore(String storeUrl) async {
    final uri = Uri.tryParse(storeUrl);
    if (uri == null) return false;
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Shows the built-in update screen. Optional — consumers may render their
  /// own UI from the [UpdateAvailable] result instead.
  ///
  /// [update] drives the screen: `isForceUpdate` decides whether it can be
  /// dismissed, and `versionName` / `releaseNotes` fill the defaults.
  ///
  /// [theme] is the screen's complete look — texts, colors, assets and the
  /// order of the blocks. Defaults to [AppUpgradeTheme.cosmic]. When the
  /// theme's `description.text` is unset, the update's release notes are shown
  /// instead.
  ///
  /// Calling this while the screen is already up is a no-op, so a double tap
  /// cannot stack two copies.
  static Future<void> showUpdateDialog(
    BuildContext context,
    UpdateAvailable update, {
    AppUpgradeTheme? theme,
  }) async {
    if (_isPrompting) return;
    _isPrompting = true;

    final screen = AppUpgradeScreen(
      isMandatory: update.isForceUpdate,
      versionName: update.versionName,
      // The screen falls back to these when the theme has no description.
      releaseNotes: update.releaseNotes,
      theme: theme,
      onUpdate: () {
        final url = update.storeUrl;
        if (url != null) openStore(url);
      },
      onSkip:
          update.isForceUpdate ? null : () => Navigator.of(context).maybePop(),
    );

    try {
      // A transition-less route: the screen plays its own entrance (see
      // AppUpgradeTheme.entrance), so the platform's push animation would fight
      // it. The reverse transition still fades, so dismissing does not snap.
      await Navigator.of(context).push<void>(
        PageRouteBuilder<void>(
          fullscreenDialog: true,
          opaque: false,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (_, __, ___) => screen,
          transitionsBuilder: (_, animation, secondary, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    } finally {
      _isPrompting = false;
    }
  }
}
