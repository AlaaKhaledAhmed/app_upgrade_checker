import 'package:flutter/material.dart';

/// The small pill above the headline — `"✦ NEW UPDATE AVAILABLE"`.
///
/// [prefix] is prepended to [text] so the glyph can be changed or dropped
/// without touching the label:
///
/// ```dart
/// AppUpgradeTheme.cosmic().copyWith(
///   badge: const UpdateBadgeStyle(
///     text: 'يتوفر تحديث جديد',
///     prefix: '',                       // no glyph
///     borderColor: Colors.tealAccent,
///   ),
/// );
/// ```
@immutable
final class UpdateBadgeStyle {
  // Stored nullable so "not set" stays distinct from "set to the default" —
  // that is what lets [merge] fill only the gaps. Readers use the getters.
  final String? _text;
  final String? _prefix;
  final Color? _textColor;
  final double? _fontSize;
  final FontWeight? _fontWeight;
  final Color? _backgroundColor;
  final Color? _borderColor;
  final double? _borderWidth;
  final double? _radius;
  final EdgeInsetsGeometry? _padding;
  final double? _horizontalInsetFactor;
  final EdgeInsetsGeometry? _margin;

  /// A partial style: **only the fields you name are yours**, the rest come from
  /// the design you pass it to.
  ///
  /// Ignore the design's badge entirely.
  const UpdateBadgeStyle({
    String? text,
    String? prefix,
    Color? textColor,
    double? fontSize,
    FontWeight? fontWeight,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? radius,
    EdgeInsetsGeometry? padding,
    double? horizontalInsetFactor,
    EdgeInsetsGeometry? margin,
  })  : _text = text,
        _prefix = prefix,
        _textColor = textColor,
        _fontSize = fontSize,
        _fontWeight = fontWeight,
        _backgroundColor = backgroundColor,
        _borderColor = borderColor,
        _borderWidth = borderWidth,
        _radius = radius,
        _padding = padding,
        _horizontalInsetFactor = horizontalInsetFactor,
        _margin = margin;

  /// Pill label.
  String get text => _text ?? 'NEW UPDATE AVAILABLE';

  /// Glyph placed before [text]. Empty string means none.
  String get prefix => _prefix ?? '˙✦ ';

  /// Label color.
  Color get textColor => _textColor ?? Colors.white;

  /// Label size.
  double? get fontSize => _fontSize;

  /// Label weight.
  FontWeight? get fontWeight => _fontWeight;

  /// Pill fill.
  Color get backgroundColor => _backgroundColor ?? Colors.transparent;

  /// Pill border color. `null` hides the border.
  Color? get borderColor => _borderColor;

  /// Pill border width.
  double get borderWidth => _borderWidth ?? 2;

  /// Pill corner radius.
  double get radius => _radius ?? 50;

