import 'package:flutter/material.dart';

import 'package:app_upgrade_checker/src/core/extensions/color_extensions.dart';
import 'package:app_upgrade_checker/src/presentation/theme/motion/update_pulse.dart';

/// Wraps the primary button in a slow breathing glow.
///
/// The glow is painted behind [child] only — it never affects layout, so turning
/// it on cannot shift the button or change the column's height.
///
/// Suppressed entirely under the platform's reduce-motion setting, where it
/// renders [child] untouched.
///
/// Internal: not exported from the package barrel.
final class PulseGlow extends StatefulWidget {
  final UpdatePulse pulse;

  /// Fallback glow color, used when [UpdatePulse.color] is null. Normally the
  /// button's own fill, so the glow stays in the design's palette.
  final Color fallbackColor;

  /// Corner radius of the glow, matched to the button's own radius.
  final double radius;

  final Widget child;

  const PulseGlow({
    super.key,
    required this.pulse,
    required this.fallbackColor,
    required this.radius,
    required this.child,
  });

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.pulse.period,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Honour reduce motion: no glow at all rather than a static halo, which
    // would read as an unexplained shadow.
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    // repeat(reverse: true) gives the out-and-back breath in one controller.
    if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }

    final pulse = widget.pulse;
    final color = pulse.color ?? widget.fallbackColor;
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    return AnimatedBuilder(
      animation: curve,
      child: widget.child,
      builder: (context, child) {
        final t = curve.value;
        final blur = pulse.minBlur + (pulse.maxBlur - pulse.minBlur) * t;
        final opacity =
            pulse.minOpacity + (pulse.maxOpacity - pulse.minOpacity) * t;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: [
              BoxShadow(
                color: color.resolveOpacity(opacity),
                blurRadius: blur,
                spreadRadius: pulse.spread,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}
