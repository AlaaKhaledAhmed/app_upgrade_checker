import 'package:flutter/material.dart';

/// What fills the screen behind everything else.
///
/// Modelled as a sealed hierarchy so a background is exactly one thing —
/// there is no "I set both a color and an image, which wins?" ambiguity:
///
/// ```dart
/// AppUpgradeTheme.cosmic().copyWith(
///   background: const UpdateBackground.solid(Color(0xff01114f)),
/// );
///
/// AppUpgradeTheme.cosmic().copyWith(
///   background: const UpdateBackground.asset(
///     'assets/img/space.png',   // your app's asset
///     package: null,            // null = the host app, not this package
///     color: Color(0xff01114f), // shows while the image loads / if it fails
///   ),
/// );
/// ```
@immutable
sealed class UpdateBackground {
  const UpdateBackground();

  /// A flat color.
  const factory UpdateBackground.solid(Color color) = SolidBackground;

  /// Any [Gradient] — linear, radial or sweep.
  const factory UpdateBackground.gradient(Gradient gradient) =
      GradientBackground;

  /// An asset image. [package] names the package that owns the asset; pass
  /// `null` for an asset in the host app.
  const factory UpdateBackground.asset(
    String path, {
    String? package,
    Color color,
    BoxFit fit,
    double opacity,
    AlignmentGeometry alignment,
    ColorFilter? colorFilter,
  }) = AssetBackground;

  /// A network image. [color] shows while it downloads and if it fails.
  const factory UpdateBackground.network(
    String url, {
    Color color,
    BoxFit fit,
    double opacity,
    AlignmentGeometry alignment,
    ColorFilter? colorFilter,
  }) = NetworkBackground;

  /// No background at all — the screen shows the ambient scaffold color.
  const factory UpdateBackground.none() = NoBackground;
}

/// A flat color background. See [UpdateBackground.solid].
final class SolidBackground extends UpdateBackground {
  final Color color;
  const SolidBackground(this.color);
}

/// A gradient background. See [UpdateBackground.gradient].
final class GradientBackground extends UpdateBackground {
  final Gradient gradient;
  const GradientBackground(this.gradient);
}

/// An asset-image background. See [UpdateBackground.asset].
final class AssetBackground extends UpdateBackground {
  final String path;

  /// Package that owns [path]. `null` means the host app's own assets.
  final String? package;

  /// Drawn under the image — visible while it loads, or if it fails.
  final Color color;
  final BoxFit fit;
  final double opacity;
  final AlignmentGeometry alignment;
  final ColorFilter? colorFilter;

  const AssetBackground(
    this.path, {
    this.package,
    this.color = const Color(0xff01114f),
    this.fit = BoxFit.cover,
    this.opacity = 1,
    this.alignment = Alignment.center,
    this.colorFilter,
  });
}

/// A network-image background. See [UpdateBackground.network].
final class NetworkBackground extends UpdateBackground {
  final String url;

  /// Drawn under the image — visible while it downloads, or if it fails.
  final Color color;
  final BoxFit fit;
  final double opacity;
  final AlignmentGeometry alignment;
  final ColorFilter? colorFilter;

  const NetworkBackground(
    this.url, {
    this.color = const Color(0xff01114f),
    this.fit = BoxFit.cover,
    this.opacity = 1,
    this.alignment = Alignment.center,
    this.colorFilter,
  });
}

/// No background. See [UpdateBackground.none].
final class NoBackground extends UpdateBackground {
  const NoBackground();
}
