import 'package:flutter/material.dart';
import 'package:app_upgrade_checker/src/presentation/theme/theme_lang.dart';

import 'package:app_upgrade_checker/src/core/enums/update_view_type.dart';
import 'package:app_upgrade_checker/src/presentation/theme/motion/dialog_entrance.dart';
import 'package:app_upgrade_checker/src/presentation/theme/designs/cosmic_design.dart';
import 'package:app_upgrade_checker/src/presentation/theme/designs/rocket_up_design.dart';
import 'package:app_upgrade_checker/src/presentation/theme/designs/super_hero_design.dart';
import 'package:app_upgrade_checker/src/presentation/theme/theme_defaults.dart';
import 'package:app_upgrade_checker/src/presentation/theme/styles/update_background.dart';
import 'package:app_upgrade_checker/src/presentation/theme/styles/update_badge_style.dart';
import 'package:app_upgrade_checker/src/presentation/theme/styles/update_button_style.dart';
import 'package:app_upgrade_checker/src/presentation/theme/motion/update_entrance.dart';
import 'package:app_upgrade_checker/src/presentation/theme/motion/update_pulse.dart';
import 'package:app_upgrade_checker/src/presentation/theme/styles/update_feature.dart';
import 'package:app_upgrade_checker/src/presentation/theme/update_section.dart';
import 'package:app_upgrade_checker/src/presentation/theme/styles/update_title.dart';
import 'package:app_upgrade_checker/src/presentation/theme/styles/update_visual.dart';

/// The complete look of the built-in update screen: every text, color, asset,
/// gradient and the vertical order of the blocks.
///
/// A theme is never built from scratch — start from a named design and change
/// only what you need:
///
/// ```dart
/// AppUpgrade.checkAndPrompt(
///   context,
///   theme: AppUpgradeTheme.cosmic(),                       // as shipped
/// );
///
/// AppUpgrade.checkAndPrompt(
///   context,
///   theme: AppUpgradeTheme.cosmic().copyWith(
///     title: const UpdateTitle(
///       firstLine: 'نستعد', secondLine: 'لشيء',
///       highlight: 'أفضل!', sparkle: '✦︎',
///     ),
///     showFeatures: false,                                  // hide the row
///     updateButton: const UpdateButtonStyle(text: 'حدّث الآن'),
///   ),
/// );
/// ```
///
/// ## Designs
///
/// Each design is a named constructor that fills these same fields with a
/// different set of defaults. The three shipped designs share one block order
/// and differ by palette, asset and copy; a design is free to declare its own
/// [order] if it wants a different sequence:
///
/// - [AppUpgradeTheme.cosmic] — an astronaut over a starfield. The default
///   when no theme is passed.
/// - [AppUpgradeTheme.rocketUp] — a rocket climbing a pink starfield.
/// - [AppUpgradeTheme.superHero] — a cartoon astronaut hero over a red
///   starfield, with filled feature cards.
///
/// Designs are **siblings, not variations**: each one names every value it
/// needs, so editing one can never change how another looks. They share the
/// building blocks and the neutral layout defaults, nothing else.
///
/// ### Adding a design
///
/// 1. Copy `src/presentation/theme/designs/cosmic_design.dart` and give it your
///    palette, asset, copy and — if it differs — its own `order`.
/// 2. Add a factory here that reads those constants, mirroring
///    [AppUpgradeTheme.cosmic] line for line.
///
/// No change to the screen, and no `switch` anywhere: the screen only ever
/// walks [order] and reads these fields.
///
/// ## Hiding blocks
///
/// Two ways, both valid:
/// - the `show*` flags (`showBadge`, `showFeatures`, …) — keeps [order] intact;
/// - dropping the entry from [order] — also changes the sequence.
@immutable
final class AppUpgradeTheme {
  /// The vertical sequence of blocks. Blocks absent from this list are not
  /// rendered at all.
  final List<UpdateSection> order;

  // ── Content & styling of each block ──

  /// What fills the screen behind everything.
  final UpdateBackground background;

  /// The artwork at the top.
  final UpdateVisual? visual;

  /// The pill above the headline.
  final UpdateBadgeStyle badge;

  /// The two-line headline with its highlighted last word.
  final UpdateTitle title;

  /// The version pill. The number itself comes from the update result.
  final UpdateVersionStyle version;

  /// The body paragraph. When its `text` is `null`, the update's release notes
  /// are used, then [fallbackDescription].
  final UpdateTextStyle description;

