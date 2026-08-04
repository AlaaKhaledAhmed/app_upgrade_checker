import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:app_upgrade_checker/src/core/constants/app_size.dart';
import 'package:app_upgrade_checker/src/core/constants/app_them.dart';
import 'package:app_upgrade_checker/src/core/constants/files_path.dart';
import 'package:app_upgrade_checker/src/core/extensions/context_extensions.dart';
import 'package:app_upgrade_checker/src/presentation/theme/styles/update_background.dart';
import 'package:app_upgrade_checker/src/presentation/theme/styles/update_badge_style.dart';
import 'package:app_upgrade_checker/src/presentation/theme/styles/update_button_style.dart';
import 'package:app_upgrade_checker/src/presentation/theme/styles/update_feature.dart';
import 'package:app_upgrade_checker/src/presentation/theme/styles/update_title.dart';
import 'package:app_upgrade_checker/src/presentation/theme/styles/update_visual.dart';
import 'package:app_upgrade_checker/src/presentation/shared/app_decoration.dart';
import 'package:app_upgrade_checker/src/presentation/shared/app_text.dart';

/// The building blocks of the update screen.
///
/// Every design uses these same widgets — a design only decides their order,
/// their colors and their content, all of which arrive through the style
/// objects. Nothing here reads a global constant, so two designs on the same
/// screen never interfere.
///
/// Internal: not exported from the package barrel.
class UpdateBlocks {
  const UpdateBlocks._();

  /// Resolves an [UpdateBackground] into a [BoxDecoration].
  static BoxDecoration background(UpdateBackground background) {
    return switch (background) {
      SolidBackground(:final color) =>
        AppDecoration.decoration(radius: 0, color: color),
      GradientBackground(:final gradient) => AppDecoration.decoration(
          radius: 0,
          isGradient: true,
          gradient: gradient,
        ),
      AssetBackground(
        :final path,
        :final package,
        :final color,
        :final fit,
        :final opacity,
        :final alignment,
        :final colorFilter,
      ) =>
        BoxDecoration(
          color: color,
          image: DecorationImage(
            image: AssetImage(path, package: package),
            fit: fit,
            opacity: opacity,
            alignment: alignment,
            colorFilter: colorFilter,
            onError: (_, __) => debugPrint(
              'AppUpgrade: could not load background asset "$path"'
              '${package == null ? '' : ' from package "$package"'}',
            ),
          ),
        ),
      NetworkBackground(
        :final url,
        :final color,
        :final fit,
        :final opacity,
        :final alignment,
        :final colorFilter,
      ) =>
        BoxDecoration(
          color: color,
          image: DecorationImage(
            image: NetworkImage(url),
            fit: fit,
            opacity: opacity,
            alignment: alignment,
            colorFilter: colorFilter,
            onError: (_, __) =>
                debugPrint('AppUpgrade: could not load background "$url"'),
          ),
        ),
      NoBackground() => const BoxDecoration(),
    };
  }

  /// The top artwork.
  static Widget visual(BuildContext context, UpdateVisual visual) {
    final height = visual.height ?? context.height * visual.heightFactor;

    // An artwork that fails to load leaves a hole in the layout and nothing
    // else — so say why in debug, or the screen looks like it simply has no
    // visual. `debugPrint` is stripped from release builds.
    Widget onArtworkError(String what, Object error) {
      debugPrint('AppUpgrade: could not load $what — $error');
      return const SizedBox.shrink();
    }

    final Widget child = switch (visual) {
      LottieVisual(:final path, :final package, :final repeat, :final fit) =>
        Lottie.asset(
          path,
          package: package,
          repeat: repeat,
          fit: fit,
          errorBuilder: (_, error, __) =>
              onArtworkError('Lottie "$path" (package: $package)', error),
        ),
      AssetVisual(:final path, :final package, :final fit) => Image.asset(
          path,
          package: package,
          fit: fit,
          errorBuilder: (_, error, __) =>
              onArtworkError('image "$path" (package: $package)', error),
        ),
      NetworkVisual(:final url, :final fit) => Image.network(
          url,
          fit: fit,
          errorBuilder: (_, error, __) => onArtworkError('image "$url"', error),
        ),
      IconVisual(
        :final icon,
        :final color,
        :final size,
        :final circleGradient,
        :final circleSize,
      ) =>
        _iconVisual(icon, color, size, circleGradient, circleSize),
      CustomVisual(:final builder) => builder(context),
    };

    return SizedBox(height: height, child: Center(child: child));
  }

