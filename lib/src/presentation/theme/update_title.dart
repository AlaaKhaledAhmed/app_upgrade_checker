import 'package:flutter/material.dart';

/// The two-line headline, e.g.
///
/// ```
///           Ready for
///     something better!✦
/// ```
///
/// The layout is deliberately fixed so every language keeps the same rhythm:
/// [firstLine] renders alone on its own line, then [secondLine] and [highlight]
/// sit side by side on the second line, with [highlight] in its own color and
/// shadow, followed by the small raised [sparkle].
///
/// So a translation only has to decide where to break:
///
/// ```dart
/// const UpdateTitle(
///   firstLine: 'نستعد',
///   secondLine: 'لشيء',
///   highlight: 'أفضل!',
/// );
/// ```
///
/// Pass `null` (or an empty string) to any part to drop just that part — a
/// title with no [highlight] simply renders the two plain lines, and a title
/// with no [firstLine] renders as a single line.
@immutable
final class UpdateTitle {
  // Stored nullable so "not set" stays distinct from "set to the default" —
  // that is what lets [merge] fill only the gaps. Readers use the getters.
  final String? _firstLine;
  final String? _secondLine;
  final String? _highlight;
  final String? _sparkle;
  final Color? _color;
  final Color? _highlightColor;
  final Color? _sparkleColor;
  final Color? _shadowColor;
  final Color? _highlightShadowColor;
  final double? _shadowBlurRadius;
  final Offset? _shadowOffset;
  final double? _fontSize;
  final double? _sparkleFontSize;
  final double? _sparkleOffsetY;
  final FontWeight? _fontWeight;
  final String? _fontFamily;
  final double? _firstLineHeight;
  final TextAlign? _textAlign;
  final TextDirection? _textDirection;

  /// A partial style: **only the fields you name are yours**, the rest come from
  /// the design you pass it to.
  ///
  /// Ignore the design's headline entirely.
  const UpdateTitle({
    String? firstLine,
    String? secondLine,
    String? highlight,
    String? sparkle,
    Color? color,
    Color? highlightColor,
    Color? sparkleColor,
    Color? shadowColor,
    Color? highlightShadowColor,
    double? shadowBlurRadius,
    Offset? shadowOffset,
    double? fontSize,
    double? sparkleFontSize,
    double? sparkleOffsetY,
    FontWeight? fontWeight,
    String? fontFamily,
    double? firstLineHeight,
    TextAlign? textAlign,
    TextDirection? textDirection,
  })  : _firstLine = firstLine,
        _secondLine = secondLine,
        _highlight = highlight,
        _sparkle = sparkle,
        _color = color,
        _highlightColor = highlightColor,
        _sparkleColor = sparkleColor,
        _shadowColor = shadowColor,
        _highlightShadowColor = highlightShadowColor,
        _shadowBlurRadius = shadowBlurRadius,
        _shadowOffset = shadowOffset,
        _fontSize = fontSize,
        _sparkleFontSize = sparkleFontSize,
        _sparkleOffsetY = sparkleOffsetY,
        _fontWeight = fontWeight,
        _fontFamily = fontFamily,
        _firstLineHeight = firstLineHeight,
        _textAlign = textAlign,
        _textDirection = textDirection;

  /// First line, rendered alone. Hidden when `null` or empty.
  String? get firstLine => _firstLine;

  /// Start of the second line, in the plain [color]. Hidden when `null` or
  /// empty.
  String? get secondLine => _secondLine;

  /// Last word of the second line, rendered in [highlightColor] with
  /// [highlightShadowColor]. Hidden when `null` or empty.
  String? get highlight => _highlight;

  /// The small glyph raised above the baseline after [highlight]. Hidden when
  /// `null` or empty.
  String? get sparkle => _sparkle;

  /// Color of [firstLine] and [secondLine].
  Color get color => _color ?? Colors.white;

  /// Color of [highlight].
  Color get highlightColor => _highlightColor ?? Colors.white;

  /// Color of [sparkle].
  Color get sparkleColor => _sparkleColor ?? Colors.amber;

  /// Glow color behind [firstLine] and [secondLine]. `null` disables the glow.
  Color? get shadowColor => _shadowColor;

  /// Glow color behind [highlight]. `null` disables that glow.
  Color? get highlightShadowColor => _highlightShadowColor;

  /// Blur of both glows.
  double get shadowBlurRadius => _shadowBlurRadius ?? 15;

  /// Offset of both glows.
  Offset get shadowOffset => _shadowOffset ?? const Offset(0, 4);

  /// Font size of [firstLine], [secondLine] and [highlight].
  double get fontSize => _fontSize ?? 40;

  /// Font size of [sparkle].
  double get sparkleFontSize => _sparkleFontSize ?? 20;

  /// How far [sparkle] is lifted above the baseline (negative goes up).
  double get sparkleOffsetY => _sparkleOffsetY ?? -12;

