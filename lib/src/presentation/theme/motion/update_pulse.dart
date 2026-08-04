import 'package:flutter/material.dart';

/// A slow glow that breathes behind the primary button, to keep the eye on the
/// action once the screen has settled.
///
/// ```dart
/// AppUpgradeTheme.cosmic(
///   pulse: const UpdatePulse(color: Colors.blueAccent),
/// );
/// ```
///
/// Pass `null` for [AppUpgradeTheme.pulse] to switch it off. It is also
/// suppressed automatically under the platform's "reduce motion" setting, and it
/// stops when the screen is not visible, so it costs nothing in the background.
@immutable
final class UpdatePulse {
  /// The glow color. When `null` the button's own fill is used, which keeps the
  /// glow in the design's palette without naming a color twice.
  final Color? color;

  /// One full breath, out and back.
  final Duration period;

  /// Blur at the dimmest point of the cycle.
  final double minBlur;

  /// Blur at the brightest point.
  final double maxBlur;

  /// Opacity at the dimmest point.
  final double minOpacity;

  /// Opacity at the brightest point. Keep this modest — a glow that reads as a
  /// flash is more annoying than persuasive.
  final double maxOpacity;

  /// How far the glow spreads beyond the button's edge.
  final double spread;

  const UpdatePulse({
    this.color,
    this.period = const Duration(milliseconds: 2000),
    this.minBlur = 8,
    this.maxBlur = 22,
    this.minOpacity = 0.18,
    this.maxOpacity = 0.5,
    this.spread = 1,
  });

  /// Returns a copy with the given fields replaced.
  UpdatePulse copyWith({
    Color? color,
    Duration? period,
    double? minBlur,
    double? maxBlur,
    double? minOpacity,
    double? maxOpacity,
    double? spread,
  }) {
    return UpdatePulse(
      color: color ?? this.color,
      period: period ?? this.period,
      minBlur: minBlur ?? this.minBlur,
      maxBlur: maxBlur ?? this.maxBlur,
      minOpacity: minOpacity ?? this.minOpacity,
      maxOpacity: maxOpacity ?? this.maxOpacity,
      spread: spread ?? this.spread,
    );
  }
}
