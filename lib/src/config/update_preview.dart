import 'package:app_upgrade/src/data/models/app_update_data.dart';

/// Forces a canned result instead of checking anything, so you can build and
/// preview the update screen **before your app is on a store**.
///
/// Both store sources read a published listing, so neither works during
/// development. Passing a preview short-circuits the check entirely: no network,
/// instant (or deliberately delayed) answer, and whatever outcome you name.
///
/// It is deliberately **not** part of [AppConfig]: your real Android/iOS
/// configuration stays exactly where it is, and previewing is one extra argument
/// you add and delete without touching it.
///
/// ```dart
/// AppUpgrade.checkAndPrompt(
///   context,
///   config: myRealConfig,                        // untouched
///   preview: const UpdatePreview.optional(),     // add / remove this line
/// );
/// ```
///
/// ## The four outcomes
///
/// ```dart
/// UpdatePreview.optional()   // an update, dismissible — the common case
/// UpdatePreview.forced()     // an update, mandatory: no "Later", no back
/// UpdatePreview.upToDate()   // nothing to show
/// UpdatePreview.failure()    // the error path, to check your onError
/// ```
///
/// ## Safety
///
/// A preview prints a warning on every check in debug, and **throws in release
/// builds** — so it cannot reach production silently.
final class UpdatePreview {
  /// The payload handed to the library, exactly as a real source would return.
  /// `null` means the check fails.
  final AppUpdateData? data;

  /// How long to wait before answering.
  ///
  /// A real check takes a network round trip, so a zero delay hides bugs that
  /// only appear while one is in flight — an unguarded button, a missing
  /// spinner. Give it a beat to see what your users will see.
  final Duration delay;

  /// Message reported when [data] is `null`.
  final String errorMessage;

  const UpdatePreview({
    this.data,
    this.delay = Duration.zero,
    this.errorMessage = 'UpdatePreview: simulated failure',
  });

  /// An update is available and dismissible — the common case, with a "Later".
  ///
  /// [storeUrl] is what "Update now" opens; the default is a harmless page so a
  /// stray tap during development does not go somewhere confusing.
  UpdatePreview.optional({
    String versionName = '9.9.9',
    String? releaseNotes,
    String storeUrl = 'https://flutter.dev',
    Duration delay = const Duration(milliseconds: 600),
  }) : this(
          delay: delay,
          data: AppUpdateData(
            versionName: versionName,
            hasUpdate: true,
            isForceUpdate: false,
            storeUrl: storeUrl,
            releaseNotes: releaseNotes,
          ),
        );

  /// A mandatory update: the screen hides "Later" and blocks the back gesture.
  UpdatePreview.forced({
    String versionName = '9.9.9',
    String? releaseNotes,
    String storeUrl = 'https://flutter.dev',
    Duration delay = const Duration(milliseconds: 600),
  }) : this(
          delay: delay,
          data: AppUpdateData(
            versionName: versionName,
            hasUpdate: true,
            isForceUpdate: true,
            storeUrl: storeUrl,
            releaseNotes: releaseNotes,
          ),
        );

  /// Already on the latest version — nothing is shown.
  const UpdatePreview.upToDate({
    Duration delay = const Duration(milliseconds: 600),
  }) : this(
          delay: delay,
          data: const AppUpdateData(hasUpdate: false, versionName: '1.0.0'),
        );

  /// The check fails, so you can see how your `onError` behaves.
  const UpdatePreview.failure({
    String message = 'UpdatePreview: simulated failure',
    Duration delay = const Duration(milliseconds: 600),
  }) : this(delay: delay, errorMessage: message);

  /// Warns in debug, throws in release — so a preview can never ship.
  ///
  /// Called by the library on every check that goes through a preview.
  void warnNotForRelease() {
    // Stripped from release builds, which is why the throw below is separate.
    assert(() {
      // ignore: avoid_print
      print(
        'AppUpgrade: ⚠️  UpdatePreview is active — the update check is '
        'simulated, not real. Remove the `preview:` argument before you '
        'release.',
      );
      return true;
    }());

    if (const bool.fromEnvironment('dart.vm.product')) {
      throw StateError(
        'AppUpgrade: UpdatePreview reached a release build. It simulates the '
        'update check and must never ship — remove the `preview:` argument.',
      );
    }
  }
}
