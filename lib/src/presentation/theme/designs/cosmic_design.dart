import 'package:flutter/material.dart';
import 'package:app_upgrade/src/presentation/theme/theme_lang.dart';

import 'package:app_upgrade/src/core/constants/files_path.dart';
import 'package:app_upgrade/src/presentation/theme/theme_defaults.dart';
import 'package:app_upgrade/src/presentation/theme/update_background.dart';
import 'package:app_upgrade/src/presentation/theme/update_badge_style.dart';
import 'package:app_upgrade/src/presentation/theme/update_button_style.dart';
import 'package:app_upgrade/src/presentation/theme/update_entrance.dart';
import 'package:app_upgrade/src/presentation/theme/update_feature.dart';
import 'package:app_upgrade/src/presentation/theme/update_pulse.dart';
import 'package:app_upgrade/src/presentation/theme/update_section.dart';
import 'package:app_upgrade/src/presentation/theme/update_title.dart';
import 'package:app_upgrade/src/presentation/theme/update_visual.dart';

/// The **Cosmic** design's identity: an astronaut riding a rocket over a
/// starfield, a glowing two-line headline and three gradient feature cards.
///
/// Everything that makes Cosmic *look like Cosmic* is here — its palette, its
/// asset, its copy. Layout it shares with other designs comes from
/// `ThemeDefaults`, and the wiring is `AppUpgradeTheme.cosmic()`.
///
/// This is a design's canonical shape: a `final class` of `static const`
/// values, one per themed block. Copy this file to start a new design.
///
/// You normally reach these through `AppUpgradeTheme.cosmic()`, but they are
/// public so you can borrow one piece while replacing another:
///
/// ```dart
/// AppUpgradeTheme.rocketUp(features: CosmicDesign.features);
/// ```
final class CosmicDesign {
  const CosmicDesign._();

  // ── Palette ──

  /// Deep navy behind the starfield, and the color shown if the image fails.
  static const Color background = Color(0xff01114f);

  /// The blue used for every border.
  static const Color border = Color(0xFF0e53ff);

  /// The lighter blue of the highlighted word.
  static const Color highlight = Color(0xFF42A5F5);

  static const Color purple = Color(0xff7E2CB7);

  /// Fills the icon circles.
  static const List<Color> iconGradient = [highlight, border, purple];

  /// Fills the primary button.
  static const List<Color> buttonGradient = [
    Colors.indigoAccent,
    Colors.blueAccent,
    Colors.deepPurple,
  ];

  // ── Layout ──

  /// Cosmic is happy with the shared sequence: artwork, then badge, then the
  /// headline.
  static const List<UpdateSection> order = ThemeDefaults.order;

  // ── Blocks ──

  static const UpdateBackground backgroundStyle =
      AssetBackground(FilesPath.background, package: FilesPath.packageName);

  static const UpdateVisual visual = LottieVisual(
    FilesPath.astronautInRocket,
    package: FilesPath.packageName,
  );

  static UpdateBadgeStyle badgeFor(ThemeLang l) => UpdateBadgeStyle(
        text: ThemeStrings.of(l).badge,
        borderColor: border,
      );

  static UpdateTitle titleFor(ThemeLang l) => UpdateTitle(
        firstLine: ThemeStrings.of(l).titleFirst,
        secondLine: ThemeStrings.of(l).titleSecond,
        highlight: ThemeStrings.of(l).titleHighlight,
        sparkle: '✦︎',
        highlightColor: highlight,
        shadowColor: Colors.blue,
        highlightShadowColor: Colors.indigo,
      );

  static const UpdateVersionStyle version = UpdateVersionStyle(
    textColor: Colors.white,
    borderColor: border,
  );

  static const UpdateTextStyle description = UpdateTextStyle();

  static String fallbackDescriptionFor(ThemeLang l) =>
      ThemeStrings.of(l).description;

  static List<UpdateFeature> featuresFor(ThemeLang l) => [
        UpdateFeature(
          icon: Icons.rocket_launch_rounded,
          title: ThemeStrings.of(l).featureTitles[0],
          subtitle: ThemeStrings.of(l).featureSubtitles[0],
          iconGradient: iconGradient,
          borderColor: border,
        ),
        UpdateFeature(
          icon: Icons.security,
          title: ThemeStrings.of(l).featureTitles[1],
          subtitle: ThemeStrings.of(l).featureSubtitles[1],
          iconGradient: iconGradient,
          borderColor: border,
        ),
        UpdateFeature(
          icon: Icons.auto_awesome,
          title: ThemeStrings.of(l).featureTitles[2],
          subtitle: ThemeStrings.of(l).featureSubtitles[2],
          iconGradient: iconGradient,
          borderColor: border,
        ),
      ];

  static UpdateButtonStyle updateButtonFor(ThemeLang l) => UpdateButtonStyle(
        text: ThemeStrings.of(l).updateButton,
        icon: Icons.rocket_launch_rounded,
        gradient: buttonGradient,
        borderColor: border,
      );

  static LaterButtonStyle laterButtonFor(ThemeLang l) =>
      LaterButtonStyle(text: ThemeStrings.of(l).laterButton);

  // ── Motion ──

  /// Dropping out of warp — the space design's natural arrival, and the cheapest
  /// of the expressive entrances.
  static const UpdateEntrance entrance = UpdateEntrance.warpIn();

  /// A blue glow, matching the button's own gradient.
  static const UpdatePulse pulse = UpdatePulse(color: highlight);
}