  /// Inner padding.
  EdgeInsetsGeometry get padding =>
      _padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 10);

  /// Horizontal inset of the pill as a fraction of the screen width, which is
  /// what keeps it narrower than the content. Ignored when [margin] is set.
  double get horizontalInsetFactor => _horizontalInsetFactor ?? 0.1;

  /// Explicit outer margin. Overrides [horizontalInsetFactor] when set.
  EdgeInsetsGeometry? get margin => _margin;

  /// The full label as rendered: [prefix] followed by [text].
  String get label => '$prefix$text';

  /// Fills this style's unset fields from [base]. A style built with
  /// [UpdateBadgeStyle.replace] is returned untouched.
  UpdateBadgeStyle merge(UpdateBadgeStyle base) {
    return UpdateBadgeStyle(
      text: _text ?? base._text,
      prefix: _prefix ?? base._prefix,
      textColor: _textColor ?? base._textColor,
      fontSize: _fontSize ?? base._fontSize,
      fontWeight: _fontWeight ?? base._fontWeight,
      backgroundColor: _backgroundColor ?? base._backgroundColor,
      borderColor: _borderColor ?? base._borderColor,
      borderWidth: _borderWidth ?? base._borderWidth,
      radius: _radius ?? base._radius,
      padding: _padding ?? base._padding,
      horizontalInsetFactor:
          _horizontalInsetFactor ?? base._horizontalInsetFactor,
      margin: _margin ?? base._margin,
    );
  }

  /// Returns a copy with the given fields replaced.
  UpdateBadgeStyle copyWith({
    String? text,
    String? prefix,
    Color? textColor,
    double? fontSize,
    FontWeight? fontWeight,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? radius,
    EdgeInsetsGeometry? padding,
    double? horizontalInsetFactor,
    EdgeInsetsGeometry? margin,
  }) {
    return UpdateBadgeStyle(
      text: text ?? _text,
      prefix: prefix ?? _prefix,
      textColor: textColor ?? _textColor,
      fontSize: fontSize ?? _fontSize,
      fontWeight: fontWeight ?? _fontWeight,
      backgroundColor: backgroundColor ?? _backgroundColor,
      borderColor: borderColor ?? _borderColor,
      borderWidth: borderWidth ?? _borderWidth,
      radius: radius ?? _radius,
      padding: padding ?? _padding,
      horizontalInsetFactor: horizontalInsetFactor ?? _horizontalInsetFactor,
      margin: margin ?? _margin,
    );
  }
}

/// The body paragraph under the headline, and the version pill.
///
/// [text] is optional: when it is `null` the screen falls back to the release
/// notes coming from the store or your backend, then to a generic sentence.
@immutable
final class UpdateTextStyle {
  // Stored nullable so "not set" stays distinct from "set to the default" —
  // that is what lets [merge] fill only the gaps. Readers use the getters.
  final String? _text;
  final Color? _color;
  final double? _fontSize;
  final FontWeight? _fontWeight;
  final TextAlign? _align;
  final double? _height;
  final int? _maxLines;
  final TextOverflow? _overflow;
  final EdgeInsetsGeometry? _padding;

  /// A partial style: **only the fields you name are yours**, the rest come from
  /// the design you pass it to.
  ///
  /// Ignore the design's text block entirely.
  const UpdateTextStyle({
    String? text,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    TextAlign? align,
    double? height,
    int? maxLines,
    TextOverflow? overflow,
    EdgeInsetsGeometry? padding,
  })  : _text = text,
        _color = color,
        _fontSize = fontSize,
        _fontWeight = fontWeight,
        _align = align,
        _height = height,
        _maxLines = maxLines,
        _overflow = overflow,
        _padding = padding;

  /// The paragraph. `null` falls back to the update's release notes.
  String? get text => _text;

  /// Text color.
  Color get color => _color ?? Colors.white;

  /// Text size.
  double? get fontSize => _fontSize;

  /// Text weight.
  FontWeight? get fontWeight => _fontWeight;

  /// Horizontal alignment.
  TextAlign get align => _align ?? TextAlign.center;

  /// Line height multiplier.
  double? get height => _height;

  /// Maximum lines before [overflow] applies. `null` means unbounded.
  int? get maxLines => _maxLines;

  /// How to clip text past [maxLines].
  TextOverflow? get overflow => _overflow;

  /// Outer padding.
  EdgeInsetsGeometry get padding => _padding ?? EdgeInsets.zero;

  /// Fills this style's unset fields from [base]. A style built with
  /// [UpdateTextStyle.replace] is returned untouched.
  UpdateTextStyle merge(UpdateTextStyle base) {
    return UpdateTextStyle(
      text: _text ?? base._text,
      color: _color ?? base._color,
      fontSize: _fontSize ?? base._fontSize,
      fontWeight: _fontWeight ?? base._fontWeight,
      align: _align ?? base._align,
      height: _height ?? base._height,
      maxLines: _maxLines ?? base._maxLines,
      overflow: _overflow ?? base._overflow,
      padding: _padding ?? base._padding,
    );
  }

