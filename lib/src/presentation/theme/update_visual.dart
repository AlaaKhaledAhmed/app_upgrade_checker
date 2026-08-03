import 'package:flutter/material.dart';

/// The artwork at the top of the screen.
///
/// Sealed, so a visual is exactly one kind of thing:
///
/// ```dart
/// // your own Lottie file
/// UpdateVisual.lottie('assets/anim/rocket.json', package: null)
///
/// // a plain image
/// UpdateVisual.asset('assets/img/hero.png', package: null)
///
/// // just an icon, no asset needed
/// UpdateVisual.icon(Icons.system_update_rounded, color: Colors.white)
///
/// // anything at all
/// UpdateVisual.custom((context) => MyHeroAnimation())
/// ```
///
/// [heightFactor] sizes the block as a fraction of the screen height, so the
/// artwork scales across devices. Pass [height] instead for a fixed size.
@immutable
sealed class UpdateVisual {
  /// Fraction of the screen height the visual occupies. Ignored when [height]
  /// is set.
  final double heightFactor;

  /// Fixed height in logical pixels. Overrides [heightFactor] when set.
  final double? height;

  const UpdateVisual({this.heightFactor = 0.35, this.height});

  /// A Lottie animation. [package] names the package that owns the file; pass
  /// `null` for a file in the host app.
  const factory UpdateVisual.lottie(
    String path, {
    String? package,
    double heightFactor,
    double? height,
    bool repeat,
    BoxFit fit,
  }) = LottieVisual;

  /// A static asset image.
  const factory UpdateVisual.asset(
    String path, {
    String? package,
    double heightFactor,
    double? height,
    BoxFit fit,
  }) = AssetVisual;

  /// A static network image.
  const factory UpdateVisual.network(
    String url, {
    double heightFactor,
    double? height,
    BoxFit fit,
  }) = NetworkVisual;

  /// An icon, optionally inside a gradient circle.
  const factory UpdateVisual.icon(
    IconData icon, {
    Color color,
    double size,
    List<Color>? circleGradient,
    double? circleSize,
    double heightFactor,
    double? height,
  }) = IconVisual;

  /// Your own widget — the escape hatch when none of the above fits.
  const factory UpdateVisual.custom(
    WidgetBuilder builder, {
    double heightFactor,
    double? height,
  }) = CustomVisual;
}

/// A Lottie animation. See [UpdateVisual.lottie].
final class LottieVisual extends UpdateVisual {
  final String path;

  /// Package that owns [path]. `null` means the host app's own assets.
  final String? package;
  final bool repeat;
  final BoxFit fit;

  const LottieVisual(
    this.path, {
    this.package,
    super.heightFactor,
    super.height,
    this.repeat = true,
    this.fit = BoxFit.contain,
  });
}

/// A static asset image. See [UpdateVisual.asset].
final class AssetVisual extends UpdateVisual {
  final String path;

  /// Package that owns [path]. `null` means the host app's own assets.
  final String? package;
  final BoxFit fit;

  const AssetVisual(
    this.path, {
    this.package,
    super.heightFactor,
    super.height,
    this.fit = BoxFit.contain,
  });
}

/// A static network image. See [UpdateVisual.network].
final class NetworkVisual extends UpdateVisual {
  final String url;
  final BoxFit fit;

  const NetworkVisual(
    this.url, {
    super.heightFactor,
    super.height,
    this.fit = BoxFit.contain,
  });
}

/// An icon, optionally in a gradient circle. See [UpdateVisual.icon].
final class IconVisual extends UpdateVisual {
  final IconData icon;
  final Color color;
  final double size;

  /// When set, the icon sits inside a circle filled with this gradient.
  final List<Color>? circleGradient;

  /// Diameter of that circle. Defaults to `size * 2.4`.
  final double? circleSize;

  const IconVisual(
    this.icon, {
    this.color = Colors.white,
    this.size = 64,
    this.circleGradient,
    this.circleSize,
    super.heightFactor = 0.25,
    super.height,
  });
}

/// Your own widget. See [UpdateVisual.custom].
final class CustomVisual extends UpdateVisual {
  final WidgetBuilder builder;

  const CustomVisual(
    this.builder, {
    super.heightFactor,
    super.height,
  });
}
