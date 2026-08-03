import 'package:flutter/material.dart';

import 'package:app_upgrade/src/core/extensions/context_extensions.dart';
import 'package:app_upgrade/src/presentation/app_upgrade_theme.dart';
import 'package:app_upgrade/src/presentation/theme/update_section.dart';
import 'package:app_upgrade/src/presentation/widgets/entrance_animator.dart';
import 'package:app_upgrade/src/presentation/widgets/pulse_glow.dart';
import 'package:app_upgrade/src/presentation/widgets/update_sections.dart';

/// The built-in update screen. Use it directly or let
/// `AppUpgrade.showUpdateDialog` present it for you.
///
/// The screen owns no styling of its own: it renders the blocks listed in
/// [AppUpgradeTheme.order], in that order, using the colors, texts and assets
/// the theme carries. So a new design is a new [AppUpgradeTheme] — never a
/// change here, and never a subclass (the class is `final` on purpose).
///
/// ```dart
/// AppUpgradeScreen(
///   isMandatory: false,
///   onUpdate: () => AppUpgrade.openStore(url),
///   onSkip: () => Navigator.of(context).maybePop(),
///   theme: AppUpgradeTheme.cosmic().copyWith(showFeatures: false),
/// );
/// ```
final class AppUpgradeScreen extends StatelessWidget {
  /// Whether the update is mandatory. Normally comes from the library's
  /// decision (`UpdateAvailable.isForceUpdate`). When `true`, the "Later"
  /// action is hidden and back-dismissal is blocked.
  final bool isMandatory;

  /// Version label shown in the version pill (e.g. `"3.5.0"`). The pill also
  /// needs [AppUpgradeTheme.showVersion] to be `true`.
  final String? versionName;

  /// Called when the user taps the update button — wire this to open the store.
  final VoidCallback onUpdate;

  /// Called when the user taps "Later". Ignored when [isMandatory] is `true`;
  /// pass `null` to hide the action entirely.
  final VoidCallback? onSkip;

  /// The complete look of the screen. Defaults to
  /// [AppUpgradeTheme.cosmic].
  final AppUpgradeTheme? theme;

  /// Release notes from the store or your backend, used when the theme's
  /// `description.text` is not set.
  final String? releaseNotes;

  const AppUpgradeScreen({
    super.key,
    required this.isMandatory,
    required this.onUpdate,
    this.onSkip,
    this.versionName,
    this.theme,
    this.releaseNotes,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme ?? AppUpgradeTheme.cosmic();

    final column = Column(
      crossAxisAlignment: t.alignment,
      mainAxisSize: MainAxisSize.min,
      children: _sections(context, t),
    );

    // Split into two layers so the entrance can move them at different rates —
    // that difference is what makes the artwork look like it is pulling the page.
    final backdrop = DecoratedBox(
      decoration: UpdateSections.background(t.background),
      child: const SizedBox.expand(),
    );

    final content = SafeArea(
      bottom: false,
      child: Padding(
        padding: t.contentPadding,
        child: t.scrollable ? SingleChildScrollView(child: column) : column,
      ),
    );

    final scaffold = Scaffold(
      backgroundColor: Colors.transparent,
      body: EntranceAnimator(
        entrance: t.entrance,
        backdrop: backdrop,
        content: content,
      ),
    );

    return PopScope(
      // A mandatory update cannot be dismissed with the system back gesture.
      canPop: !isMandatory,
      child: t.textDirection == null
          ? scaffold
          // Lets a design read right-to-left even in an app with no RTL locale.
          : Directionality(textDirection: t.textDirection!, child: scaffold),
    );
  }

  /// Builds the blocks named in [AppUpgradeTheme.order], skipping the ones
  /// switched off, and inserting [AppUpgradeTheme.sectionSpacing] between the
  /// ones that survive.
  List<Widget> _sections(BuildContext context, AppUpgradeTheme t) {
    final widgets = <Widget>[];

    for (final section in t.order) {
      final widget = _section(context, t, section);
      if (widget == null) continue;

      if (widgets.isNotEmpty) {
        widgets.add(SizedBox(height: t.sectionSpacing));
      }
      widgets.add(widget);
    }

    // Keeps the last block clear of the home indicator / nav bar.
    if (widgets.isNotEmpty) {
      widgets.add(SizedBox(height: context.bottom + t.sectionSpacing));
    }
    return widgets;
  }

  /// Returns the widget for [section], or `null` when it should not appear —
  /// either switched off by a `show*` flag, or with nothing to show.
  Widget? _section(
    BuildContext context,
    AppUpgradeTheme t,
    UpdateSection section,
  ) {
    switch (section) {
      case UpdateSection.visual:
        final visual = t.visual;
        if (!t.showVisual || visual == null) return null;
        return UpdateSections.visual(context, visual);

      case UpdateSection.badge:
        if (!t.showBadge || t.badge.label.trim().isEmpty) return null;
        return UpdateSections.badge(context, t.badge, fontFamily: t.fontFamily);

      case UpdateSection.title:
        if (!t.showTitle || t.title.isEmpty) return null;
        return UpdateSections.title(t.title, fontFamily: t.fontFamily);

      case UpdateSection.version:
        final name = versionName;
        if (!t.showVersion || name == null || name.trim().isEmpty) return null;
        return UpdateSections.version(name, t.version,
            fontFamily: t.fontFamily);

      case UpdateSection.description:
        if (!t.showDescription) return null;
        // Theme text first, then the release notes, then the design's fallback.
        final text = _firstNonBlank(
          t.description.text,
          releaseNotes,
          t.fallbackDescription,
        );
        if (text == null) return null;
        return UpdateSections.description(text, t.description,
            fontFamily: t.fontFamily);

      case UpdateSection.features:
        if (!t.showFeatures || t.features.isEmpty) return null;
        return UpdateSections.features(
          t.features,
          spacing: t.featureSpacing,
          fontFamily: t.fontFamily,
        );

      case UpdateSection.updateButton:
        if (!t.showUpdateButton) return null;
        // Only used when the design styles neither gradient nor color.
        final fallback = Theme.of(context).colorScheme.primary;
        final button = UpdateSections.updateButton(
          t.updateButton,
          onTap: onUpdate,
          fallbackColor: fallback,
          fontFamily: t.fontFamily,
        );

        final pulse = t.pulse;
        if (pulse == null) return button;
        return PulseGlow(
          pulse: pulse,
          // Defaults the glow to the button's own fill, so a design does not
          // have to name the same color twice.
          fallbackColor: t.updateButton.gradient?.last ??
              t.updateButton.backgroundColor ??
              fallback,
          radius: t.updateButton.radius,
          child: button,
        );

      case UpdateSection.laterButton:
        final skip = onSkip;
        // A mandatory update never offers a way out.
        if (isMandatory || !t.showLaterButton || skip == null) return null;
        return UpdateSections.laterButton(
          t.laterButton,
          onTap: skip,
          fontFamily: t.fontFamily,
        );
    }
  }

  static String? _firstNonBlank(String? a, String? b, String? c) {
    for (final value in [a, b, c]) {
      if (value != null && value.trim().isNotEmpty) return value;
    }
    return null;
  }
}