  /// Returns a copy with the given fields replaced.
  UpdateTextStyle copyWith({
    String? text,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    TextAlign? align,
    double? height,
    int? maxLines,
    TextOverflow? overflow,
    EdgeInsetsGeometry? padding,
  }) {
    return UpdateTextStyle(
      text: text ?? _text,
      color: color ?? _color,
      fontSize: fontSize ?? _fontSize,
      fontWeight: fontWeight ?? _fontWeight,
      align: align ?? _align,
      height: height ?? _height,
      maxLines: maxLines ?? _maxLines,
      overflow: overflow ?? _overflow,
      padding: padding ?? _padding,
    );
  }
}

/// The version pill (e.g. `"v3.5.0"`).
///
/// The number itself comes from the update result — this only styles it.
/// [prefix] defaults to `"v"`; set it to `''` to show the bare number.
@immutable
final class UpdateVersionStyle {
  // Stored nullable so "not set" stays distinct from "set to the default" —
  // that is what lets [merge] fill only the gaps. Readers use the getters.
  final String? _prefix;
  final Color? _textColor;
  final double? _fontSize;
  final FontWeight? _fontWeight;
  final Color? _backgroundColor;
  final Color? _borderColor;
  final double? _borderWidth;
  final double? _radius;
  final EdgeInsetsGeometry? _padding;

  /// A partial style: **only the fields you name are yours**, the rest come from
  /// the design you pass it to.
  ///
  /// Ignore the design's version pill entirely.
  const UpdateVersionStyle({
    String? prefix,
    Color? textColor,
    double? fontSize,
    FontWeight? fontWeight,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? radius,
    EdgeInsetsGeometry? padding,
  })  : _prefix = prefix,
        _textColor = textColor,
        _fontSize = fontSize,
        _fontWeight = fontWeight,
        _backgroundColor = backgroundColor,
        _borderColor = borderColor,
        _borderWidth = borderWidth,
        _radius = radius,
        _padding = padding;

  /// Placed before the version number.
  String get prefix => _prefix ?? 'v';

  /// Label color. `null` uses [borderColor], then white.
  Color? get textColor => _textColor;

  /// Label size.
  double? get fontSize => _fontSize;

  /// Label weight.
  FontWeight? get fontWeight => _fontWeight;

  /// Pill fill.
  Color get backgroundColor => _backgroundColor ?? Colors.transparent;

  /// Pill border color. `null` hides the border.
  Color? get borderColor => _borderColor;

  /// Pill border width.
  double get borderWidth => _borderWidth ?? 1.5;

  /// Pill corner radius.
  double get radius => _radius ?? 999;

  /// Inner padding.
  EdgeInsetsGeometry get padding =>
      _padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 6);

  /// Fills this style's unset fields from [base]. A style built with
  /// [UpdateVersionStyle.replace] is returned untouched.
  UpdateVersionStyle merge(UpdateVersionStyle base) {
    return UpdateVersionStyle(
      prefix: _prefix ?? base._prefix,
      textColor: _textColor ?? base._textColor,
      fontSize: _fontSize ?? base._fontSize,
      fontWeight: _fontWeight ?? base._fontWeight,
      backgroundColor: _backgroundColor ?? base._backgroundColor,
      borderColor: _borderColor ?? base._borderColor,
      borderWidth: _borderWidth ?? base._borderWidth,
      radius: _radius ?? base._radius,
      padding: _padding ?? base._padding,
    );
  }

  /// Returns a copy with the given fields replaced.
  UpdateVersionStyle copyWith({
    String? prefix,
    Color? textColor,
    double? fontSize,
    FontWeight? fontWeight,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? radius,
    EdgeInsetsGeometry? padding,
  }) {
    return UpdateVersionStyle(
      prefix: prefix ?? _prefix,
      textColor: textColor ?? _textColor,
      fontSize: fontSize ?? _fontSize,
      fontWeight: fontWeight ?? _fontWeight,
      backgroundColor: backgroundColor ?? _backgroundColor,
      borderColor: borderColor ?? _borderColor,
      borderWidth: borderWidth ?? _borderWidth,
      radius: radius ?? _radius,
      padding: padding ?? _padding,
    );
  }
}
