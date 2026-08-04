import 'package:flutter/material.dart';

import 'package:app_upgrade_checker/src/presentation/theme/motion/dialog_entrance.dart';

/// Plays a [DialogEntrance] over the dialog or the sheet.
///
/// Unlike the full screen's `EntranceAnimator`, there is nothing to move
/// independently here — the backdrop and the content are one clipped card — so
/// every variant animates the card as a whole.
///
/// Under reduce-motion each variant collapses to a short fade, since scaling and
/// sliding a card is exactly what that setting exists to prevent.
///
/// Internal: not exported from the package barrel.
final class DialogEntranceAnimator extends StatefulWidget {
  final DialogEntrance entrance;

  /// The card to animate.
  final Widget child;

  const DialogEntranceAnimator({
    super.key,
    required this.entrance,
    required this.child,
  });

  @override
  State<DialogEntranceAnimator> createState() => _DialogEntranceAnimatorState();
}

class _DialogEntranceAnimatorState extends State<DialogEntranceAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.entrance.duration,
  );

  /// Set once the first frame has told us whether motion is allowed.
  bool _started = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final entrance = widget.entrance;

    // Start on the first build, now that MediaQuery is available.
    if (!_started) {
      _started = true;
      if (entrance is DialogNoEntrance) {
        _controller.value = 1;
      } else {
        _controller.duration = reduceMotion
            ? const Duration(milliseconds: 160)
            : entrance.duration;
        _controller.forward();
      }
    }

    if (entrance is DialogNoEntrance) return widget.child;

    // Scale and slide both move the whole card, so reduce-motion takes the fade.
    if (reduceMotion || entrance is DialogFadeEntrance) {
      return _fade(widget.child);
    }

    return switch (entrance) {
      PopInEntrance(:final fromScale, :final overshoot) =>
        _popIn(fromScale, overshoot),
      DialogSlideUpEntrance() => _slideUp(),
      // Handled above, but the switch must be exhaustive.
      DialogFadeEntrance() || DialogNoEntrance() => _fade(widget.child),
    };
  }

  Widget _fade(Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: child,
    );
  }

  /// [DialogEntrance.popIn] — zooms up to its natural size.
  ///
  /// The fade runs on its own curve so the card is already legible while the
  /// last of the scale plays out.
  Widget _popIn(double fromScale, bool overshoot) {
    final scale = Tween<double>(begin: fromScale, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        // easeOutBack passes 1.0 by a hair and settles back onto it.
        curve: overshoot ? Curves.easeOutBack : Curves.easeOutCubic,
      ),
    );

    return _fade(ScaleTransition(scale: scale, child: widget.child));
  }

  /// [DialogEntrance.slideUp] — rises from the bottom edge.
  Widget _slideUp() {
    final travel = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    return _fade(SlideTransition(position: travel, child: widget.child));
  }
}
