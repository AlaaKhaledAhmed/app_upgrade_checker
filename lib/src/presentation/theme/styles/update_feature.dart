import 'package:flutter/material.dart';

/// One card in the feature row ("Faster / faster performance").
///
/// Every visual property is per-card, so the three cards can each carry their
/// own icon gradient, border and text colors:
///
/// ```dart
/// AppUpgradeTheme.cosmic().copyWith(
///   features: const [
///     UpdateFeature(
///       icon: Icons.bolt,
///       title: 'أسرع',
///       subtitle: 'أداء أسرع',
///       iconGradient: [Colors.orange, Colors.deepOrange],
///     ),
///     UpdateFeature(icon: Icons.lock, title: 'آمن', subtitle: 'حماية أفضل'),
///   ],
/// );
/// ```
///
/// Pass an empty list to hide the row, or set
/// [AppUpgradeTheme.showFeatures] to `false`.
@immutable
final class UpdateFeature {
  // Stored nullable so "not set" stays distinct from "set to the default" —
  // that is what lets [merge] fill only the gaps. Readers use the getters.
  final IconData? _icon;
  final Widget? _iconWidget;
  final String? _title;
  final String? _subtitle;
  final Color? _iconColor;
  final double? _iconSize;
  final List<Color>? _iconGradient;
  final Color? _iconBackgroundColor;
  final double? _iconBubbleSize;
  final bool? _iconShadow;
  final Color? _backgroundColor;
  final Color? _borderColor;
  final double? _borderWidth;
  final double? _radius;
  final EdgeInsetsGeometry? _padding;
  final Color? _titleColor;
  final Color? _subtitleColor;
  final double? _titleFontSize;
  final double? _subtitleFontSize;
  final FontWeight? _titleFontWeight;
  final FontWeight? _subtitleFontWeight;

  /// A partial style: **only the fields you name are yours**, the rest come from
  /// the design you pass it to.
  ///
  /// Ignore the design's feature card entirely.
  const UpdateFeature({
    IconData? icon,
    Widget? iconWidget,
    String? title,
    String? subtitle,
    Color? iconColor,
    double? iconSize,
    List<Color>? iconGradient,
    Color? iconBackgroundColor,
    double? iconBubbleSize,
    bool? iconShadow,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? radius,
    EdgeInsetsGeometry? padding,
    Color? titleColor,
    Color? subtitleColor,
    double? titleFontSize,
    double? subtitleFontSize,
    FontWeight? titleFontWeight,
    FontWeight? subtitleFontWeight,
  })  : _icon = icon,
        _iconWidget = iconWidget,
        _title = title,
        _subtitle = subtitle,
        _iconColor = iconColor,
        _iconSize = iconSize,
        _iconGradient = iconGradient,
        _iconBackgroundColor = iconBackgroundColor,
        _iconBubbleSize = iconBubbleSize,
        _iconShadow = iconShadow,
        _backgroundColor = backgroundColor,
        _borderColor = borderColor,
        _borderWidth = borderWidth,
        _radius = radius,
        _padding = padding,
        _titleColor = titleColor,
        _subtitleColor = subtitleColor,
        _titleFontSize = titleFontSize,
        _subtitleFontSize = subtitleFontSize,
        _titleFontWeight = titleFontWeight,
        _subtitleFontWeight = subtitleFontWeight;

  /// The icon. Ignored when [iconWidget] is set.
  IconData? get icon => _icon;

  /// A custom widget in place of [icon] — use this for an SVG or an image.
  Widget? get iconWidget => _iconWidget;

  /// Card headline. Hidden when `null` or empty.
  String? get title => _title;

  /// Card sub-line. Hidden when `null` or empty.
  String? get subtitle => _subtitle;

  /// Color of [icon].
  Color get iconColor => _iconColor ?? Colors.white;

  /// Size of [icon].
  double get iconSize => _iconSize ?? 30;

  /// Gradient filling the circle behind the icon. When `null` the circle is
  /// filled with [iconBackgroundColor] instead.
  List<Color>? get iconGradient => _iconGradient;

  /// Flat fill behind the icon, used when [iconGradient] is `null`.
  Color? get iconBackgroundColor => _iconBackgroundColor;

  /// Diameter of the icon circle.
  double get iconBubbleSize => _iconBubbleSize ?? 50;

