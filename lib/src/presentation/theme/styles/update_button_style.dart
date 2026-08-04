import 'package:flutter/material.dart';

/// The primary call-to-action ("UPDATE NOW").
///
/// The label, its icon, the fill and the border are all here, so the button can
/// be restyled without touching the screen:
///
/// ```dart
/// AppUpgradeTheme.cosmic().copyWith(
///   updateButton: const UpdateButtonStyle(
///     text: 'حدّث الآن',
///     icon: Icons.download_rounded,
///     gradient: [Colors.teal, Colors.green],
///   ),
/// );
/// ```
///
/// Set [icon] and [iconWidget] to `null` for a text-only button.
@immutable
final class UpdateButtonStyle {
  // Stored nullable so "not set" stays distinguishable from "set to the default
  // value" — that distinction is what makes [merge] able to fill only the gaps.
  // Readers use the getters below, which resolve a null to the default.
  final String? _text;
  final IconData? _icon;
  final Widget? _iconWidget;
  final Color? _iconColor;
  final double? _iconSize;
  final List<Color>? _gradient;
  final AlignmentGeometry? _gradientBegin;
  final AlignmentGeometry? _gradientEnd;
  final Color? _backgroundColor;
  final Color? _textColor;
  final double? _fontSize;
  final FontWeight? _fontWeight;
  final Color? _borderColor;
  final double? _borderWidth;
  final double? _radius;
  final EdgeInsetsGeometry? _padding;
  final double? _iconSpacing;

  /// A partial style: **only the fields you name are yours**, the rest come
  /// from the design you pass it to.
  ///
  /// ```dart
  /// AppUpgradeTheme.cosmic(
  ///   updateButton: const UpdateButtonStyle(text: 'حدّث الآن'),
  /// ); // your label, Cosmic's gradient, icon and border
  /// ```
  ///
  /// Use [UpdateButtonStyle.replace] when you want none of the design's values.
  const UpdateButtonStyle({
    String? text,
    IconData? icon,
    Widget? iconWidget,
    Color? iconColor,
    double? iconSize,
    List<Color>? gradient,
    AlignmentGeometry? gradientBegin,
    AlignmentGeometry? gradientEnd,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    FontWeight? fontWeight,
    Color? borderColor,
    double? borderWidth,
    double? radius,
    EdgeInsetsGeometry? padding,
    double? iconSpacing,
  })  : _text = text,
        _icon = icon,
        _iconWidget = iconWidget,
        _iconColor = iconColor,
        _iconSize = iconSize,
        _gradient = gradient,
        _gradientBegin = gradientBegin,
        _gradientEnd = gradientEnd,
        _backgroundColor = backgroundColor,
        _textColor = textColor,
        _fontSize = fontSize,
        _fontWeight = fontWeight,
        _borderColor = borderColor,
        _borderWidth = borderWidth,
        _radius = radius,
        _padding = padding,
        _iconSpacing = iconSpacing;

  /// Button label.
  String get text => _text ?? 'UPDATE NOW';

  /// Leading icon. Falls back to the default rocket unless an [iconWidget] is
  /// supplied instead — passing one is how you replace the icon, and passing
  /// neither on a [UpdateButtonStyle.replace] gives the default.
  IconData? get icon =>
      _icon ?? (_iconWidget == null ? Icons.rocket_launch_rounded : null);

  /// A custom widget in place of [icon] — for an SVG or an image.
  Widget? get iconWidget => _iconWidget;

  /// Color of [icon].
  Color get iconColor => _iconColor ?? Colors.white;

  /// Size of [icon].
  double? get iconSize => _iconSize;

  /// Gradient fill. When `null`, [backgroundColor] is used instead.
  List<Color>? get gradient => _gradient;

  /// Where the [gradient] starts.
  AlignmentGeometry get gradientBegin => _gradientBegin ?? Alignment.centerLeft;

  /// Where the [gradient] ends.
  AlignmentGeometry get gradientEnd => _gradientEnd ?? Alignment.centerRight;

  /// Flat fill, used when [gradient] is `null`.
  Color? get backgroundColor => _backgroundColor;

  /// Label color.
  Color get textColor => _textColor ?? Colors.white;

  /// Label size.
  double? get fontSize => _fontSize;

  /// Label weight.
  FontWeight get fontWeight => _fontWeight ?? FontWeight.bold;

  /// Border color. `null` hides the border.
  Color? get borderColor => _borderColor;

  /// Border width.
  double get borderWidth => _borderWidth ?? 0.5;

  /// Corner radius.
  double get radius => _radius ?? 20;

  /// Inner padding.
  EdgeInsetsGeometry get padding => _padding ?? const EdgeInsets.all(10);

  /// Gap between the icon and the label.
  double get iconSpacing => _iconSpacing ?? 5;

  /// Fills this style's unset fields from [base].
  ///
  /// Used by every design constructor, so passing a partial
  /// [UpdateButtonStyle] keeps the design's remaining values. A style built
  /// with [UpdateButtonStyle.replace] is returned untouched.
  UpdateButtonStyle merge(UpdateButtonStyle base) {
    return UpdateButtonStyle(
      text: _text ?? base._text,
      icon: _icon ?? base._icon,
      iconWidget: _iconWidget ?? base._iconWidget,
      iconColor: _iconColor ?? base._iconColor,
      iconSize: _iconSize ?? base._iconSize,
      gradient: _gradient ?? base._gradient,
      gradientBegin: _gradientBegin ?? base._gradientBegin,
      gradientEnd: _gradientEnd ?? base._gradientEnd,
      backgroundColor: _backgroundColor ?? base._backgroundColor,
      textColor: _textColor ?? base._textColor,
      fontSize: _fontSize ?? base._fontSize,
      fontWeight: _fontWeight ?? base._fontWeight,
      borderColor: _borderColor ?? base._borderColor,
      borderWidth: _borderWidth ?? base._borderWidth,
      radius: _radius ?? base._radius,
      padding: _padding ?? base._padding,
      iconSpacing: _iconSpacing ?? base._iconSpacing,
    );
  }

