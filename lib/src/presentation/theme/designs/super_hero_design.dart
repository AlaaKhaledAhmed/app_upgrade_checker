import 'package:flutter/material.dart';
import 'package:app_upgrade_checker/src/presentation/theme/theme_lang.dart';

import 'package:app_upgrade_checker/src/core/constants/files_path.dart';
import 'package:app_upgrade_checker/src/presentation/theme/theme_defaults.dart';
import 'package:app_upgrade_checker/src/presentation/theme/update_background.dart';
import 'package:app_upgrade_checker/src/presentation/theme/update_badge_style.dart';
import 'package:app_upgrade_checker/src/presentation/theme/update_button_style.dart';
import 'package:app_upgrade_checker/src/presentation/theme/update_entrance.dart';
import 'package:app_upgrade_checker/src/presentation/theme/update_feature.dart';
import 'package:app_upgrade_checker/src/presentation/theme/update_pulse.dart';
import 'package:app_upgrade_checker/src/presentation/theme/update_section.dart';
import 'package:app_upgrade_checker/src/presentation/theme/update_title.dart';
import 'package:app_upgrade_checker/src/presentation/theme/update_visual.dart';

/// The **SuperHero** design's identity: a cartoon astronaut hero flying over a
/// red starfield, in deep reds and ambers that pick up the character's suit.
///
/// It is a sibling of [CosmicDesign] and [RocketUpDesign], not a variation of
/// either: it names every value it needs, so editing one design can never change
/// how another looks.
///
/// Deliberately different from the other two in more than color:
/// - **order** — the headline comes *before* the badge, so the badge reads as a
///   confirmation under the promise rather than a label above it, and the
///   version pill is part of the layout;
/// - **copy** — a hero/rescue voice ("Here comes / a better you!") rather than
///   Cosmic's "Ready for something better!" or RocketUp's launch framing;
/// - **cards** — filled tinted cards with a soft border, where Cosmic and
///   RocketUp both use transparent cards with a bright outline.
///
/// You normally reach these through `AppUpgradeTheme.superHero()`, but they are
/// public so you can borrow one piece while replacing another:
///
/// ```dart
/// AppUpgradeTheme.cosmic(visual: SuperHeroDesign.visual);
/// ```
final class SuperHeroDesign {
  const SuperHeroDesign._();

  // ── Palette ──

  /// The image's own bottom-edge color, sampled from `background_red.png`.
  ///
  /// The screen fills its container with this and paints the image on top, so
  /// wherever the image does not reach — a taller screen, a different aspect
  /// ratio, or while it is still decoding — the seam is invisible. Same
  /// principle as [CosmicDesign.background].
  static const Color background = Color(0xFF260D0E);

  /// Near-black plum, matching the top of the starfield.
  static const Color deepRed = Color(0xFF230707);

  /// The brightest red in the image's nebula, used for glows.
  static const Color red = Color(0xFF671A16);

  /// The image's cloud mass, sampled from its brightest band. This is the
  /// warmest large area on screen, so the button borrows it.
  static const Color emberOrange = Color(0xFFF15A32);

  /// The deeper cloud tone underneath [emberOrange].
  static const Color ember = Color(0xFFC83F24);

  /// The pale gold of the image's star glints and comet trails — the only truly
  /// light color in the picture, which is what makes it read as a light source.
  static const Color starGold = Color(0xFFFFE7B6);

  /// The amber used for every border — between [starGold] and [emberOrange], so
  /// borders sit visually between the glints and the clouds.
  static const Color border = Color(0xFFF0A03C);

  /// The light gold of the highlighted word, matching the star glints.
  static const Color highlight = starGold;

  /// Translucent white that fills the feature cards — the structural difference
  /// from the other designs' transparent cards.
  static const Color cardFill = Color(0x14FFFFFF);

  /// Softer border for those filled cards.
  static const Color cardBorder = Color(0x4DF0A03C);

  /// Fills the icon circles: amber into ember.
  ///
  /// A step below the button in brightness on purpose. The three tiers read as
  /// a hierarchy — the button is lightest (the action), the circles sit in the
  /// middle (supporting detail), and the cards stay dark (containers) — so the
  /// eye lands on the button first rather than being pulled six ways at once.
  static const List<Color> iconGradient = [border, emberOrange];

  /// The glyph inside those circles must be dark to stay readable.
  static const Color iconGlyph = Color(0xFF4A1207);

  /// Fills the primary button: gold into ember orange.
  ///
  /// It runs from the image's lightest tone to its cloud tone, which puts the
  /// button at the top of the value scale — brighter than the clouds behind it.
  /// A button made only of cloud colors sinks into the background, however
  /// saturated it is; leading with [starGold] is what lifts it clear.
  static const List<Color> buttonGradient = [starGold, emberOrange];

  /// Dark ember for the button's label and icon, legible on that light fill.
  static const Color buttonLabel = Color(0xFF4A1207);

  // ── Layout ──

  /// The same sequence as Cosmic and RocketUp — artwork, badge, headline, then
  /// the rest. The designs differ by palette, asset and copy, not by order.
  static const List<UpdateSection> order = ThemeDefaults.order;

  // ── Blocks ──

  /// A red starfield image over [background], which is the image's own bottom
  /// color — so the fill and the artwork meet without a visible seam.
  static const UpdateBackground backgroundStyle = AssetBackground(
    FilesPath.backgroundRed,
    package: FilesPath.packageName,
    color: background,
  );

  static const UpdateVisual visual = LottieVisual(
    FilesPath.astronautSuperHero,
    package: FilesPath.packageName,
    heightFactor: 0.3,
  );

  static UpdateBadgeStyle badgeFor(ThemeLang l) => UpdateBadgeStyle(
        text: ThemeStrings.of(l).badge,
        borderColor: border,
      );

  /// Note the voice: a rescue arriving, not a journey starting.
  static UpdateTitle titleFor(ThemeLang l) => UpdateTitle(
        firstLine: ThemeStrings.of(l).titleFirst,
        secondLine: ThemeStrings.of(l).titleSecond,
        highlight: ThemeStrings.of(l).titleHighlight,
        sparkle: '✦︎',
        highlightColor: highlight,
        shadowColor: border,
        highlightShadowColor: emberOrange,
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

  /// A plain slide up from the bottom edge — no parallax, no stagger, so the
  /// artwork and the copy arrive together.
  static const UpdateEntrance entrance = UpdateEntrance.slideUp();

  /// An ember glow, matching the button's own gradient.
  static const UpdatePulse pulse = UpdatePulse(color: emberOrange);
}