  /// Whether the icon circle casts a shadow.
  bool get iconShadow => _iconShadow ?? true;

  /// Card fill. Defaults to transparent.
  Color get backgroundColor => _backgroundColor ?? Colors.transparent;

  /// Card border color. `null` hides the border.
  Color? get borderColor => _borderColor;

  /// Card border width.
  double get borderWidth => _borderWidth ?? 1.9;

  /// Card corner radius.
  double get radius => _radius ?? 20;

  /// Inner padding of the card.
  EdgeInsetsGeometry get padding =>
      _padding ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 20);

  Color get titleColor => _titleColor ?? Colors.white;

  Color get subtitleColor => _subtitleColor ?? Colors.white;

  double? get titleFontSize => _titleFontSize;

  double? get subtitleFontSize => _subtitleFontSize;

  FontWeight? get titleFontWeight => _titleFontWeight;

  FontWeight? get subtitleFontWeight => _subtitleFontWeight;

  /// Fills this style's unset fields from [base]. A style built with
  /// [UpdateFeature.replace] is returned untouched.
  UpdateFeature merge(UpdateFeature base) {
    return UpdateFeature(
      icon: _icon ?? base._icon,
      iconWidget: _iconWidget ?? base._iconWidget,
      title: _title ?? base._title,
      subtitle: _subtitle ?? base._subtitle,
      iconColor: _iconColor ?? base._iconColor,
      iconSize: _iconSize ?? base._iconSize,
      iconGradient: _iconGradient ?? base._iconGradient,
      iconBackgroundColor: _iconBackgroundColor ?? base._iconBackgroundColor,
      iconBubbleSize: _iconBubbleSize ?? base._iconBubbleSize,
      iconShadow: _iconShadow ?? base._iconShadow,
      backgroundColor: _backgroundColor ?? base._backgroundColor,
      borderColor: _borderColor ?? base._borderColor,
      borderWidth: _borderWidth ?? base._borderWidth,
      radius: _radius ?? base._radius,
      padding: _padding ?? base._padding,
      titleColor: _titleColor ?? base._titleColor,
      subtitleColor: _subtitleColor ?? base._subtitleColor,
      titleFontSize: _titleFontSize ?? base._titleFontSize,
      subtitleFontSize: _subtitleFontSize ?? base._subtitleFontSize,
      titleFontWeight: _titleFontWeight ?? base._titleFontWeight,
      subtitleFontWeight: _subtitleFontWeight ?? base._subtitleFontWeight,
    );
  }

  /// Returns a copy with the given fields replaced.
  UpdateFeature copyWith({
    IconData? icon,
    Widget? iconWidget,
    String? title,
    String? subtitle,
    Color? iconColor,
    double? iconSize,
    List<Color>? iconGradient,
    Color? iconBackgroundColor,
    double? iconBubbleSize,
    bool? iconShadow,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? radius,
    EdgeInsetsGeometry? padding,
    Color? titleColor,
    Color? subtitleColor,
    double? titleFontSize,
    double? subtitleFontSize,
    FontWeight? titleFontWeight,
    FontWeight? subtitleFontWeight,
  }) {
    return UpdateFeature(
      icon: icon ?? _icon,
      iconWidget: iconWidget ?? _iconWidget,
      title: title ?? _title,
      subtitle: subtitle ?? _subtitle,
      iconColor: iconColor ?? _iconColor,
      iconSize: iconSize ?? _iconSize,
      iconGradient: iconGradient ?? _iconGradient,
      iconBackgroundColor: iconBackgroundColor ?? _iconBackgroundColor,
      iconBubbleSize: iconBubbleSize ?? _iconBubbleSize,
      iconShadow: iconShadow ?? _iconShadow,
      backgroundColor: backgroundColor ?? _backgroundColor,
      borderColor: borderColor ?? _borderColor,
      borderWidth: borderWidth ?? _borderWidth,
      radius: radius ?? _radius,
      padding: padding ?? _padding,
      titleColor: titleColor ?? _titleColor,
      subtitleColor: subtitleColor ?? _subtitleColor,
      titleFontSize: titleFontSize ?? _titleFontSize,
      subtitleFontSize: subtitleFontSize ?? _subtitleFontSize,
      titleFontWeight: titleFontWeight ?? _titleFontWeight,
      subtitleFontWeight: subtitleFontWeight ?? _subtitleFontWeight,
    );
  }
}