  /// Used when neither `description.text` nor the release notes are available.
  final String fallbackDescription;

  /// The feature cards. An empty list hides the row.
  final List<UpdateFeature> features;

  /// The primary call-to-action.
  final UpdateButtonStyle updateButton;

  /// The dismiss action. Never shown for a mandatory update.
  final LaterButtonStyle laterButton;

  // ── Per-block visibility ──

  /// Whether to render the artwork.
  final bool showVisual;

  /// Whether to render the badge pill. The shipped designs leave this off —
  /// pass `showBadge: true` to bring it in.
  final bool showBadge;

  /// Whether to render the headline.
  final bool showTitle;

  /// Whether to render the version pill.
  final bool showVersion;

  /// Whether to render the body paragraph.
  final bool showDescription;

  /// Whether to render the feature row. The shipped designs leave this off —
  /// pass `showFeatures: true` to bring in the design's own cards.
  final bool showFeatures;

  /// Whether to render the primary button. Turning this off leaves the user no
  /// way to update, so it defaults to `true` and is rarely worth changing.
  final bool showUpdateButton;

  /// Whether to render the dismiss action for an *optional* update. A mandatory
  /// update hides it regardless.
  final bool showLaterButton;

  // ── Layout ──

  /// Horizontal padding around the whole content column.
  final EdgeInsetsGeometry contentPadding;

  /// Vertical gap inserted between consecutive blocks.
  final double sectionSpacing;

  /// Gap between the feature cards.
  final double featureSpacing;

  /// Whether the content column scrolls when it is taller than the screen.
  /// Keep this on — it is what prevents an overflow on short screens or with
  /// large system font sizes.
  final bool scrollable;

  /// Horizontal alignment of the blocks in the column.
  final CrossAxisAlignment alignment;

  /// Font family for every text on the screen. `null` uses the package font.
  final String? fontFamily;

  /// Reading direction of the whole screen. `null` follows the host app's
  /// [Directionality]; set [TextDirection.rtl] to force an Arabic layout even
  /// in an app that has no RTL locale configured.
  final TextDirection? textDirection;

  // ── Presentation ──

  /// Whether the built-in UI is a full screen, a centred dialog or a bottom
  /// sheet. Defaults to [UpdateViewType.screen].
  ///
  /// All three render the same blocks from this same theme, in [order],
  /// honouring every `show*` flag — only the container differs. The dialog and
  /// the sheet additionally lift the artwork out of the column into a header
  /// strip, so it stays above the text wherever [order] places it.
  final UpdateViewType viewType;

  // ── Motion ──

  /// How the **full screen** arrives. Each design picks its own; every variant
  /// stays under 600ms and degrades to a fade under reduce-motion.
  ///
  /// Read only when [viewType] is [UpdateViewType.screen]. Under
  /// [UpdateViewType.dialog] and [UpdateViewType.sheet] this field is ignored
  /// and [dialogEntrance] is used instead — so a theme may carry both and switch
  /// between them with `copyWith(viewType: …)`.
  final UpdateEntrance entrance;

  /// How the **dialog** and the **sheet** arrive. Defaults to
  /// [DialogEntrance.popIn] — a zoom up to the card's natural size.
  ///
  /// Read only when [viewType] is [UpdateViewType.dialog] or
  /// [UpdateViewType.sheet]. Under [UpdateViewType.screen] this field is
  /// ignored and [entrance] is used instead.
  ///
  /// It is a separate type from [entrance] on purpose: the screen's variants
  /// move the backdrop and the content apart by a screen height, which a card
  /// cannot do. Keeping the types apart means a screen-only entrance cannot be
  /// handed to a dialog — the compiler rejects it.
  final DialogEntrance dialogEntrance;

  /// The breathing glow behind the primary button. `null` switches it off.
  final UpdatePulse? pulse;