  static Widget _iconVisual(
    IconData icon,
    Color color,
    double size,
    List<Color>? gradient,
    double? circleSize,
  ) {
    final glyph = Icon(icon, color: color, size: size);
    if (gradient == null) return glyph;

    final diameter = circleSize ?? size * 2.4;
    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: AppDecoration.decoration(
        isCircle: true,
        isGradient: true,
        shadow: true,
        gradient: LinearGradient(colors: gradient),
      ),
      child: glyph,
    );
  }

  /// The pill above the headline.
  static Widget badge(
    BuildContext context,
    UpdateBadgeStyle style, {
    String? fontFamily,
  }) {
    return Container(
      padding: style.padding,
      margin: style.margin ??
          EdgeInsets.symmetric(
            horizontal: context.width * style.horizontalInsetFactor,
          ),
      decoration: AppDecoration.decoration(
        radius: style.radius,
        color: style.backgroundColor,
        showBorder: style.borderColor != null,
        borderColor: style.borderColor,
        borderWidth: style.borderWidth,
      ),
      child: AppText(
        text: style.label,
        color: style.textColor,
        fontSize: style.fontSize,
        fontWeight: style.fontWeight ?? AppThem().semeBold,
        fontFamily: fontFamily,
        align: TextAlign.center,
      ),
    );
  }

  /// The two-line headline.
  ///
  /// The layout is fixed on purpose: [UpdateTitle.firstLine] alone, then
  /// [UpdateTitle.secondLine] + [UpdateTitle.highlight] + the raised sparkle on
  /// one row — so a translated title keeps the same shape. Parts left blank are
  /// skipped without disturbing the rest.
  static Widget title(UpdateTitle title, {String? fontFamily}) {
    final lineShadow = title.shadowColor == null
        ? null
        : [
            Shadow(
              color: title.shadowColor!,
              offset: title.shadowOffset,
              blurRadius: title.shadowBlurRadius,
            ),
          ];

    final highlightShadow = title.highlightShadowColor == null
        ? null
        : [
            Shadow(
              color: title.highlightShadowColor!,
              offset: title.shadowOffset,
              blurRadius: title.shadowBlurRadius,
            ),
          ];

    final hasFirst = _has(title.firstLine);
    final hasSecond = _has(title.secondLine);
    final hasHighlight = _has(title.highlight);
    final hasSparkle = _has(title.sparkle);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasFirst)
          AppText(
            text: title.firstLine!,
            color: title.color,
            fontSize: title.fontSize,
            fontWeight: title.fontWeight ?? AppThem().semeBold,
            fontFamily: fontFamily,
            align: title.textAlign,
            textDirection: title.textDirection,
            // Tightens the gap to the second line.
            textHeight:
                title.firstLineHeightFor(hasCustomFont: fontFamily != null),
            shadow: lineShadow,
          ),
        // One paragraph rather than a Row of separate texts: the parts differ
        // only in color, so as spans they wrap together instead of each one
        // demanding its full width and pushing the line past the screen.
        if (hasSecond || hasHighlight || hasSparkle)
          Text.rich(
            TextSpan(
              children: [
                if (hasSecond)
                  TextSpan(
                    // The trailing space is what separates the plain part from
                    // the highlighted word.
                    text: hasHighlight
                        ? '${title.secondLine!} '
                        : title.secondLine!,
                    style: _titleStyle(
                      title,
                      fontFamily,
                      color: title.color,
                      shadow: lineShadow,
                    ),
                  ),
                if (hasHighlight)
                  TextSpan(
                    text: title.highlight!,
                    style: _titleStyle(
                      title,
                      fontFamily,
                      color: title.highlightColor,
                      shadow: highlightShadow,
                    ),
                  ),
                if (hasSparkle)
                  WidgetSpan(
                    // Keeps the sparkle riding above the baseline, as before.
                    child: Transform.translate(
                      offset: Offset(0, title.sparkleOffsetY),
                      child: AppText(
                        text: title.sparkle!,
                        color: title.sparkleColor,
                        fontSize: title.sparkleFontSize,
                        fontWeight: title.fontWeight ?? AppThem().semeBold,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
              ],
            ),
            textAlign: TextAlign.center,
            // In RTL this lays the spans out right-to-left, which keeps the
            // highlighted word last in reading order without reordering them.
            textDirection: title.textDirection,
          ),
      ],
    );
  }

  /// The style [title] renders its spans with — the same values [AppText] would
  /// apply, so a span and a widget line look identical.
  static TextStyle _titleStyle(
    UpdateTitle title,
    String? fontFamily, {
    Color? color,
    List<Shadow>? shadow,
  }) {
    return TextStyle(
      color: color,
      fontSize: title.fontSize,
      fontWeight: title.fontWeight ?? AppThem().semeBold,
      fontFamily: fontFamily ?? AppThem().fontFamily,
      // Only the bundled font is package-scoped; a caller's font is their own.
      package: fontFamily == null ? FilesPath.packageName : null,
      shadows: shadow,
    );
  }

  /// The version pill.
  static Widget version(
    String versionName,
    UpdateVersionStyle style, {
    String? fontFamily,
  }) {
    return Container(
      padding: style.padding,
      decoration: AppDecoration.decoration(
        radius: style.radius,
        color: style.backgroundColor,
        showBorder: style.borderColor != null,
        borderColor: style.borderColor,
        borderWidth: style.borderWidth,
      ),
      child: AppText(
        text: '${style.prefix}$versionName',
        color: style.textColor ?? style.borderColor ?? Colors.white,
        fontSize: style.fontSize,
        fontWeight: style.fontWeight,
        fontFamily: fontFamily,
      ),
    );
  }

  /// The body paragraph.
  static Widget description(
    String text,
    UpdateTextStyle style, {
    String? fontFamily,
  }) {
    return Padding(
      padding: style.padding,
      child: AppText(
        text: text,
        color: style.color,
        fontSize: style.fontSize ?? AppSize.bodyText,
        fontWeight: style.fontWeight,
        fontFamily: fontFamily,
        align: style.align,
        textHeight: style.height,
        maxLine: style.maxLines,
        overflow: style.overflow,
      ),
    );
  }

  /// The feature row.
  ///
  /// Up to three cards share the row evenly. Beyond that they wrap, so a design
  /// with five features degrades into rows instead of overflowing.
  static Widget features(
    List<UpdateFeature> features, {
    required double spacing,
    String? fontFamily,
  }) {
    if (features.length <= 3) {
      return Row(
        spacing: spacing,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final feature in features)
            Expanded(child: featureCard(feature, fontFamily: fontFamily)),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Three per row, minus the gaps between them.
        final width = (constraints.maxWidth - spacing * 2) / 3;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: [
            for (final feature in features)
              SizedBox(
                width: width,
                child: featureCard(feature, fontFamily: fontFamily),
              ),
          ],
        );
      },
    );
  }

  /// A single feature card.
  static Widget featureCard(UpdateFeature feature, {String? fontFamily}) {
    final hasTitle = _has(feature.title);
    final hasSubtitle = _has(feature.subtitle);

    return DecoratedBox(
      decoration: AppDecoration.decoration(
        radius: feature.radius,
        color: feature.backgroundColor,
        showBorder: feature.borderColor != null,
        borderColor: feature.borderColor,
        borderWidth: feature.borderWidth,
      ),
      child: Padding(
        padding: feature.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: feature.iconBubbleSize,
              height: feature.iconBubbleSize,
              alignment: Alignment.center,
              decoration: AppDecoration.decoration(
                isCircle: true,
                shadow: feature.iconShadow,
                isGradient: feature.iconGradient != null,
                gradient: feature.iconGradient == null
                    ? null
                    : LinearGradient(colors: feature.iconGradient!),
                color: feature.iconBackgroundColor,
              ),
              child: feature.iconWidget ??
                  (feature.icon == null
                      ? const SizedBox.shrink()
                      : Icon(
                          feature.icon,
                          color: feature.iconColor,
                          size: feature.iconSize,
                        )),
            ),
            if (hasTitle) ...[
              const SizedBox(height: 20),
              AppText(
                text: feature.title!,
                color: feature.titleColor,
                fontSize: feature.titleFontSize ?? AppSize.smallText + 2,
                fontWeight: feature.titleFontWeight ?? AppThem().semeBold,
                fontFamily: fontFamily,
                textHeight: 0.2,
                align: TextAlign.center,
              ),
            ],
            if (hasSubtitle) ...[
              SizedBox(height: hasTitle ? 10 : 20),
              AppText(
                text: feature.subtitle!,
                color: feature.subtitleColor,
                fontSize: feature.subtitleFontSize ?? AppSize.smallText,
                fontWeight: feature.subtitleFontWeight,
                fontFamily: fontFamily,
                align: TextAlign.center,
                maxLine: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// The primary call-to-action.
  ///
  /// [fallbackColor] fills the button when the style names neither a gradient
  /// nor a background color — so a design that forgets to style it still gets a
  /// visible, tappable button rather than a transparent one.
  static Widget updateButton(
    UpdateButtonStyle style, {
    required VoidCallback onTap,
    required Color fallbackColor,
    String? fontFamily,
  }) {
    final icon = style.iconWidget ??
        (style.icon == null
            ? null
            : Icon(
                style.icon,
                size: style.iconSize ?? AppSize.largeIconSize,
                color: style.iconColor,
              ));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(style.radius),
      child: Container(
        padding: style.padding,
        alignment: Alignment.center,
        width: double.infinity,
        decoration: AppDecoration.decoration(
          radius: style.radius,
          isGradient: style.gradient != null,
          gradient: style.gradient == null
              ? null
              : LinearGradient(
                  colors: style.gradient!,
                  begin: style.gradientBegin,
                  end: style.gradientEnd,
                ),
          color: style.backgroundColor ??
              (style.gradient == null ? fallbackColor : null),
          showBorder: style.borderColor != null,
          borderColor: style.borderColor,
          borderWidth: style.borderWidth,
        ),
        child: Row(
          spacing: style.iconSpacing,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) icon,
            AppText(
              text: style.text,
              color: style.textColor,
              fontSize: style.fontSize,
              fontWeight: style.fontWeight,
              fontFamily: fontFamily,
            ),
          ],
        ),
      ),
    );
  }

  /// The dismiss action.
  static Widget laterButton(
    LaterButtonStyle style, {
    required VoidCallback onTap,
    String? fontFamily,
  }) {
    final label = AppText(
      text: style.text,
      color: style.textColor,
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      fontFamily: fontFamily,
      textDecoration: style.underline ? TextDecoration.underline : null,
      decorationColor: style.underlineColor,
    );

    // A bare label unless the style asks for a pill.
    final needsBox = style.backgroundColor != null || style.borderColor != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(style.radius),
      child: needsBox
          ? Container(
              padding: style.padding,
              decoration: AppDecoration.decoration(
                radius: style.radius,
                color: style.backgroundColor ?? Colors.transparent,
                showBorder: style.borderColor != null,
                borderColor: style.borderColor,
              ),
              child: label,
            )
          : label,
    );
  }

  static bool _has(String? value) => value != null && value.trim().isNotEmpty;
}
