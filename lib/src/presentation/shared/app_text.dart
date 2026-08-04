import 'package:flutter/material.dart';
import 'package:app_upgrade_checker/src/core/constants/app_color.dart';
import 'package:app_upgrade_checker/src/core/constants/app_size.dart';
import 'package:app_upgrade_checker/src/core/constants/app_them.dart';
import 'package:app_upgrade_checker/src/core/constants/files_path.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextAlign? align;
  final Color? color;
  final TextOverflow? overflow;
  final String? fontFamily;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextDecoration? textDecoration;

  /// Color of [textDecoration]. Falls back to [color], so an underline matches
  /// its label unless overridden.
  final Color? decorationColor;
  final double? textHeight;
  final List<Shadow>? shadow;
  final TextDirection? textDirection;
  final bool? softWrap;
  final int? maxLine;
  const AppText(
      {super.key,
      required this.text,
      this.align,
      this.color,
      this.overflow,
      this.fontSize,
      this.fontWeight,
      this.textDecoration,
      this.decorationColor,
      this.textHeight,
      this.shadow,
      this.textDirection,
      this.softWrap,
      this.fontFamily,
      this.maxLine});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      textDirection: textDirection,
      softWrap: softWrap,
      maxLines: maxLine,
      overflow: overflow,
      style: TextStyle(
        fontSize: fontSize ?? AppSize.captionText,
        fontWeight: fontWeight ?? AppThem().regular,
        color: color ?? AppColor.white,
        decoration: textDecoration,
        decorationColor: decorationColor ?? color,
        height: textHeight,
        shadows: shadow,
        fontFamily: fontFamily ?? AppThem().fontFamily,
        // `package` rewrites the family to `packages/app_upgrade_checker/<family>`,
        // which only resolves for fonts this package ships. A caller-supplied
        // family lives in *their* pubspec, so qualifying it would silently miss
        // and fall back to the default font.
        package: fontFamily == null ? FilesPath.packageName : null,
      ),
    );
  }
}