  const AppUpgradeTheme({
    this.order = const [
      UpdateSection.visual,
      UpdateSection.badge,
      UpdateSection.title,
      UpdateSection.description,
      UpdateSection.features,
      UpdateSection.updateButton,
      UpdateSection.laterButton,
    ],
    this.background = const UpdateBackground.solid(Color(0xff01114f)),
    this.visual,
    this.badge = const UpdateBadgeStyle(),
    this.title = const UpdateTitle(),
    this.version = const UpdateVersionStyle(),
    this.description = const UpdateTextStyle(),
    this.fallbackDescription = 'A new version is ready to install.',
    this.features = const [],
    this.updateButton = const UpdateButtonStyle(),
    this.laterButton = const LaterButtonStyle(),
    this.showVisual = true,
    this.showBadge = true,
    this.showTitle = true,
    this.showVersion = true,
    this.showDescription = true,
    this.showFeatures = true,
    this.showUpdateButton = true,
    this.showLaterButton = true,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 15),
    this.sectionSpacing = 20,
    this.featureSpacing = 10,
    this.scrollable = true,
    this.alignment = CrossAxisAlignment.center,
    this.fontFamily,
    this.textDirection,
    this.viewType = UpdateViewType.screen,
    this.entrance = const UpdateEntrance.fade(),
    this.dialogEntrance = const DialogEntrance.popIn(),
    this.pulse,
  });

  /// **Cosmic** — the space design: an astronaut riding a rocket over a
  /// starfield, with a glowing two-line headline.
  ///
  /// This is the default when no theme is given. The badge pill and the feature
  /// row are off by default; switch either on to bring in the design's own copy
  /// and cards. Every argument overrides one of its defaults, so the common
  /// tweaks stay short:
  ///
  /// ```dart
  /// AppUpgradeTheme.cosmic(
  ///   title: const UpdateTitle(
  ///     firstLine: 'نستعد', secondLine: 'لشيء',
  ///     highlight: 'أفضل!', sparkle: '✦︎',
  ///   ),
  ///   showFeatures: true,   // the three gradient cards
  ///   showBadge: true,      // "NEW UPDATE AVAILABLE"
  /// );
  /// ```
  ///
  /// Pass [viewType] to show the same design as a dialog or a bottom sheet
  /// instead of a full screen — same blocks, same order, same `show*` flags:
  ///
  /// ```dart
  /// AppUpgradeTheme.cosmic(viewType: UpdateViewType.dialog);
  /// ```
  factory AppUpgradeTheme.cosmic({
    ThemeLang? lang,
    List<UpdateSection>? order,
    UpdateBackground? background,
    UpdateVisual? visual,
    UpdateBadgeStyle? badge,
    UpdateTitle? title,
    UpdateVersionStyle? version,
    UpdateTextStyle? description,
    String? fallbackDescription,
    List<UpdateFeature>? features,
    UpdateButtonStyle? updateButton,
    LaterButtonStyle? laterButton,
    bool showVisual = true,
    bool showBadge = false,
    bool showTitle = true,
    bool showVersion = false,
    bool showDescription = true,
    bool showFeatures = false,
    bool showUpdateButton = true,
    bool showLaterButton = true,
    EdgeInsetsGeometry? contentPadding,
    double? sectionSpacing,
    double? featureSpacing,
    bool scrollable = true,
    CrossAxisAlignment? alignment,
    String? fontFamily,
    TextDirection? textDirection,
    UpdateViewType viewType = UpdateViewType.screen,
    UpdateEntrance? entrance,
    DialogEntrance? dialogEntrance,
    UpdatePulse? pulse,
  }) {
    final l = lang ?? ThemeLang.device;
    return AppUpgradeTheme(
      order: order ?? CosmicDesign.order,
      background: background ?? CosmicDesign.backgroundStyle,
      visual: visual ?? CosmicDesign.visual,
      badge: badge?.merge(CosmicDesign.badgeFor(l)) ?? CosmicDesign.badgeFor(l),
      title: title?.merge(CosmicDesign.titleFor(l)) ?? CosmicDesign.titleFor(l),
      version: version?.merge(CosmicDesign.version) ?? CosmicDesign.version,
      description: description?.merge(CosmicDesign.description) ??
          CosmicDesign.description,
      fallbackDescription:
          fallbackDescription ?? CosmicDesign.fallbackDescriptionFor(l),
      features: _mergeFeatures(features, CosmicDesign.featuresFor(l)),
      updateButton: updateButton?.merge(CosmicDesign.updateButtonFor(l)) ??
          CosmicDesign.updateButtonFor(l),
      laterButton: laterButton?.merge(CosmicDesign.laterButtonFor(l)) ??
          CosmicDesign.laterButtonFor(l),
      showVisual: showVisual,
      showBadge: showBadge,
      showTitle: showTitle,
      showVersion: showVersion,
      showDescription: showDescription,
      showFeatures: showFeatures,
      showUpdateButton: showUpdateButton,
      showLaterButton: showLaterButton,
      contentPadding: contentPadding ?? ThemeDefaults.contentPadding,
      sectionSpacing: sectionSpacing ?? ThemeDefaults.sectionSpacing,
      featureSpacing: featureSpacing ?? ThemeDefaults.featureSpacing,
      scrollable: scrollable,
      alignment: alignment ?? ThemeDefaults.alignment,
      fontFamily: fontFamily,
      textDirection: textDirection ?? (l.isRtl ? TextDirection.rtl : null),
      viewType: viewType,
      entrance: entrance ?? CosmicDesign.entrance,
      dialogEntrance: dialogEntrance ?? CosmicDesign.dialogEntrance,
      pulse: pulse ?? CosmicDesign.pulse,
    );
  }

  /// **RocketUp** — a rocket climbing over a pink starfield, in magentas
  /// sampled from that image.
  ///
  /// It shares Cosmic's building blocks but none of its values: the two are
  /// siblings, so changing one never changes the other. As with every design,
  /// the badge and the feature row are off until you ask for them.
  ///
  /// ```dart
  /// AppUpgradeTheme.rocketUp(
  ///   title: const UpdateTitle(
  ///     firstLine: 'انطلق', secondLine: 'إلى',
  ///     highlight: 'الأفضل!', sparkle: '✦︎',
  ///   ),
  ///   textDirection: TextDirection.rtl,
  /// );
  /// ```
  ///
  /// Pass [viewType] to show the same design as a dialog or a bottom sheet
  /// instead of a full screen — same blocks, same order, same `show*` flags:
  ///
  /// ```dart
  /// AppUpgradeTheme.rocketUp(viewType: UpdateViewType.dialog);
  /// ```
  factory AppUpgradeTheme.rocketUp({
    ThemeLang? lang,
    List<UpdateSection>? order,
    UpdateBackground? background,
    UpdateVisual? visual,
    UpdateBadgeStyle? badge,
    UpdateTitle? title,
    UpdateVersionStyle? version,
    UpdateTextStyle? description,
    String? fallbackDescription,
    List<UpdateFeature>? features,
    UpdateButtonStyle? updateButton,
    LaterButtonStyle? laterButton,
    bool showVisual = true,
    bool showBadge = false,
    bool showTitle = true,
    bool showVersion = false,
    bool showDescription = true,
    bool showFeatures = false,
    bool showUpdateButton = true,
    bool showLaterButton = true,
    EdgeInsetsGeometry? contentPadding,
    double? sectionSpacing,
    double? featureSpacing,
    bool scrollable = true,
    CrossAxisAlignment? alignment,
    String? fontFamily,
    TextDirection? textDirection,
    UpdateViewType viewType = UpdateViewType.screen,
    UpdateEntrance? entrance,
    DialogEntrance? dialogEntrance,
    UpdatePulse? pulse,
  }) {
    final l = lang ?? ThemeLang.device;
    return AppUpgradeTheme(
      order: order ?? RocketUpDesign.order,
      background: background ?? RocketUpDesign.backgroundStyle,
      visual: visual ?? RocketUpDesign.visual,
      badge: badge?.merge(RocketUpDesign.badgeFor(l)) ??
          RocketUpDesign.badgeFor(l),
      title: title?.merge(RocketUpDesign.titleFor(l)) ??
          RocketUpDesign.titleFor(l),
      version: version?.merge(RocketUpDesign.version) ?? RocketUpDesign.version,
      description: description?.merge(RocketUpDesign.description) ??
          RocketUpDesign.description,
      fallbackDescription:
          fallbackDescription ?? RocketUpDesign.fallbackDescriptionFor(l),
      features: _mergeFeatures(features, RocketUpDesign.featuresFor(l)),
      updateButton: updateButton?.merge(RocketUpDesign.updateButtonFor(l)) ??
          RocketUpDesign.updateButtonFor(l),
      laterButton: laterButton?.merge(RocketUpDesign.laterButtonFor(l)) ??
          RocketUpDesign.laterButtonFor(l),
      showVisual: showVisual,
      showBadge: showBadge,
      showTitle: showTitle,
      showVersion: showVersion,
      showDescription: showDescription,
      showFeatures: showFeatures,
      showUpdateButton: showUpdateButton,
      showLaterButton: showLaterButton,
      contentPadding: contentPadding ?? ThemeDefaults.contentPadding,
      sectionSpacing: sectionSpacing ?? ThemeDefaults.sectionSpacing,
      featureSpacing: featureSpacing ?? ThemeDefaults.featureSpacing,
      scrollable: scrollable,
      alignment: alignment ?? ThemeDefaults.alignment,
      fontFamily: fontFamily,
      textDirection: textDirection ?? (l.isRtl ? TextDirection.rtl : null),
      viewType: viewType,
      entrance: entrance ?? RocketUpDesign.entrance,
      dialogEntrance: dialogEntrance ?? RocketUpDesign.dialogEntrance,
      pulse: pulse ?? RocketUpDesign.pulse,
    );
  }

  /// **SuperHero** — a cartoon astronaut hero flying over a red starfield, in
  /// deep reds and ambers.
  ///
  /// Shares the other designs' block order; differs in its palette, its filled
  /// (rather than outlined) feature cards, and its hero/rescue copy. The badge
  /// and the feature row are off until you ask for them.
  ///
  /// ```dart
  /// AppUpgradeTheme.superHero(
  ///   title: const UpdateTitle(
  ///     firstLine: 'وصل', secondLine: 'إصدارك',
  ///     highlight: 'الأقوى!', sparkle: '✦︎',
  ///   ),
  ///   textDirection: TextDirection.rtl,
  /// );
  /// ```
  ///
  /// Pass [viewType] to show the same design as a dialog or a bottom sheet
  /// instead of a full screen — same blocks, same order, same `show*` flags:
  ///
  /// ```dart
  /// AppUpgradeTheme.superHero(viewType: UpdateViewType.dialog);
  /// ```
  factory AppUpgradeTheme.superHero({
    ThemeLang? lang,
    List<UpdateSection>? order,
    UpdateBackground? background,
    UpdateVisual? visual,
    UpdateBadgeStyle? badge,
    UpdateTitle? title,
    UpdateVersionStyle? version,
    UpdateTextStyle? description,
    String? fallbackDescription,
    List<UpdateFeature>? features,
    UpdateButtonStyle? updateButton,
    LaterButtonStyle? laterButton,
    bool showVisual = true,
    bool showBadge = false,
    bool showTitle = true,
    bool showVersion = false,
    bool showDescription = true,
    bool showFeatures = false,
    bool showUpdateButton = true,
    bool showLaterButton = true,
    EdgeInsetsGeometry? contentPadding,
    double? sectionSpacing,
    double? featureSpacing,
    bool scrollable = true,
    CrossAxisAlignment? alignment,
    String? fontFamily,
    TextDirection? textDirection,
    UpdateViewType viewType = UpdateViewType.screen,
    UpdateEntrance? entrance,
    DialogEntrance? dialogEntrance,
    UpdatePulse? pulse,
  }) {
    final l = lang ?? ThemeLang.device;
    return AppUpgradeTheme(
      order: order ?? SuperHeroDesign.order,
      background: background ?? SuperHeroDesign.backgroundStyle,
      visual: visual ?? SuperHeroDesign.visual,
      badge: badge?.merge(SuperHeroDesign.badgeFor(l)) ??
          SuperHeroDesign.badgeFor(l),
      title: title?.merge(SuperHeroDesign.titleFor(l)) ??
          SuperHeroDesign.titleFor(l),
      version:
          version?.merge(SuperHeroDesign.version) ?? SuperHeroDesign.version,
      description: description?.merge(SuperHeroDesign.description) ??
          SuperHeroDesign.description,
      fallbackDescription:
          fallbackDescription ?? SuperHeroDesign.fallbackDescriptionFor(l),
      features: _mergeFeatures(features, SuperHeroDesign.featuresFor(l)),
      updateButton: updateButton?.merge(SuperHeroDesign.updateButtonFor(l)) ??
          SuperHeroDesign.updateButtonFor(l),
      laterButton: laterButton?.merge(SuperHeroDesign.laterButtonFor(l)) ??
          SuperHeroDesign.laterButtonFor(l),
      showVisual: showVisual,
      showBadge: showBadge,
      showTitle: showTitle,
      showVersion: showVersion,
      showDescription: showDescription,
      showFeatures: showFeatures,
      showUpdateButton: showUpdateButton,
      showLaterButton: showLaterButton,
      contentPadding: contentPadding ?? ThemeDefaults.contentPadding,
      sectionSpacing: sectionSpacing ?? ThemeDefaults.sectionSpacing,
      featureSpacing: featureSpacing ?? ThemeDefaults.featureSpacing,
      scrollable: scrollable,
      alignment: alignment ?? ThemeDefaults.alignment,
      fontFamily: fontFamily,
      textDirection: textDirection ?? (l.isRtl ? TextDirection.rtl : null),
      viewType: viewType,
      entrance: entrance ?? SuperHeroDesign.entrance,
      dialogEntrance: dialogEntrance ?? SuperHeroDesign.dialogEntrance,
      pulse: pulse ?? SuperHeroDesign.pulse,
    );
  }

  /// Merges a caller's feature list against the design's, card by card.
  ///
  /// A design's cards carry its border and icon colours; a caller who only
  /// names an icon and two labels still wants those. Cards are paired by
  /// position, and any extra card the caller adds is kept as-is.
  static List<UpdateFeature> _mergeFeatures(
    List<UpdateFeature>? mine,
    List<UpdateFeature> base,
  ) {
    if (mine == null) return base;
    return [
      for (var i = 0; i < mine.length; i++)
        i < base.length ? mine[i].merge(base[i]) : mine[i],
    ];
  }

  /// Returns a copy with the given fields replaced. This is the normal way to
  /// tweak a design:
  ///
  /// ```dart
  /// AppUpgradeTheme.cosmic().copyWith(showFeatures: false);
  /// ```
  ///
  /// It is also how one theme is shown two ways — the entrance for each is
  /// already on the theme, so only the container changes:
  ///
  /// ```dart
  /// final t = AppUpgradeTheme.cosmic();
  /// t;                                                  // a full screen
  /// t.copyWith(viewType: UpdateViewType.dialog);         // the same, as a dialog
  /// ```
  ///
  /// Note: [visual] cannot be cleared through `copyWith` — use
  /// `showVisual: false` to hide the artwork.
  AppUpgradeTheme copyWith({
    List<UpdateSection>? order,
    UpdateBackground? background,
    UpdateVisual? visual,
    UpdateBadgeStyle? badge,
    UpdateTitle? title,
    UpdateVersionStyle? version,
    UpdateTextStyle? description,
    String? fallbackDescription,
    List<UpdateFeature>? features,
    UpdateButtonStyle? updateButton,
    LaterButtonStyle? laterButton,
    bool? showVisual,
    bool? showBadge,
    bool? showTitle,
    bool? showVersion,
    bool? showDescription,
    bool? showFeatures,
    bool? showUpdateButton,
    bool? showLaterButton,
    EdgeInsetsGeometry? contentPadding,
    double? sectionSpacing,
    double? featureSpacing,
    bool? scrollable,
    CrossAxisAlignment? alignment,
    String? fontFamily,
    TextDirection? textDirection,
    UpdateViewType? viewType,
    UpdateEntrance? entrance,
    DialogEntrance? dialogEntrance,
    UpdatePulse? pulse,
    // `pulse: null` cannot mean "clear it" — null also means "leave it alone".
    // This flag is the explicit way to switch the glow off.
    bool noPulse = false,
  }) {
    return AppUpgradeTheme(
      order: order ?? this.order,
      background: background ?? this.background,
      visual: visual ?? this.visual,
      badge: badge?.merge(this.badge) ?? this.badge,
      title: title?.merge(this.title) ?? this.title,
      version: version?.merge(this.version) ?? this.version,
      description: description?.merge(this.description) ?? this.description,
      fallbackDescription: fallbackDescription ?? this.fallbackDescription,
      features: _mergeFeatures(features, this.features),
      updateButton: updateButton?.merge(this.updateButton) ?? this.updateButton,
      laterButton: laterButton?.merge(this.laterButton) ?? this.laterButton,
      showVisual: showVisual ?? this.showVisual,
      showBadge: showBadge ?? this.showBadge,
      showTitle: showTitle ?? this.showTitle,
      showVersion: showVersion ?? this.showVersion,
      showDescription: showDescription ?? this.showDescription,
      showFeatures: showFeatures ?? this.showFeatures,
      showUpdateButton: showUpdateButton ?? this.showUpdateButton,
      showLaterButton: showLaterButton ?? this.showLaterButton,
      contentPadding: contentPadding ?? this.contentPadding,
      sectionSpacing: sectionSpacing ?? this.sectionSpacing,
      featureSpacing: featureSpacing ?? this.featureSpacing,
      scrollable: scrollable ?? this.scrollable,
      alignment: alignment ?? this.alignment,
      fontFamily: fontFamily ?? this.fontFamily,
      textDirection: textDirection ?? this.textDirection,
      viewType: viewType ?? this.viewType,
      entrance: entrance ?? this.entrance,
      dialogEntrance: dialogEntrance ?? this.dialogEntrance,
      pulse: noPulse ? null : (pulse ?? this.pulse),
    );
  }
}
