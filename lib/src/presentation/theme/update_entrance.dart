import 'package:flutter/material.dart';

/// How the update screen arrives on screen.
///
/// Picked per design, exactly like colors and copy:
///
/// ```dart
/// AppUpgradeTheme.cosmic(
///   entrance: const UpdateEntrance.rocketPull(),
/// );
/// ```
///
/// ## Why these are short
///
/// The screen does not appear when the app launches — it appears after a network
/// round trip to the store or your backend, which is itself 200ms–2s. Any
/// entrance is therefore *added* to a wait the user has already served, so every
/// variant here stays at or under 600ms and starts revealing text well before it
/// finishes. A cinematic multi-second liftoff reads as jank, not polish.
///
/// ## Reduce motion
///
/// When the platform's "reduce motion" accessibility setting is on
/// ([MediaQuery.disableAnimationsOf]), every variant degrades to a short fade
/// automatically — these animations move large areas, which is exactly what that
/// setting exists to prevent. Nothing to configure.
@immutable
sealed class UpdateEntrance {
  /// Total length of the entrance.
  final Duration duration;

  const UpdateEntrance({required this.duration});

  /// The whole panel rises from below while the artwork runs slightly ahead of
  /// it, so the artwork reads as *pulling* the page up. The content then fades
  /// in block by block.
  ///
  /// The signature entrance for a rocket design.
  const factory UpdateEntrance.rocketPull({
    Duration duration,
    double parallax,
    Duration stagger,
  }) = RocketPullEntrance;

  /// Dropping out of faster-than-light: the screen eases down from a slight
  /// over-scale as it fades in, like a ship settling after a jump.
  ///
  /// The cheapest of the expressive options — it animates opacity and scale
  /// only, no layout.
  const factory UpdateEntrance.warpIn({
    Duration duration,
    double fromScale,
  }) = WarpInEntrance;

  /// The background sinks while the content holds still, so the camera seems to
  /// climb with the rocket.
  ///
  /// Only the backdrop moves, which makes this the smoothest option on low-end
  /// devices.
  const factory UpdateEntrance.liftoff({
    Duration duration,
    double backdropDrop,
  }) = LiftoffEntrance;

  /// The content descends from above — the mirror of [UpdateEntrance.rocketPull],
  /// for a design about something arriving to help rather than departing.
  const factory UpdateEntrance.descend({
    Duration duration,
    double parallax,
    Duration stagger,
  }) = DescendEntrance;

  /// A plain slide up from the bottom edge. No parallax, no stagger.
  const factory UpdateEntrance.slideUp({Duration duration}) = SlideUpEntrance;

  /// A plain cross-fade. The safest choice, and what every other variant falls
  /// back to under reduce-motion.
  const factory UpdateEntrance.fade({Duration duration}) = FadeEntrance;

  /// No entrance at all — the screen is simply there.
  const factory UpdateEntrance.none() = NoEntrance;
}

/// The artwork pulls the page up. See [UpdateEntrance.rocketPull].
final class RocketPullEntrance extends UpdateEntrance {
  /// How much further the artwork travels than the panel, as a fraction of the
  /// panel's own travel. `0.35` means the artwork leads by 35%.
  final double parallax;

  /// Delay between consecutive blocks fading in.
  final Duration stagger;

  const RocketPullEntrance({
    super.duration = const Duration(milliseconds: 900),
    this.parallax = 0.35,
    this.stagger = const Duration(milliseconds: 40),
  });
}

/// Settling out of a warp jump. See [UpdateEntrance.warpIn].
final class WarpInEntrance extends UpdateEntrance {
  /// Starting scale, eased down to 1.0. Keep it near 1 — a large value reads as
  /// a zoom, not a jump.
  final double fromScale;

  const WarpInEntrance({
    super.duration = const Duration(milliseconds: 900),
    this.fromScale = 1.08,
  });
}

/// The backdrop sinks. See [UpdateEntrance.liftoff].
final class LiftoffEntrance extends UpdateEntrance {
  /// How far the backdrop travels down, in logical pixels.
  final double backdropDrop;

  const LiftoffEntrance({
    super.duration = const Duration(milliseconds: 900),
    this.backdropDrop = 90,
  });
}

/// The content descends from above. See [UpdateEntrance.descend].
final class DescendEntrance extends UpdateEntrance {
  /// How much further the artwork travels than the panel, as a fraction of the
  /// panel's own travel.
  final double parallax;

  /// Delay between consecutive blocks fading in.
  final Duration stagger;

  const DescendEntrance({
    super.duration = const Duration(milliseconds: 900),
    this.parallax = 0.3,
    this.stagger = const Duration(milliseconds: 40),
  });
}

/// A plain slide up. See [UpdateEntrance.slideUp].
final class SlideUpEntrance extends UpdateEntrance {
  const SlideUpEntrance({
    super.duration = const Duration(milliseconds: 900),
  });
}

/// A plain cross-fade. See [UpdateEntrance.fade].
final class FadeEntrance extends UpdateEntrance {
  const FadeEntrance({
    super.duration = const Duration(milliseconds: 900),
  });
}

/// No entrance. See [UpdateEntrance.none].
final class NoEntrance extends UpdateEntrance {
  const NoEntrance() : super(duration: Duration.zero);
}
