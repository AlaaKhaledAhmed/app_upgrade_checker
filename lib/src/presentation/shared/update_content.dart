import 'package:flutter/material.dart';

import 'package:app_upgrade_checker/src/presentation/app_upgrade_theme.dart';
import 'package:app_upgrade_checker/src/presentation/theme/update_section.dart';
import 'package:app_upgrade_checker/src/presentation/shared/pulse_glow.dart';
import 'package:app_upgrade_checker/src/presentation/shared/update_blocks.dart';

/// Turns a theme into the list of blocks to render.
///
/// This is the one place that knows what [AppUpgradeTheme.order] means and which
/// `show*` flag switches which block off — so the full screen, the dialog and
/// the sheet all show the same thing from the same theme, and a block added here
/// appears in all three without touching any of them.
///
/// Internal: not exported from the package barrel.
final class UpdateContent {
  /// Whether the update is mandatory — hides the "Later" action.
  final bool isMandatory;

  /// Version label for the version pill.
  final String? versionName;

  /// Release notes, used when the theme's `description.text` is unset.
  final String? releaseNotes;

  /// Called when the user taps the update button.
  final VoidCallback onUpdate;

  /// Called when the user taps "Later". `null` hides the action.
  final VoidCallback? onSkip;

  /// The look of every block.
  final AppUpgradeTheme theme;

  /// Caps the body paragraph when the theme itself sets no `maxLines`.
  ///
  /// A full screen lets release notes run as long as they like — it scrolls. A
  /// card cannot: an unbounded paragraph is the one block that can push it to
  /// its height cap on its own, so the dialog supplies a limit. A theme that
  /// names `maxLines` always wins.
  final int? descriptionMaxLines;

  const UpdateContent({
    required this.isMandatory,
    required this.onUpdate,
    required this.theme,
    this.onSkip,
    this.versionName,
    this.releaseNotes,
    this.descriptionMaxLines,
  });

  /// Builds the blocks named in [AppUpgradeTheme.order], skipping the ones
  /// switched off, and inserting [AppUpgradeTheme.sectionSpacing] between the
  /// ones that survive.
  ///
  /// [only] restricts the walk to a subset of the order — the dialog uses it to
  /// pull [UpdateSection.visual] out into its header and leave the rest for the
  /// card. [skip] is its complement. Passing neither renders the whole order,
  /// which is what the full screen does.
  ///
  /// [spacing] overrides [AppUpgradeTheme.sectionSpacing]. The theme's value is
  /// tuned for a full screen; a card is tighter, so the dialog passes its own —
  /// unless the caller set `sectionSpacing` themselves, which always wins.
  List<Widget> sections(
    BuildContext context, {
    Set<UpdateSection>? only,
    Set<UpdateSection>? skip,
    double? spacing,
  }) {
    final gap = spacing ?? theme.sectionSpacing;
    final widgets = <Widget>[];

    for (final section in theme.order) {
      if (only != null && !only.contains(section)) continue;
      if (skip != null && skip.contains(section)) continue;

      final widget = build(context, section);
      if (widget == null) continue;

      if (widgets.isNotEmpty) {
        widgets.add(SizedBox(height: gap));
      }
      widgets.add(widget);
    }
    return widgets;
  }

  /// Returns the widget for [section], or `null` when it should not appear —
  /// either switched off by a `show*` flag, or with nothing to show.
  Widget? build(BuildContext context, UpdateSection section) {
    final t = theme;

    switch (section) {
      case UpdateSection.visual:
        final visual = t.visual;
        if (!t.showVisual || visual == null) return null;
        return UpdateBlocks.visual(context, visual);

      case UpdateSection.badge:
        if (!t.showBadge || t.badge.label.trim().isEmpty) return null;
        return UpdateBlocks.badge(context, t.badge, fontFamily: t.fontFamily);

      case UpdateSection.title:
        if (!t.showTitle || t.title.isEmpty) return null;
        return UpdateBlocks.title(t.title, fontFamily: t.fontFamily);

      case UpdateSection.version:
        final name = versionName;
        if (!t.showVersion || name == null || name.trim().isEmpty) return null;
        return UpdateBlocks.version(name, t.version, fontFamily: t.fontFamily);

      case UpdateSection.description:
        if (!t.showDescription) return null;
        // Theme text first, then the release notes, then the design's fallback.
        final text = _firstNonBlank(
          t.description.text,
          releaseNotes,
          t.fallbackDescription,
        );
        if (text == null) return null;
        final style =
            t.description.maxLines == null && descriptionMaxLines != null
                ? t.description.copyWith(
                    maxLines: descriptionMaxLines,
                    overflow: TextOverflow.ellipsis,
                  )
                : t.description;
        return UpdateBlocks.description(text, style, fontFamily: t.fontFamily);

      case UpdateSection.features:
        if (!t.showFeatures || t.features.isEmpty) return null;
        return UpdateBlocks.features(
          t.features,
          spacing: t.featureSpacing,
          fontFamily: t.fontFamily,
        );

      case UpdateSection.updateButton:
        if (!t.showUpdateButton) return null;
        // Only used when the design styles neither gradient nor color.
        final fallback = Theme.of(context).colorScheme.primary;
        final button = UpdateBlocks.updateButton(
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
        return UpdateBlocks.laterButton(
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
