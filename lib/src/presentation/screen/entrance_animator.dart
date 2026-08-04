import 'package:flutter/material.dart';

import 'package:app_upgrade_checker/src/presentation/theme/motion/update_entrance.dart';

/// Plays an [UpdateEntrance] over the update screen.
///
/// It builds the backdrop and the content separately so a variant can move them
/// at different rates — that difference is what sells [RocketPullEntrance]'s
/// "the rocket is pulling the page" and [LiftoffEntrance]'s climbing camera.
///
/// Under the platform's reduce-motion setting every variant collapses to a short
/// fade, because all of them translate or scale large areas.
///
/// Internal: not exported from the package barrel.
final class EntranceAnimator extends StatefulWidget {
  final UpdateEntrance entrance;

  /// The full-bleed background.
  final Widget backdrop;

  /// The scrolling content column, laid over [backdrop].
  final Widget content;

  const EntranceAnimator({
    super.key,
    required this.entrance,
    required this.backdrop,
    required this.content,
  });

  @override
  State<EntranceAnimator> createState() => _EntranceAnimatorState();
}

class _EntranceAnimatorState extends State<EntranceAnimator>
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

    // Start on the first build, now that MediaQuery is available. A zero-length
    // entrance (or reduce-motion with nothing to play) just lands at the end.
    if (!_started) {
      _started = true;
      if (entrance is NoEntrance) {
        _controller.value = 1;
      } else {
        // Reduce motion still fades, just briefly.
        _controller.duration = reduceMotion
            ? const Duration(milliseconds: 160)
            : entrance.duration;
        _controller.forward();
      }
    }

    // Every large-area move is replaced by a fade when motion is reduced.
    if (reduceMotion || entrance is NoEntrance || entrance is FadeEntrance) {
      return _fade(_stack(widget.backdrop, widget.content));
    }

    return switch (entrance) {
      RocketPullEntrance(:final parallax, :final stagger) =>
        _slide(parallax: parallax, stagger: stagger, fromBelow: true),
      DescendEntrance(:final parallax, :final stagger) =>
        _slide(parallax: parallax, stagger: stagger, fromBelow: false),
      WarpInEntrance(:final fromScale) => _warp(fromScale),
      LiftoffEntrance(:final backdropDrop) => _liftoff(backdropDrop),
      SlideUpEntrance() =>
        _slide(parallax: 0, stagger: Duration.zero, fromBelow: true),
      // Handled above, but the switch must be exhaustive.
      FadeEntrance() || NoEntrance() => _fade(
          _stack(widget.backdrop, widget.content),
        ),
    };
  }

  Widget _stack(Widget backdrop, Widget content) {
    return Stack(
      fit: StackFit.expand,
      children: [backdrop, content],
    );
  }

  Widget _fade(Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: child,
    );
  }

  /// [RocketPullEntrance] / [DescendEntrance] / [SlideUpEntrance].
  ///
  /// The backdrop is pinned so only the content travels; the content's own
  /// artwork leads it by [parallax], which is what reads as being pulled.
  Widget _slide({
    required double parallax,
    required Duration stagger,
    required bool fromBelow,
  }) {
    final direction = fromBelow ? 1.0 : -1.0;

    // The panel arrives before the controller finishes, leaving the tail of the
    // timeline for the content to fade in — so text is readable early.
    final travel = Tween<Offset>(
      begin: Offset(0, direction),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.78, curve: Curves.easeOutCubic),
      ),
    );

    // Runs further than the panel, then eases back to meet it.
    final lead = Tween<Offset>(
      begin: Offset(0, direction * parallax),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 1, curve: Curves.easeOutCubic),
      ),
    );

    final reveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 1, curve: Curves.easeOut),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.backdrop,
        SlideTransition(
          position: travel,
          child: FadeTransition(
            opacity: reveal,
            // The extra lead is applied on top of the panel's own travel.
            child: parallax == 0
                ? widget.content
                : SlideTransition(position: lead, child: widget.content),
          ),
        ),
      ],
    );
  }

  /// [WarpInEntrance] — opacity and scale only, no layout work.
  Widget _warp(double fromScale) {
    final scale = Tween<double>(begin: fromScale, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    return _fade(
      ScaleTransition(
        scale: scale,
        child: _stack(widget.backdrop, widget.content),
      ),
    );
  }

  /// [LiftoffEntrance] — the backdrop sinks, the content holds still and fades.
  Widget _liftoff(double drop) {
    final sink = Tween<double>(begin: -drop, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    final reveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 1, curve: Curves.easeOut),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: sink,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, sink.value),
            child: child,
          ),
          child: widget.backdrop,
        ),
        FadeTransition(opacity: reveal, child: widget.content),
      ],
    );
  }
}
