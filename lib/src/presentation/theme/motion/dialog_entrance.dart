import 'package:flutter/material.dart';

/// How the **dialog** and the **bottom sheet** arrive.
///
/// Read only when the theme's `viewType` is [UpdateViewType.dialog] or
/// [UpdateViewType.sheet]. Under [UpdateViewType.screen] this is ignored
/// entirely and the screen uses `UpdateEntrance` instead — so one theme may
/// carry both and switch between them:
///
/// ```dart
/// final theme = AppUpgradeTheme.cosmic(
///   entrance: const UpdateEntrance.liftoff(),        // used as a screen
///   dialogEntrance: const DialogEntrance.slideUp(),  // used as a dialog
/// );
///
/// theme;                                                  // screen, liftoff
/// theme.copyWith(viewType: UpdateViewType.dialog);         // dialog, slideUp
/// ```
///
/// This is a separate type from `UpdateEntrance` on purpose: the screen's
/// variants are built on moving the backdrop and the content apart by a screen
/// height, and a dialog draws both inside one clipped card. Keeping the types
/// apart means a screen-only entrance cannot be handed to a dialog — the
/// compiler rejects it, so there is no silent fallback to explain.
///
/// ## Reduce motion
///
/// When the platform's "reduce motion" setting is on
/// ([MediaQuery.disableAnimationsOf]), every variant except [DialogEntrance.none]
/// degrades to a short fade. Nothing to configure.
@immutable
sealed class DialogEntrance {
  /// Total length of the entrance.
  final Duration duration;

  const DialogEntrance({required this.duration});

  /// Zooms up from smaller to its natural size while fading in — the default,
  /// and what a dialog is expected to do on both platforms.
  ///
  /// [fromScale] is where the zoom starts, as a fraction of the final size.
  /// [overshoot] lets it pass the final size by a hair and settle back, which
  /// is what keeps the motion from reading as mechanical; pass `false` for a
  /// clean stop.
  const factory DialogEntrance.popIn({
    Duration duration,
    double fromScale,
    bool overshoot,
  }) = PopInEntrance;

  /// Slides up from the bottom edge while fading in. The natural choice for
  /// [UpdateViewType.sheet].
  const factory DialogEntrance.slideUp({Duration duration}) =
      DialogSlideUpEntrance;

  /// A plain cross-fade — the quietest option, and where the others land under
  /// reduce-motion.
  const factory DialogEntrance.fade({Duration duration}) = DialogFadeEntrance;

  /// No entrance at all: the dialog is simply there.
  const factory DialogEntrance.none() = DialogNoEntrance;
}

/// Zooms up to its natural size. See [DialogEntrance.popIn].
final class PopInEntrance extends DialogEntrance {
  /// Starting scale, eased up to 1.0.
  final double fromScale;

  /// Whether to pass 1.0 slightly and settle back.
  final bool overshoot;

  const PopInEntrance({
    super.duration = const Duration(milliseconds: 220),
    this.fromScale = 0.85,
    this.overshoot = true,
  });
}

/// Slides up from the bottom edge. See [DialogEntrance.slideUp].
final class DialogSlideUpEntrance extends DialogEntrance {
  const DialogSlideUpEntrance({
    super.duration = const Duration(milliseconds: 260),
  });
}

/// A plain cross-fade. See [DialogEntrance.fade].
final class DialogFadeEntrance extends DialogEntrance {
  const DialogFadeEntrance({
    super.duration = const Duration(milliseconds: 200),
  });
}

/// No entrance. See [DialogEntrance.none].
final class DialogNoEntrance extends DialogEntrance {
  const DialogNoEntrance() : super(duration: Duration.zero);
}