  /// Returns a copy with the given fields replaced.
  UpdateButtonStyle copyWith({
    String? text,
    IconData? icon,
    Widget? iconWidget,
    Color? iconColor,
    double? iconSize,
    List<Color>? gradient,
    AlignmentGeometry? gradientBegin,
    AlignmentGeometry? gradientEnd,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    FontWeight? fontWeight,
    Color? borderColor,
    double? borderWidth,
    double? radius,
    EdgeInsetsGeometry? padding,
    double? iconSpacing,
  }) {
    return UpdateButtonStyle(
      text: text ?? _text,
      icon: icon ?? _icon,
      iconWidget: iconWidget ?? _iconWidget,
      iconColor: iconColor ?? _iconColor,
      iconSize: iconSize ?? _iconSize,
      gradient: gradient ?? _gradient,
      gradientBegin: gradientBegin ?? _gradientBegin,
      gradientEnd: gradientEnd ?? _gradientEnd,
      backgroundColor: backgroundColor ?? _backgroundColor,
      textColor: textColor ?? _textColor,
      fontSize: fontSize ?? _fontSize,
      fontWeight: fontWeight ?? _fontWeight,
      borderColor: borderColor ?? _borderColor,
      borderWidth: borderWidth ?? _borderWidth,
      radius: radius ?? _radius,
      padding: padding ?? _padding,
      iconSpacing: iconSpacing ?? _iconSpacing,
    );
  }
}

/// The dismiss action ("LATER") — a plain tappable label by default.
///
/// Never rendered when the update is mandatory, or when
/// [AppUpgradeTheme.showLaterButton] is `false`.
@immutable
final class LaterButtonStyle {
  // Stored nullable so "not set" stays distinct from "set to the default" —
  // that is what lets [merge] fill only the gaps. Readers use the getters.
  final String? _text;
  final Color? _textColor;
  final double? _fontSize;
  final FontWeight? _fontWeight;
  final bool? _underline;
  final Color? _underlineColor;
  final Color? _backgroundColor;
  final Color? _borderColor;
  final double? _radius;
  final EdgeInsetsGeometry? _padding;

  /// A partial style: **only the fields you name are yours**, the rest come from
  /// the design you pass it to.
  ///
  /// Ignore the design's dismiss link entirely.
  const LaterButtonStyle({
    String? text,
    Color? textColor,
    double? fontSize,
    FontWeight? fontWeight,
    bool? underline,
    Color? underlineColor,
    Color? backgroundColor,
    Color? borderColor,
    double? radius,
    EdgeInsetsGeometry? padding,
  })  : _text = text,
        _textColor = textColor,
        _fontSize = fontSize,
        _fontWeight = fontWeight,
        _underline = underline,
        _underlineColor = underlineColor,
        _backgroundColor = backgroundColor,
        _borderColor = borderColor,
        _radius = radius,
        _padding = padding;

  /// Button label.
  String get text => _text ?? 'LATER';

  /// Label color.
  Color get textColor => _textColor ?? Colors.white;

  /// Label size.
  double? get fontSize => _fontSize;

  /// Label weight.
  FontWeight get fontWeight => _fontWeight ?? FontWeight.bold;

  /// Whether to underline the label.
  bool get underline => _underline ?? true;

  /// Underline color. `null` uses the default decoration color.
  Color? get underlineColor => _underlineColor;

  /// Optional pill fill behind the label. `null` keeps it a bare label.
  Color? get backgroundColor => _backgroundColor;

  /// Border color of that pill. `null` hides the border.
  Color? get borderColor => _borderColor;

  /// Corner radius of that pill.
  double get radius => _radius ?? 20;

  /// Inner padding.
  EdgeInsetsGeometry get padding =>
      _padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

  /// Fills this style's unset fields from [base]. A style built with
  /// [LaterButtonStyle.replace] is returned untouched.
  LaterButtonStyle merge(LaterButtonStyle base) {
    return LaterButtonStyle(
      text: _text ?? base._text,
      textColor: _textColor ?? base._textColor,
      fontSize: _fontSize ?? base._fontSize,
      fontWeight: _fontWeight ?? base._fontWeight,
      underline: _underline ?? base._underline,
      underlineColor: _underlineColor ?? base._underlineColor,
      backgroundColor: _backgroundColor ?? base._backgroundColor,
      borderColor: _borderColor ?? base._borderColor,
      radius: _radius ?? base._radius,
      padding: _padding ?? base._padding,
    );
  }

  /// Returns a copy with the given fields replaced.
  LaterButtonStyle copyWith({
    String? text,
    Color? textColor,
    double? fontSize,
    FontWeight? fontWeight,
    bool? underline,
    Color? underlineColor,
    Color? backgroundColor,
    Color? borderColor,
    double? radius,
    EdgeInsetsGeometry? padding,
  }) {
    return LaterButtonStyle(
      text: text ?? _text,
      textColor: textColor ?? _textColor,
      fontSize: fontSize ?? _fontSize,
      fontWeight: fontWeight ?? _fontWeight,
      underline: underline ?? _underline,
      underlineColor: underlineColor ?? _underlineColor,
      backgroundColor: backgroundColor ?? _backgroundColor,
      borderColor: borderColor ?? _borderColor,
      radius: radius ?? _radius,
      padding: padding ?? _padding,
    );
  }
}