  /// Weight of all three text parts.
  FontWeight? get fontWeight => _fontWeight;

  /// Font family of all three text parts. `null` uses the package font.
  String? get fontFamily => _fontFamily;

  /// Line height multiplier for [firstLine]. The default tightens the gap
  /// between the two lines, matching the reference design.
  /// Line height of the first line, as a multiple of [fontSize].
  ///
  /// Defaults to **1.0** — the font's natural height. A tighter value pulls the
  /// two lines together, but it also tightens the gap *within* a line that
  /// wraps, so a long headline can end up overlapping itself.
  ///
  /// Set it yourself to close or open that gap:
  /// `UpdateTitle(firstLineHeight: 0.8)`.
  double firstLineHeightFor({required bool hasCustomFont}) =>
      _firstLineHeight ?? 1.0;

  /// The line height as set, or `null` to let the renderer decide from the font.
  double? get firstLineHeight => _firstLineHeight;

  /// Horizontal alignment of both lines.
  TextAlign get textAlign => _textAlign ?? TextAlign.center;

  /// Reading direction of the second line, which decides whether [highlight]
  /// sits to the right or the left of [secondLine].
  ///
  /// `null` follows the ambient [Directionality] — correct when the host app
  /// sets a locale. Set it explicitly ([TextDirection.rtl] for Arabic) when the
  /// update screen must read correctly regardless of the app's locale.
  TextDirection? get textDirection => _textDirection;

  /// Whether there is anything at all to render.
  bool get isEmpty =>
      _blank(firstLine) &&
      _blank(secondLine) &&
      _blank(highlight) &&
      _blank(sparkle);

  static bool _blank(String? v) => v == null || v.trim().isEmpty;

  /// Fills this style's unset fields from [base]. A style built with
  /// [UpdateTitle.replace] is returned untouched.
  UpdateTitle merge(UpdateTitle base) {
    return UpdateTitle(
      firstLine: _firstLine ?? base._firstLine,
      secondLine: _secondLine ?? base._secondLine,
      highlight: _highlight ?? base._highlight,
      sparkle: _sparkle ?? base._sparkle,
      color: _color ?? base._color,
      highlightColor: _highlightColor ?? base._highlightColor,
      sparkleColor: _sparkleColor ?? base._sparkleColor,
      shadowColor: _shadowColor ?? base._shadowColor,
      highlightShadowColor: _highlightShadowColor ?? base._highlightShadowColor,
      shadowBlurRadius: _shadowBlurRadius ?? base._shadowBlurRadius,
      shadowOffset: _shadowOffset ?? base._shadowOffset,
      fontSize: _fontSize ?? base._fontSize,
      sparkleFontSize: _sparkleFontSize ?? base._sparkleFontSize,
      sparkleOffsetY: _sparkleOffsetY ?? base._sparkleOffsetY,
      fontWeight: _fontWeight ?? base._fontWeight,
      fontFamily: _fontFamily ?? base._fontFamily,
      firstLineHeight: _firstLineHeight ?? base._firstLineHeight,
      textAlign: _textAlign ?? base._textAlign,
      textDirection: _textDirection ?? base._textDirection,
    );
  }

  /// Returns a copy with the given fields replaced.
  UpdateTitle copyWith({
    String? firstLine,
    String? secondLine,
    String? highlight,
    String? sparkle,
    Color? color,
    Color? highlightColor,
    Color? sparkleColor,
    Color? shadowColor,
    Color? highlightShadowColor,
    double? shadowBlurRadius,
    Offset? shadowOffset,
    double? fontSize,
    double? sparkleFontSize,
    double? sparkleOffsetY,
    FontWeight? fontWeight,
    String? fontFamily,
    double? firstLineHeight,
    TextAlign? textAlign,
    TextDirection? textDirection,
  }) {
    return UpdateTitle(
      firstLine: firstLine ?? _firstLine,
      secondLine: secondLine ?? _secondLine,
      highlight: highlight ?? _highlight,
      sparkle: sparkle ?? _sparkle,
      color: color ?? _color,
      highlightColor: highlightColor ?? _highlightColor,
      sparkleColor: sparkleColor ?? _sparkleColor,
      shadowColor: shadowColor ?? _shadowColor,
      highlightShadowColor: highlightShadowColor ?? _highlightShadowColor,
      shadowBlurRadius: shadowBlurRadius ?? _shadowBlurRadius,
      shadowOffset: shadowOffset ?? _shadowOffset,
      fontSize: fontSize ?? _fontSize,
      sparkleFontSize: sparkleFontSize ?? _sparkleFontSize,
      sparkleOffsetY: sparkleOffsetY ?? _sparkleOffsetY,
      fontWeight: fontWeight ?? _fontWeight,
      fontFamily: fontFamily ?? _fontFamily,
      firstLineHeight: firstLineHeight ?? _firstLineHeight,
      textAlign: textAlign ?? _textAlign,
      textDirection: textDirection ?? _textDirection,
    );
  }
}
