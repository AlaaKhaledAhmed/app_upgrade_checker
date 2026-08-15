import 'package:flutter/material.dart';
import 'package:app_upgrade_checker/src/presentation/theme/theme_lang.dart';

import 'package:app_upgrade_checker/src/core/constants/files_path.dart';
import 'package:app_upgrade_checker/src/presentation/theme/motion/dialog_entrance.dart';
import 'package:app_upgrade_checker/src/presentation/theme/theme_defaults.dart';
import 'package:app_upgrade_checker/src/presentation/theme/styles/update_background.dart';
import 'package:app_upgrade_checker/src/presentation/theme/styles/update_badge_style.dart';
import 'package:app_upgrade_checker/src/presentation/theme/styles/update_button_style.dart';
import 'package:app_upgrade_checker/src/presentation/theme/motion/update_entrance.dart';
import 'package:app_upgrade_checker/src/presentation/theme/styles/update_feature.dart';
import 'package:app_upgrade_checker/src/presentation/theme/motion/update_pulse.dart';
import 'package:app_upgrade_checker/src/presentation/theme/update_section.dart';
import 'package:app_upgrade_checker/src/presentation/theme/styles/update_title.dart';
import 'package:app_upgrade_checker/src/presentation/theme/styles/update_visual.dart';

/// The **RocketUp** design's identity: a rocket climbing over a pink starfield,
/// in magentas and pinks sampled from that image.
///
/// This is a sibling of [CosmicDesign], not a variation of it: it repeats the
/// values it shares rather than deriving them, so editing Cosmic can never
/// change how RocketUp looks. That independence is the point — a design is a
/// complete specification you can read top to bottom.
///
/// Layout it does not care about (padding, spacing, alignment) comes from
/// `ThemeDefaults`, and the wiring is `AppUpgradeTheme.rocketUp()`.
///
/// You normally reach these through `AppUpgradeTheme.rocketUp()`, but they are
/// public so you can borrow one piece while replacing another:
///
/// ```dart
/// AppUpgradeTheme.cosmic(background: RocketUpDesign.backgroundStyle);
/// ```
final class RocketUpDesign {
  const RocketUpDesign._();

  // ── Palette ──
  //
  // Every value here is sampled from `background_pink.png`, so nothing on the
  // screen introduces a color the picture does not already contain.

  /// The image's own bottom-edge color.
  ///
  /// The screen fills its container with this and paints the image on top, so
  /// wherever the image does not reach — a taller screen, a different aspect
  /// ratio, or while it is still decoding — the seam is invisible. Same
  /// principle as [CosmicDesign.background].
  static const Color background = Color(0xFF0A0112);

  /// Near-black violet, matching the top of the starfield.
  static const Color deepViolet = Color(0xFF180521);

  /// The plum of the nebula band.
  static const Color purple = Color(0xFF440934);

  /// The image's cloud mass, sampled from its brightest band — the warmest
  /// large area on screen.
  static const Color magenta = Color(0xFFEA497F);

  /// The deeper cloud tone underneath [magenta].
  static const Color deepPink = Color(0xFFC72D6B);

  /// The near-white of the image's star glints and comet trails — the only
  /// truly light color in the picture.
  static const Color starWhite = Color(0xFFFFDCEB);

  /// The pink used for every border — between [starWhite] and [magenta].
  static const Color border = Color(0xFFE94FA1);

  /// The light pink of the highlighted word, matching the star glints.
  static const Color highlight = starWhite;

  /// Translucent white that fills the feature cards.
  static const Color cardFill = Color(0x14FFFFFF);

  /// Softer border for those filled cards.
  static const Color cardBorder = Color(0x4DE94FA1);

  /// Fills the icon circles: border pink into cloud magenta.
  ///
  /// A step below the button in brightness on purpose — the three tiers read as
  /// a hierarchy (button lightest, circles mid, cards dark), so the eye lands
  /// on the button first.
  static const List<Color> iconGradient = [border, magenta];

  /// The glyph inside those circles must be dark to stay readable.
  static const Color iconGlyph = Color(0xFF3D0322);

  /// Fills the primary button: star white into cloud magenta.
  ///
  /// Running from the image's lightest tone to its cloud tone puts the button at
  /// the top of the value scale, brighter than the clouds behind it. A button
  /// made only of cloud colors sinks into the background however saturated it
  /// is; leading with [starWhite] is what lifts it clear.
  static const List<Color> buttonGradient = [starWhite, magenta];

  /// Dark plum for the button's label and icon, legible on that light fill.
  static const Color buttonLabel = Color(0xFF3D0322);

  // ── Layout ──

  /// The same sequence as Cosmic and SuperHero — artwork, badge, headline, then
  /// the rest. The designs differ by palette, asset and copy, not by order.
  static const List<UpdateSection> order = ThemeDefaults.order;

  // ── Blocks ──

  /// A pink starfield image over [background], which is the image's own bottom
  /// color — so the fill and the artwork meet without a visible seam.
  static const UpdateBackground backgroundStyle = AssetBackground(
    FilesPath.backgroundPink,
    package: FilesPath.packageName,
    color: background,
  );

  /// A rocket that stays in frame — the screen sits still, so an animation that
  /// flies out of frame would spend most of its time empty.
  static const UpdateVisual visual = LottieVisual(
    FilesPath.manOnRocket,
    package: FilesPath.packageName,
    heightFactor: 0.32,
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
        highlightColor: Colors.pink,
        shadowColor: border,
        highlightShadowColor: Colors.purple,
      );

  static const UpdateVersionStyle version = UpdateVersionStyle(
    textColor: highlight,
    borderColor: cardBorder,
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

  /// The rocket pulls the page up from below — the signature entrance for this
  /// design, and the reason the artwork leads the panel.
  ///
  /// Used only as a full screen; see [dialogEntrance] for the other two.
  static const UpdateEntrance entrance = UpdateEntrance.rocketPull();

  /// A rise from below — the card keeps the upward travel of [entrance] in the
  /// form a dialog or a sheet can carry.
  static const DialogEntrance dialogEntrance = DialogEntrance.slideUp();

  /// A magenta glow, matching the button's own gradient.
  static const UpdatePulse pulse = UpdatePulse(color: magenta);
}
